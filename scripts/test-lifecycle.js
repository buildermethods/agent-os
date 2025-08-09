#!/usr/bin/env node

/**
 * Test Lifecycle Management System
 * 
 * Simple script to test and set up lifecycle management in any project
 */

const fs = require('fs');
const path = require('path');

function testLifecycleManagement() {
  console.log('🧪 Testing Lifecycle Management System...\n');
  
  // Step 1: Project Analysis
  console.log('📋 Step 1: Project Analysis');
  const projectAnalysis = analyzeProject();
  console.log(projectAnalysis);
  
  // Step 2: Spec Categorization
  console.log('\n📊 Step 2: Spec Categorization');
  const specStatus = categorizeSpecs();
  console.log(specStatus);
  
  // Step 3: Setup Lifecycle Management
  console.log('\n🔧 Step 3: Setting up Lifecycle Management');
  const setupResults = setupLifecycleManagement();
  console.log(setupResults);
  
  // Step 4: Generate Dashboard
  console.log('\n📈 Step 4: Generating Dashboard');
  const dashboardResult = generateDashboard();
  console.log(dashboardResult);
  
  // Step 5: Show Results
  console.log('\n✅ Step 5: Test Results');
  showTestResults();
}

function analyzeProject() {
  const specsDir = '.agent-os/specs';
  const exists = fs.existsSync(specsDir);
  
  let result = `Project Analysis:\n`;
  result += `- Specs Directory: ${exists ? 'EXISTS' : 'MISSING'}\n`;
  
  if (exists) {
    const items = fs.readdirSync(specsDir, { withFileTypes: true });
    const specs = items.filter(item => item.isDirectory()).length;
    result += `- Total Specs: ${specs}\n`;
    
    // Check for dashboard files
    const dashboardExists = fs.existsSync(path.join(specsDir, 'specs-dashboard.md'));
    const guideExists = fs.existsSync(path.join(specsDir, 'spec-lifecycle-guide.md'));
    result += `- Dashboard File: ${dashboardExists ? 'EXISTS' : 'MISSING'}\n`;
    result += `- Guide File: ${guideExists ? 'EXISTS' : 'MISSING'}\n`;
  }
  
  return result;
}

