---
description: Audit claimed-complete work vs codebase; propose and apply spec/task updates
globs:
alwaysApply: false
version: 1.1
encoding: UTF-8
---

# /audit-missing - Audit and Fix Missing Implementations (Generalized)

## Overview

Analyzes claimed-complete work against the actual codebase, identifies missing or incorrect functionality, and proposes concrete changes to specs and tasks for immediate re-execution. Works with any programming language and project structure.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<project_detection>
  <auto_detect>
    CHECK: package.json → nodejs/typescript
    CHECK: requirements.txt OR pyproject.toml → python
    CHECK: Cargo.toml → rust
    CHECK: go.mod → golang
    CHECK: pom.xml OR build.gradle → java
    CHECK: composer.json → php
    CHECK: *.sln OR *.csproj → dotnet
    DEFAULT: generic
  </auto_detect>
  
  <custom_config>
    READ: .agent-os/config/audit-patterns.yml
    IF exists: Use custom patterns
    ELSE: Use detected project type patterns
  </custom_config>
</project_detection>

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
  <universal_components>
    - Functions and methods
    - Classes and structs
    - Modules and packages
    - Configuration files
    - Test coverage requirements
    - Documentation files
  </universal_components>
  
  <conditional_components>
    IF database_project:
      - Database tables and columns
      - Migrations and schema changes
      - Indexes and constraints
    
    IF web_api_project:
      - API endpoints and routes
      - Middleware and handlers
      - Authentication and authorization
    
    IF frontend_project:
      - UI components and states
      - Stylesheets and assets
      - Client-side routing
  </conditional_components>
</extraction_targets>

<instructions>
  ACTION: Parse all specification documents
  BUILD: Comprehensive list of expected components
  ORGANIZE: By category (functions, classes, config, etc.)
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

### Step 4: Technology-Aware Codebase Analysis

Systematically verify each expected component exists using language-specific patterns.

<file_patterns>
  <nodejs_typescript>
    SOURCE:
      - src/**/*.{js,ts,jsx,tsx}
      - lib/**/*.{js,ts}
      - app/**/*.{js,ts}
      - routes/**/*.{js,ts}
    CONFIG:
      - package.json
      - *.config.{js,ts}
      - tsconfig.json
    TESTS:
      - test/**/*.{js,ts}
      - tests/**/*.{js,ts}
      - **/*.test.{js,ts}
      - **/*.spec.{js,ts}
    DATABASE:
      - migrations/**/*
      - prisma/**/*
      - models/**/*.{js,ts}
  </nodejs_typescript>
  
  <python>
    SOURCE:
      - src/**/*.py
      - app/**/*.py
      - backend/**/*.py
      - api/**/*.py
    CONFIG:
      - requirements.txt
      - pyproject.toml
      - setup.py
      - config/**/*.py
    TESTS:
      - test/**/*.py
      - tests/**/*.py
      - **/*_test.py
      - **/test_*.py
    DATABASE:
      - migrations/**/*.py
      - models/**/*.py
      - database/**/*.py
  </python>
  
  <rust>
    SOURCE:
      - src/**/*.rs
      - lib/**/*.rs
    CONFIG:
      - Cargo.toml
      - Cargo.lock
    TESTS:
      - tests/**/*.rs
      - **/*_test.rs
    DATABASE:
      - migrations/**/*.rs
      - src/models/**/*.rs
  </rust>
  
  <golang>
    SOURCE:
      - **/*.go
      - cmd/**/*.go
      - internal/**/*.go
    CONFIG:
      - go.mod
      - go.sum
    TESTS:
      - **/*_test.go
    DATABASE:
      - migrations/**/*.go
      - models/**/*.go
  </golang>
  
  <java>
    SOURCE:
      - src/main/java/**/*.java
      - src/main/kotlin/**/*.kt
    CONFIG:
      - pom.xml
      - build.gradle
      - application.properties
    TESTS:
      - src/test/java/**/*.java
      - src/test/kotlin/**/*.kt
    DATABASE:
      - src/main/resources/db/migration/**/*
      - src/main/java/**/entity/**/*.java
  </java>
  
  <generic>
    SOURCE:
      - src/**/*
      - lib/**/*
      - app/**/*
    CONFIG:
      - config/**/*
      - *.config.*
      - *.json
      - *.yml
      - *.yaml
    TESTS:
      - test/**/*
      - tests/**/*
    DATABASE:
      - migrations/**/*
      - models/**/*
      - database/**/*
      - db/**/*
  </generic>
