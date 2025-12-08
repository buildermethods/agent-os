# Task JSON Format Patterns

Canonical patterns for machine-readable task tracking alongside markdown. JSON provides programmatic access while markdown remains the human-editable source of truth.

---

## Core Principles

1. **Markdown is Source of Truth**: Human edits go to tasks.md
2. **JSON is Generated**: tasks.json is auto-generated from markdown
3. **Metadata Preserved**: JSON stores additional metadata not in markdown
4. **Bidirectional Sync**: Changes sync from markdown to JSON (not reverse)

---

## File Locations

```
.agent-os/tasks/[spec-name]/
├── tasks.md          # Human-readable, editable (source of truth)
└── tasks.json        # Machine-readable (auto-generated)
```

---

## JSON Schema

### tasks.json Structure

```json
{
  "$schema": "https://agent-os.dev/schemas/tasks-v1.json",
  "version": "1.0",
  "spec": "feature-name",
  "spec_path": ".agent-os/specs/feature-name/",
  "created": "2025-12-08T10:00:00Z",
  "updated": "2025-12-08T14:30:00Z",
  "tasks": [
    {
      "id": "1",
      "type": "parent",
      "description": "Implement authentication endpoints",
      "status": "in_progress",
      "subtasks": ["1.1", "1.2", "1.3"],
      "progress_percent": 66,
      "started_at": "2025-12-08T10:30:00Z",
      "completed_at": null
    },
    {
      "id": "1.1",
      "type": "subtask",
      "parent": "1",
      "description": "Create login endpoint",
      "status": "pass",
      "attempts": 1,
      "started_at": "2025-12-08T10:30:00Z",
      "completed_at": "2025-12-08T11:15:00Z",
      "duration_minutes": 45,
      "notes": null,
      "blocker": null
    },
    {
      "id": "1.2",
      "type": "subtask",
      "parent": "1",
      "description": "Implement JWT validation",
      "status": "pass",
      "attempts": 2,
      "started_at": "2025-12-08T11:20:00Z",
      "completed_at": "2025-12-08T13:00:00Z",
      "duration_minutes": 100,
      "notes": "Required JWKS endpoint fix on attempt 2",
      "blocker": null
    },
    {
      "id": "1.3",
      "type": "subtask",
      "parent": "1",
      "description": "Add session management",
      "status": "pending",
      "attempts": 0,
      "started_at": null,
      "completed_at": null,
      "duration_minutes": null,
      "notes": null,
      "blocker": null
    }
  ],
  "summary": {
    "total_tasks": 4,
    "parent_tasks": 1,
    "subtasks": 3,
    "completed": 2,
    "in_progress": 1,
    "blocked": 0,
    "pending": 1,
    "overall_percent": 50
  }
}
```

### Field Definitions

**Top-level fields:**

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Schema version ("1.0") |
| `spec` | string | Spec folder name |
| `spec_path` | string | Path to spec directory |
| `created` | ISO8601 | When tasks.json was created |
| `updated` | ISO8601 | Last sync timestamp |
| `tasks` | array | Task objects |
| `summary` | object | Aggregated statistics |

**Task fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Task identifier ("1", "1.1", "1.2") |
| `type` | enum | "parent" or "subtask" |
| `parent` | string | Parent task ID (subtasks only) |
| `description` | string | Task description from markdown |
| `status` | enum | "pending", "in_progress", "pass", "blocked" |
| `subtasks` | array | Child task IDs (parent tasks only) |
| `progress_percent` | number | Completion percentage (parent tasks only) |
| `attempts` | number | Number of execution attempts |
| `started_at` | ISO8601 | When task was first attempted |
| `completed_at` | ISO8601 | When task was completed |
| `duration_minutes` | number | Total time spent |
| `notes` | string | Additional context |
| `blocker` | string | Blocker description if blocked |

---

## Pattern: Parse Markdown to JSON

Convert tasks.md checkbox format to JSON structure.