function categorizeSpecs() {
  const specsDir = '.agent-os/specs';
  if (!fs.existsSync(specsDir)) {
    return 'No specs directory found';
  }
  
  const items = fs.readdirSync(specsDir, { withFileTypes: true });
  const specs = items.filter(item => item.isDirectory());
  
  const categories = {
    planning: [],
    active: [],
    completed: [],
    archived: []
  };
  
  specs.forEach(spec => {
    const specPath = path.join(specsDir, spec.name);
    const status = getSpecStatus(specPath, spec.name);
    if (status) {
      categories[status].push(spec.name);
    }
  });
  
  let result = 'Spec Status Categorization:\n';
  Object.entries(categories).forEach(([status, specs]) => {
    result += `- ${status.toUpperCase()}: ${specs.length} specs\n`;
    if (specs.length > 0) {
      specs.forEach(spec => result += `  - ${spec}\n`);
    }
  });
  
  return result;
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

function setupLifecycleManagement() {
  const specsDir = '.agent-os/specs';
  let results = [];
  
  // Create specs directory if it doesn't exist
  if (!fs.existsSync(specsDir)) {
    fs.mkdirSync(specsDir, { recursive: true });
    results.push('✅ Created .agent-os/specs directory');
  }
  
  // Create dashboard file if missing
  const dashboardPath = path.join(specsDir, 'specs-dashboard.md');
  if (!fs.existsSync(dashboardPath)) {
    const dashboardContent = `# Specs Dashboard

> Auto-generated dashboard for spec lifecycle management
> Last updated: ${new Date().toISOString().split('T')[0]}

## 📋 Planning (Backlog)
*No planning specs*

## 🔄 Active (In Progress)
*No active specs*

## ✅ Completed (Done)
*No completed specs*

## 🗄️ Archived
*No archived specs*

## 📊 Summary
- **Planning**: 0 specs
- **Active**: 0 specs
- **Completed**: 0 specs
- **Archived**: 0 specs
- **Total**: 0 specs

---
*Dashboard generated automatically. Update spec status files to refresh this dashboard.*
`;
    fs.writeFileSync(dashboardPath, dashboardContent);
    results.push('✅ Created specs-dashboard.md');
  }
  
  // Create guide file if missing
  const guidePath = path.join(specsDir, 'spec-lifecycle-guide.md');
  if (!fs.existsSync(guidePath)) {
    const guideContent = `# Spec Lifecycle Management Guide

## Quick Reference

### Status Categories
- **Planning**: Specs ready for implementation
- **Active**: Specs currently being implemented
- **Completed**: Specs finished and tested
- **Archived**: Specs cleaned up and archived

### Folder Naming Convention
- \`planning-YYYY-MM-DD-spec-name\` (backlog)
- \`active-YYYY-MM-DD-spec-name\` (in progress)
- \`completed-YYYY-MM-DD-spec-name\` (done)
- \`archived/YYYY-MM-DD-spec-name\` (archived)

### Commands
\`\`\`bash
# Generate dashboard
npm run dashboard

# Move spec to active
mv .agent-os/specs/planning-YYYY-MM-DD-spec-name .agent-os/specs/active-YYYY-MM-DD-spec-name

# Move spec to completed
mv .agent-os/specs/active-YYYY-MM-DD-spec-name .agent-os/specs/completed-YYYY-MM-DD-spec-name

# Archive completed spec
mv .agent-os/specs/completed-YYYY-MM-DD-spec-name .agent-os/specs/archived/YYYY-MM-DD-spec-name
\`\`\`
`;
    fs.writeFileSync(guidePath, guideContent);
    results.push('✅ Created spec-lifecycle-guide.md');
  }
  
  // Create status.md files for existing specs
  const items = fs.readdirSync(specsDir, { withFileTypes: true });
  const specs = items.filter(item => item.isDirectory());
  
  specs.forEach(spec => {
    const specPath = path.join(specsDir, spec.name);
    const statusPath = path.join(specPath, 'status.md');
    
    if (!fs.existsSync(statusPath)) {
      const statusContent = `# Spec Status

**Spec Name**: ${spec.name}
**Created**: ${new Date().toISOString().split('T')[0]}
**Current Status**: planning
**Last Updated**: ${new Date().toISOString().split('T')[0]}

## Status History
- ${new Date().toISOString().split('T')[0]} - Created (planning)

## Current Phase
Spec is in planning phase. Ready for implementation when resources are available.

## Next Actions
- [ ] Review spec requirements
- [ ] Prioritize against other specs
- [ ] Begin implementation when approved

## Notes
Status file created automatically by lifecycle management system.
`;
      fs.writeFileSync(statusPath, statusContent);
      results.push(`✅ Created status.md for ${spec.name}`);
    }
  });
  
  return results.join('\n');
}

function generateDashboard() {
  const specsDir = '.agent-os/specs';
  if (!fs.existsSync(specsDir)) {
    return '❌ No specs directory found';
  }
  
  const items = fs.readdirSync(specsDir, { withFileTypes: true });
  const specs = items.filter(item => item.isDirectory());
  
  const categories = {
    planning: [],
    active: [],
    completed: [],
    archived: []
  };
  
  specs.forEach(spec => {
    const specPath = path.join(specsDir, spec.name);
    const status = getSpecStatus(specPath, spec.name);
    if (status) {
      categories[status].push(spec.name);
    }
  });
  
  const dashboardContent = `# Specs Dashboard

> Auto-generated dashboard for spec lifecycle management
> Last updated: ${new Date().toISOString().split('T')[0]}

## 📋 Planning (Backlog)
${formatSpecsList(categories.planning, 'planning')}

## 🔄 Active (In Progress)
${formatSpecsList(categories.active, 'active')}

## ✅ Completed (Done)
${formatSpecsList(categories.completed, 'completed')}

## 🗄️ Archived
${formatSpecsList(categories.archived, 'archived')}

## 📊 Summary
- **Planning**: ${categories.planning.length} specs
- **Active**: ${categories.active.length} specs
- **Completed**: ${categories.completed.length} specs
- **Archived**: ${categories.archived.length} specs
- **Total**: ${categories.planning.length + categories.active.length + categories.completed.length + categories.archived.length} specs

---
*Dashboard generated automatically. Update spec status files to refresh this dashboard.*
`;
  
  const dashboardPath = path.join(specsDir, 'specs-dashboard.md');
  fs.writeFileSync(dashboardPath, dashboardContent);
  
  return `✅ Dashboard generated with ${specs.length} specs`;
}

function formatSpecsList(specs, status) {
  if (specs.length === 0) {
    return `*No ${status} specs*`;
  }
  
  return specs
    .map(spec => {
      const checkbox = status === 'completed' || status === 'archived' ? '[x]' : '[ ]';
      return `- ${checkbox} ${spec}`;
    })
    .join('\n');
}

function showTestResults() {
  console.log('🎉 Lifecycle Management Test Complete!\n');
  console.log('📋 Available Commands:');
  console.log('- npm run dashboard          # Generate dashboard');
  console.log('- npm run dashboard:simple   # Generate simple dashboard');
  console.log('\n📁 Files Created:');
  console.log('- .agent-os/specs/specs-dashboard.md');
  console.log('- .agent-os/specs/spec-lifecycle-guide.md');
  console.log('- status.md files for existing specs');
  console.log('\n🔄 Next Steps:');
  console.log('1. Review generated dashboard');
  console.log('2. Update spec statuses as needed');
  console.log('3. Use lifecycle management for new specs');
  console.log('4. Regular dashboard updates');
}

// CLI usage
if (require.main === module) {
  testLifecycleManagement();
}

module.exports = { testLifecycleManagement }; 