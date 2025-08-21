---
description: Debug Task Rules for Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Debug Task Rules

## Overview

Debug issues encountered while implementing a specific task within the current spec, maintaining task context and updating task status accordingly.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="context-fetcher" name="task_context_gathering">

### Step 1: Task Context Gathering

Use the context-fetcher subagent to gather the current task context from spec and task files.

<context_retrieval>
  <current_spec>
    READ: .agent-os/specs/[current-spec]/technical-spec.md
    EXTRACT:
      - Spec name and description
      - Technical requirements
      - Integration points
      - Expected behaviors
  </current_spec>
  
  <current_task>
    READ: .agent-os/tasks/[current-spec]/tasks.md
    IDENTIFY:
      - Current task being debugged
      - Task description and requirements
      - Related subtasks
      - Task dependencies
      - Current completion status
  </current_task>
  
  <test_requirements>
    IDENTIFY:
      - Tests written for this task
      - Expected test outcomes
      - Current test failures
  </test_requirements>
</context_retrieval>

<task_identification>
  IF task_not_specified:
    ASK: "Which task are you debugging? Please provide:
          1. Task number/name from tasks.md
          2. What issue you're encountering
          3. At what point in implementation"
    WAIT for user response
</task_identification>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Get context for debugging task [TASK_NAME] in spec [SPEC_NAME]
            Read technical-spec.md section for this task
            Read tasks.md for task requirements
            Identify related tests and dependencies"
  DOCUMENT: Task context and requirements
  NOTE: Current task implementation status
</instructions>

</step>

<step number="2" name="task_specific_investigation">

### Step 2: Task-Specific Investigation

Investigate the issue within the context of the current task implementation.

<implementation_review>
  <task_code>
    - Review code written for this task
    - Check if implementation matches spec
    - Verify task requirements are met
    - Identify incomplete portions
  </task_code>
  
  <test_analysis>
    - Run tests specific to this task
    - Identify which tests are failing
    - Determine if tests match requirements
    - Check for test implementation issues
  </test_analysis>
  
  <dependency_check>
    - Verify prerequisite tasks completed
    - Check integration with other tasks
    - Validate shared components work
    - Ensure data flow is correct
  </dependency_check>
</implementation_review>

<common_task_issues>
  <implementation_gaps>
    - Missing functionality
    - Incomplete error handling
    - Skipped edge cases
    - Incorrect assumptions
  </implementation_gaps>
  
  <integration_problems>
    - Mismatched interfaces
    - Incorrect data formats
    - Missing dependencies
    - State management issues
  </integration_problems>
  
  <test_issues>
    - Tests not matching spec
    - Missing test coverage
    - Incorrect test expectations
    - Test environment problems
  </test_issues>
</common_task_issues>

<instructions>
  ACTION: Investigate task-specific issues
  REVIEW: Implementation against task requirements
  RUN: Task-specific tests
  IDENTIFY: Gaps between spec and implementation
  CHECK: Integration with completed tasks
</instructions>

</step>

<step number="3" subagent="debug-helper" name="focused_debugging">

### Step 3: Focused Debugging

Use the debug-helper subagent to debug the specific issue within task context.

<debugging_scope>
  <task_boundaries>
    - Focus on code for this task
    - Include immediate dependencies
    - Check task interfaces
    - Verify task outputs
  </task_boundaries>
  
  <spec_alignment>
    - Compare behavior to spec
    - Verify acceptance criteria
    - Check technical requirements
    - Validate assumptions
  </spec_alignment>
  
  <test_driven_debugging>
    - Use failing tests as guide
    - Add debug output to tests
    - Create minimal reproductions
    - Isolate specific failures
  </test_driven_debugging>
</debugging_scope>

<instructions>
  ACTION: Use debug-helper subagent
  REQUEST: "Debug issue in task: [TASK_NAME]
            Context: [TASK_REQUIREMENTS]
            Failing tests: [TEST_NAMES]
            Focus on: [SPECIFIC_ISSUE]
            Check alignment with spec requirements"
  PROCESS: Debug findings
  IDENTIFY: Root cause within task scope
</instructions>

</step>

<step number="4" name="task_fix_implementation">

### Step 4: Implement Task-Aligned Fix

Implement a fix that maintains task and spec requirements.

<fix_constraints>
  <maintain_spec_compliance>
    - Fix must satisfy task requirements
    - Preserve spec acceptance criteria
    - Maintain integration contracts
    - Keep existing tests passing
  </maintain_spec_compliance>
  
  <task_scope>
    - Stay within task boundaries
    - Don't modify unrelated code
    - Preserve completed task work
    - Update only necessary files
  </task_scope>
  
  <test_updates>
    - Update tests if requirements changed
    - Add tests for bug discovered
    - Ensure all task tests pass
    - Verify integration tests work
  </test_updates>
</fix_constraints>

<implementation_approach>
  1. Write failing test for the bug (if missing)
  2. Implement minimal fix
  3. Verify task tests pass
  4. Check spec requirements met
  5. Validate integration points
</implementation_approach>

<instructions>
  ACTION: Implement fix within task context
  ENSURE: Fix aligns with spec requirements
  MAINTAIN: Task boundaries and scope
  VERIFY: All task tests pass
  UPDATE: Task implementation as needed
</instructions>

</step>

<step number="5" subagent="test-runner" name="task_test_verification">

