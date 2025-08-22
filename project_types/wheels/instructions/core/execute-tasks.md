---
description: Rules to initiate execution of a set of tasks using Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Task Execution Rules

## Overview

Initiate execution of one or more tasks for a given spec.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="task_assignment">

### Step 1: Task Assignment

Identify which tasks to execute from the spec (using spec_srd_reference file path and optional specific_tasks array), defaulting to the next uncompleted parent task if not specified.

<task_selection>
  <explicit>user specifies exact task(s)</explicit>
  <implicit>find next uncompleted task in tasks.md</implicit>
</task_selection>

<instructions>
  ACTION: Identify task(s) to execute
  DEFAULT: Select next uncompleted parent task if not specified
  CONFIRM: Task selection with user
</instructions>

</step>

<step number="2" subagent="context-fetcher" name="context_analysis">

### Step 2: Context Analysis

Use the context-fetcher subagent to gather minimal context for task understanding by always loading spec tasks.md, and conditionally loading @.agent-os/product/mission-lite.md, spec-lite.md, and sub-specs/technical-spec.md if not already in context.

<instructions>
  ACTION: Use context-fetcher subagent to:
    - REQUEST: "Get product pitch from mission-lite.md"
    - REQUEST: "Get spec summary from spec-lite.md"
    - REQUEST: "Get technical approach from technical-spec.md"
  PROCESS: Returned information
</instructions>


<context_gathering>
  <essential_docs>
    - tasks.md for task breakdown
  </essential_docs>
  <conditional_docs>
    - mission-lite.md for product alignment
    - spec-lite.md for feature summary
    - technical-spec.md for implementation details
  </conditional_docs>
</context_gathering>

</step>

<step number="3" name="development_server_check">

### Step 3: Check for Development Server

Check for any running development server and ask user permission to shut it down if found to prevent port conflicts.

<server_check_flow>
  <if_running>
    ASK user to shut down
    WAIT for response
  </if_running>
  <if_not_running>
    PROCEED immediately
  </if_not_running>
</server_check_flow>

<user_prompt>
  A development server is currently running.
  Should I shut it down before proceeding? (yes/no)
</user_prompt>

<instructions>
  ACTION: Check for running local development server
  CONDITIONAL: Ask permission only if server is running
  PROCEED: Immediately if no server detected
</instructions>

</step>

<step number="4" subagent="git-workflow" name="git_branch_management">

### Step 4: Git Branch Management

Use the git-workflow subagent to manage git branches to ensure proper isolation by creating or switching to the appropriate branch for the spec.

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Check and manage branch for spec: [SPEC_FOLDER]
            - Create branch if needed
            - Switch to correct branch
            - Handle any uncommitted changes"
  WAIT: For branch setup completion
</instructions>

<branch_naming>
  <source>spec folder name</source>
  <format>exclude date prefix</format>
  <example>
    - folder: 2025-03-15-password-reset
    - branch: password-reset
  </example>
</branch_naming>

</step>

<step number="5" name="task_execution_loop">

### Step 5: Task Execution Loop

Execute all assigned parent tasks and their subtasks using @.agent-os/instructions/core/execute-task.md instructions, continuing until all tasks are complete.

<execution_flow>
  LOAD @.agent-os/instructions/core/execute-task.md ONCE

  FOR each parent_task assigned in Step 1:
    EXECUTE instructions from execute-task.md with:
      - parent_task_number
      - all associated subtasks
    WAIT for task completion
    UPDATE tasks.md status
  END FOR
</execution_flow>

<loop_logic>
  <continue_conditions>
    - More unfinished parent tasks exist
    - User has not requested stop
  </continue_conditions>
  <exit_conditions>
    - All assigned tasks marked complete
    - User requests early termination
    - Blocking issue prevents continuation
  </exit_conditions>
</loop_logic>

<task_status_check>
  AFTER each task execution:
    CHECK tasks.md for remaining tasks
    IF all assigned tasks complete:
      PROCEED to next step
    ELSE:
      CONTINUE with next task
</task_status_check>

<instructions>
  ACTION: Load execute-task.md instructions once at start
  REUSE: Same instructions for each parent task iteration
  LOOP: Through all assigned parent tasks
  UPDATE: Task status after each completion
  VERIFY: All tasks complete before proceeding
  HANDLE: Blocking issues appropriately
</instructions>

</step>

<step number="6" subagent="test-runner" name="test_suite_verification">

### Step 6: Run All Tests

Use the test-runner subagent to run the entire test suite to ensure no regressions and fix any failures until all tests pass.

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run the full test suite"
  WAIT: For test-runner analysis
  PROCESS: Fix any reported failures
  REPEAT: Until all tests pass
</instructions>

<test_execution>
  <order>
    1. Run entire test suite
    2. Fix any failures
  </order>
  <requirement>100% pass rate</requirement>
