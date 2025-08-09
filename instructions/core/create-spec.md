---
description: Spec Creation Rules for Agent OS
globs:
alwaysApply: false
version: 1.1
encoding: UTF-8
---

# Spec Creation Rules

## Overview

Generate detailed feature specifications aligned with product roadmap and mission.

<pre_flight_check>
  EXECUTE: @~/.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="context-fetcher" name="spec_initiation">

### Step 1: Spec Initiation

Use the context-fetcher subagent to identify spec initiation method by either finding the next uncompleted roadmap item when user asks "what's next?" or accepting a specific spec idea from the user.

<option_a_flow>
  <trigger_phrases>
    - "what's next?"
  </trigger_phrases>
  <actions>
    1. CHECK @.agent-os/product/roadmap.md
    2. FIND next uncompleted item
    3. SUGGEST item to user
    4. WAIT for approval
  </actions>
</option_a_flow>

<option_b_flow>
  <trigger>user describes specific spec idea</trigger>
  <accept>any format, length, or detail level</accept>
  <proceed>to context gathering</proceed>
</option_b_flow>

</step>

<step number="2" subagent="context-fetcher" name="context_gathering">

### Step 2: Context Gathering (Conditional)

Use the context-fetcher subagent to read @.agent-os/product/mission-lite.md and @.agent-os/product/tech-stack.md only if not already in context to ensure minimal context for spec alignment.

<conditional_logic>
  IF both mission-lite.md AND tech-stack.md already read in current context:
    SKIP this entire step
    PROCEED to step 3
  ELSE:
    READ only files not already in context:
      - mission-lite.md (if not in context)
      - tech-stack.md (if not in context)
    CONTINUE with context analysis
</conditional_logic>

<context_analysis>
  <mission_lite>core product purpose and value</mission_lite>
  <tech_stack>technical requirements</tech_stack>
</context_analysis>

</step>

<step number="3" subagent="context-fetcher" name="requirements_clarification">

### Step 3: Requirements Clarification

Use the context-fetcher subagent to clarify scope boundaries and technical considerations by asking numbered questions as needed to ensure clear requirements before proceeding.

<clarification_areas>
  <scope>
    - in_scope: what is included
    - out_of_scope: what is excluded (optional)
  </scope>
  <technical>
    - functionality specifics
    - UI/UX requirements
    - integration points
  </technical>
</clarification_areas>

<decision_tree>
  IF clarification_needed:
    ASK numbered_questions
    WAIT for_user_response
  ELSE:
    PROCEED to_date_determination
</decision_tree>

</step>

<step number="4" name="date_determination">

### Step 4: Date Determination

Determine accurate date for folder naming by creating a temporary file to extract timestamp in YYYY-MM-DD format, falling back to asking user if needed.

<date_determination_process>
  <primary_method>
    <name>File System Timestamp</name>
    <process>
      1. CREATE directory if not exists: .agent-os/specs/
      2. CREATE temporary file: .agent-os/specs/.date-check
      3. READ file creation timestamp from filesystem
      4. EXTRACT date in YYYY-MM-DD format
      5. DELETE temporary file
      6. STORE date in variable for folder naming
    </process>
  </primary_method>

  <fallback_method>
    <trigger>if file system method fails</trigger>
    <name>User Confirmation</name>
    <process>
      1. STATE: "I need to confirm today's date for the spec folder"
      2. ASK: "What is today's date? (YYYY-MM-DD format)"
      3. WAIT for user response
      4. VALIDATE format matches YYYY-MM-DD
      5. STORE date for folder naming
    </process>
  </fallback_method>
</date_determination_process>

<validation>
  <format_check>^\d{4}-\d{2}-\d{2}$</format_check>
  <reasonableness_check>
    - year: 2024-2030
    - month: 01-12
    - day: 01-31
  </reasonableness_check>
</validation>

<error_handling>
  IF date_invalid:
    USE fallback_method
  IF both_methods_fail:
    ERROR "Unable to determine current date"
</error_handling>

</step>

