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
  { content: "Get current date for timestamps", status: "pending", activeForm: "Getting current date for timestamps" },
  { content: "Gather issue information", status: "pending", activeForm: "Gathering issue information" },
  { content: "Conduct targeted investigation", status: "pending", activeForm: "Conducting targeted investigation" },
  { content: "Reproduce the issue", status: "pending", activeForm: "Reproducing the issue" },
  { content: "Implement context-aware fix", status: "pending", activeForm: "Implementing context-aware fix" },
  { content: "Verify fix with scoped tests", status: "pending", activeForm: "Verifying fix with scoped tests" },
  { content: "Update codebase references if needed", status: "pending", activeForm: "Updating codebase references if needed" },
  { content: "Update project status", status: "pending", activeForm: "Updating project status" },
  { content: "Create debug documentation", status: "pending", activeForm: "Creating debug documentation" },
  { content: "Verify build and diagnostics", status: "pending", activeForm: "Verifying build and diagnostics" },
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

### Step 2: Get Current Date and Time

Use the current date from the environment context for timestamps in debug reports.

**Instructions:**
```
ACTION: Get today's date from environment context
NOTE: Claude Code provides "Today's date: YYYY-MM-DD" in every session
STORE: Date for use in debug report generation
```

### Step 3: Issue Information Gathering

Gather issue details appropriate to the detected context.

**Task Context Gathering:**
```
IF scope == "task":
  READ: .agent-os/tasks/[spec]/tasks.md for task details
  READ: .agent-os/specs/[spec]/technical-spec.md for requirements
  CHECK: .agent-os/specs/[spec]/sub-specs/content-mapping.md (if exists)
  IDENTIFY: Current task implementation status
  NOTE: Specific subtask if applicable
```

**Spec Context Gathering:**
```
IF scope == "spec":
  READ: Complete spec documentation
  ANALYZE: All task statuses in tasks.md
  CHECK: .agent-os/specs/[spec]/sub-specs/content-mapping.md (if exists)
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

**Content Reference Gathering (Conditional):**
```
IF scope == "task" OR scope == "spec":
  CHECK: .agent-os/specs/[SPEC]/sub-specs/content-mapping.md

  IF exists AND issue_involves_files:
    READ: Content mapping
    NOTE: Expected file paths and reference names
    PURPOSE: Verify actual paths match content-mapping expectations
```

**Instructions:**
- ACTION: Gather context-appropriate information
- LOAD: Relevant documentation based on scope
- CHECK: Content mapping if debugging file/content issues
- DOCUMENT: Issue details and affected areas

### Step 4: Targeted Investigation (systematic-debugging skill)

The systematic-debugging skill auto-invokes to enforce root cause analysis before attempting fixes.

**Core Principle:** NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST

**Systematic Investigation Phases:**

**Phase 1: Root Cause Investigation**
```
ACTION: systematic-debugging skill auto-invokes
WORKFLOW:
  1. Read complete error messages and stack traces
  2. Reproduce issue consistently
  3. Check recent changes (git log, git diff)
  4. Trace data flow from source to error point
```

**Phase 2: Pattern Analysis**
```
SEARCH: Find working examples in codebase
COMPARE: Working vs broken code
IDENTIFY: Key differences (config, types, dependencies, timing)
```

**Phase 3: Hypothesis Formation**
```
FORMAT: "The error occurs because [specific cause] which leads to [observed behavior]"
TEST: Change ONE variable at a time
VERIFY: Each test confirms or refutes hypothesis
```

**Scope-Specific Focus:**

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

**Escalation Protocol:**
```
IF 3+ fix attempts have failed:
  STOP - Do not attempt another fix
  ASK:
    1. Am I treating a symptom instead of the cause?
    2. Is there an architectural problem?
    3. Do I need to step back and re-examine assumptions?
  EVIDENCE: Multiple failed fixes indicate deeper problem
```

**Instructions:**
```
ACTION: Use systematic-debugging skill
OUTPUT: Root cause analysis with evidence
REQUIRE: Identified root cause BEFORE proceeding to fix
```

### Step 4.1: Systematic-Debugging Skill Invocation Gate (MANDATORY)

**VALIDATION CHECKPOINT - Verify systematic-debugging skill was properly invoked:**

```
GATE CHECK: Before attempting any fix
─────────────────────────────────────────────────
VERIFY the following evidence exists:

