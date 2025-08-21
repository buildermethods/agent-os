---
description: Rules to finish off and deliver to user set of tasks that have been completed using Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Task Execution Rules

## Overview

After all tasks in the current spec have been completed, follow these steps to mark your progress updates, create a recap, and deliver the final report to the user.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="test-runner" name="test_suite_verification" parallel="true">

### Step 1: Run All Tests (Can Run in Parallel)

Use the test-runner subagent to run the ALL tests in the application's test suite to ensure no regressions and fix any failures until all tests pass.

<parallel_execution>
  CAN_RUN_WITH: Steps that don't modify code
  SPECIFICALLY: Step 5 (roadmap check - read only)
  BENEFIT: Saves 10-15 seconds when tests are long
</parallel_execution>

<smart_test_execution>
  IF test results cached from execute-task (last 5 minutes):
    CHECK: Cached test status
    IF all tests passed in cache:
      SKIP: Re-running tests
      USE: Cached results
      SAVE: 15-30 seconds
    ELSE:
      RUN: Only previously failed tests
  ELSE:
    RUN: Full test suite as normal
</smart_test_execution>

<instructions>
  ACTION: Check for cached test results first
  IF CACHED AND PASSING: Skip test execution
  ELSE: Use test-runner subagent
  REQUEST: "Run the full test suite" (or subset if cache partial)
  PARALLEL: Can start while other read-only operations run
  WAIT: For test-runner analysis before Step 3
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

<step number="2" name="specification_compliance_check">

### Step 2: Quick Specification Compliance Check

Verify that specification validation was completed during task execution. Only perform full validation if it was skipped or failed previously.

<smart_skip_logic>
  IF execute-task already validated specifications (Step 9):
    SKIP: Full validation (already completed)
    VERIFY: No new specification violations reported
    PROCEED: To test suite execution
  ELSE IF validation was skipped or incomplete:
    PERFORM: Quick compliance check on changed files only
    FOCUS: New functionality added since last validation
  ELSE:
    CONTINUE: With minimal verification
</smart_skip_logic>

<quick_verification>
  CHECK: Task completion notes for validation status
  REVIEW: Any specification deviation notes from execute-task
  CONFIRM: No critical compliance issues remain
  TIME_SAVED: 5-10 seconds when validation already passed
</quick_verification>

<validation_required_only_if>
  - Execute-task validation was skipped
  - New code was added after validation
  - Specification files were modified during execution
  - User explicitly requests re-validation
</validation_required_only_if>

</step>

<step number="3" subagent="git-workflow" name="git_workflow">

### Step 3: Git Workflow

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

<step number="4" subagent="project-manager" name="tasks_list_check">

### Step 4: Tasks Completion Verification

Use the project-manager subagent to read the current spec's tasks.md file and verify that all tasks have been properly marked as complete with [x] or documented with blockers.

<instructions>
  ACTION: Use project-manager subagent
  REQUEST: "Verify task completion in current spec:
            - Read [SPEC_FOLDER_PATH]/tasks.md
            - Check all tasks are marked complete with [x]
            - Verify any incomplete tasks have documented blockers
            - Mark completed tasks as [x] if verification confirms completion"
  WAIT: For task verification analysis
  PROCESS: Update task status as needed
</instructions>

<verification_process>
  <read_tasks>
    <file>[SPEC_FOLDER_PATH]/tasks.md</file>
    <purpose>verify completion status</purpose>
  </read_tasks>
  <check_status>
    <complete>tasks marked with [x]</complete>
    <incomplete>tasks without [x] marking</incomplete>
    <blockers>documented impediments</blockers>
  </check_status>
  <update_required>
    <action>mark verified completed tasks with [x]</action>
    <condition>when task is actually finished</condition>
  </update_required>
</verification_process>

<completion_criteria>
  <valid_states>
    - Task marked complete [x]
    - Task has documented blocker preventing completion
  </valid_states>
  <invalid_state>
    - Task unmarked without blocker documentation
  </invalid_state>
</completion_criteria>

</step>

<step number="5" subagent="project-manager" name="roadmap_progress_check">

### Step 5: Roadmap Progress Update (conditional)

Use the project-manager subagent to read @.agent-os/product/roadmap.md and mark roadmap items as complete with [x] ONLY IF the executed tasks have completed any roadmap item(s) and the spec completes that item.

<conditional_execution>
  <smart_preliminary_check>
    QUICK_CHECK: Task names against roadmap keywords
    IF no task names match roadmap items:
      SKIP: Entire step immediately
      SAVE: 3-5 seconds
      PROCEED: To step 6
    ELSE IF partial match found:
      EVALUATE: Did executed tasks complete any roadmap item(s)?
      IF NO:
        SKIP: This entire step
        PROCEED: To step 6
      IF YES:
        CONTINUE: With roadmap check
  </smart_preliminary_check>
</conditional_execution>

<quick_match_logic>
  COMPARE: Parent task names with roadmap item titles
  USE: Simple string matching for initial filter
  BENEFIT: Avoid reading roadmap when clearly unrelated
</quick_match_logic>

<roadmap_criteria>
  <update_when>
    - spec fully implements roadmap feature
    - all related tasks completed
    - tests passing
  </update_when>
</roadmap_criteria>

<instructions>
  ACTION: First evaluate if roadmap check is needed
      SKIP: If tasks clearly don't complete roadmap items
  EVALUATE: If current spec completes roadmap goals
  UPDATE: Mark roadmap items complete with [x] if applicable
  VERIFY: Certainty before marking complete
</instructions>

</step>

<step number="6" subagent="project-manager" name="document_and_summarize">

### Step 6: Create Documentation and Summary (Batched)

Use the project-manager subagent to create BOTH the recap document and completion summary in a single batched request.

<batched_request>
  ACTION: Use project-manager subagent
  REQUEST: "Complete documentation and summary tasks:
            
            TASK 1 - Create recap document:
            - Create file: .agent-os/recaps/[SPEC_FOLDER_NAME].md
            - Use template format with completed features summary
            - Include context from spec-lite.md
            - Document: [SPEC_FOLDER_PATH]
            
            TASK 2 - Generate completion summary:
            - List what's been done with descriptions
            - Note any issues encountered
            - Include testing instructions if applicable
            - Add PR link from Step 3
            
            Return both outputs in single response"
  BENEFIT: Saves 3-5 seconds by batching operations
</batched_request>

<recap_template>
  # [yyyy-mm-dd] Recap: Feature Name

  This recaps what was built for the spec documented at .agent-os/specs/[spec-folder-name]/spec.md.

  ## Recap

  [1 paragraph summary plus short bullet list of what was completed]

  ## Context

  [Copy the summary found in spec-lite.md to provide concise context of what the initial goal for this spec was]
</recap_template>

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

</step>

<step number="7" subagent="project-manager" name="completion_notification">

### Step 7: Task Completion Notification

Use the project-manager subagent to play a system sound to alert the user that tasks are complete.

<notification_command>
  afplay /System/Library/Sounds/Glass.aiff
</notification_command>

<instructions>
  ACTION: Play completion sound
  PURPOSE: Alert user that task is complete
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