<step number="5" subagent="file-creator" name="spec_folder_creation">

### Step 5: Spec Folder Creation

Use the file-creator subagent to create directory: .agent-os/specs/YYYY-MM-DD-spec-name/ using the date from step 4.

Use kebab-case for spec name. Maximum 5 words in name.

<folder_naming>
  <format>YYYY-MM-DD-spec-name</format>
  <date>use stored date from step 4</date>
  <name_constraints>
    - max_words: 5
    - style: kebab-case
    - descriptive: true
  </name_constraints>
</folder_naming>

<example_names>
  - 2025-03-15-password-reset-flow
  - 2025-03-16-user-profile-dashboard
  - 2025-03-17-api-rate-limiting
</example_names>

</step>

<step number="6" subagent="file-creator" name="create_spec_md">

### Step 6: Create spec.md

Use the file-creator subagent to create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec.md using this template:

<file_template>
  <header>
    # Spec Requirements Document

    > Spec: [SPEC_NAME]
    > Created: [CURRENT_DATE]
    > Status: Planning
  </header>
  <required_sections>
    - Overview
    - User Stories
    - Spec Scope
    - Out of Scope
    - Expected Deliverable
  </required_sections>
</file_template>

<section name="overview">
  <template>
    ## Overview

    [1-2_SENTENCE_GOAL_AND_OBJECTIVE]
  </template>
  <constraints>
    - length: 1-2 sentences
    - content: goal and objective
  </constraints>
  <example>
    Implement a secure password reset functionality that allows users to regain account access through email verification. This feature will reduce support ticket volume and improve user experience by providing self-service account recovery.
  </example>
</section>

<section name="user_stories">
  <template>
    ## User Stories

    ### [STORY_TITLE]

    As a [USER_TYPE], I want to [ACTION], so that [BENEFIT].

    [DETAILED_WORKFLOW_DESCRIPTION]
  </template>
  <constraints>
    - count: 1-3 stories
    - include: workflow and problem solved
    - format: title + story + details
  </constraints>
</section>

<section name="spec_scope">
  <template>
    ## Spec Scope

    1. **[FEATURE_NAME]** - [ONE_SENTENCE_DESCRIPTION]
    2. **[FEATURE_NAME]** - [ONE_SENTENCE_DESCRIPTION]
  </template>
  <constraints>
    - count: 1-5 features
    - format: numbered list
    - description: one sentence each
  </constraints>
</section>

<section name="out_of_scope">
  <template>
    ## Out of Scope

    - [EXCLUDED_FUNCTIONALITY_1]
    - [EXCLUDED_FUNCTIONALITY_2]
  </template>
  <purpose>explicitly exclude functionalities</purpose>
</section>

<section name="expected_deliverable">
  <template>
    ## Expected Deliverable

    1. [TESTABLE_OUTCOME_1]
    2. [TESTABLE_OUTCOME_2]
  </template>
  <constraints>
    - count: 1-3 expectations
    - focus: browser-testable outcomes
  </constraints>
</section>

</step>

<step number="7" subagent="file-creator" name="create_spec_lite_md">

### Step 7: Create spec-lite.md

Use the file-creator subagent to create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md for the purpose of establishing a condensed spec for efficient AI context usage.

<file_template>
  <header>
    # Spec Summary (Lite)
  </header>
</file_template>

<content_structure>
  <spec_summary>
    - source: Step 6 spec.md overview section
    - length: 1-3 sentences
    - content: core goal and objective of the feature
  </spec_summary>
</content_structure>

<content_template>
  [1-3_SENTENCES_SUMMARIZING_SPEC_GOAL_AND_OBJECTIVE]
</content_template>

<example>
  Implement secure password reset via email verification to reduce support tickets and enable self-service account recovery. Users can request a reset link, receive a time-limited token via email, and set a new password following security best practices.
</example>

</step>

<step number="8" subagent="file-creator" name="create_technical_spec">

### Step 8: Create Technical Specification

Use the file-creator subagent to create the file: sub-specs/technical-spec.md using this template:

