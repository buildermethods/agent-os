# State Management Patterns

Canonical patterns for state management across all Agent OS commands. Use these patterns to ensure consistent, reliable state handling.

---

## Core Principles

1. **Atomic Writes**: Always write to temp file first, then rename
2. **Recovery Backups**: Create backup before modifying state
3. **Schema Validation**: Validate state structure before use
4. **Expiration by Mtime**: Use file modification time for cache expiration

---

## State File Locations

```
.agent-os/state/
├── workflow.json        # Current workflow state
├── session-cache.json   # Runtime cache (auto-generated)
├── .lock               # File lock for concurrent access
└── recovery/           # Automatic state backups (last 5)

.agent-os/progress/
├── progress.json        # Persistent cross-session memory (NEVER expires)
├── progress.md          # Human-readable version (auto-generated)
└── archive/             # Archived entries older than 30 days
```

---

## Two-Tier Memory Architecture

Agent OS uses two complementary memory systems with different time horizons:

### Session Cache (Short-Term Memory)
- **Purpose**: Performance optimization within a single workflow
- **Lifespan**: 5 minutes, auto-extends up to 1 hour max
- **Content**: File paths, cached document content, test results
- **Git tracked**: No (ephemeral, in .gitignore)
- **Recovery**: Rebuilds from source files if expired/corrupted

**Use for**: Avoiding redundant file reads, caching spec locations, storing test results

### Progress Log (Long-Term Memory)
- **Purpose**: Cross-session context and accomplishment tracking
- **Lifespan**: Never expires (permanent record)
- **Content**: Events, decisions, accomplishments, blockers
- **Git tracked**: Yes (version controlled, team-visible)
- **Recovery**: N/A - represents irreplaceable history

**Use for**: Session continuity, blocker tracking, understanding "what happened"

### How They Complement Each Other

```
┌─────────────────────────────────────────────────────────────┐
│                     Session Workflow                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  SESSION CACHE (ephemeral)      PROGRESS LOG (permanent)    │
│  ┌─────────────────────┐        ┌─────────────────────┐     │
│  │ spec_cache:         │        │ session_started:    │     │
│  │   file paths        │        │   what we're doing  │     │
│  │   section indexes   │        │                     │     │
│  │                     │        │ task_completed:     │     │
│  │ context_cache:      │        │   what we achieved  │     │
│  │   mission content   │        │   how long it took  │     │
│  │   tech stack        │        │                     │     │
│  │                     │        │ task_blocked:       │     │
│  │ test_cache:         │        │   what's stopping us│     │
│  │   recent results    │        │                     │     │
│  └─────────────────────┘        └─────────────────────┘     │
│           │                              │                  │
│           ▼                              ▼                  │
│    Expires after                  Persists forever          │
│    workflow ends                  across all sessions       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Key Distinction

| Question | Answer From |
|----------|-------------|
| "Where is the auth spec file?" | Session Cache (or re-discover) |
| "What's in mission.md?" | Session Cache (or re-read file) |
| "Did tests pass recently?" | Session Cache |
| "What did we accomplish yesterday?" | **Progress Log only** |
| "Why was Task 1.2 blocked?" | **Progress Log only** |
| "What's the next step?" | **Progress Log only** |

**Critical insight**: Session cache content is *re-discoverable* from source files. Progress log content is *irreplaceable* - it records decisions and events that only existed in the agent's context window.

### When to Use Each

**Session Cache** (see @shared/state-patterns.md patterns):
- Cache file paths during spec discovery
- Store document content to avoid re-reading
- Track test results within a workflow

**Progress Log** (see @shared/progress-log.md patterns):
- Record session start with context
- Log task completions with notes
- Document blockers and resolutions
- Summarize session accomplishments

---

## Pattern: Atomic State Write

Use this pattern for ALL state modifications to prevent corruption.

```javascript
// ATOMIC_WRITE_PATTERN
function saveState(filepath, data) {
  // 1. Validate schema
  validateStateSchema(data);

  // 2. Create recovery backup
  createRecoveryBackup(filepath);

  // 3. Write to temp file
  const tempFile = `${filepath}.tmp`;
  writeFileSync(tempFile, JSON.stringify(data, null, 2));

  // 4. Atomic rename (prevents partial writes)
  renameSync(tempFile, filepath);

  // 5. Clean old recovery files (keep last 5)
  cleanOldRecoveryFiles();
}
```

**Commands using this pattern:**
- All commands that modify workflow.json
- All commands that modify session-cache.json

---

## Pattern: State Loading with Recovery

Use this pattern when loading state files.

```javascript
// STATE_LOAD_PATTERN
function loadState(filepath, defaultState) {
  try {
    // 1. Check if file exists
    if (!existsSync(filepath)) {
      return defaultState;
    }

    // 2. Read and parse
    const content = readFileSync(filepath, 'utf8');
    const state = JSON.parse(content);

    // 3. Validate schema
    validateStateSchema(state);

    return state;

  } catch (error) {
    // 4. Attempt recovery
    const recovered = attemptRecovery(filepath);
    if (recovered) return recovered;

    // 5. Fall back to default
    console.warn(`State recovery failed, using defaults`);
    return defaultState;
  }
}
```

---

## Pattern: Cache Validation

Use file modification time for cache expiration (not JavaScript dates).

```javascript
// CACHE_VALIDATION_PATTERN
function isCacheValid(cacheFile, maxAgeMinutes = 5) {
  try {
    const stats = statSync(cacheFile);
    const mtime = stats.mtimeMs;
    const now = Date.now();
    const ageMinutes = (now - mtime) / (1000 * 60);

    return ageMinutes < maxAgeMinutes;
  } catch {
    return false; // File doesn't exist
  }
}