</file_patterns>

<verification_patterns>
  <nodejs_typescript>
    FUNCTIONS: "function [NAME]|const [NAME] =|export.*[NAME]"
    CLASSES: "class [NAME]|interface [NAME]|type [NAME]"
    EXPORTS: "export.*[NAME]|module.exports.*[NAME]"
    ROUTES: "app\.(get|post|put|delete)|router\.|@[A-Z].*\("
  </nodejs_typescript>
  
  <python>
    FUNCTIONS: "def [NAME]"
    CLASSES: "class [NAME]"
    IMPORTS: "from.*import.*[NAME]|import.*[NAME]"
    ROUTES: "@app\.route|@api\.|def.*endpoint"
  </python>
  
  <rust>
    FUNCTIONS: "fn [NAME]|pub fn [NAME]"
    STRUCTS: "struct [NAME]|pub struct [NAME]"
    TRAITS: "trait [NAME]|impl.*[NAME]"
    MODULES: "mod [NAME]|pub mod [NAME]"
  </rust>
  
  <golang>
    FUNCTIONS: "func [NAME]|func \([^)]*\) [NAME]"
    STRUCTS: "type [NAME] struct"
    INTERFACES: "type [NAME] interface"
    METHODS: "func \([^)]*\) [NAME]"
  </golang>
  
  <java>
    CLASSES: "class [NAME]|interface [NAME]|enum [NAME]"
    METHODS: "public.*[NAME]\(|private.*[NAME]\("
    ANNOTATIONS: "@[A-Z][a-zA-Z]*"
    IMPORTS: "import.*[NAME]"
  </java>
  
  <generic>
    GENERAL: "[NAME]"
    DEFINITIONS: "def.*[NAME]|function.*[NAME]|class.*[NAME]"
    REFERENCES: "[NAME]\s*[=:(]"
  </generic>
</verification_patterns>

<instructions>
  ACTION: Auto-detect project type and load appropriate patterns
  SCAN: Codebase using technology-specific verification patterns
  VERIFY: Implementation matches specification requirements
  DOCUMENT: Missing, partial, or incorrect implementations
  COLLECT: Evidence of what actually exists vs what's claimed
</instructions>

</step>

<step number="5" name="discrepancy_analysis">

### Step 5: Analyze Discrepancies

Compare expectations vs reality to identify all gaps using language-agnostic analysis.

<discrepancy_types>
  <missing_entirely>
    DEFINITION: Specified but not implemented at all
    SEVERITY: Critical
    ACTION: Full implementation needed
    DETECTION: No matching patterns found in codebase
  </missing_entirely>
  
  <partial_implementation>
    DEFINITION: Started but incomplete
    SEVERITY: High
    ACTION: Complete missing parts
    DETECTION: Some but not all expected patterns found
  </partial_implementation>
  
  <incorrect_implementation>
    DEFINITION: Exists but doesn't match spec
    SEVERITY: High
    ACTION: Fix implementation
    DETECTION: Pattern found but behavior/structure wrong
  </incorrect_implementation>
  
  <missing_tests>
    DEFINITION: Implementation exists but no tests
    SEVERITY: Medium
    ACTION: Add test coverage
    DETECTION: Source patterns found, test patterns missing
  </missing_tests>
  
  <false_completion>
    DEFINITION: Marked complete but not done
    SEVERITY: Critical
    ACTION: Reopen task and implement
    DETECTION: Task marked [x] but implementation missing
  </false_completion>