<file_template>
  <header>
    # Technical Specification

    This is the technical specification for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  </header>
</file_template>

<spec_sections>
  <technical_requirements>
    - functionality details
    - UI/UX specifications
    - integration requirements
    - performance criteria
  </technical_requirements>
  <external_dependencies_conditional>
    - only include if new dependencies needed
    - new libraries/packages
    - justification for each
    - version requirements
  </external_dependencies_conditional>
</spec_sections>

<example_template>
  ## Technical Requirements

  - [SPECIFIC_TECHNICAL_REQUIREMENT]
  - [SPECIFIC_TECHNICAL_REQUIREMENT]

  ## External Dependencies (Conditional)

  [ONLY_IF_NEW_DEPENDENCIES_NEEDED]
  - **[LIBRARY_NAME]** - [PURPOSE]
  - **Justification:** [REASON_FOR_INCLUSION]
</example_template>

<conditional_logic>
  IF spec_requires_new_external_dependencies:
    INCLUDE "External Dependencies" section
  ELSE:
    OMIT section entirely
</conditional_logic>

</step>

<step number="9" subagent="file-creator" name="create_database_schema">

### Step 9: Create Database Schema (Conditional)

Use the file-creator subagent to create the file: sub-specs/database-schema.md ONLY IF database changes needed for this task.

<decision_tree>
  IF spec_requires_database_changes:
    CREATE sub-specs/database-schema.md
  ELSE:
    SKIP this_step
</decision_tree>

<file_template>
  <header>
    # Database Schema

    This is the database schema implementation for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  </header>
</file_template>

<schema_sections>
  <changes>
    - new tables
    - new columns
    - modifications
    - migrations
  </changes>
  <specifications>
    - exact SQL or migration syntax
    - indexes and constraints
    - foreign key relationships
  </specifications>
  <rationale>
    - reason for each change
    - performance considerations
    - data integrity rules
  </rationale>
</schema_sections>

</step>

<step number="10" subagent="file-creator" name="create_api_spec">

### Step 10: Create API Specification (Conditional)

Use the file-creator subagent to create file: sub-specs/api-spec.md ONLY IF API changes needed.

<decision_tree>
  IF spec_requires_api_changes:
    CREATE sub-specs/api-spec.md
  ELSE:
    SKIP this_step
</decision_tree>

<file_template>
  <header>
    # API Specification

    This is the API specification for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  </header>
</file_template>

<api_sections>
  <routes>
    - HTTP method
    - endpoint path
    - parameters
    - response format
  </routes>
  <controllers>
    - action names
    - business logic
    - error handling
  </controllers>
  <purpose>
    - endpoint rationale
    - integration with features
  </purpose>
</api_sections>

<endpoint_template>
  ## Endpoints

  ### [HTTP_METHOD] [ENDPOINT_PATH]

  **Purpose:** [DESCRIPTION]
  **Parameters:** [LIST]
  **Response:** [FORMAT]
  **Errors:** [POSSIBLE_ERRORS]
</endpoint_template>

</step>

<step number="11" name="user_review">

### Step 11: User Review

Request user review of spec.md and all sub-specs files, waiting for approval or revision requests before proceeding to task creation.

<review_request>
  I've created the spec documentation:

  - Spec Requirements: @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  - Spec Summary: @.agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md
  - Technical Spec: @.agent-os/specs/YYYY-MM-DD-spec-name/sub-specs/technical-spec.md
  [LIST_OTHER_CREATED_SPECS]

  Please review and let me know if any changes are needed before I create the task breakdown.
</review_request>

</step>

<step number="12" subagent="file-creator" name="create_tasks">

### Step 12: Create tasks.md

Use the file-creator subagent to await user approval from step 11 and then create file: tasks.md

<file_template>
  <header>
    # Spec Tasks
  </header>
</file_template>

<task_structure>
  <major_tasks>
    - count: 1-5
    - format: numbered checklist
    - grouping: by feature or component
  </major_tasks>
  <subtasks>
    - count: up to 8 per major task
    - format: decimal notation (1.1, 1.2)
    - first_subtask: typically write tests
    - last_subtask: verify all tests pass
  </subtasks>
