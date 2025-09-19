---
description: Audit claimed-complete work vs codebase; propose and apply spec/task updates
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# /audit-missing - Audit and Fix Missing Implementations

## Overview

Analyzes claimed-complete work against the actual codebase, identifies missing or incorrect functionality, and proposes concrete changes to specs and tasks for immediate re-execution.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="context-fetcher" name="scope_determination">

### Step 1: Scope Determination

Use the context-fetcher subagent to determine audit scope based on user input or recent activity.

<scope_analysis>
  <user_input_check>
    IF user provided description of missing functionality:
      EXTRACT: Key terms and feature names
      SEARCH: Related specs in .agent-os/specs/**/
      IDENTIFY: 1-3 most relevant spec folders
    ELSE:
      CHECK: Most recent recap in .agent-os/recaps/
      IDENTIFY: Latest spec folder from recap
      USE: As default audit scope
  </user_input_check>
</scope_analysis>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Find recent recaps and identify scope for audit"
  PROCESS: Extract spec folders and feature names
  VALIDATE: Ensure spec folders exist
</instructions>

</step>

<step number="2" name="expectation_gathering">

### Step 2: Gather Expected Implementation

Build comprehensive expectation graph from specifications and tasks.

<expectation_sources>
  <specs>
    READ: .agent-os/specs/[SCOPE]/spec.md
    READ: .agent-os/specs/[SCOPE]/spec-lite.md
    READ: .agent-os/specs/[SCOPE]/sub-specs/technical-spec.md
    READ: .agent-os/specs/[SCOPE]/sub-specs/database-schema.md
    READ: .agent-os/specs/[SCOPE]/sub-specs/api-spec.md
  </specs>
  
  <tasks>
    READ: .agent-os/specs/[SCOPE]/tasks.md
    EXTRACT: All tasks marked as complete [x]
    NOTE: Acceptance criteria for each task
  </tasks>
  
  <recaps>
    READ: .agent-os/recaps/[SCOPE].md
    EXTRACT: Claimed completions
    NOTE: Any corrections or follow-ups
  </recaps>
</expectation_sources>

<extraction_targets>
  - Database tables and columns
  - RLS policies and indexes
  - API endpoints and middleware
  - Functions and classes
  - Test coverage requirements
  - UI components and states
  - Configuration and settings
</extraction_targets>

<instructions>
  ACTION: Parse all specification documents
  BUILD: Comprehensive list of expected components
  ORGANIZE: By category (database, API, tests, etc.)
  TRACK: Which tasks claimed to implement each component
</instructions>

</step>

<step number="3" subagent="git-workflow" name="evidence_collection">

### Step 3: Collect Implementation Evidence

Use git-workflow subagent to analyze recent commits and current codebase state.

<git_analysis>
  <commit_history>
    COMMAND: git log --since="[RECAP_DATE]" --name-status
    EXTRACT: Files added/modified
    IDENTIFY: Related commits to spec
  </commit_history>
  
  <working_tree>
    COMMAND: git status --porcelain
    CHECK: Uncommitted changes
    NOTE: Incomplete work
  </working_tree>
  
  <diff_analysis>
    COMMAND: git diff HEAD
    EXAMINE: Current changes
    IDENTIFY: Work in progress
  </diff_analysis>
</git_analysis>

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Analyze commits since [RECAP_DATE] for [SPEC_NAME]"
  COLLECT: All file changes related to spec
  DOCUMENT: Actual implementation files
</instructions>

</step>

<step number="4" name="codebase_analysis">

### Step 4: Deep Codebase Analysis

Systematically verify each expected component exists and works correctly.

<verification_matrix>
  <database_verification>
    FOR each expected table:
      CHECK: Table exists in schema
      VERIFY: All columns present
      CONFIRM: RLS policies enabled
      TEST: Indexes created
    
    FOR each migration:
      CHECK: Migration file exists
      VERIFY: Applied successfully
      CONFIRM: Rollback capability
  </database_verification>
  
  <api_verification>
    FOR each expected endpoint:
      CHECK: Route definition exists
      VERIFY: Handler implemented
      CONFIRM: Middleware applied
      TEST: Error handling present
    
    FOR each middleware:
      CHECK: Implementation exists
      VERIFY: Properly registered
      CONFIRM: Test coverage
  </api_verification>
  
  <test_verification>
    FOR each component:
      CHECK: Test file exists
      VERIFY: Test coverage adequate
      CONFIRM: Tests passing
      NOTE: Missing test cases
  </test_verification>
