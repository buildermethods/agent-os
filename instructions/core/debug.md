---
description: Unified Debug Rules for Agent OS
globs:
alwaysApply: false
version: 2.0
encoding: UTF-8
---

# Debug Rules

## Overview

Intelligently debug and fix issues with automatic context detection for the appropriate scope (task, spec, or general).

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="context_detection">

### Step 1: Context Detection

Automatically determine the debugging context based on the current situation.

<context_analysis>
  <check_for_active_spec>
    IF .agent-os/tasks/[spec-name]/tasks.md exists AND has incomplete tasks:
      SET context = "spec_implementation"
      NOTE current_spec_name
      CHECK which_tasks_affected
  </check_for_active_spec>
  
  <check_issue_scope>
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
  </check_issue_scope>
</context_analysis>

<user_clarification>
  IF context_unclear:
    ASK: "Are you debugging:
          1. An issue during spec/task implementation?
          2. A general bug or production issue?
          3. An integration issue across multiple tasks?"
    WAIT for response
    SET appropriate context
</user_clarification>

<instructions>
  ACTION: Detect debugging context automatically
  IDENTIFY: Whether in spec implementation or general debugging
  DETERMINE: Appropriate scope (task, spec, or general)
  PROCEED: With context-appropriate workflow
</instructions>

</step>

<step number="2" name="issue_gathering">

### Step 2: Issue Information Gathering

Gather issue details appropriate to the detected context.

<task_context_gathering>
  IF scope == "task":
    READ: .agent-os/tasks/[spec]/tasks.md for task details
    READ: .agent-os/specs/[spec]/technical-spec.md for requirements
    IDENTIFY: Current task implementation status
    NOTE: Specific subtask if applicable
</task_context_gathering>

<spec_context_gathering>
  IF scope == "spec":
    READ: Complete spec documentation
    ANALYZE: All task statuses in tasks.md
    IDENTIFY: Integration points between tasks
    MAP: Cross-task dependencies
</spec_context_gathering>

<general_gathering>
  IF scope == "general":
    GATHER:
      - Error messages or unexpected behavior
      - Steps to reproduce
      - Expected vs actual behavior
      - When issue started
      - Recent changes
</general_gathering>

<instructions>
  ACTION: Gather context-appropriate information
  LOAD: Relevant documentation based on scope
  DOCUMENT: Issue details and affected areas
</instructions>

</step>

<step number="3" subagent="debug-helper" name="investigation">

### Step 3: Targeted Investigation

Use the debug-helper subagent to investigate based on detected scope.

<investigation_approach>
  <task_investigation>
    IF scope == "task":
      FOCUS: Task-specific code and tests
      CHECK: Task requirements alignment
      VERIFY: Subtask implementations
      REVIEW: Task-level integration
  </task_investigation>
  
  <spec_investigation>
    IF scope == "spec":
      FOCUS: Cross-task integration
      RUN: All spec-related tests
      CHECK: Data flow between tasks
      VERIFY: End-to-end functionality
  </spec_investigation>
  
  <general_investigation>
    IF scope == "general":
      FOCUS: Broad system analysis
      CHECK: Recent commits and changes
      REVIEW: Error logs and traces
      ANALYZE: System-wide impacts
  </general_investigation>
</investigation_approach>

<instructions>
  ACTION: Use debug-helper subagent
  REQUEST: "Investigate [SCOPE] issue: [DESCRIPTION]
            Context: [RELEVANT_CONTEXT]
            Focus: [SCOPE_SPECIFIC_AREAS]"
  ANALYZE: Returned findings
  IDENTIFY: Root cause
</instructions>

</step>

<step number="4" name="reproduction">

### Step 4: Issue Reproduction

Attempt to reproduce the issue with scope-appropriate methods.

<reproduction_methods>
  <task_reproduction>
    IF scope == "task":
      - Run task-specific tests
      - Execute subtask code
      - Verify against task requirements
  </task_reproduction>
  
  <spec_reproduction>
    IF scope == "spec":
      - Run integration tests
      - Execute end-to-end scenarios
      - Test task interactions
  </spec_reproduction>
  
  <general_reproduction>
    IF scope == "general":
      - Follow user-provided steps
      - Create minimal test case
      - Isolate problem area
  </general_reproduction>
</reproduction_methods>

<instructions>
  ACTION: Reproduce issue using appropriate method
  DOCUMENT: Exact reproduction steps
  CAPTURE: All error output
  CONFIRM: Issue is reproducible
</instructions>

</step>

<step number="5" name="fix_implementation">

### Step 5: Context-Aware Fix Implementation

Implement fix with appropriate scope constraints.