</discrepancy_types>

<analysis_output>
  FOR each discrepancy:
    TYPE: [discrepancy_type]
    COMPONENT: [component_name]
    EXPECTED: [from_spec]
    ACTUAL: [from_code_analysis]
    TASK: [original_task_number]
    EVIDENCE: [files_searched_and_patterns_used]
    FIX_REQUIRED: [specific_language_appropriate_action]
</analysis_output>

<instructions>
  ACTION: Compare expectation graph with evidence graph
  CATEGORIZE: Each discrepancy by type and severity
  PRIORITIZE: By impact and dependencies
  DOCUMENT: Clear gap analysis with technology-specific details
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
      SPECIFY: Technology-specific requirements
  </srd_updates>
  
  <technical_spec_updates>
    IF implementation details missing:
      ADD: Language-specific implementation requirements
      UPDATE: Function/method signatures
      CLARIFY: Data models and structures
      SPECIFY: Error handling patterns
      NOTE: Testing requirements
  </technical_spec_updates>
  
  <task_updates>
    FOR each false completion:
      REOPEN: Change [x] to [ ]
      ADD: "REOPENED: [reason]" comment
      CLARIFY: Technology-specific acceptance criteria
    
    FOR each missing component:
      ADD: New subtask with clear implementation requirements
      SPECIFY: Language-appropriate test requirements
      LINK: To specific files to create/modify
      NOTE: Dependencies and prerequisites
  </task_updates>
</spec_updates>

<update_template>
  ## AUDIT UPDATE - [TIMESTAMP]
  ### Missing Implementations Detected
  
  #### Core Components ([PROJECT_TYPE])
  - [ ] Function: [function_name] - Missing entirely
    - Expected in: [file_path]
    - Signature: [expected_signature]
    - Tests: [test_requirements]
  
  #### Configuration
  - [ ] Config: [config_item] - Not implemented
    - File: [config_file]
    - Format: [format_requirements]
  
  #### Tests
  - [ ] Test: [test_name] - Missing coverage
    - Component: [component_tested]
    - Coverage: [requirements]
  
  #### Reopened Tasks
  - [ ] Task 3.2 - REOPENED: [specific_reason]
    - Evidence: [what_was_missing]
    - Fix: [language_specific_action]
  
  ### Re-execution Command
  Run: `/execute-task spec=[spec_folder] task=3.2`
</update_template>

<instructions>
  ACTION: Use file-creator subagent
  REQUEST: "Update [spec_file] with audit findings"
  GENERATE: Technology-appropriate, actionable updates
  PRESERVE: Original content (append only)
  ADAPT: Language and framework conventions
</instructions>

</step>

<step number="7" subagent="file-creator" name="create_recap_correction">

### Step 7: Create Recap Correction

Use file-creator subagent to document the audit findings in recaps.

<recap_correction_template>
  # [YYYY-MM-DD] Audit Correction: [Feature Name]
  
  This corrects the recap at .agent-os/recaps/[original_recap].md
  
  ## Project Context
  - Language/Framework: [detected_project_type]
  - Patterns Used: [verification_patterns_applied]
  - Files Analyzed: [number_of_files_checked]
  
  ## Audit Findings
  
  The following components were marked complete but found missing or incorrect:
  
  ### Missing Implementations
  - [Component 1]: Expected in [file], pattern "[pattern]" not found
  - [Component 2]: Partially implemented, missing [specific_language_details]
  
  ### False Completions
  - Task [X.Y]: Marked complete but [specific_technology_issue]
  
  ### Required Fixes
  1. [Technology-specific action 1]
  2. [Language-appropriate action 2]
  
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
  DOCUMENT: All corrections and findings with technology context
  LINK: To updated specs and specific implementation requirements
</instructions>

</step>

