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

<step number="1" subagent="test-runner" name="test_suite_verification">

### Step 1: Run All Tests

Use the test-runner subagent to run the ALL tests in the application's test suite to ensure no regressions and fix any failures until all tests pass.

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

<step number="2" name="specification_compliance_verification">

### Step 2: Specification Compliance Verification

Before running tests, validate that the implemented features comply with the original specifications to catch requirement violations early.

<instructions>
  ACTION: Load original specifications for the current feature
  SEARCH: Specification files in [SPEC_FOLDER_PATH] and related spec directories
  VALIDATE: Implementation matches specification requirements
  CHECK: All specified functionality is present and correct
  VERIFY: No specification requirements were missed or incorrectly implemented
  DOCUMENT: Any deviations from specifications with justification
</instructions>

<compliance_checklist>
  <specification_adherence>
    ✓ All specified features are implemented
    ✓ API contracts match specification definitions
    ✓ User interface matches design specifications
    ✓ Business rules are correctly enforced
    ✓ Error handling covers specified scenarios
  </specification_adherence>
  <requirement_coverage>
    ✓ Functional requirements are met
    ✓ Non-functional requirements are addressed
    ✓ Edge cases from specifications are handled
    ✓ Integration points work as specified
  </requirement_coverage>
</compliance_checklist>

<validation_failure_handling>
  IF specification violations found:
    HALT: Do not proceed to testing
    FIX: Address specification compliance issues
    RETRY: Re-validate compliance before continuing
  ELSE:
    PROCEED: To test suite execution
</validation_failure_handling>

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
  <preliminary_check>
    EVALUATE: Did executed tasks complete any roadmap item(s)?
    IF NO:
      SKIP this entire step
      PROCEED to step 7
    IF YES:
      CONTINUE with roadmap check
  </preliminary_check>
</conditional_execution>

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

<step number="6" subagent="project-manager" name="document_recap">

### Step 6: Create Recap Document

Use the project-manager subagent to create a recap document in .agent-os/recaps/ folder that summarizes what was built for this spec.

<instructions>
  ACTION: Use project-manager subagent
  REQUEST: "Create recap document for current spec:
            - Create file: .agent-os/recaps/[SPEC_FOLDER_NAME].md
            - Use template format with completed features summary
            - Include context from spec-lite.md
            - Document: [SPEC_FOLDER_PATH]"
  WAIT: For recap document creation
  PROCESS: Verify file is created with proper content
</instructions>

<recap_template>
  # [yyyy-mm-dd] Recap: Feature Name

  This recaps what was built for the spec documented at .agent-os/specs/[spec-folder-name]/spec.md.

  ## Recap

  [1 paragraph summary plus short bullet list of what was completed]

  ## Context

  [Copy the summary found in spec-lite.md to provide concise context of what the initial goal for this spec was]
</recap_template>

<file_creation>
  <location>.agent-os/recaps/</location>
  <naming>[SPEC_FOLDER_NAME].md</naming>
  <format>markdown with yaml frontmatter if needed</format>
</file_creation>

<content_requirements>
  <summary>1 paragraph plus bullet points</summary>
  <context>from spec-lite.md summary</context>
  <reference>link to original spec</reference>
</content_requirements>

</step>

<step number="7" subagent="project-manager" name="completion_summary">

### Step 7: Completion Summary

Use the project-manager subagent to create a structured summary message with emojis showing what was done, any issues, testing instructions, and PR link.

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

<step number="8" subagent="project-manager" name="completion_notification">

### Step 8: Task Completion Notification

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
