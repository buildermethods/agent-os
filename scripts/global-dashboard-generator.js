#!/usr/bin/env node

/**
 * Global Spec Dashboard Generator
 * 
 * Can be run from any project directory to generate a specs dashboard
 * without needing to copy files to each project
 */

const fs = require('fs');
const path = require('path');

function generateGlobalDashboard() {
  // Look for .agent-os/specs in current directory or parent directories
  const specsDir = findSpecsDirectory();
  
  if (!specsDir) {
    console.log('❌ No .agent-os/specs directory found');
    console.log('💡 Make sure you\'re in a project directory with Agent OS specs');
    return;
  }

  const dashboardPath = path.join(specsDir, 'specs-dashboard.md');
  const specs = scanSpecs(specsDir);
  const dashboard = buildDashboard(specs);
  
  try {
    fs.writeFileSync(dashboardPath, dashboard, 'utf8');
    console.log(`✅ Specs dashboard generated at: ${dashboardPath}`);
  } catch (error) {
    console.error('❌ Error generating dashboard:', error.message);
  }
}

function findSpecsDirectory() {
  let currentDir = process.cwd();
  const maxDepth = 5; // Prevent infinite loops
  
  for (let depth = 0; depth < maxDepth; depth++) {
    const specsPath = path.join(currentDir, '.agent-os', 'specs');
    if (fs.existsSync(specsPath)) {
      return specsPath;
    }
    
    const parentDir = path.dirname(currentDir);
    if (parentDir === currentDir) {
      break; // Reached root directory
    }
    currentDir = parentDir;
  }
  
  return null;
}

function scanSpecs(specsDir) {
  const specs = {
    planning: [],
    active: [],
    completed: [],
    archived: []
  };

  const items = fs.readdirSync(specsDir, { withFileTypes: true });
  
  for (const item of items) {
    if (!item.isDirectory()) continue;
    
    const specPath = path.join(specsDir, item.name);
    const status = getSpecStatus(specPath, item.name);
    
    if (status) {
      specs[status].push({
        name: item.name,
        path: specPath,
        status: status,
        lastUpdated: getLastUpdated(specPath),
        progress: getProgress(specPath)
      });
    }
  }

  return specs;
}

function getSpecStatus(specPath, folderName) {
  // Check folder naming convention
  if (folderName.startsWith('planning-')) return 'planning';
  if (folderName.startsWith('active-')) return 'active';
  if (folderName.startsWith('completed-')) return 'completed';
  if (folderName.startsWith('archived-') || folderName.includes('/archived/')) return 'archived';
  
  // Check status.md file
  const statusPath = path.join(specPath, 'status.md');
  if (fs.existsSync(statusPath)) {
    const statusContent = fs.readFileSync(statusPath, 'utf8');
    const statusMatch = statusContent.match(/Current Status[:\s]+(\w+)/i);
    if (statusMatch) {
      return statusMatch[1].toLowerCase();
    }
  }
  
  return 'planning';
}

function getLastUpdated(specPath) {
  const statusPath = path.join(specPath, 'status.md');
  if (fs.existsSync(statusPath)) {
    const statusContent = fs.readFileSync(statusPath, 'utf8');
    const dateMatch = statusContent.match(/Last Updated[:\s]+(\d{4}-\d{2}-\d{2})/i);
    if (dateMatch) {
      return dateMatch[1];
    }
  }
  return null;
}

function getProgress(specPath) {
  const tasksPath = path.join(specPath, 'tasks.md');
  if (!fs.existsSync(tasksPath)) return null;
  
  try {
    const tasksContent = fs.readFileSync(tasksPath, 'utf8');
    const totalTasks = (tasksContent.match(/- \[ \]/g) || []).length;
    const completedTasks = (tasksContent.match(/- \[x\]/g) || []).length;
    
    if (totalTasks === 0) return null;
    
    const percentage = Math.round((completedTasks / (totalTasks + completedTasks)) * 100);
    return percentage;
  } catch (error) {
    return null;
  }
}

function buildDashboard(specs) {
  return `# Specs Dashboard

> Auto-generated dashboard for spec lifecycle management
> Last updated: ${new Date().toISOString().split('T')[0]}

## 📋 Planning (Backlog)
${formatSpecsList(specs.planning, 'planning')}

## 🔄 Active (In Progress)
${formatSpecsList(specs.active, 'active')}

## ✅ Completed (Done)
${formatSpecsList(specs.completed, 'completed')}

## 🗄️ Archived
${formatSpecsList(specs.archived, 'archived')}

## 📊 Summary
- **Planning**: ${specs.planning.length} specs
- **Active**: ${specs.active.length} specs
- **Completed**: ${specs.completed.length} specs
- **Archived**: ${specs.archived.length} specs
- **Total**: ${specs.planning.length + specs.active.length + specs.completed.length + specs.archived.length} specs

---
*Dashboard generated automatically. Update spec status files to refresh this dashboard.*
`;
}

function formatSpecsList(specs, status) {
  if (specs.length === 0) {
    return `*No ${status} specs*`;
  }

  return specs
    .sort((a, b) => {
      if (a.lastUpdated && b.lastUpdated) {
        return new Date(b.lastUpdated) - new Date(a.lastUpdated);
      }
      return 0;
    })
    .map(spec => {
      const checkbox = status === 'completed' || status === 'archived' ? '[x]' : '[ ]';
      const date = spec.lastUpdated ? ` (${spec.lastUpdated})` : '';
      const progress = spec.progress ? ` (${spec.progress}% complete)` : '';
      
      return `- ${checkbox} ${spec.name}${date}${progress}`;
    })
    .join('\n');
}

// CLI usage
if (require.main === module) {
  generateGlobalDashboard();
}

module.exports = { generateGlobalDashboard }; 