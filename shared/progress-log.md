# Progress Log Patterns

Canonical patterns for persistent progress logging across Agent OS sessions. These patterns ensure cross-session memory and accomplishment tracking.

**Reference**: Based on Anthropic's "Effective Harnesses for Long-Running Agents" research.

---

## Core Principles

1. **Permanent Persistence**: Progress log NEVER expires (unlike session cache)
2. **Chronological Append**: Always append, never overwrite entries
3. **Dual Format**: JSON source of truth, Markdown for human readability
4. **Atomic Operations**: All writes use atomic patterns from state-patterns.md

---

## Progress File Locations

```
.agent-os/progress/
├── progress.json        # Machine-readable source of truth
├── progress.md          # Human-readable (generated from JSON)
└── archive/             # Archived entries (>30 days old)
    └── YYYY-MM.json     # Monthly archive files
```

**Important**: Progress files are NOT cached and do NOT expire. They persist permanently.

---

## Pattern: Progress Entry Types

Standard entry types for progress logging.

```javascript
// PROGRESS_ENTRY_TYPES
const ENTRY_TYPES = {
  SESSION_STARTED: 'session_started',
  SESSION_ENDED: 'session_ended',
  TASK_COMPLETED: 'task_completed',
  TASK_BLOCKED: 'task_blocked',
  DEBUG_RESOLVED: 'debug_resolved',
  SCOPE_OVERRIDE: 'scope_override',
  MILESTONE_REACHED: 'milestone_reached'
};
```

---

## Pattern: Progress JSON Schema

Standard structure for progress.json.

```json
{
  "version": "1.0",
  "project": "project-name",
  "entries": [
    {
      "id": "entry-YYYYMMDD-HHMMSS-XXX",
      "timestamp": "ISO 8601 timestamp",
      "type": "entry_type",
      "spec": "spec-folder-name (optional)",
      "task_id": "1.2 (optional)",
      "data": {
        "description": "What happened",
        "duration_minutes": 15,
        "notes": "Additional context",
        "next_steps": "What comes next"
      }
    }
  ],
  "metadata": {
    "total_entries": 0,
    "oldest_entry": null,
    "last_updated": null,
    "archived_through": null
  }
}
```

---

## Pattern: Append Progress Entry

Use this pattern to add entries to the progress log.

```javascript
// PROGRESS_APPEND_PATTERN
function appendProgressEntry(entryType, data) {
  const PROGRESS_FILE = '.agent-os/progress/progress.json';

  // 1. Ensure progress directory exists
  mkdirSync('.agent-os/progress', { recursive: true });

  // 2. Load existing progress (or create new)
  let progress = loadProgressFile(PROGRESS_FILE);

  // 3. Generate unique entry ID
  const timestamp = new Date().toISOString();
  const entryId = `entry-${timestamp.replace(/[-:T.Z]/g, '').slice(0,15)}-${randomString(3)}`;

  // 4. Create entry
  const entry = {
    id: entryId,
    timestamp: timestamp,
    type: entryType,
    ...data
  };

  // 5. Append to entries array
  progress.entries.push(entry);

  // 6. Update metadata
  progress.metadata.total_entries = progress.entries.length;
  progress.metadata.last_updated = timestamp;
  if (!progress.metadata.oldest_entry) {
    progress.metadata.oldest_entry = timestamp;
  }

  // 7. Atomic write (use ATOMIC_WRITE_PATTERN from state-patterns.md)
  saveProgressFile(PROGRESS_FILE, progress);

  // 8. Regenerate markdown
  regenerateProgressMarkdown(progress);

  // 9. Check if archival needed
  checkAndArchive(progress);

  return entry;
}
```

---

## Pattern: Load Progress File

Safe loading with initialization.

```javascript
// PROGRESS_LOAD_PATTERN
function loadProgressFile(filepath) {
  const DEFAULT_PROGRESS = {
    version: '1.0',
    project: getProjectName(),
    entries: [],
    metadata: {
      total_entries: 0,
      oldest_entry: null,
      last_updated: null,
      archived_through: null
    }
  };

  try {
    if (!existsSync(filepath)) {
      return DEFAULT_PROGRESS;
    }

    const content = readFileSync(filepath, 'utf8');
    const progress = JSON.parse(content);

    // Validate schema version
    if (progress.version !== '1.0') {
      console.warn('Progress file version mismatch, migrating...');
      return migrateProgressSchema(progress);
    }

    return progress;

  } catch (error) {
    console.warn('Error loading progress file, starting fresh');
    return DEFAULT_PROGRESS;
  }
}
```

---

## Pattern: Generate Markdown from JSON

Regenerate human-readable markdown from JSON source.