</test_execution>

<failure_handling>
  <action>troubleshoot and fix</action>
  <priority>before proceeding</priority>
</failure_handling>

</step>

<step number="7" subagent="git-workflow" name="git_workflow">

### Step 7: Git Workflow

Use the git-workflow subagent to create git commit, push to GitHub, and create pull request for the implemented features.

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Complete git workflow for [SPEC_NAME] feature:
            - Spec: [SPEC_FOLDER_PATH]
            - Changes: All modified files
            - Target: main branch
            - Description: [SUMMARY_OF_IMPLEMENTED_FEATURES]"
  WAIT: For workflow completion
  PROCESS: Save PR URL for summary
</instructions>

<commit_process>
  <commit>
    <message>descriptive summary of changes</message>
    <format>conventional commits if applicable</format>
  </commit>
  <push>
    <target>spec branch</target>
    <remote>origin</remote>
  </push>
  <pull_request>
    <title>descriptive PR title</title>
    <description>functionality recap</description>
  </pull_request>
</commit_process>

</step>

<step number="8" name="roadmap_progress_check">

### Step 8: Roadmap Progress Check (Conditional)

Check @.agent-os/product/roadmap.md (if not in context) and update roadmap progress only if the executed tasks may have completed a roadmap item and the spec completes that item.

<conditional_execution>
  <preliminary_check>
    EVALUATE: Did executed tasks potentially complete a roadmap item?
    IF NO:
      SKIP this entire step
      PROCEED to step 9
    IF YES:
      CONTINUE with roadmap check
  </preliminary_check>
</conditional_execution>

<conditional_loading>
  IF roadmap.md NOT already in context:
    LOAD @.agent-os/product/roadmap.md
  ELSE:
    SKIP loading (use existing context)
</conditional_loading>

<roadmap_criteria>
  <update_when>
    - spec fully implements roadmap feature
    - all related tasks completed
    - tests passing
  </update_when>
  <caution>only mark complete if absolutely certain</caution>
</roadmap_criteria>

<instructions>
  ACTION: First evaluate if roadmap check is needed
  SKIP: If tasks clearly don't complete roadmap items
  CHECK: If roadmap.md already in context
  LOAD: Only if needed and not in context
  EVALUATE: If current spec completes roadmap goals
  UPDATE: Mark roadmap items complete if applicable
  VERIFY: Certainty before marking complete
</instructions>

</step>

<step number="9" name="completion_notification">

### Step 9: Task Completion Notification

Play a system sound to alert the user that tasks are complete.

<notification_command>
  afplay /System/Library/Sounds/Glass.aiff
</notification_command>

<instructions>
  ACTION: Play completion sound
  PURPOSE: Alert user that task is complete
</instructions>

</step>

<step number="10" name="completion_summary">

### Step 10: Completion Summary

Create a structured summary message with emojis showing what was done, any issues, testing instructions, and PR link.

<summary_template>
  ## ✅ What's been done

  1. **[FEATURE_1]** - [ONE_SENTENCE_DESCRIPTION]
  2. **[FEATURE_2]** - [ONE_SENTENCE_DESCRIPTION]

  ## ⚠️ Issues encountered

  [ONLY_IF_APPLICABLE]
  - **[ISSUE_1]** - [DESCRIPTION_AND_REASON]

  ## 👀 Ready to test in browser

  [ONLY_IF_APPLICABLE]
  1. [STEP_1_TO_TEST]
  2. [STEP_2_TO_TEST]

  ## 📦 Pull Request

  View PR: [GITHUB_PR_URL]
</summary_template>

<summary_sections>
  <required>
    - functionality recap
    - pull request info
  </required>
  <conditional>
    - issues encountered (if any)
    - testing instructions (if testable in browser)
  </conditional>
</summary_sections>

<instructions>
  ACTION: Create comprehensive summary
  INCLUDE: All required sections
  ADD: Conditional sections if applicable
  FORMAT: Use emoji headers for scannability
</instructions>

</step>

</process_flow>

## Error Handling

<error_protocols>
  <blocking_issues>
    - document in tasks.md
    - mark with ⚠️ emoji
    - include in summary
  </blocking_issues>
  <test_failures>
    - fix before proceeding
    - never commit broken tests
  </test_failures>
  <technical_roadblocks>
    - attempt 3 approaches
    - document if unresolved
    - seek user input
  </technical_roadblocks>
</error_protocols>

<final_checklist>
  <verify>
    - [ ] Task implementation complete
    - [ ] All tests passing
    - [ ] tasks.md updated
    - [ ] Code committed and pushed
    - [ ] Pull request created
    - [ ] Roadmap checked/updated
    - [ ] Summary provided to user
  </verify>
</final_checklist>
