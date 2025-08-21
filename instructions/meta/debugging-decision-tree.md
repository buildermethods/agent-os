---
description: Decision tree for choosing the appropriate debugging workflow
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Debugging Decision Tree

## Overview

Quick reference guide for choosing the appropriate debugging workflow based on context and issue type.

## Decision Flow

```
Is the issue occurring during spec/task implementation?
├─ YES
│   ├─ Is it specific to a single task?
│   │   ├─ YES → Use @commands/debug-task.md
│   │   └─ NO
│   │       └─ Are multiple tasks affected or integration issues present?
│   │           ├─ YES → Use @commands/debug-spec.md
│   │           └─ NO → Use @commands/debug-issue.md
│   └─ 
└─ NO
    ├─ Is it a regression (previously working)?
    │   ├─ YES → Use @commands/fix-regression.md
    │   └─ NO
    │       ├─ Do you need to fix it immediately?
    │       │   ├─ YES → Use @commands/debug-issue.md
    │       │   └─ NO → Use @commands/investigate-bug.md
    │       └─
    └─
```

## Command Selection Guide

### Use `@commands/debug-task.md` when:
- Debugging during task implementation
- Issue is isolated to a single task
- Tests for that specific task are failing
- Need to maintain task context and update task status

### Use `@commands/debug-spec.md` when:
- Multiple tasks in a spec are affected
- Integration between tasks is broken
- Systemic issues across the spec
- End-to-end tests failing despite unit tests passing

### Use `@commands/debug-issue.md` when:
- General debugging needed (not spec/task specific)
- Production issue or bug report
- Want systematic debugging with immediate fix
- Issue spans multiple specs or is application-wide

### Use `@commands/investigate-bug.md` when:
- Need to analyze without fixing immediately
- Gathering information for later resolution
- Creating documentation for another developer
- Issue is complex and needs thorough investigation

### Use `@commands/fix-regression.md` when:
- Feature was previously working
- Can identify when it last worked
- Need quick restoration of functionality
- Want to use git bisect to find breaking commit

## Integration Points

### During execute-task.md:
- Persistent issues in subtask → debug-task.md
- Test failures after implementation → debug-task.md
- Blocking issues after 3 attempts → debug-task.md or investigate-bug.md

### During execute-tasks.md:
- Multiple tasks experiencing issues → debug-spec.md
- Integration issues detected → debug-spec.md
- Pre-completion verification failures → debug-spec.md

### Standalone Debugging:
- User reports bug → debug-issue.md
- User reports regression → fix-regression.md
- User needs investigation → investigate-bug.md

## Escalation Path

1. **Simple Fix**: Try inline debugging first
2. **Task Issue**: Escalate to debug-task.md
3. **Spec Issue**: Escalate to debug-spec.md
4. **Investigation**: Use investigate-bug.md if can't fix
5. **Documentation**: Create debug report for handoff

## Output Locations

- **Task debugging**: `.agent-os/debugging/tasks/[spec]-[task]-[timestamp].md`
- **Spec debugging**: `.agent-os/debugging/specs/[spec]-[timestamp].md`
- **General debugging**: `.agent-os/debugging/[timestamp]-[issue].md`
- **Investigations**: `.agent-os/debugging/investigations/[timestamp]-[bug].md`
- **Regressions**: `.agent-os/debugging/regressions/[timestamp]-[issue].md`

## Best Practices

1. **Choose the right scope**: Don't use spec-wide debugging for single task issues
2. **Maintain context**: Use task/spec debugging when in implementation flow
3. **Document findings**: All debugging workflows create reports
4. **Update status**: Task/spec debugging updates tasks.md automatically
5. **Prevent recurrence**: Add tests for all bugs found