```javascript
// PROGRESS_MARKDOWN_PATTERN
function regenerateProgressMarkdown(progress) {
  const MARKDOWN_FILE = '.agent-os/progress/progress.md';

  let markdown = '# Agent OS Progress Log\n\n';
  markdown += `*Project: ${progress.project}*\n`;
  markdown += `*Total entries: ${progress.metadata.total_entries}*\n\n`;
  markdown += '---\n\n';

  // Group entries by date
  const entriesByDate = groupEntriesByDate(progress.entries);

  // Generate markdown for each date (newest first)
  const dates = Object.keys(entriesByDate).sort().reverse();

  for (const date of dates) {
    markdown += `## ${formatDateHeader(date)}\n\n`;

    for (const entry of entriesByDate[date].reverse()) {
      markdown += formatEntryAsMarkdown(entry);
      markdown += '\n';
    }

    markdown += '---\n\n';
  }

  // Add archive note if applicable
  if (progress.metadata.archived_through) {
    markdown += `\n*Older entries archived through ${progress.metadata.archived_through}*\n`;
    markdown += `*See .agent-os/progress/archive/ for historical data*\n`;
  }

  writeFileSync(MARKDOWN_FILE, markdown);
}

function formatEntryAsMarkdown(entry) {
  const time = formatTime(entry.timestamp);
  const icon = getEntryIcon(entry.type);

  let md = `### ${time} - ${icon} ${formatEntryTitle(entry)}\n`;

  if (entry.spec) md += `- **Spec**: ${entry.spec}\n`;
  if (entry.task_id) md += `- **Task**: ${entry.task_id}\n`;
  if (entry.data.description) md += `- **Details**: ${entry.data.description}\n`;
  if (entry.data.duration_minutes) md += `- **Duration**: ~${entry.data.duration_minutes} minutes\n`;
  if (entry.data.notes) md += `- **Notes**: ${entry.data.notes}\n`;
  if (entry.data.next_steps) md += `- **Next**: ${entry.data.next_steps}\n`;

  return md;
}

function getEntryIcon(type) {
  const icons = {
    'session_started': '🚀',
    'session_ended': '🏁',
    'task_completed': '✅',
    'task_blocked': '⚠️',
    'debug_resolved': '🔧',
    'scope_override': '📋',
    'milestone_reached': '🎯'
  };
  return icons[type] || '📝';
}
```

---

## Pattern: Read Recent Progress

Read recent entries for session startup.

```javascript
// PROGRESS_READ_RECENT_PATTERN
function getRecentProgress(count = 20) {
  const PROGRESS_FILE = '.agent-os/progress/progress.json';

  const progress = loadProgressFile(PROGRESS_FILE);

  if (progress.entries.length === 0) {
    return {
      entries: [],
      summary: 'No previous progress recorded.',
      last_spec: null,
      last_task: null,
      unresolved_blockers: []
    };
  }

  // Get last N entries
  const recentEntries = progress.entries.slice(-count);

  // Extract summary information
  const lastTaskEntry = recentEntries
    .filter(e => e.type === 'task_completed')
    .pop();

  const lastSpec = lastTaskEntry?.spec || null;
  const lastTask = lastTaskEntry?.task_id || null;

  // Find unresolved blockers
  const blockers = recentEntries
    .filter(e => e.type === 'task_blocked')
    .filter(blocker => {
      // Check if blocker was resolved
      const resolved = recentEntries.find(e =>
        e.type === 'task_completed' &&
        e.task_id === blocker.task_id &&
        new Date(e.timestamp) > new Date(blocker.timestamp)
      );
      return !resolved;
    });

  // Generate human-readable summary
  const summary = generateProgressSummary(recentEntries);

  return {
    entries: recentEntries,
    summary: summary,
    last_spec: lastSpec,
    last_task: lastTask,
    unresolved_blockers: blockers
  };
}

function generateProgressSummary(entries) {
  const completed = entries.filter(e => e.type === 'task_completed').length;
  const blocked = entries.filter(e => e.type === 'task_blocked').length;
  const lastEntry = entries[entries.length - 1];

  let summary = `Last ${entries.length} entries: `;
  summary += `${completed} tasks completed`;
  if (blocked > 0) summary += `, ${blocked} blockers`;
  summary += `.`;

  if (lastEntry) {
    summary += ` Most recent: ${formatEntryTitle(lastEntry)}`;
    if (lastEntry.data.next_steps) {
      summary += ` Next: ${lastEntry.data.next_steps}`;
    }
  }

  return summary;
}
```

---

## Pattern: Archive Old Entries

Archive entries older than 30 days.

```javascript
// PROGRESS_ARCHIVE_PATTERN
const ARCHIVE_THRESHOLD_DAYS = 30;
const MAX_ENTRIES_BEFORE_ARCHIVE = 500;