</task_structure>

<task_template>
  ## Tasks

  - [ ] 1. [MAJOR_TASK_DESCRIPTION]
    - [ ] 1.1 Write tests for [COMPONENT]
    - [ ] 1.2 [IMPLEMENTATION_STEP]
    - [ ] 1.3 [IMPLEMENTATION_STEP]
    - [ ] 1.4 Verify all tests pass

  - [ ] 2. [MAJOR_TASK_DESCRIPTION]
    - [ ] 2.1 Write tests for [COMPONENT]
    - [ ] 2.2 [IMPLEMENTATION_STEP]

  - [ ] 3. Code Refactoring and Optimization (Post-UI Approval)
    - [ ] 3.1 Analyze codebase for optimization opportunities
    - [ ] 3.2 Create refactoring plan and get user approval
    - [ ] 3.3 Extract common functionality and split large files
    - [ ] 3.4 Optimize performance and improve error handling
    - [ ] 3.5 Verify all functionality and UI remain unchanged
    - [ ] 3.6 Confirm all tests pass and code quality improved
</task_template>

<ordering_principles>
  - Consider technical dependencies
  - Follow TDD approach
  - Group related functionality
  - Build incrementally
</ordering_principles>

</step>

<step number="13" subagent="file-creator" name="create_status">

### Step 13: Create status.md

Use the file-creator subagent to create file: status.md for lifecycle management

<file_template>
  <header>
    # Spec Status

    **Spec Name**: [SPEC_NAME]
    **Created**: [CURRENT_DATE]
    **Current Status**: planning
    **Last Updated**: [CURRENT_DATE]
  </header>
</file_template>

<status_template>
  ## Status History
  - [CURRENT_DATE] - Created (planning)

  ## Current Phase
  Spec is in planning phase. Ready for implementation when resources are available.

  ## Next Actions
  - [ ] Review spec requirements
  - [ ] Prioritize against other specs
  - [ ] Begin implementation when approved

  ## Notes
  [ANY_RELEVANT_NOTES_FROM_SPEC_CREATION]
</status_template>

<lifecycle_integration>
  <status_tracking>
    - planning: Spec created, ready for implementation
    - active: Implementation in progress
    - completed: Implementation finished, ready for cleanup
    - archived: Spec archived, minimal maintenance
  </status_tracking>
  
  <folder_naming>
    - planning-YYYY-MM-DD-spec-name (backlog)
    - active-YYYY-MM-DD-spec-name (in progress)
    - completed-YYYY-MM-DD-spec-name (done)
    - archived/YYYY-MM-DD-spec-name (archived)
  </folder_naming>
</lifecycle_integration>

</step>

<step number="14" subagent="file-creator" name="create_lifecycle_files">

### Step 14: Create Lifecycle Management Files

Use the file-creator subagent to create lifecycle management files for the project.