<fix_constraints>
  <task_fix>
    IF scope == "task":
      - Stay within task boundaries
      - Maintain spec requirements
      - Update task tests
      - Preserve other task work
  </task_fix>
  
  <spec_fix>
    IF scope == "spec":
      - Fix integration issues first
      - Update multiple tasks if needed
      - Maintain architectural consistency
      - Verify all task interactions
  </spec_fix>
  
  <general_fix>
    IF scope == "general":
      - Apply minimal necessary changes
      - Consider system-wide impacts
      - Add regression tests
      - Update documentation
  </general_fix>
</fix_constraints>

<implementation>
  1. Write test for bug (if missing)
  2. Implement fix at appropriate scope
  3. Verify tests pass
  4. Check for side effects
  5. Refactor if needed
</implementation>

<instructions>
  ACTION: Implement fix within scope constraints
  ENSURE: Fix addresses root cause
  MAINTAIN: Appropriate boundaries
  VERIFY: No regressions introduced
</instructions>

</step>

<step number="6" subagent="test-runner" name="verification">

### Step 6: Scoped Test Verification

Use the test-runner subagent to verify fix at appropriate level.

<test_scope>
  <task_tests>
    IF scope == "task":
      RUN: Task-specific tests
      VERIFY: Subtask functionality
      CHECK: Task integration points
  </task_tests>
  
  <spec_tests>
    IF scope == "spec":
      RUN: All spec tests
      VERIFY: Integration tests
      CHECK: End-to-end scenarios
  </spec_tests>
  
  <general_tests>
    IF scope == "general":
      RUN: Affected area tests
      VERIFY: Regression suite
      CHECK: System stability
  </general_tests>
</test_scope>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run [SCOPE] tests for debugging fix"
  VERIFY: All relevant tests pass
  CONFIRM: Issue resolved
</instructions>

</step>

<step number="7" name="status_updates">

### Step 7: Context-Appropriate Status Updates

Update project status based on debugging scope.

<task_updates>
  IF scope == "task":
    UPDATE: Task status in tasks.md
    ADD: Debug note to task
    REMOVE: Any blocking indicators
    NOTE: Fix applied
</task_updates>

<spec_updates>
  IF scope == "spec":
    UPDATE: All affected tasks in tasks.md
    DOCUMENT: Integration fixes
    NOTE: Cross-task resolutions
    UPDATE: Spec documentation if needed
</spec_updates>

<general_updates>
  IF scope == "general":
    DOCUMENT: Fix in appropriate location
    UPDATE: Changelog if exists
    NOTE: System changes made
</general_updates>

<instructions>
  ACTION: Update status appropriately
  DOCUMENT: Debug work completed
  MAINTAIN: Project consistency
</instructions>

</step>

<step number="8" subagent="file-creator" name="documentation">

### Step 8: Create Debug Documentation

Use the file-creator subagent to document debugging based on scope.

<documentation_paths>
  <task_documentation>
    IF scope == "task":
      PATH: .agent-os/debugging/tasks/[SPEC]-[TASK]-[TIMESTAMP].md
      INCLUDE: Task context, issue, fix
  </task_documentation>
  
  <spec_documentation>
    IF scope == "spec":
      PATH: .agent-os/debugging/specs/[SPEC]-[TIMESTAMP].md
      INCLUDE: Integration issues, cross-task fixes
  </spec_documentation>
  
  <general_documentation>
    IF scope == "general":
      PATH: .agent-os/debugging/[TIMESTAMP]-[ISSUE].md
      INCLUDE: Full investigation and fix
  </general_documentation>
</documentation_paths>

<report_content>
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
</report_content>

<instructions>
  ACTION: Use file-creator subagent
  CREATE: Debug report at appropriate path
  INCLUDE: Context-relevant information
  FOCUS: Lessons learned and prevention
</instructions>

</step>

<step number="9" subagent="git-workflow" name="commit">

### Step 9: Commit with Context

Use the git-workflow subagent to commit with appropriate context.

<commit_message_format>
  <task_commit>
    IF scope == "task":
      fix: [spec] resolve [issue] in task [number]
  </task_commit>
  
  <spec_commit>
    IF scope == "spec":
      fix: [spec] resolve integration issues
  </spec_commit>
  
  <general_commit>
    IF scope == "general":
      fix: resolve [issue description]
  </general_commit>
</commit_message_format>

<instructions>
  ACTION: Use git-workflow subagent
  COMMIT: With context-appropriate message
  REFERENCE: Spec/task if applicable
  INCLUDE: Clear description of fix
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>

<debugging_principles>

## Core Principles

### Automatic Context Detection
- Intelligently determine debugging scope
- Adapt workflow to current situation
- Maintain appropriate boundaries

### Unified Workflow
- Single command for all debugging
- Context-aware investigation
- Appropriate documentation paths

### Progressive Enhancement
- Start with detected context
- Escalate scope if needed
- Maintain project coherence

</debugging_principles>