</verification_matrix>

<file_patterns>
  DATABASE:
    - database/migrations/versions/*.py
    - backend/models/*.py
    - config/database.py
  
  API:
    - backend/api/*.py
    - backend/middleware/*.py
    - backend/app.py
  
  TESTS:
    - tests/backend/test_*.py
    - tests/integration/*.py
</file_patterns>

<instructions>
  ACTION: Scan codebase for each expected component
  VERIFY: Implementation matches specification
  DOCUMENT: Missing, partial, or incorrect implementations
  COLLECT: Evidence of what actually exists
</instructions>

</step>

<step number="5" name="discrepancy_analysis">

### Step 5: Analyze Discrepancies

Compare expectations vs reality to identify all gaps.

<discrepancy_types>
  <missing_entirely>
    DEFINITION: Specified but not implemented at all
    SEVERITY: Critical
    ACTION: Full implementation needed
  </missing_entirely>
  
  <partial_implementation>
    DEFINITION: Started but incomplete
    SEVERITY: High
    ACTION: Complete missing parts
  </partial_implementation>
  
  <incorrect_implementation>
    DEFINITION: Exists but doesn't match spec
    SEVERITY: High
    ACTION: Fix implementation
  </incorrect_implementation>
  
  <missing_tests>
    DEFINITION: Implementation exists but no tests
    SEVERITY: Medium
    ACTION: Add test coverage
  </missing_tests>
  
  <false_completion>
    DEFINITION: Marked complete but not done
    SEVERITY: Critical
    ACTION: Reopen task and implement
  </false_completion>
</discrepancy_types>

<analysis_output>
  FOR each discrepancy:
    TYPE: [discrepancy_type]
    COMPONENT: [component_name]
    EXPECTED: [from_spec]
    ACTUAL: [from_code]
    TASK: [original_task_number]
    EVIDENCE: [files_checked]
    FIX_REQUIRED: [specific_action]
</analysis_output>

<instructions>
  ACTION: Compare expectation graph with evidence graph
  CATEGORIZE: Each discrepancy by type
  PRIORITIZE: By severity and dependencies
  DOCUMENT: Clear gap analysis
</instructions>

</step>

<step number="6" subagent="file-creator" name="propose_fixes">

### Step 6: Propose Specification Updates

Use file-creator subagent to generate updated specs and tasks.

<spec_updates>
  <srd_updates>
    IF requirements changed or unclear:
      ADD: Clarifications section
      UPDATE: Acceptance criteria
      DOCUMENT: Edge cases discovered
  </srd_updates>
  
  <technical_spec_updates>
    IF implementation details missing:
      ADD: Specific implementation requirements
      UPDATE: API signatures
      CLARIFY: Data models
      SPECIFY: Error handling
  </technical_spec_updates>
  
  <task_updates>
    FOR each false completion:
      REOPEN: Change [x] to [ ]
      ADD: "REOPENED: [reason]" comment
      CLARIFY: Acceptance criteria
    
    FOR each missing component:
      ADD: New subtask with clear requirements
      SPECIFY: Test requirements
      LINK: To specific files to create/modify
  </task_updates>
</spec_updates>

<update_template>
  ## AUDIT UPDATE - [TIMESTAMP]
  ### Missing Implementations Detected
  
  #### Database Components
  - [ ] Table: [table_name] - Missing entirely
    - Required columns: [list]
    - RLS policies needed
    - Indexes: [list]
  
  #### API Components  
  - [ ] Endpoint: [method] [path] - Not implemented
    - Handler: [file_path]
    - Middleware: [requirements]
    - Tests: [test_file]
  
  #### Reopened Tasks
  - [ ] Task 3.2 - REOPENED: RLS policies not created
    - Evidence: No policies found in pg_policies
    - Fix: Run create_rls_policies() for all tables
  
  ### Re-execution Command
  Run: `/execute-task spec=[spec_folder] task=3.2`
</update_template>

<instructions>
  ACTION: Use file-creator subagent
  REQUEST: "Update [spec_file] with audit findings"
  GENERATE: Clear, actionable updates
  PRESERVE: Original content (append only)
</instructions>

</step>

<step number="7" subagent="file-creator" name="create_recap_correction">

### Step 7: Create Recap Correction

Use file-creator subagent to document the audit findings in recaps.

<recap_correction_template>
  # [YYYY-MM-DD] Audit Correction: [Feature Name]
  
  This corrects the recap at .agent-os/recaps/[original_recap].md
  
  ## Audit Findings
  
  The following components were marked complete but found missing or incorrect:
  
  ### Missing Implementations
  - [Component 1]: Expected in [file], not found
  - [Component 2]: Partially implemented, missing [details]
  
  ### False Completions
  - Task [X.Y]: Marked complete but [specific_issue]
  
  ### Required Fixes
  1. [Specific action 1]
  2. [Specific action 2]
  
  ## Updated Status
  - Components verified: X/Y
  - Tasks actually complete: X/Y
  - Re-execution required: Yes
  
  ## Next Steps
  See updated specs at: .agent-os/specs/[spec_folder]/
  Run: `/execute-task spec=[spec_folder]`
</recap_correction_template>

<instructions>
  ACTION: Use file-creator subagent
  CREATE: .agent-os/recaps/[date]-audit-[feature].md
  DOCUMENT: All corrections and findings
  LINK: To updated specs
</instructions>

</step>

<step number="8" name="generate_execution_plan">

### Step 8: Generate Ready-to-Run Execution Plan

Create ordered list of tasks ready for immediate execution.

<execution_plan>
  <task_queue>
    PRIORITY 1 - Critical Missing:
    - [ ] Task X.Y: [description]
      Command: `/execute-task spec=[folder] task=X.Y`
      Files: [list_of_files_to_create]
      Tests: [required_tests]
    
    PRIORITY 2 - Fix Incorrect:
    - [ ] Task A.B: [description]
      Command: `/execute-task spec=[folder] task=A.B`
      Fix: [specific_correction]
    
    PRIORITY 3 - Add Tests:
    - [ ] Task M.N: [description]
      Command: `/execute-task spec=[folder] task=M.N`
      Tests: [test_requirements]
  </task_queue>
  
  <dependencies>
    IDENTIFY: Task dependencies
    ORDER: By execution sequence
    NOTE: Blockers and prerequisites
  </dependencies>
</execution_plan>

<final_output>
  ## Audit Summary
  - Scope: [spec_folders_audited]
  - User prompt: "[original_prompt]"
  - Verdict: X verified / Y missing / Z partial / W incorrect
  
  ## Key Findings
  1. [Most critical missing component]
  2. [Second critical issue]
  3. [Third issue]
  
  ## Proposed Spec Changes
  - Updated: .agent-os/specs/[folder]/tasks.md
  - Updated: .agent-os/specs/[folder]/sub-specs/technical-spec.md
  - Created: .agent-os/recaps/[date]-audit-[feature].md
  
  ## Ready to Execute
  
  ### Immediate (Run Now):
  ```
  /execute-task spec=[folder] task=3.2
  ```
  
  ### Next:
  ```
  /execute-task spec=[folder] task=3.3
  ```
  
  ### Verification:
  After execution, run:
  ```
  /reconcile scope=database
  /audit-missing
  ```
</final_output>

<instructions>
  ACTION: Generate clear execution plan
  PRIORITIZE: By severity and dependencies
  FORMAT: Ready-to-copy commands
  INCLUDE: Verification steps
</instructions>

</step>

</process_flow>

<critical_behaviors>
  - NEVER delete or overwrite existing content
  - ALWAYS append audit markers with timestamps
  - PRESERVE original specifications
  - MAINTAIN clear audit trail
  - FOCUS on actionable fixes
  - GENERATE immediately runnable commands
  - LINK evidence to findings
  - RESPECT task dependencies
</critical_behaviors>

<error_handling>
  IF spec not found:
    PROMPT: "Which spec would you like to audit?"
    LIST: Available specs in .agent-os/specs/
  
  IF no git history:
    FALLBACK: Analyze current state only
    NOTE: "No git history available for timeline analysis"
  
  IF database unreachable:
    FOCUS: On code analysis only
    NOTE: "Database verification skipped - connection unavailable"
</error_handling>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
  VERIFY: All spec updates are valid for /execute-task
  CONFIRM: Recap correction created
  CHECK: Execution commands are ready
</post_flight_check>