<lifecycle_files>
  <specs_dashboard>
    <file_path>.agent-os/specs/specs-dashboard.md</file_path>
    <template>
      # Specs Dashboard

      > Auto-generated dashboard for spec lifecycle management
      > Last updated: [CURRENT_DATE]

      ## 📋 Planning (Backlog)
      *No planning specs*

      ## 🔄 Active (In Progress)
      *No active specs*

      ## ✅ Completed (Done)
      *No completed specs*

      ## 🗄️ Archived
      *No archived specs*

      ## 📊 Summary
      - **Planning**: 0 specs
      - **Active**: 0 specs
      - **Completed**: 0 specs
      - **Archived**: 0 specs
      - **Total**: 0 specs

      ---
      *Dashboard generated automatically. Update spec status files to refresh this dashboard.*
    </template>
  </specs_dashboard>
  
  <lifecycle_guide>
    <file_path>.agent-os/spec-lifecycle-guide.md</file_path>
    <template>
      # Spec Lifecycle Management Guide

      ## Quick Reference

      ### Status Categories
      - **Planning**: Specs ready for implementation
      - **Active**: Specs currently being implemented
      - **Completed**: Specs finished and tested
      - **Archived**: Specs cleaned up and archived

      ### Folder Naming Convention
      - `planning-YYYY-MM-DD-spec-name` (backlog)
      - `active-YYYY-MM-DD-spec-name` (in progress)
      - `completed-YYYY-MM-DD-spec-name` (done)
      - `archived/YYYY-MM-DD-spec-name` (archived)

      ### Commands
      ```bash
      # Generate dashboard
      npm run dashboard

      # Move spec to active
      mv .agent-os/specs/planning-YYYY-MM-DD-spec-name .agent-os/specs/active-YYYY-MM-DD-spec-name

      # Move spec to completed
      mv .agent-os/specs/active-YYYY-MM-DD-spec-name .agent-os/specs/completed-YYYY-MM-DD-spec-name

      # Archive completed spec
      mv .agent-os/specs/completed-YYYY-MM-DD-spec-name .agent-os/specs/archived/YYYY-MM-DD-spec-name
      ```

      ## Status File Template
      Each spec should have a `status.md` file:
      ```markdown
      # Spec Status

      **Spec Name**: [SPEC_NAME]
      **Created**: [YYYY-MM-DD]
      **Current Status**: [planning|active|completed|archived]
      **Last Updated**: [YYYY-MM-DD]

      ## Status History
      - [YYYY-MM-DD] - Created (planning)

      ## Current Phase
      [DESCRIPTION_OF_CURRENT_PHASE]

      ## Next Actions
      - [ ] [NEXT_ACTION_1]
      - [ ] [NEXT_ACTION_2]

      ## Notes
      [ANY_RELEVANT_NOTES]
      ```
    </template>
  </lifecycle_guide>
</lifecycle_files>

<conditional_creation>
  <if_first_spec>
    - Create specs-dashboard.md if it doesn't exist
    - Create spec-lifecycle-guide.md if it doesn't exist
    - Add dashboard generation script to package.json if it doesn't exist
    - Create scripts/ directory if it doesn't exist
    - Create scripts/simple-dashboard-generator.js if it doesn't exist
  </if_first_spec>
  
  <if_not_first_spec>
    - Skip creating dashboard and guide files
    - Skip creating dashboard script
    - Only create status.md for current spec
  </if_not_first_spec>
</conditional_creation>

</step>

<step number="15" name="decision_documentation">

### Step 15: Decision Documentation (Conditional)

Evaluate strategic impact without loading decisions.md and update it only if there's significant deviation from mission/roadmap and user approves.

<conditional_reads>
  IF mission-lite.md NOT in context:
    USE: context-fetcher subagent
    REQUEST: "Get product pitch from mission-lite.md"
  IF roadmap.md NOT in context:
    USE: context-fetcher subagent
    REQUEST: "Get current development phase from roadmap.md"

  <manual_reads>
    <mission_lite>
      - IF NOT already in context: READ @.agent-os/product/mission-lite.md
      - IF already in context: SKIP reading
    </mission_lite>
    <roadmap>
      - IF NOT already in context: READ @.agent-os/product/roadmap.md
      - IF already in context: SKIP reading
    </roadmap>
    <decisions>
      - NEVER load decisions.md into context
    </decisions>
  </manual_reads>
</conditional_reads>

<decision_analysis>
  <review_against>
    - @.agent-os/product/mission-lite.md (conditional)
    - @.agent-os/product/roadmap.md (conditional)
  </review_against>
  <criteria>
    - significantly deviates from mission in mission-lite.md
    - significantly changes or conflicts with roadmap.md
  </criteria>
</decision_analysis>

<decision_tree>
  IF spec_does_NOT_significantly_deviate:
    SKIP this entire step
    STATE "Spec aligns with mission and roadmap"
    PROCEED to step 13
  ELSE IF spec_significantly_deviates:
    EXPLAIN the significant deviation
    ASK user: "This spec significantly deviates from our mission/roadmap. Should I draft a decision entry?"
    IF user_approves:
      DRAFT decision entry
      UPDATE decisions.md
    ELSE:
      SKIP updating decisions.md
      PROCEED to step 13