// Check cache validity
// COMMAND: ls -la .agent-os/state/session-cache.json
// Compare modification time to current time
```

**Cache Expiration Rules:**
- Default expiration: 5 minutes
- Auto-extension: If workflow active and < 1 minute remaining
- Maximum extensions: 12 (total 1 hour maximum)

---

## Pattern: Session Cache Structure

Standard structure for session-cache.json.

```json
{
  "spec_cache": {
    "[spec-file-name]": {
      "path": ".agent-os/specs/[spec-folder]/[file].md",
      "sections": ["section1", "section2"],
      "last_modified": "timestamp"
    }
  },
  "context_cache": {
    "mission": "cached mission content",
    "tech_stack": "cached tech stack content",
    "standards": {}
  },
  "test_cache": {
    "last_run": "timestamp",
    "results": {},
    "passing": true
  },
  "metadata": {
    "created_date": "YYYY-MM-DD",
    "workflow_id": "tasks-YYYY-MM-DD-NNN",
    "access_count": 1,
    "auto_extend": true,
    "extension_count": 0,
    "max_extensions": 12,
    "state_version": "1.0.0"
  }
}
```

---

## Pattern: Lock Management

Use file locking for critical sections.

```javascript
// LOCK_PATTERN
const LOCK_FILE = '.agent-os/state/.lock';
const LOCK_TIMEOUT = 30000; // 30 seconds

function acquireLock() {
  const startTime = Date.now();

  while (existsSync(LOCK_FILE)) {
    // Check if lock is stale (> timeout)
    const lockAge = Date.now() - statSync(LOCK_FILE).mtimeMs;
    if (lockAge > LOCK_TIMEOUT) {
      // Force acquire stale lock
      break;
    }

    // Check for overall timeout
    if (Date.now() - startTime > LOCK_TIMEOUT) {
      throw new Error('Failed to acquire state lock');
    }

    // Wait before retry
    sleepSync(100);
  }

  // Create lock with PID
  writeFileSync(LOCK_FILE, process.pid.toString());
}