<step number="8" name="generate_execution_plan">

### Step 8: Generate Ready-to-Run Execution Plan

Create ordered list of tasks ready for immediate execution, adapted to project technology.

<execution_plan>
  <task_queue>
    PRIORITY 1 - Critical Missing:
    - [ ] Task X.Y: [description]
      Command: `/execute-task spec=[folder] task=X.Y`
      Files: [technology_appropriate_files_to_create]
      Tests: [language_specific_test_requirements]
      Dependencies: [framework_specific_dependencies]
    
    PRIORITY 2 - Fix Incorrect:
    - [ ] Task A.B: [description]
      Command: `/execute-task spec=[folder] task=A.B`
      Fix: [technology_specific_correction]
    
    PRIORITY 3 - Add Tests:
    - [ ] Task M.N: [description]
      Command: `/execute-task spec=[folder] task=M.N`
      Tests: [language_appropriate_test_patterns]
  </task_queue>
  
  <dependencies>
    IDENTIFY: Task dependencies and language-specific prerequisites
    ORDER: By execution sequence and build requirements
    NOTE: Blockers, missing dependencies, and setup requirements
  </dependencies>
</execution_plan>

<final_output>
  ## Audit Summary
  - Project Type: [detected_language_framework]
  - Scope: [spec_folders_audited]
  - User prompt: "[original_prompt]"
  - Verdict: X verified / Y missing / Z partial / W incorrect
  
  ## Key Findings
  1. [Most critical missing component with technology context]
  2. [Second critical issue with implementation details]
  3. [Third issue with language-specific requirements]
  
  ## Files Analyzed
  - Source: [source_patterns] ([number] files)
  - Tests: [test_patterns] ([number] files)
  - Config: [config_patterns] ([number] files)
  
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
  /reconcile scope=[appropriate_scope]
  /audit-missing
  ```
</final_output>

<instructions>
  ACTION: Generate technology-aware execution plan
  PRIORITIZE: By severity, dependencies, and build order
  FORMAT: Ready-to-copy commands with language-specific context
  INCLUDE: Technology-appropriate verification steps
</instructions>

</step>

</process_flow>

<critical_behaviors>
  - NEVER delete or overwrite existing content
  - ALWAYS append audit markers with timestamps
  - PRESERVE original specifications
  - MAINTAIN clear audit trail
  - FOCUS on actionable fixes appropriate to detected technology
  - GENERATE immediately runnable commands
  - LINK evidence to findings with file paths and patterns
  - RESPECT task dependencies and build requirements
  - ADAPT analysis to project language and framework conventions
</critical_behaviors>

<error_handling>
  IF spec not found:
    PROMPT: "Which spec would you like to audit?"
    LIST: Available specs in .agent-os/specs/
  
  IF project type unclear:
    USE: Generic patterns
    NOTE: "Project type auto-detection failed, using generic analysis"
  
  IF no git history:
    FALLBACK: Analyze current state only
    NOTE: "No git history available for timeline analysis"
  
  IF language-specific tools unavailable:
    FALLBACK: Text-based pattern matching
    NOTE: "Language-specific analysis unavailable, using generic patterns"
</error_handling>

<custom_configuration>
  FILE: .agent-os/config/audit-patterns.yml
  PURPOSE: Override default patterns for custom project structures
  
  EXAMPLE:
  ```yaml
  project_type: "custom"
  file_patterns:
    source:
      - "custom/src/**/*.ext"
      - "special/lib/**/*.ext"
    tests:
      - "custom/test/**/*.ext"
  verification_patterns:
    functions: "mydef [NAME]"
    classes: "myclass [NAME]"
  ```
</custom_configuration>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
  VERIFY: All spec updates are valid for /execute-task
  CONFIRM: Recap correction created with technology context
  CHECK: Execution commands are ready and appropriate for project type
  VALIDATE: Pattern matching worked correctly for detected language
</post_flight_check>
