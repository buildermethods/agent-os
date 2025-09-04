/**
 * State Management Helpers for Agent-OS
 * These functions will be embedded in commands for robust state management
 */

const fs = require('fs');
const path = require('path');

/**
 * Validates state data structure
 */
function validateStateSchema(data) {
  if (!data || typeof data !== 'object') return false;
  
  // Check for state_version if it's workflow.json
  if (data.state_version && typeof data.state_version !== 'string') {
    return false;
  }
  
  // Check for metadata in cache files
  if (data.metadata) {
    const meta = data.metadata;
    if (!meta.timestamp || !meta.expires) return false;
  }
  
  return true;
}

/**
 * Creates a recovery backup of a state file
 */
function createRecoveryBackup(filepath) {
  const recoveryDir = path.join(path.dirname(filepath), 'recovery');
  
  // Ensure recovery directory exists
  if (!fs.existsSync(recoveryDir)) {
    fs.mkdirSync(recoveryDir, { recursive: true });
  }
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filename = path.basename(filepath, '.json');
  const backupPath = path.join(recoveryDir, `${filename}-${timestamp}.json`);
  
  try {
    if (fs.existsSync(filepath)) {
      fs.copyFileSync(filepath, backupPath);
    }
    return backupPath;
  } catch (e) {
    console.warn(`Failed to create backup: ${e.message}`);
    return null;
  }
}

/**
 * Cleans old recovery files, keeping only the most recent 5
 */
function cleanOldRecoveryFiles(filepath) {
  const recoveryDir = path.join(path.dirname(filepath), 'recovery');
  if (!fs.existsSync(recoveryDir)) return;
  
  const filename = path.basename(filepath, '.json');
  const files = fs.readdirSync(recoveryDir)
    .filter(f => f.startsWith(filename))
    .map(f => ({
      name: f,
      path: path.join(recoveryDir, f),
      mtime: fs.statSync(path.join(recoveryDir, f)).mtime
    }))
    .sort((a, b) => b.mtime - a.mtime);
  
  // Keep only the 5 most recent files
  files.slice(5).forEach(file => {
    try {
      fs.unlinkSync(file.path);
    } catch (e) {
      console.warn(`Failed to delete old backup: ${file.name}`);
    }
  });
}

/**
 * Attempts to recover from backup files
 */
function attemptRecoveryFromBackup(filepath) {
  const recoveryDir = path.join(path.dirname(filepath), 'recovery');
  if (!fs.existsSync(recoveryDir)) return null;
  
  const filename = path.basename(filepath, '.json');
  const files = fs.readdirSync(recoveryDir)
    .filter(f => f.startsWith(filename))
    .map(f => ({
      path: path.join(recoveryDir, f),
      mtime: fs.statSync(path.join(recoveryDir, f)).mtime
    }))
    .sort((a, b) => b.mtime - a.mtime);
  
  // Try to load the most recent backup
  for (const file of files) {
    try {
      const data = JSON.parse(fs.readFileSync(file.path, 'utf8'));
      if (validateStateSchema(data)) {
        console.log(`Recovered state from backup: ${file.path}`);
        return data;
      }
    } catch (e) {
      continue;
    }
  }
  
  return null;
}

/**
 * Saves state with atomic operations and recovery
 */
function saveState(filepath, data) {
  // Validate data structure
  if (!validateStateSchema(data)) {
    throw new Error('Invalid state data structure');
  }
  
  // Create recovery backup
  createRecoveryBackup(filepath);
  
  // Ensure directory exists
  const dir = path.dirname(filepath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  // Atomic write using temp file
  const tempFile = `${filepath}.tmp`;
  fs.writeFileSync(tempFile, JSON.stringify(data, null, 2));
  fs.renameSync(tempFile, filepath);
  
  // Clean old recovery files
  cleanOldRecoveryFiles(filepath);
  
  return true;
}

/**
 * Loads state with recovery fallback
 */
function loadState(filepath, defaultState = {}) {
  try {
    if (!fs.existsSync(filepath)) {
      return defaultState;
    }
    
    const data = JSON.parse(fs.readFileSync(filepath, 'utf8'));
    if (!validateStateSchema(data)) {
      throw new Error('Invalid state schema');
    }
    return data;
  } catch (e) {
    // Attempt recovery from backups
    const recovered = attemptRecoveryFromBackup(filepath);
    if (recovered) return recovered;
    
    console.warn(`State corrupted: ${filepath}, using defaults`);
    return defaultState;
  }
}

/**
 * Checks and extends cache expiration
 */
function checkAndExtendCache(cacheData) {
  if (!cacheData || !cacheData.metadata) {
    return false;
  }
  
  const now = new Date();
  const expires = new Date(cacheData.metadata.expires);
  
  // Auto-extend if recently accessed and not exceeded max extensions
  const oneMinute = 60000;
  const maxExtensions = cacheData.metadata.max_extensions || 12;
  
  if (expires - now < oneMinute && 
      cacheData.metadata.extension_count < maxExtensions) {
    
    // Extend by 5 minutes
    cacheData.metadata.expires = new Date(now.getTime() + 5 * oneMinute).toISOString();
    cacheData.metadata.extension_count = (cacheData.metadata.extension_count || 0) + 1;
    cacheData.metadata.last_accessed = now.toISOString();
    return true;
  }
  
  return expires > now; // Return validity status
}

/**
 * Acquires a file lock
 */
function acquireLock(lockfile = '.agent-os/state/.lock', timeout = 30000) {
  const startTime = Date.now();
  
  while (fs.existsSync(lockfile)) {
    if (Date.now() - startTime > timeout) {
      console.warn('Lock timeout exceeded, forcing acquisition');
      break;
    }
    // Wait 100ms before checking again
    const waitTime = Date.now() + 100;
    while (Date.now() < waitTime) {
      // Busy wait
    }
  }
  
  // Ensure directory exists
  const dir = path.dirname(lockfile);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  const lockInfo = `${process.pid}:${new Date().toISOString()}`;
  fs.writeFileSync(lockfile, lockInfo);
}

/**
 * Releases a file lock
 */
function releaseLock(lockfile = '.agent-os/state/.lock') {
  try {
    if (fs.existsSync(lockfile)) {
      fs.unlinkSync(lockfile);
    }
  } catch (e) {
    console.warn(`Failed to release lock: ${e.message}`);
  }
}

/**
 * Creates default state files
 */
function initializeStateFiles(baseDir = '.agent-os') {
  const stateDir = path.join(baseDir, 'state');
  const recoveryDir = path.join(stateDir, 'recovery');
  
  // Create directories
  [stateDir, recoveryDir].forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  });
  
  // Create default workflow.json if it doesn't exist
  const workflowFile = path.join(stateDir, 'workflow.json');
  if (!fs.existsSync(workflowFile)) {
    const defaultWorkflow = {
      state_version: "1.0.0",
      current_workflow: null,
      created_at: new Date().toISOString()
    };
    saveState(workflowFile, defaultWorkflow);
  }
  
  return true;
}

module.exports = {
  validateStateSchema,
  createRecoveryBackup,
  cleanOldRecoveryFiles,
  attemptRecoveryFromBackup,
  saveState,
  loadState,
  checkAndExtendCache,
  acquireLock,
  releaseLock,
  initializeStateFiles
};