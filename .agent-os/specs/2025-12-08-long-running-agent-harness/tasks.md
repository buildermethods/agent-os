# Tasks: Long-Running Agent Harness Improvements

**Spec**: `.agent-os/specs/2025-12-08-long-running-agent-harness/`
**Created**: 2025-12-08
**Status**: Ready for execution

---

## Task 1: Implement Progress Log System

**Goal**: Create persistent progress logging that survives across unlimited sessions

### Subtasks

- [ ] 1.1 Create progress directory structure
  - Create `.agent-os/progress/` directory
  - Create `.agent-os/progress/archive/` for old entries
  - Add to `.gitignore` patterns as needed

- [ ] 1.2 Implement progress.json schema and operations
  - Define JSON schema for progress entries
  - Implement atomic append operation
  - Implement archive operation for entries >30 days
  - Add schema validation

- [ ] 1.3 Implement progress.md generator
  - Create markdown renderer from JSON source
  - Format with date headers and entry types
  - Ensure human-readable output

- [ ] 1.4 Create progress logging utilities
  - `logSessionStart(spec, focusTask, context)`
  - `logTaskCompleted(spec, taskId, duration, notes)`
  - `logBlocker(spec, taskId, issue)`
  - `logSessionEnd(summary, nextSteps)`

- [ ] 1.5 Write tests for progress log operations
  - Test append atomicity
  - Test archive threshold
  - Test JSON/Markdown sync
  - Test entry validation

---

## Task 2: Implement Session Startup Protocol

**Goal**: Create explicit 6-step environment verification at session start

### Subtasks

- [ ] 2.1 Create session-startup skill file
  - Create `claude-code/skills/session-startup.md`
  - Define YAML frontmatter (name, description, allowed-tools)
  - Document auto-invoke trigger

- [ ] 2.2 Implement Step 1-2: Directory and Progress verification
  - Verify working directory
  - Read last 20 progress entries
  - Display summary to user

- [ ] 2.3 Implement Step 3-4: Git and Task status checks
  - Check git status and recent commits
  - Identify uncommitted changes
  - Load current spec's tasks.md
  - Calculate progress percentage

- [ ] 2.4 Implement Step 5-6: Environment and Focus confirmation
  - Check for dev server conflicts
  - Present task selection
  - Log session_started entry

- [ ] 2.5 Integrate with execute-tasks command
  - Add startup protocol invocation to Phase 1
  - Ensure protocol runs before task assignment
  - Handle protocol failures gracefully

- [ ] 2.6 Write tests for startup protocol
  - Test each verification step
  - Test failure handling
  - Test progress log integration

---

## Task 3: Implement Scope Constraint Logic

**Goal**: Add guardrails to encourage single-task focus per session

### Subtasks

- [ ] 3.1 Add scope detection to execute-tasks
  - Count requested parent tasks
  - Detect multi-task scenarios

- [ ] 3.2 Implement scope warning display
  - Create warning message format
  - Display research-backed recommendation
  - Present options to user

- [ ] 3.3 Implement scope override handling
  - Handle user's single-task choice
  - Handle user's override choice
  - Log override to progress log

- [ ] 3.4 Update execute-tasks.md command
  - Add constraint logic to Step 1
  - Document new behavior
  - Update task tracking examples

- [ ] 3.5 Write tests for scope constraints
  - Test single-task pass-through
  - Test multi-task warning trigger
  - Test override logging

---

## Task 4: Implement JSON Task Format

**Goal**: Add machine-readable task tracking alongside markdown

### Subtasks

- [ ] 4.1 Define tasks.json schema
  - Create JSON schema file
  - Document all fields and types
  - Define status enum values

- [ ] 4.2 Implement markdown-to-JSON parser
  - Parse checkbox syntax `- [x]` / `- [ ]`
  - Extract task IDs and descriptions
  - Handle parent/subtask hierarchy

- [ ] 4.3 Implement JSON generator
  - Generate tasks.json from tasks.md
  - Preserve metadata (attempts, timestamps)
  - Calculate summary statistics

- [ ] 4.4 Add sync triggers to execute-tasks
  - Sync after task status change
  - Sync on session startup
  - Validate consistency

- [ ] 4.5 Update create-tasks command
  - Generate tasks.json alongside tasks.md
  - Initialize with proper structure

- [ ] 4.6 Write tests for JSON task format
  - Test parser accuracy
  - Test sync consistency
  - Test schema validation

---

## Task 5: Integration Testing

**Goal**: Validate all components work together correctly

### Subtasks

- [ ] 5.1 Create multi-session test scenario
  - Session 1: Start task, partial completion
  - Session 2: Resume, verify progress context
  - Session 3: Complete, verify full log

- [ ] 5.2 Test scope constraint integration
  - Attempt multi-task with override
  - Verify progress log records override
  - Verify task execution continues

- [ ] 5.3 Test JSON/Markdown synchronization
  - Make changes via execute-tasks
  - Verify both formats updated
  - Test recovery from drift

- [ ] 5.4 Test error recovery
  - Corrupt progress.json, verify recovery
  - Interrupt mid-task, verify state
  - Test archive operation

---

## Task 6: Documentation Updates

**Goal**: Update all documentation to reflect new features

### Subtasks

- [ ] 6.1 Update SYSTEM-OVERVIEW.md
  - Add progress log section
  - Add session startup protocol
  - Document scope constraints
  - Document JSON task format

- [ ] 6.2 Update CLAUDE.md
  - Add progress log location
  - Document new skills
  - Update workflow descriptions

- [ ] 6.3 Update command documentation
  - Update execute-tasks.md inline docs
  - Update create-tasks.md inline docs
  - Add cross-references

- [ ] 6.4 Create CHANGELOG entry
  - Document all new features
  - Note breaking changes (if any)
  - Credit Anthropic research reference

---

## Execution Order

```
Task 1 (Progress Log) ──┬──► Task 2 (Session Startup)
                        │
                        └──► Task 3 (Scope Constraints)
                                      │
Task 4 (JSON Tasks) ◄─────────────────┘
        │
        ▼
Task 5 (Integration) ──► Task 6 (Documentation)
```

**Notes**:
- Task 1 is foundational - other features depend on progress log
- Tasks 2, 3, 4 can be parallelized after Task 1
- Task 5 validates integration of all components
- Task 6 should capture all implemented features