☐ Phase 1 - Root Cause Investigation Evidence:
  - Complete error messages and stack traces read
  - Issue reproduced at least once
  - Recent changes reviewed (git log/diff)
  - Data flow traced from source to error point

☐ Phase 2 - Pattern Analysis Evidence:
  - Working examples found in codebase
  - Comparison between working vs broken code documented
  - Key differences identified (config, types, dependencies, timing)

☐ Phase 3 - Hypothesis Formation Evidence:
  - Root cause hypothesis stated in format:
    "The error occurs because [specific cause] which leads to [observed behavior]"
  - At least one test performed to validate hypothesis
  - Hypothesis confirmed or alternative identified

☐ Root Cause Statement:
  - Clear, specific root cause identified (not symptoms)
  - Evidence supporting the root cause documented
  - Confidence level noted (high/medium/low)

VALIDATION:
  IF all checkboxes verified:
    ✓ Systematic debugging complete - PROCEED to fix
  ELSE IF missing root cause:
    ✗ HALT - Do NOT attempt fix without root cause
    ACTION: Return to Phase 1, complete investigation
  ELSE IF hypothesis untested:
    ⚠ WARNING - Test hypothesis before proceeding
    ACTION: Run at least one confirming test
─────────────────────────────────────────────────
```

**Debugging Gate Failure Recovery:**
```
IF systematic-debugging gate fails:
  1. STOP: Do not attempt any fixes
  2. IDENTIFY: Which phase is incomplete
  3. EXECUTE: Missing investigation steps
  4. DOCUMENT: Findings at each phase
  5. RE-VERIFY: Run gate check again

ESCALATION (after 3+ failed fix attempts):
  STOP IMMEDIATELY
  ASK:
    1. Am I treating a symptom instead of the cause?
    2. Is there an architectural problem?
    3. Do I need to step back and re-examine assumptions?
  NOTE: Multiple failed fixes = incomplete root cause analysis
```

### Step 5: Issue Reproduction

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

### Step 5.5: Verify Existing Names (MANDATORY Before Fix Implementation)

Before implementing any code changes, verify existing function/variable/component names to prevent introducing naming errors during the fix.

**Name Verification Check:**
```
ACTION: Check if .agent-os/codebase/ exists
IF exists AND fix involves modifying existing code:
  MANDATORY: Retrieve existing names via codebase-names skill
  REASON: Prevents incorrect names in debug fixes
ELSE:
  SKIP: Name verification (new code or no index)
```

**Retrieve Existing Names:**
```
IF name verification required:
  ACTION: Use codebase-names skill via Task tool
  REQUEST: "Retrieve codebase references for debug fix:

    FROM .agent-os/codebase/:
    - Function signatures in files to be modified: [FILE_LIST]
    - Import paths for components/utilities referenced
    - Existing variable/class names in target modules
    - Related schemas if data operations involved

    RETURN as 'Existing Names Reference' with:
    - Exact function names with signatures and line numbers
    - Exact import paths with component names
    - Exact variable/class names with types"
```

**Retrieve Content References (if content-related fix):**
```
IF content-mapping.md exists AND fix_involves_content:
  ACTION: Use codebase-names skill via Task tool
  REQUEST: "Retrieve content references for debug fix:

    FROM .agent-os/specs/[SPEC]/sub-specs/content-mapping.md:
    - File paths for content items related to fix
    - Reference names to use in code
    - Implementation guidelines
    - Validation rules

    RETURN as 'Content References' with:
    - Exact file paths relative to project root
    - Exact reference names for imports
    - Import patterns from guidelines"
```

**Create Reference Sheet:**
```
IF names retrieved:
  EXTRACT AND NOTE:
  1. Functions to call (exact spelling, casing, parameters)
  2. Components to import (exact paths and names)
  3. Variables to reference (exact names and types)
  4. Schemas to use (exact table/column names)

  VALIDATION GATE:
  - ✓ Do NOT guess names during fix
  - ✓ Do NOT write code until names verified
  - ✓ Use exact names from reference sheet
  - HALT if critical names missing
