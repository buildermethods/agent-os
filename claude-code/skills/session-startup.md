---
name: session-startup
description: Auto-invoke at the start of execute-tasks to verify environment, load progress context, and confirm task focus. Ensures cross-session continuity.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - TodoWrite
---

# Session Startup Protocol

## Purpose

Verify environment state and load cross-session context before beginning work. This ensures continuity across agent sessions by reading the persistent progress log.

**Reference**: Based on Anthropic's "Effective Harnesses for Long-Running Agents" research.

---

## When to Invoke

This skill should auto-invoke when:
- `/execute-tasks` command begins (before Phase 1)
- User explicitly requests session context review
- Resuming work after a break

---

## Protocol Steps (6-Step Checklist)

### Step 1: Directory Verification
Confirm working directory is correct project root.

```
ACTION: Run pwd command
VERIFY: Working directory contains .agent-os/ folder
DISPLAY: "Working directory: [path]"

IF .agent-os/ not found:
  WARN: "Not in an Agent OS project. Run from project root."
  HALT: Cannot proceed without Agent OS structure
```

### Step 2: Progress Context Load
Read recent progress entries for cross-session context.

```
ACTION: Read .agent-os/progress/progress.json
EXTRACT: Last 20 entries (or all if fewer)

ANALYZE:
  - Last session's accomplishments
  - Any unresolved blockers (task_blocked without subsequent task_completed)
  - Suggested next steps from last session_ended entry

DISPLAY to user:
  "📋 Progress Context
   ─────────────────────────────────────────
   Last session: [date] - [summary]
   Tasks completed: [list recent task_completed entries]

   ⚠️ Unresolved blockers: [if any]
   - [blocker description]

   Suggested next: [from last entry's next_steps]
   ─────────────────────────────────────────"

IF progress.json not found or empty:
  NOTE: "No previous progress recorded. Starting fresh."
```

### Step 3: Git State Review
Check git status and recent commits for context.

```
ACTION: Run git status
ANALYZE:
  - Current branch name
  - Any uncommitted changes
  - Whether branch matches expected spec branch

ACTION: Run git log --oneline -5
DISPLAY: Recent commits for context

WARN IF:
  - Uncommitted changes detected: "⚠️ Uncommitted changes found. Consider committing or stashing."
  - On wrong branch: "⚠️ Expected branch [X], currently on [Y]"
```

### Step 4: Task Status Check
Load current spec's task status.

```
ACTION: Identify current spec from:
  1. User-provided spec_srd_reference parameter
  2. Progress log's last session spec
  3. Most recently modified tasks.md in .agent-os/tasks/

ACTION: Read .agent-os/tasks/[spec-name]/tasks.md
ANALYZE:
  - Total tasks and subtasks
  - Completed vs incomplete
  - Next incomplete task

DISPLAY:
  "📊 Task Status: [spec-name]
   ─────────────────────────────────────────
   Progress: [X]/[Y] parent tasks complete ([Z]%)

   Next task: [task-id] - [description]
   Subtasks: [list first 3 subtasks]
   ─────────────────────────────────────────"

CALCULATE: progress_percent = (completed / total) * 100
```

### Step 5: Environment Health Check
Verify development environment is ready.

```
ACTION: Check for common dev server ports
COMMAND: lsof -i :3000,5173,8000,8080 2>/dev/null | head -5

IF port conflicts found:
  DISPLAY: "🔌 Dev server detected on port [X]"
  NOTE: Will prompt to handle in execute-tasks Step 5

ACTION: Check for required config files
VERIFY:
  - .agent-os/state/workflow.json exists
  - .agent-os/standards/ directory exists
  - .claude/commands/ directory exists (if Claude Code)

WARN IF missing critical files
```

### Step 6: Session Focus Confirmation
Confirm task selection with user before proceeding.

```
DISPLAY:
  "🎯 Session Focus
   ─────────────────────────────────────────
   Spec: [spec-name]
   Task: [task-id] - [task-description]

   Ready to begin?
   ─────────────────────────────────────────"

OPTIONS:
  1. Proceed with suggested task (default)
  2. Select different task
  3. Review more context first

WAIT: For user confirmation or selection

AFTER confirmation:
  LOG: session_started entry to progress log (Step 6.5 of execute-tasks)
```

---

## Output Summary Format

After completing all steps, provide concise summary:

```
✅ Session Startup Complete
─────────────────────────────────────────────────
Directory: ✓ [project-name]
Progress:  ✓ [X] previous entries loaded
Git:       ✓ On branch [branch-name] | [clean/uncommitted changes]
Tasks:     ✓ [X]/[Y] complete ([Z]%)
Env:       ✓ Ready [or ⚠️ with notes]
Focus:     → Task [id]: [description]
─────────────────────────────────────────────────
```

---

## Error Handling

| Error | Recovery |
|-------|----------|
| progress.json missing | Initialize empty, note "first session" |
| progress.json corrupted | Warn user, initialize fresh |
| Git not initialized | Skip git checks, warn user |
| tasks.md not found | Prompt user for spec path |
| No incomplete tasks | Celebrate completion, suggest next spec |

---

## Integration with execute-tasks

This skill runs BEFORE execute-tasks Phase 1:

```
execute-tasks workflow:
├── [session-startup skill auto-invokes] ← HERE
├── Phase 1: Task Discovery and Setup
│   ├── Step 1: Task Assignment (informed by startup)
│   ├── ...
```

The startup protocol provides context that informs:
- Task selection (Step 1)
- Branch verification (Step 6)
- Progress logging (Step 6.5)

---

## Example Session

```
User: /execute-tasks .agent-os/specs/auth-feature

[session-startup skill auto-invokes]

✅ Session Startup Complete
─────────────────────────────────────────────────
Directory: ✓ my-project
Progress:  ✓ 12 previous entries loaded
           Last: 2025-12-07 - Completed Task 1.2 (JWT validation)
Git:       ✓ On branch auth-feature | clean
Tasks:     ✓ 2/5 complete (40%)
Env:       ✓ Ready
Focus:     → Task 1.3: Implement session management
─────────────────────────────────────────────────

Proceeding with execute-tasks Phase 1...
```