### Step 5: Verify Task Tests

Use the test-runner subagent to verify all task-related tests pass.

<test_hierarchy>
  <immediate_tests>
    - Bug fix test (newly added)
    - Task-specific unit tests
    - Task integration tests
    - Subtask tests if applicable
  </immediate_tests>
  
  <related_tests>
    - Dependent task tests
    - Spec integration tests
    - Feature-level tests
    - Regression test suite
  </related_tests>
</test_hierarchy>

<verification_process>
  1. Run task-specific tests first
  2. Verify all pass with fix
  3. Run related integration tests
  4. Check no regressions introduced
  5. Confirm spec requirements met
</verification_process>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run tests for task: [TASK_NAME]
            Include: unit, integration, and spec tests
            Verify: bug is fixed and requirements met"
  CONFIRM: All task tests passing
  VERIFY: No regression in other tasks
</instructions>

</step>

<step number="6" subagent="project-manager" name="task_status_update">

### Step 6: Update Task Status

Use the project-manager subagent to update task status and document the debugging.

<status_updates>
  <tasks_md_update>
    IF task_was_blocked:
      - Remove blocking indicator
      - Update task status if resolved
      - Note debugging completed
    
    IF task_partially_complete:
      - Update completion percentage
      - Document what's fixed
      - Note remaining work
    
    IF task_now_complete:
      - Mark task as [x] complete
      - Verify all subtasks done
      - Update completion timestamp
  </tasks_md_update>
  
  <debugging_note>
    ADD to task in tasks.md:
    ```
    - [status] Task description
      📝 Debug: [Issue found and fixed]
      ✅ Tests: All passing
    ```
  </debugging_note>
</status_updates>

<documentation>
  <inline_documentation>
    - Add debug note to task
    - Reference fix commit
    - Note test additions
  </inline_documentation>
  
  <debug_report>
    IF significant_issue:
      CREATE: .agent-os/debugging/tasks/[SPEC]-[TASK]-[TIMESTAMP].md
      INCLUDE:
        - Task context
        - Issue encountered
        - Root cause
        - Fix applied
        - Tests added
        - Lessons learned
  </debug_report>
</documentation>

<instructions>
  ACTION: Use project-manager subagent
  REQUEST: "Update task status for: [TASK_NAME]
            Add debug note about issue fixed
            Update completion status if applicable
            Document in tasks.md"
  ENSURE: Task status accurate
  DOCUMENT: Debugging work done
</instructions>

</step>

<step number="7" name="spec_impact_assessment">

### Step 7: Assess Spec Impact

Evaluate if the debugging revealed spec-level issues or improvements needed.

<impact_analysis>
  <spec_implications>
    - Does fix affect other tasks?
    - Are spec assumptions invalid?
    - Do requirements need updating?
    - Are integration points affected?
  </spec_implications>
  
  <cross_task_effects>
    - Check dependent tasks
    - Verify task interfaces
    - Update shared components
    - Validate data contracts
  </cross_task_effects>
  
  <spec_updates_needed>
    IF spec_changes_required:
      - Document needed updates
      - Propose spec amendments
      - Update technical-spec.md
      - Notify about changes
  </spec_updates_needed>
</impact_analysis>

<preventive_measures>
  <task_patterns>
    - Identify similar tasks at risk
    - Add validation for common issues
    - Improve task templates
    - Enhance testing strategy
  </task_patterns>
  
  <spec_improvements>
    - Clarify ambiguous requirements
    - Add missing edge cases
    - Improve integration specs
    - Document assumptions
  </spec_improvements>
</preventive_measures>

<instructions>
  ACTION: Assess debugging impact on spec
  CHECK: Other tasks affected
  IDENTIFY: Spec improvements needed
  DOCUMENT: Preventive measures
  UPDATE: Spec if necessary
</instructions>

</step>

<step number="8" subagent="git-workflow" name="commit_task_debug_fix">

### Step 8: Commit Task Debug Fix

Use the git-workflow subagent to commit the fix with task context.

<commit_format>
  <message_structure>
    fix: [spec-name] resolve [issue] in task [task-number]
    
    Task: [task-description]
    Issue: [what was broken]
    Root cause: [why it broke]
    Solution: [how it was fixed]
    
    - Updated [files changed]
    - Added test for [test coverage]
    - Verified task requirements met
    
    Spec: [spec-name]
    Task: [task-number]
  </message_structure>
</commit_format>

<commit_contents>
  - Bug fix implementation
  - New or updated tests
  - Task status updates
  - Documentation changes
</commit_contents>

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Commit task debug fix
            Reference spec: [SPEC_NAME]
            Reference task: [TASK_NUMBER]
            Include context in message"
  ENSURE: Clear task reference
  LINK: To spec and task context
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>

<task_debugging_best_practices>

## Task Debugging Best Practices

### Maintain Task Context
- Always reference the spec and task
- Keep fixes within task scope
- Preserve spec requirements
- Update task status appropriately

### Test-Driven Debugging
- Use task tests as guide
- Add tests for bugs found
- Verify against spec requirements
- Ensure integration tests pass

### Documentation
- Add debug notes to tasks.md
- Reference fixes in commits
- Document patterns discovered
- Update spec if needed

### Progressive Debugging
- Start with task-specific issues
- Check integration points next
- Verify spec compliance last
- Consider cross-task impacts

</task_debugging_best_practices>