```

**Create Content Reference Sheet:**
```
IF content references retrieved:
  EXTRACT AND NOTE:
  1. File paths (exact, relative to project root)
  2. Reference names to use in imports
  3. Import patterns from implementation guidelines
  4. Content types and validation rules

  VALIDATION GATE:
  - ✓ Do NOT guess file paths during fix
  - ✓ Do NOT write code until paths verified
  - ✓ Use exact reference names from content-mapping
  - HALT if critical content paths missing
```

**Example Reference Sheet:**
```markdown
## Names to Use in Debug Fix

Functions (from src/auth/service.js):
- authenticateUser(email, password): Promise<User> ::line:23
- validateSession(token): boolean ::line:45

Imports:
- import { logger } from '@/utils/logger'
- import { AuthError } from '@/errors/auth'

Variables (in src/auth/service.js):
- currentSession: Session | null
- authConfig: AuthConfig

USE THESE EXACT NAMES IN FIX
```

### Step 6: Context-Aware Fix Implementation

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

### Step 7: Scoped Test Verification

The test-check skill auto-invokes to verify fix at appropriate level.

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
ACTION: test-check skill auto-invokes
REQUEST: "Run [SCOPE] tests for debugging fix"
VERIFY: All relevant tests pass
CONFIRM: Issue resolved
```

### Step 8: Context-Appropriate Status Updates

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

### Step 9: Create Debug Documentation

Create debug documentation based on scope using the Write tool.

**Documentation Paths:**

**Task Documentation:**
```
IF scope == "task":
  PATH: .agent-os/debugging/tasks/[SPEC]-[TASK]-[CURRENT_DATE from environment].md
  INCLUDE: Task context, issue, fix
```

**Spec Documentation:**
```
IF scope == "spec":
  PATH: .agent-os/debugging/specs/[SPEC]-[CURRENT_DATE from environment].md
  INCLUDE: Integration issues, cross-task fixes
```

**General Documentation:**
```
IF scope == "general":
  PATH: .agent-os/debugging/[CURRENT_DATE from environment]-[ISSUE].md
  INCLUDE: Full investigation and fix
```

**Report Content:**
```markdown
# Debug Report

**Scope:** [task/spec/general]
**Context:** [Implementation/Production]
**Date:** [CURRENT_DATE from environment]

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
ACTION: Create file using Write tool
CREATE: Debug report at appropriate path
INCLUDE: Context-relevant information
FOCUS: Lessons learned and prevention
```

### Step 10: Update Codebase References (Conditional)

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

### Step 10.5: Build Verification and Diagnostics Check

Use the build-checker subagent to verify build status and check for type/lint errors before committing the debug fix.

**Instructions:**
```
ACTION: Get list of modified files from git
COMMAND: git diff --name-only [BASE_BRANCH]...HEAD

ACTION: Determine context for build check
IF scope == "task" OR scope == "spec":
  READ: .agent-os/tasks/[SPEC_FOLDER]/tasks.md
  EXTRACT: Remaining uncompleted tasks
  CONTEXT: spec
ELSE:
  CONTEXT: general
  FUTURE_TASKS: none (standalone fix)

ACTION: Use build-checker subagent via Task tool
REQUEST: "Check build status before commit for debug fix:
          - Context: [task/spec/general based on scope]
          - Modified files: [LIST_OF_MODIFIED_FILES]
          - Current fix: [DEBUG_FIX_DESCRIPTION]
          - Spec path: [SPEC_FOLDER_PATH if applicable]
          - Future tasks: [REMAINING_TASKS if applicable]"

ANALYZE: Returned decision (COMMIT | FIX_REQUIRED | DOCUMENT_AND_COMMIT)
```

**Decision Handling:**

**FIX_REQUIRED:**
```
IF decision == "FIX_REQUIRED":
  DISPLAY: List of must-fix errors to user
  ACTION: Fix each error (additional debugging)
  VERIFY: Re-run build-checker until COMMIT decision
  THEN: Proceed to git workflow
```

**DOCUMENT_AND_COMMIT:**
```
IF decision == "DOCUMENT_AND_COMMIT":
  DISPLAY: Acceptable errors and reasoning
  SAVE: Commit message addendum for git workflow
  NOTE: These errors will be fixed by future tasks (if task/spec scope)
  PROCEED: To git workflow with enhanced commit message
```

