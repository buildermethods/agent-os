# Debug

## Quick Navigation
- [Description](#description)
- [Parameters](#parameters)
- [Dependencies](#dependencies)
- [Task Tracking](#task-tracking)
- [Core Instructions](#core-instructions)
- [State Management](#state-management)
- [Error Handling](#error-handling)
- [Subagent Integration](#subagent-integration)

## Description
Debug and fix issues with automatic context detection for the appropriate scope (general, task, or spec scope). This unified debugging command intelligently determines the debugging context and applies scope-appropriate investigation and resolution strategies.

## Parameters
- `issue_description` (optional): Description of the issue to debug
- `scope_hint` (optional): "task", "spec", or "general" to hint at debugging scope
- `reproduction_steps` (optional): Array of steps to reproduce the issue

## Dependencies
**Required State Files:**
- `.agent-os/tasks/[spec-name]/tasks.md` (conditional - for task/spec context detection)
- `.agent-os/specs/[spec-name]/technical-spec.md` (conditional - for task/spec requirements)

**Expected Directories:**
- `.agent-os/debugging/` (created for debug documentation)
- `.agent-os/tasks/` (conditional - for active spec detection)

**Creates Directories:**
- `.agent-os/debugging/tasks/` (task-specific debug reports)
- `.agent-os/debugging/specs/` (spec-specific debug reports)
- `.agent-os/debugging/` (general debug reports)

**Creates Files:**
- `.agent-os/debugging/[timestamp]-[issue].md` (debug report based on scope)

## Task Tracking
**IMPORTANT: Use Claude's TodoWrite tool throughout execution:**
```javascript
// Example todos for this command workflow
const todos = [
  { content: "Detect debugging context and scope", status: "pending", activeForm: "Detecting debugging context and scope" },
  { content: "Gather issue information", status: "pending", activeForm: "Gathering issue information" },
  { content: "Conduct targeted investigation", status: "pending", activeForm: "Conducting targeted investigation" },
  { content: "Reproduce the issue", status: "pending", activeForm: "Reproducing the issue" },
  { content: "Implement context-aware fix", status: "pending", activeForm: "Implementing context-aware fix" },
  { content: "Verify fix with scoped tests", status: "pending", activeForm: "Verifying fix with scoped tests" },
  { content: "Update codebase references if needed", status: "pending", activeForm: "Updating codebase references if needed" },
  { content: "Update project status", status: "pending", activeForm: "Updating project status" },
  { content: "Create debug documentation", status: "pending", activeForm: "Creating debug documentation" },
  { content: "Complete git workflow", status: "pending", activeForm: "Completing git workflow" }
];
// Update status to "in_progress" when starting each task
// Mark as "completed" immediately after finishing
```

## For Claude Code
When executing this command:
1. **Initialize TodoWrite** with the workflow steps above for visibility
2. Automatically detect debugging context (task/spec/general)
3. Use Task tool to invoke subagents as specified
4. Apply scope-appropriate investigation and resolution strategies
5. **Update TodoWrite** status throughout execution
6. Create contextual documentation and commit messages

---

## SECTION: Core Instructions
<!-- BEGIN EMBEDDED CONTENT -->

# Debug Rules

## Overview

Intelligently debug and fix issues with automatic context detection for the appropriate scope (task, spec, or general).

## Process Flow

### Step 1: Context Detection

Automatically determine the debugging context based on the current situation.

**Context Analysis:**

**Check for Active Spec:**
```
IF .agent-os/tasks/[spec-name]/tasks.md exists AND has incomplete tasks:
  SET context = "spec_implementation"
  NOTE current_spec_name
  CHECK which_tasks_affected
```

**Check Issue Scope:**
```
IF context == "spec_implementation":
  IF issue affects single task:
    SET scope = "task"
    NOTE task_number and description
  ELSE IF issue affects multiple tasks OR integration:
    SET scope = "spec"
    NOTE all affected tasks
ELSE:
  SET scope = "general"
  NOTE this is production or standalone debugging
```

**User Clarification:**
```
IF context_unclear:
  ASK: "Are you debugging:
        1. An issue during spec/task implementation?
        2. A general bug or production issue?
        3. An integration issue across multiple tasks?"
  WAIT for response
  SET appropriate context
```

**Instructions:**
- ACTION: Detect debugging context automatically
- IDENTIFY: Whether in spec implementation or general debugging
- DETERMINE: Appropriate scope (task, spec, or general)
- PROCEED: With context-appropriate workflow

### Step 2: Issue Information Gathering

Gather issue details appropriate to the detected context.

**Task Context Gathering:**
```
IF scope == "task":
  READ: .agent-os/tasks/[spec]/tasks.md for task details
  READ: .agent-os/specs/[spec]/technical-spec.md for requirements
  IDENTIFY: Current task implementation status
  NOTE: Specific subtask if applicable
```

**Spec Context Gathering:**
```
IF scope == "spec":
  READ: Complete spec documentation
  ANALYZE: All task statuses in tasks.md
  IDENTIFY: Integration points between tasks
  MAP: Cross-task dependencies
```

**General Gathering:**
```
IF scope == "general":
  GATHER:
    - Error messages or unexpected behavior
    - Steps to reproduce
    - Expected vs actual behavior
    - When issue started
    - Recent changes
```

**Instructions:**
- ACTION: Gather context-appropriate information
- LOAD: Relevant documentation based on scope
- DOCUMENT: Issue details and affected areas

### Step 3: Targeted Investigation

Use the debug-helper subagent to investigate based on detected scope.

**Investigation Approach:**

**Task Investigation:**
```
IF scope == "task":
  FOCUS: Task-specific code and tests
  CHECK: Task requirements alignment
  VERIFY: Subtask implementations
  REVIEW: Task-level integration
```

**Spec Investigation:**
```
IF scope == "spec":
  FOCUS: Cross-task integration
  RUN: All spec-related tests
  CHECK: Data flow between tasks
  VERIFY: End-to-end functionality
```

**General Investigation:**
```
IF scope == "general":
  FOCUS: Broad system analysis
  CHECK: Recent commits and changes
  REVIEW: Error logs and traces
  ANALYZE: System-wide impacts
```

**Instructions:**
```
ACTION: Use debug-helper subagent
REQUEST: "Investigate [SCOPE] issue: [DESCRIPTION]
          Context: [RELEVANT_CONTEXT]
          Focus: [SCOPE_SPECIFIC_AREAS]"
ANALYZE: Returned findings
IDENTIFY: Root cause
```

### Step 4: Issue Reproduction

Attempt to reproduce the issue with scope-appropriate methods.

**Reproduction Methods:**

**Task Reproduction:**
```
IF scope == "task":
  - Run task-specific tests
  - Execute subtask code
  - Verify against task requirements
```

**Spec Reproduction:**
```
IF scope == "spec":
  - Run integration tests
  - Execute end-to-end scenarios
  - Test task interactions
```

**General Reproduction:**
```
IF scope == "general":
  - Follow user-provided steps
  - Create minimal test case
  - Isolate problem area
```

**Instructions:**
- ACTION: Reproduce issue using appropriate method
- DOCUMENT: Exact reproduction steps
- CAPTURE: All error output
- CONFIRM: Issue is reproducible

### Step 5: Context-Aware Fix Implementation

Implement fix with appropriate scope constraints.

**Fix Constraints:**

**Task Fix:**
```
IF scope == "task":
  - Stay within task boundaries
  - Maintain spec requirements
  - Update task tests
  - Preserve other task work
```

**Spec Fix:**
```
IF scope == "spec":
  - Fix integration issues first
  - Update multiple tasks if needed
  - Maintain architectural consistency
  - Verify all task interactions
```

**General Fix:**
```
IF scope == "general":
  - Apply minimal necessary changes
  - Consider system-wide impacts
  - Add regression tests
  - Update documentation
```

**Implementation:**
1. Write test for bug (if missing)
2. Implement fix at appropriate scope
3. Verify tests pass
4. Check for side effects
5. Refactor if needed

**Instructions:**
- ACTION: Implement fix within scope constraints
- ENSURE: Fix addresses root cause
- MAINTAIN: Appropriate boundaries
- VERIFY: No regressions introduced

### Step 6: Scoped Test Verification

Use the test-runner subagent to verify fix at appropriate level.

**Test Scope:**

**Task Tests:**
```
IF scope == "task":
  RUN: Task-specific tests
  VERIFY: Subtask functionality
  CHECK: Task integration points
```

**Spec Tests:**
```
IF scope == "spec":
  RUN: All spec tests
  VERIFY: Integration tests
  CHECK: End-to-end scenarios
```

**General Tests:**
```
IF scope == "general":
  RUN: Affected area tests
  VERIFY: Regression suite
  CHECK: System stability
```

**Instructions:**
```
ACTION: Use test-runner subagent
REQUEST: "Run [SCOPE] tests for debugging fix"
VERIFY: All relevant tests pass
CONFIRM: Issue resolved
```

### Step 7: Context-Appropriate Status Updates

Update project status based on debugging scope.

**Task Updates:**
```
IF scope == "task":
  UPDATE: Task status in tasks.md
  ADD: Debug note to task
  REMOVE: Any blocking indicators
  NOTE: Fix applied
```

**Spec Updates:**
```
IF scope == "spec":
  UPDATE: All affected tasks in tasks.md
  DOCUMENT: Integration fixes
  NOTE: Cross-task resolutions
  UPDATE: Spec documentation if needed
```

**General Updates:**
```
IF scope == "general":
  DOCUMENT: Fix in appropriate location
  UPDATE: Changelog if exists
  NOTE: System changes made
```

**Instructions:**
- ACTION: Update status appropriately
- DOCUMENT: Debug work completed
- MAINTAIN: Project consistency

### Step 8: Create Debug Documentation

Use the file-creator subagent to document debugging based on scope.

**Documentation Paths:**

**Task Documentation:**
```
IF scope == "task":
  PATH: .agent-os/debugging/tasks/[SPEC]-[TASK]-[TIMESTAMP].md
  INCLUDE: Task context, issue, fix
```

**Spec Documentation:**
```
IF scope == "spec":
  PATH: .agent-os/debugging/specs/[SPEC]-[TIMESTAMP].md
  INCLUDE: Integration issues, cross-task fixes
```

**General Documentation:**
```
IF scope == "general":
  PATH: .agent-os/debugging/[TIMESTAMP]-[ISSUE].md
  INCLUDE: Full investigation and fix
```

**Report Content:**
```markdown
# Debug Report

**Scope:** [task/spec/general]
**Context:** [Implementation/Production]
**Date:** [TIMESTAMP]

## Issue
[Description of the problem]

## Root Cause
[Why it happened]

## Fix Applied
[What was changed]

## Verification
[How we verified the fix]

## Prevention
[How to avoid similar issues]
```

**Instructions:**
```
ACTION: Use file-creator subagent
CREATE: Debug report at appropriate path
INCLUDE: Context-relevant information
FOCUS: Lessons learned and prevention
```

### Step 9: Update Codebase References (Conditional)

If any new functions, classes, or exports were created or modified during debugging, update the codebase references.

**Smart Update Check:**
```
CHECK: Git diff for code changes
IF only debug documentation changed:
  SKIP: No code to index
ELSE IF new functions/classes added OR signatures changed:
  ACTION: Use codebase-indexer subagent
  REQUEST: "Update codebase references for debug fixes:
            - Files modified: [LIST_OF_MODIFIED_FILES]
            - Extract new/updated signatures
            - Update functions.md and imports.md
            - Focus on fix-related changes"
ELSE:
  SKIP: No significant code structure changes
```

**Instructions:**
```
ACTION: Check if .agent-os/codebase/ exists
IF exists AND code was modified:
  USE: codebase-indexer for incremental update
  UPDATE: Only changed file references
  PRESERVE: Existing unchanged references
ELSE:
  SKIP: No reference updates needed
```

### Step 10: Complete Git Workflow

Use the git-workflow subagent to commit, push, and optionally create a PR for the debug fix.

**Workflow Decision:**
```
IF scope == "task" OR scope == "spec":
  # Part of active implementation
  ACTION: Commit to current feature branch
  NO_PR: Continue with implementation
ELSE IF scope == "general":
  # Standalone fix
  ACTION: Create dedicated fix branch
  CREATE_PR: For review and merge
```

**Commit Message Format:**

**Task Commit:**
```
IF scope == "task":
  fix: [spec] resolve [issue] in task [number]
  
  - Fixed: [brief description]
  - Cause: [root cause]
  - Impact: Task [number] now functioning correctly
```

**Spec Commit:**
```
IF scope == "spec":
  fix: [spec] resolve integration issues
  
  - Fixed: [brief description]
  - Affected tasks: [list of task numbers]
  - Integration points corrected
```

**General Commit:**
```
IF scope == "general":
  fix: resolve [issue description]
  
  - Fixed: [brief description]
  - Root cause: [explanation]
  - Prevented similar issues by: [prevention measures]
```

**Instructions:**
```
ACTION: Use git-workflow subagent via Task tool
REQUEST: "Complete git workflow for debug fix:
          - Scope: [task/spec/general]
          - Changes: All modified files
          - Commit message: [formatted as above]
          - Branch strategy: [current/new based on scope]
          - PR creation: [yes/no based on scope]"
SAVE: PR URL if created for documentation
```

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

### State Operations
All debugging uses context-aware state management with scope preservation:

```javascript
// Detect debugging context
const debugContext = detectDebuggingContext();
const debugState = {
  context: debugContext.type, // 'spec_implementation' or 'general'
  scope: debugContext.scope,  // 'task', 'spec', or 'general'
  spec_name: debugContext.specName,
  task_number: debugContext.taskNumber,
  issue_details: {},
  investigation_results: {},
  fix_applied: false,
  tests_verified: false
};

// Context-specific state management
if (debugState.scope === 'task') {
  debugState.task_context = loadTaskContext(debugState.spec_name, debugState.task_number);
} else if (debugState.scope === 'spec') {
  debugState.spec_context = loadSpecContext(debugState.spec_name);
}

// Track debugging progress
debugState.steps_completed = [];
debugState.current_step = null;
debugState.errors_encountered = [];
```

### Context Detection Logic
- Scan for active spec implementations in .agent-os/tasks/
- Check task completion status and identify blocking issues
- Determine scope based on issue impact (single task vs multiple tasks vs system-wide)
- Preserve context information throughout debugging workflow

---

## SECTION: Error Handling

### Error Recovery Procedures

1. **Context Detection Failures**:
   - Fall back to general debugging scope
   - Prompt user for context clarification
   - Continue with available context information
   - Document context limitations in debug report

2. **Issue Reproduction Failures**:
   - Document reproduction attempts and failures
   - Continue with available error information
   - Use alternative investigation methods
   - Note reproduction limitations in final report

3. **Fix Implementation Failures**:
   - Roll back partial changes
   - Document what was attempted
   - Preserve debugging state for retry
   - Suggest manual intervention points

4. **Test Verification Failures**:
   - Identify which tests failed after fix
   - Determine if fix introduced regressions
   - Provide rollback instructions
   - Document incomplete resolution status

5. **Documentation Creation Failures**:
   - Use fallback documentation format
   - Store debug information in temporary files
   - Allow manual documentation completion
   - Preserve investigation results for reference

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- `test-runner` for running scope-appropriate test verification
- `codebase-indexer` for updating code references after fixes
- `file-creator` for creating debug documentation with proper context paths
- `git-workflow` for complete git workflow including commits, pushes, and PRs