function releaseLock() {
  if (existsSync(LOCK_FILE)) {
    unlinkSync(LOCK_FILE);
  }
}
```

**Usage:**
```javascript
acquireLock();
try {
  // Critical section - modify state
  saveState(filepath, newState);
} finally {
  releaseLock();
}
```

---

## Pattern: Recovery Backup

Create backups before modifying state.

```javascript
// BACKUP_PATTERN
const RECOVERY_DIR = '.agent-os/state/recovery';
const MAX_BACKUPS = 5;

function createRecoveryBackup(filepath) {
  // 1. Ensure recovery directory exists
  mkdirSync(RECOVERY_DIR, { recursive: true });

  // 2. Only backup if file exists
  if (!existsSync(filepath)) return;

  // 3. Create timestamped backup
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filename = basename(filepath);
  const backupPath = `${RECOVERY_DIR}/${filename}.${timestamp}`;

  copyFileSync(filepath, backupPath);

  // 4. Clean old backups
  cleanOldBackups(filename);
}

function cleanOldBackups(filename) {
  const pattern = `${filename}.*`;
  const backups = readdirSync(RECOVERY_DIR)
    .filter(f => f.startsWith(filename))
    .sort()
    .reverse();

  // Keep only MAX_BACKUPS
  for (const backup of backups.slice(MAX_BACKUPS)) {
    unlinkSync(`${RECOVERY_DIR}/${backup}`);
  }
}
```

---

## Pattern: Workflow State Structure

Standard structure for workflow.json.

```json
{
  "state_version": "1.0.0",
  "current_workflow": {
    "type": "execute-tasks|create-spec|debug|...",
    "spec_folder": "YYYY-MM-DD-spec-name",
    "started": "ISO timestamp",
    "status": "in_progress|completed|failed",
    "current_step": "step identifier",
    "completed_steps": ["step1", "step2"],
    "context": {
      "branch": "feature-branch-name",
      "tasks_completed": 0,
      "tasks_total": 5
    }
  },
  "history": [
    {
      "type": "workflow-type",
      "completed": "ISO timestamp",
      "summary": "brief description"
    }
  ]
}
```

---

## Pattern: Cache Auto-Extension

Extend cache expiration for active workflows.

```javascript
// AUTO_EXTEND_PATTERN
function checkAndExtendCache(cacheFile) {
  const cache = loadState(cacheFile, null);
  if (!cache) return false;

  const { metadata } = cache;

  // Check if auto-extend is enabled
  if (!metadata.auto_extend) return false;

  // Check if at max extensions
  if (metadata.extension_count >= metadata.max_extensions) {
    return false; // Cache must expire
  }

  // Check if cache is about to expire (< 1 minute)
  if (isCacheValid(cacheFile, 1)) {
    // Still valid, no extension needed
    return true;
  }

  // Extend by touching the file (updates mtime)
  metadata.extension_count += 1;
  metadata.access_count += 1;
  saveState(cacheFile, cache);

  return true;
}
```

---

## Command-Specific State Notes

Commands should define only their unique state fields:

### execute-tasks
```json
{
  "task_iteration": {
    "current_task": "1.2",
    "subtask_index": 0,
    "tdd_phase": "RED|GREEN|REFACTOR"
  }
}
```

### debug
```json
{
  "debug_context": {
    "scope": "task|spec|general",
    "spec_name": "optional",
    "task_number": "optional",
    "investigation_phase": 1
  }
}
```

### create-spec
```json
{
  "spec_creation": {
    "current_step": 1,
    "spec_folder": "YYYY-MM-DD-name",
    "files_created": []
  }
}
```

---

## Usage in Commands

Reference these patterns in command files:

```markdown
## State Management

Use patterns from @shared/state-patterns.md:
- State writes: ATOMIC_WRITE_PATTERN
- State loads: STATE_LOAD_PATTERN
- Cache checks: CACHE_VALIDATION_PATTERN
- Locking: LOCK_PATTERN

Command-specific state fields:
- [document only unique fields for this command]
```