**COMMIT:**
```
IF decision == "COMMIT":
  NOTE: All checks passed
  PROCEED: To git workflow
```

**Build Check Benefits for Debugging:**
- Ensures debug fixes don't introduce new type/lint errors
- Prevents fixes from causing breaking changes
- Verifies that the fix is complete and doesn't require additional work
- Documents any acceptable build issues if debugging within active spec
- Provides confidence that the fix is production-ready

### Step 11: Complete Git Workflow

Use the git-workflow subagent to commit, push, and optionally create a PR for the debug fix.

**MANDATORY Git Strategy:**

The workflow is **automatic based on scope** - no user confirmation needed:

```
IF scope == "task" OR scope == "spec":
  # Debugging during active feature work
  BRANCH: Stay on current feature branch
  COMMIT: Add fix to existing branch
  PUSH: Push to existing feature branch
  PR: NO - fix will be included in feature PR
  REASON: Part of ongoing implementation work

ELSE IF scope == "general":
  # Standalone bug fix (production, hotfix, general issue)
  BRANCH: Create new fix branch (REQUIRED - NOT OPTIONAL)
  BRANCH_NAME: "fix/[brief-description]" (or "hotfix/[brief-description]" for critical issues)
  COMMIT: Add fix to new branch
  PUSH: Push new branch to remote (REQUIRED)
  PR: YES - Create pull request (REQUIRED - NOT OPTIONAL)
  REASON: Standalone fix needs code review

  ⚠️ NEVER commit directly to main/master for general scope
```

**Branch Naming Convention:**
- General fixes: `fix/[issue-description]` (e.g., fix/session-timeout)
- Critical production: `hotfix/[issue-description]` (e.g., hotfix/payment-error)
- Security issues: `security/[issue-description]` (e.g., security/xss-vulnerability)

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
          - Commit addendum: [BUILD_CHECK_ADDENDUM if any from Step 10.5]

          **MANDATORY Git Strategy:**
          IF scope is 'general':
            1. Create new branch named: fix/[brief-description]
            2. Commit changes to new branch
            3. Push new branch to remote
            4. Create pull request (REQUIRED)
            5. Use PR template for debug fixes
            6. NEVER commit directly to main/master
          ELSE IF scope is 'task' or 'spec':
            1. Commit to current feature branch
            2. Push to current branch
            3. Do NOT create PR (fix part of feature work)"
SAVE: PR URL if created for documentation
```

**PR Template for Debug Fixes:**
When creating PR for general scope, use this structure:
```markdown
## Debug Fix: [Issue Summary]

**Scope:** general
**Issue:** [What was broken]
**Root Cause:** [Why it happened]
**Solution:** [What was changed]

**Testing:**
- [How fix was verified]

**Files Changed:**
[Auto-populated by PR]
```

**Commit Message Enhancement:**
If Step 10.5 returned DOCUMENT_AND_COMMIT, append the build check addendum to the commit message to document expected errors and their resolution plan.

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

Use patterns from @shared/state-patterns.md:
- State writes: ATOMIC_WRITE_PATTERN
- State loads: STATE_LOAD_PATTERN

**Debug-specific state:**
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

**Context detection:** Scan .agent-os/tasks/ for active specs, determine scope by issue impact.

---

## SECTION: Error Handling

See @shared/error-recovery.md for general recovery procedures.

### Debug-Specific Error Handling

| Error | Recovery |
|-------|----------|
| Context detection failure | Fall back to "general" scope, ask user |
| Issue reproduction failure | Document attempts, continue with available info |
| Fix implementation failure | Roll back partial changes, preserve debug state |
| Test verification failure | Identify regressions, provide rollback instructions |
| Documentation creation failure | Use fallback format, preserve investigation results |

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- `codebase-names` skill (auto-invoked) for validating existing function/variable names before implementing fixes
- `test-check` skill (auto-invoked) for running test verification
- Use `build-check` skill (auto-invoked) for build verification before commits
- `codebase-indexer` for updating code references after fixes
- `git-workflow` for complete git workflow including commits, pushes, and PRs