```javascript
// MARKDOWN_TO_JSON_PATTERN
function parseTasksMarkdown(markdownContent) {
  const tasks = [];
  const lines = markdownContent.split('\n');

  let currentParent = null;

  for (const line of lines) {
    // Match parent task: ## Task 1: Description
    const parentMatch = line.match(/^##\s+Task\s+(\d+):\s+(.+)$/);
    if (parentMatch) {
      currentParent = {
        id: parentMatch[1],
        type: 'parent',
        description: parentMatch[2].trim(),
        status: 'pending',
        subtasks: [],
        progress_percent: 0
      };
      tasks.push(currentParent);
      continue;
    }

    // Match subtask: - [x] 1.1 Description or - [ ] 1.1 Description
    const subtaskMatch = line.match(/^-\s+\[([ x])\]\s+(\d+\.\d+)\s+(.+)$/);
    if (subtaskMatch && currentParent) {
      const isComplete = subtaskMatch[1] === 'x';
      const subtask = {
        id: subtaskMatch[2],
        type: 'subtask',
        parent: currentParent.id,
        description: subtaskMatch[3].trim(),
        status: isComplete ? 'pass' : 'pending',
        attempts: isComplete ? 1 : 0,
        completed_at: isComplete ? new Date().toISOString() : null
      };

      // Check for blocker marker
      if (subtask.description.includes('⚠️')) {
        subtask.status = 'blocked';
        const blockerMatch = subtask.description.match(/⚠️\s*(.+)$/);
        if (blockerMatch) {
          subtask.blocker = blockerMatch[1];
          subtask.description = subtask.description.replace(/⚠️.*$/, '').trim();
        }
      }

      tasks.push(subtask);
      currentParent.subtasks.push(subtask.id);
    }
  }

  // Calculate parent progress
  for (const task of tasks) {
    if (task.type === 'parent') {
      const subtasks = tasks.filter(t => t.parent === task.id);
      const completed = subtasks.filter(t => t.status === 'pass').length;
      task.progress_percent = subtasks.length > 0
        ? Math.round((completed / subtasks.length) * 100)
        : 0;
      task.status = completed === subtasks.length ? 'pass'
        : completed > 0 ? 'in_progress'
        : 'pending';
    }
  }

  return tasks;
}
```

---

## Pattern: Generate JSON from Markdown

Create or update tasks.json from tasks.md.

```javascript
// SYNC_TASKS_PATTERN
function syncTasksToJson(specFolder) {
  const markdownPath = `${specFolder}/tasks.md`;
  const jsonPath = `${specFolder}/tasks.json`;

  // 1. Read markdown (source of truth)
  const markdownContent = readFileSync(markdownPath, 'utf8');

  // 2. Parse to task objects
  const parsedTasks = parseTasksMarkdown(markdownContent);

  // 3. Load existing JSON for metadata preservation
  let existingJson = { tasks: [] };
  if (existsSync(jsonPath)) {
    try {
      existingJson = JSON.parse(readFileSync(jsonPath, 'utf8'));
    } catch (e) {
      // Corrupted JSON, will regenerate
    }
  }

  // 4. Merge metadata from existing JSON
  for (const task of parsedTasks) {
    const existing = existingJson.tasks.find(t => t.id === task.id);
    if (existing) {
      // Preserve metadata not in markdown
      task.attempts = existing.attempts || task.attempts;
      task.started_at = existing.started_at || task.started_at;
      task.completed_at = existing.completed_at || task.completed_at;
      task.duration_minutes = existing.duration_minutes || task.duration_minutes;
      task.notes = existing.notes || task.notes;

      // Update completion time if newly completed
      if (task.status === 'pass' && !task.completed_at) {
        task.completed_at = new Date().toISOString();
      }
    }
  }

  // 5. Calculate summary
  const summary = calculateSummary(parsedTasks);

  // 6. Build final JSON
  const tasksJson = {
    version: '1.0',
    spec: basename(specFolder),
    spec_path: `.agent-os/specs/${basename(specFolder)}/`,
    created: existingJson.created || new Date().toISOString(),
    updated: new Date().toISOString(),
    tasks: parsedTasks,
    summary: summary
  };

  // 7. Write JSON (atomic)
  const tempPath = `${jsonPath}.tmp`;
  writeFileSync(tempPath, JSON.stringify(tasksJson, null, 2));
  renameSync(tempPath, jsonPath);

  return tasksJson;
}

function calculateSummary(tasks) {
  const parentTasks = tasks.filter(t => t.type === 'parent');
  const subtasks = tasks.filter(t => t.type === 'subtask');

  const completed = tasks.filter(t => t.status === 'pass').length;
  const inProgress = tasks.filter(t => t.status === 'in_progress').length;
  const blocked = tasks.filter(t => t.status === 'blocked').length;
  const pending = tasks.filter(t => t.status === 'pending').length;

  return {
    total_tasks: tasks.length,
    parent_tasks: parentTasks.length,
    subtasks: subtasks.length,
    completed: completed,
    in_progress: inProgress,
    blocked: blocked,
    pending: pending,
    overall_percent: tasks.length > 0
      ? Math.round((completed / tasks.length) * 100)
      : 0
  };
}
```

---

## Pattern: Update Task Metadata

Update JSON metadata when task status changes.