function checkAndArchive(progress) {
  // Check if archival needed
  if (progress.entries.length < MAX_ENTRIES_BEFORE_ARCHIVE) {
    return; // Not enough entries to warrant archival
  }

  const now = new Date();
  const threshold = new Date(now - ARCHIVE_THRESHOLD_DAYS * 24 * 60 * 60 * 1000);

  // Separate old and recent entries
  const oldEntries = progress.entries.filter(e =>
    new Date(e.timestamp) < threshold
  );

  if (oldEntries.length === 0) {
    return; // Nothing to archive
  }

  const recentEntries = progress.entries.filter(e =>
    new Date(e.timestamp) >= threshold
  );

  // Group old entries by month
  const entriesByMonth = {};
  for (const entry of oldEntries) {
    const monthKey = entry.timestamp.slice(0, 7); // YYYY-MM
    if (!entriesByMonth[monthKey]) {
      entriesByMonth[monthKey] = [];
    }
    entriesByMonth[monthKey].push(entry);
  }

  // Write archive files
  const ARCHIVE_DIR = '.agent-os/progress/archive';
  mkdirSync(ARCHIVE_DIR, { recursive: true });

  for (const [month, entries] of Object.entries(entriesByMonth)) {
    const archiveFile = `${ARCHIVE_DIR}/${month}.json`;

    // Merge with existing archive if present
    let archive = { entries: [] };
    if (existsSync(archiveFile)) {
      archive = JSON.parse(readFileSync(archiveFile, 'utf8'));
    }

    archive.entries = [...archive.entries, ...entries];
    archive.entries.sort((a, b) => a.timestamp.localeCompare(b.timestamp));

    writeFileSync(archiveFile, JSON.stringify(archive, null, 2));
  }

  // Update main progress file
  progress.entries = recentEntries;
  progress.metadata.total_entries = recentEntries.length;
  progress.metadata.archived_through = threshold.toISOString().slice(0, 10);
}
```

---

## Entry Templates

### Session Started
```javascript
appendProgressEntry('session_started', {
  spec: 'auth-feature',
  data: {
    description: 'Starting work on authentication',
    focus_task: '1.2',
    context: 'Continuing from JWT implementation'
  }
});
```

### Task Completed
```javascript
appendProgressEntry('task_completed', {
  spec: 'auth-feature',
  task_id: '1.2',
  data: {
    description: 'Implemented JWT validation',
    duration_minutes: 45,
    notes: 'Added refresh token support',
    next_steps: 'Task 1.3 - Session management'
  }
});
```

### Task Blocked
```javascript
appendProgressEntry('task_blocked', {
  spec: 'auth-feature',
  task_id: '1.2',
  data: {
    description: 'Cannot proceed with JWT validation',
    issue: 'Missing JWKS endpoint configuration',
    suggested_resolution: 'Add JWKS_URI to environment config'
  }
});
```

### Debug Resolved
```javascript
appendProgressEntry('debug_resolved', {
  spec: 'auth-feature',
  data: {
    description: 'Fixed token expiration bug',
    root_cause: 'Timezone mismatch in expiry calculation',
    resolution: 'Normalized all timestamps to UTC',
    files_modified: ['src/auth/token.ts', 'src/utils/time.ts']
  }
});
```

### Scope Override
```javascript
appendProgressEntry('scope_override', {
  spec: 'auth-feature',
  data: {
    description: 'User chose to execute multiple tasks',
    requested_tasks: ['1.1', '1.2', '1.3'],
    reason: 'user_override'
  }
});
```

---

## Usage in Commands

Reference these patterns in command files:

```markdown
## Progress Logging

Use patterns from @shared/progress-log.md:
- Append entries: PROGRESS_APPEND_PATTERN
- Load progress: PROGRESS_LOAD_PATTERN
- Read recent: PROGRESS_READ_RECENT_PATTERN
- Archive: PROGRESS_ARCHIVE_PATTERN

Log events:
- SESSION_STARTED: At session startup after environment verified
- TASK_COMPLETED: After each task marked complete
- TASK_BLOCKED: When blocker documented
- SESSION_ENDED: At explicit end or before context expiration
```

---

## Integration Points

### execute-tasks
- Log `session_started` at Phase 1 completion
- Log `task_completed` after each parent task
- Log `session_ended` at Phase 3 completion

### debug
- Log `debug_resolved` after fix verified
- Log `task_blocked` if debug reveals blocker

### Session Startup
- Read `getRecentProgress(20)` for context
- Display summary to user
- Highlight unresolved blockers