</decision_tree>

<decision_template>
  ## [CURRENT_DATE]: [DECISION_TITLE]

  **ID:** DEC-[NEXT_NUMBER]
  **Status:** Accepted
  **Category:** [technical/product/business/process]
  **Related Spec:** @.agent-os/specs/YYYY-MM-DD-spec-name/

  ### Decision

  [DECISION_SUMMARY]

  ### Context

  [WHY_THIS_DECISION_WAS_NEEDED]

  ### Deviation

  [SPECIFIC_DEVIATION_FROM_MISSION_OR_ROADMAP]
</decision_template>

</step>

<step number="16" name="execution_readiness">

### Step 16: Execution Readiness Check

Evaluate readiness to begin implementation after completing all previous steps, presenting the first task summary and requesting user confirmation to proceed.

<readiness_summary>
  <present_to_user>
    - Spec name and description
    - First task summary from tasks.md
    - Estimated complexity/scope
    - Key deliverables for task 1
  </present_to_user>
</readiness_summary>

<execution_prompt>
  PROMPT: "The spec planning is complete. The first task is:

  **Task 1:** [FIRST_TASK_TITLE]
  [BRIEF_DESCRIPTION_OF_TASK_1_AND_SUBTASKS]

  **Note:** I will create a feature branch for this implementation to keep the main branch clean and enable proper code review.

  Would you like me to proceed with implementing Task 1? I will focus only on this first task and its subtasks unless you specify otherwise.

  Type 'yes' to proceed with Task 1, or let me know if you'd like to review or modify the plan first."
</execution_prompt>

<execution_flow>
  IF user_confirms_yes:
    REFERENCE: @~/.agent-os/instructions/core/execute-tasks.md
    FOCUS: Only Task 1 and its subtasks
    CONSTRAINT: Do not proceed to additional tasks without explicit user request
  ELSE:
    WAIT: For user clarification or modifications
</execution_flow>

</step>

</process_flow>

## Lifecycle Management Commands

### Test Lifecycle Management
Use `@test-lifecycle` to test the lifecycle management system in your project:

<test_lifecycle_command>
  <trigger>@test-lifecycle</trigger>
  <actions>
    1. Check if .agent-os/specs directory exists
    2. Generate dashboard if specs exist
    3. Create test lifecycle files if needed
    4. Show lifecycle management status
    5. Provide next steps for implementation
  </actions>
</test_lifecycle_command>

<test_lifecycle_process>
  <check_project_structure>
    - Verify .agent-os/specs directory exists
    - Count existing specs
    - Check for dashboard files
    - Verify package.json scripts
  </check_project_structure>
  
  <generate_test_files>
    - Create specs-dashboard.md if missing
    - Create spec-lifecycle-guide.md if missing
    - Add dashboard script to package.json if missing
    - Create test status.md files for existing specs
  </generate_test_files>
  
  <show_results>
    - Display current spec status
    - Show dashboard preview
    - List available commands
    - Provide implementation guidance
  </show_results>
</test_lifecycle_process>

## Execution Standards

<standards>
  <follow>
    - @.agent-os/product/code-style.md
    - @.agent-os/product/dev-best-practices.md
    - @.agent-os/product/tech-stack.md
  </follow>
  <maintain>
    - Consistency with product mission
    - Alignment with roadmap
    - Technical coherence
  </maintain>
  <create>
    - Comprehensive documentation
    - Clear implementation path
    - Testable outcomes
  </create>
</standards>

<final_checklist>
  <verify>
    - [ ] Accurate date determined via file system
    - [ ] Spec folder created with correct date prefix
    - [ ] spec.md contains all required sections
    - [ ] All applicable sub-specs created
    - [ ] User approved documentation
    - [ ] tasks.md created with TDD approach
    - [ ] Cross-references added to spec.md
    - [ ] Strategic decisions evaluated
  </verify>
</final_checklist>