```javascript
// UPDATE_TASK_METADATA_PATTERN
function updateTaskMetadata(specFolder, taskId, metadata) {
  const jsonPath = `${specFolder}/tasks.json`;

  // 1. Load existing JSON
  const tasksJson = JSON.parse(readFileSync(jsonPath, 'utf8'));

  // 2. Find task
  const task = tasksJson.tasks.find(t => t.id === taskId);
  if (!task) {
    throw new Error(`Task ${taskId} not found`);
  }

  // 3. Update metadata
  if (metadata.status === 'in_progress' && !task.started_at) {
    task.started_at = new Date().toISOString();
    task.attempts = (task.attempts || 0) + 1;
  }

  if (metadata.status === 'pass' && !task.completed_at) {
    task.completed_at = new Date().toISOString();
    if (task.started_at) {
      const start = new Date(task.started_at);
      const end = new Date(task.completed_at);
      task.duration_minutes = Math.round((end - start) / (1000 * 60));
    }
  }

  if (metadata.notes) {
    task.notes = metadata.notes;
  }

  if (metadata.blocker) {
    task.status = 'blocked';
    task.blocker = metadata.blocker;
  }

  // 4. Recalculate summary
  tasksJson.summary = calculateSummary(tasksJson.tasks);
  tasksJson.updated = new Date().toISOString();

  // 5. Write JSON (atomic)
  const tempPath = `${jsonPath}.tmp`;
  writeFileSync(tempPath, JSON.stringify(tasksJson, null, 2));
  renameSync(tempPath, jsonPath);

  return task;
}
```

---

## Pattern: Query Task Status

Query task status programmatically.

```javascript
// QUERY_TASKS_PATTERN
function getTaskStatus(specFolder) {
  const jsonPath = `${specFolder}/tasks.json`;
  const tasksJson = JSON.parse(readFileSync(jsonPath, 'utf8'));

  return {
    summary: tasksJson.summary,
    nextTask: getNextTask(tasksJson.tasks),
    blockedTasks: tasksJson.tasks.filter(t => t.status === 'blocked'),
    recentlyCompleted: getRecentlyCompleted(tasksJson.tasks)
  };
}

function getNextTask(tasks) {
  // Find first pending subtask
  const pending = tasks.filter(t =>
    t.type === 'subtask' && t.status === 'pending'
  );
  return pending[0] || null;
}

function getRecentlyCompleted(tasks, hours = 24) {
  const cutoff = new Date(Date.now() - hours * 60 * 60 * 1000);
  return tasks.filter(t =>
    t.status === 'pass' &&
    t.completed_at &&
    new Date(t.completed_at) > cutoff
  );
}
```

---

## Sync Triggers

Tasks.json should be synced:

1. **After /create-tasks command** - Initial generation
2. **After task status change** - When checkbox toggled in tasks.md
3. **At session startup** - Validate consistency
4. **After execute-tasks completion** - Final sync with metadata

---

## Integration with execute-tasks

Add sync points in execute-tasks:

```
Step 7.10 (Mark Task Complete):
  1. Update tasks.md checkbox to [x]
  2. SYNC: Regenerate tasks.json
  3. UPDATE: Task metadata (completed_at, duration)
  4. Log to progress log

Step 8 (Phase 3 - All tests pass):
  1. Final sync of tasks.json
  2. Verify consistency with tasks.md
```

---

## Validation

```javascript
// VALIDATE_SYNC_PATTERN
function validateTasksSync(specFolder) {
  const markdownPath = `${specFolder}/tasks.md`;
  const jsonPath = `${specFolder}/tasks.json`;

  const markdownContent = readFileSync(markdownPath, 'utf8');
  const parsedFromMd = parseTasksMarkdown(markdownContent);
  const jsonContent = JSON.parse(readFileSync(jsonPath, 'utf8'));

  const errors = [];

  // Check task count matches
  if (parsedFromMd.length !== jsonContent.tasks.length) {
    errors.push(`Task count mismatch: MD=${parsedFromMd.length}, JSON=${jsonContent.tasks.length}`);
  }

  // Check status matches for each task
  for (const mdTask of parsedFromMd) {
    const jsonTask = jsonContent.tasks.find(t => t.id === mdTask.id);
    if (!jsonTask) {
      errors.push(`Task ${mdTask.id} missing from JSON`);
    } else if (mdTask.status !== jsonTask.status) {
      // Allow JSON to have more specific status
      if (!(mdTask.status === 'pending' && jsonTask.status === 'blocked')) {
        errors.push(`Status mismatch for ${mdTask.id}: MD=${mdTask.status}, JSON=${jsonTask.status}`);
      }
    }
  }

  return {
    valid: errors.length === 0,
    errors: errors
  };
}
```

---

## Usage in Commands

Reference these patterns:

```markdown
## Task JSON Sync

Use patterns from @shared/task-json.md:
- Parse markdown: MARKDOWN_TO_JSON_PATTERN
- Sync to JSON: SYNC_TASKS_PATTERN
- Update metadata: UPDATE_TASK_METADATA_PATTERN
- Query status: QUERY_TASKS_PATTERN

Sync triggers:
- After checkbox change in tasks.md
- At session startup (validation)
- After task completion (with metadata)
```
