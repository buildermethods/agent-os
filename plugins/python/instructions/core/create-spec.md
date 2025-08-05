---
description: Python-Specific Spec Creation Rules for Agent OS
globs:
alwaysApply: false
version: 1.1
encoding: UTF-8
---

# Python Spec Creation Rules (Plugin Override)

## Overview

Generate detailed feature specifications aligned with product roadmap and mission, with Python-specific technology stack integration.

<pre_flight_check>
  EXECUTE: @~/.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<python_detection>
  This file is automatically loaded when Python project is detected via:
  - pyproject.toml presence
  - requirements.txt presence  
  - main.py or app.py presence
  - Manual override in .agent-os/product/tech-stack.md
</python_detection>

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

### Step 2: Context Gathering (Conditional) - Python Enhanced

Use the context-fetcher subagent to read mission-lite.md and Python-specific tech stack only if not already in context.

<conditional_logic>
  IF both mission-lite.md AND python tech stack already read in current context:
    SKIP this entire step
    PROCEED to step 3
  ELSE:
    READ only files not already in context:
      - @.agent-os/product/mission-lite.md (if not in context)
      - @plugins/python/standards/python-tech-stack.md (Python override)
      - @plugins/python/standards/python-style.md (if code style needed)
    CONTINUE with context analysis
</conditional_logic>

<context_analysis>
  <mission_lite>core product purpose and value</mission_lite>
  <python_tech_stack>Python 3.12+, NiceGUI, FastAPI, SQLModel requirements</python_tech_stack>
  <python_patterns>NiceGUI UI patterns, FastAPI async patterns, SQLModel ORM patterns</python_patterns>
</context_analysis>

</step>

<step number="3" subagent="context-fetcher" name="requirements_clarification">

### Step 3: Requirements Clarification - Python Enhanced

Use the context-fetcher subagent to clarify scope boundaries and Python-specific technical considerations.

<clarification_areas>
  <scope>
    - in_scope: what is included
    - out_of_scope: what is excluded (optional)
  </scope>
  <python_technical>
    - NiceGUI UI components and layout requirements
    - FastAPI endpoint specifications
    - SQLModel database model requirements
    - Async/await patterns needed
    - Integration with existing Python codebase
  </python_technical>
</clarification_areas>

<decision_tree>
  IF clarification_needed:
    ASK numbered_questions (include Python-specific questions)
    WAIT for_user_response
  ELSE:
    PROCEED to_date_determination
</decision_tree>

</step>

<step number="4" subagent="date-checker" name="date_determination">

### Step 4: Date Determination

Use the date-checker subagent to determine the current date in YYYY-MM-DD format for folder naming. The subagent will output today's date which will be used in subsequent steps.

<subagent_output>
  The date-checker subagent will provide the current date in YYYY-MM-DD format at the end of its response. Store this date for use in folder naming in step 5.
</subagent_output>

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
  - 2025-03-15-user-dashboard-nicegui
  - 2025-03-16-api-authentication-fastapi
  - 2025-03-17-data-models-sqlmodel
</example_names>

</step>

<step number="6" subagent="file-creator" name="create_spec_md">

### Step 6: Create spec.md - Python Enhanced

Use the file-creator subagent to create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec.md using this Python-enhanced template:

<file_template>
  <header>
    # Spec Requirements Document

    > Spec: [SPEC_NAME]
    > Created: [CURRENT_DATE]
    > Tech Stack: Python 3.12+, NiceGUI, FastAPI, SQLModel
  </header>
  <required_sections>
    - Overview
    - User Stories
    - Spec Scope
    - Out of Scope
    - Expected Deliverable
    - Python Implementation Notes
  </required_sections>
</file_template>

<section name="python_implementation_notes">
  <template>
    ## Python Implementation Notes

    ### NiceGUI Components
    - [UI_COMPONENTS_NEEDED]
    - [LAYOUT_REQUIREMENTS]

    ### FastAPI Endpoints
    - [API_ENDPOINTS_NEEDED]
    - [ASYNC_PATTERNS_REQUIRED]

    ### SQLModel Models
    - [DATABASE_MODELS_NEEDED]
    - [RELATIONSHIPS_REQUIRED]
  </template>
  <purpose>Python-specific implementation guidance</purpose>
</section>

</step>

<step number="7" subagent="file-creator" name="create_spec_lite_md">

### Step 7: Create spec-lite.md

Use the file-creator subagent to create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md for the purpose of establishing a condensed spec for efficient AI context usage.

<file_template>
  <header>
    # Spec Summary (Lite) - Python Project
  </header>
</file_template>

<content_structure>
  <spec_summary>
    - source: Step 6 spec.md overview section
    - length: 1-3 sentences
    - content: core goal and objective of the feature
    - python_context: mention key Python technologies used
  </spec_summary>
</content_structure>

</step>

<step number="8" subagent="file-creator" name="create_technical_spec">

### Step 8: Create Technical Specification - Python Enhanced

Use the file-creator subagent to create the file: sub-specs/technical-spec.md using this Python-enhanced template:

<file_template>
  <header>
    # Technical Specification - Python Implementation

    This is the technical specification for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  </header>
</file_template>

<python_spec_sections>
  <nicegui_requirements>
    - UI component specifications
    - Layout and styling requirements
    - Event handling patterns
    - Reactive data binding needs
  </nicegui_requirements>
  <fastapi_requirements>
    - API endpoint definitions
    - Request/response models
    - Authentication requirements
    - Async operation patterns
  </fastapi_requirements>
  <sqlmodel_requirements>
    - Database model definitions
    - Relationship specifications
    - Migration requirements
    - Query patterns needed
  </sqlmodel_requirements>
  <external_dependencies_conditional>
    - only include if new Python packages needed
    - new libraries/packages with version requirements
    - justification for each
    - compatibility with existing stack
  </external_dependencies_conditional>
</python_spec_sections>

</step>

<step number="9" subagent="file-creator" name="create_database_schema">

### Step 9: Create Database Schema (Conditional) - SQLModel Enhanced

Use the file-creator subagent to create the file: sub-specs/database-schema.md ONLY IF database changes needed for this task.

<decision_tree>
  IF spec_requires_database_changes:
    CREATE sub-specs/database-schema.md with SQLModel patterns
  ELSE:
    SKIP this_step
</decision_tree>

<sqlmodel_template>
  <header>
    # Database Schema - SQLModel Implementation

    This is the SQLModel database schema for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  </header>
</sqlmodel_template>

<sqlmodel_sections>
  <model_definitions>
    - SQLModel class definitions
    - Field specifications with types
    - Validation rules
    - Table configurations
  </model_definitions>
  <relationships>
    - Foreign key relationships
    - Back references
    - Many-to-many relationships
    - Cascade behaviors
  </relationships>
  <migrations>
    - SQLModel.metadata.create_all() usage
    - Data migration scripts if needed
    - Index creation
  </migrations>
</sqlmodel_sections>

</step>

<step number="10" subagent="file-creator" name="create_api_spec">

### Step 10: Create API Specification (Conditional) - FastAPI Enhanced

Use the file-creator subagent to create file: sub-specs/api-spec.md ONLY IF API changes needed.

<decision_tree>
  IF spec_requires_api_changes:
    CREATE sub-specs/api-spec.md with FastAPI patterns
  ELSE:
    SKIP this_step
</decision_tree>

<fastapi_template>
  <header>
    # API Specification - FastAPI Implementation

    This is the FastAPI specification for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  </header>
</fastapi_template>

<fastapi_sections>
  <endpoints>
    - FastAPI route decorators
    - Path and query parameters
    - Request/response Pydantic models
    - HTTP status codes
  </endpoints>
  <async_patterns>
    - Async/await usage
    - Database session handling
    - Background tasks if needed
  </async_patterns>
  <integration>
    - NiceGUI frontend integration
    - SQLModel database integration
    - Error handling patterns
  </integration>
</fastapi_sections>

</step>

<step number="11" name="user_review">

### Step 11: User Review

Request user review of spec.md and all sub-specs files, waiting for approval or revision requests before proceeding to task creation.

<review_request>
  I've created the Python-specific spec documentation:

  - Spec Requirements: @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
  - Spec Summary: @.agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md
  - Technical Spec: @.agent-os/specs/YYYY-MM-DD-spec-name/sub-specs/technical-spec.md
  [LIST_OTHER_CREATED_SPECS]

  This spec is configured for Python development with NiceGUI, FastAPI, and SQLModel.
  Please review and let me know if any changes are needed before I create the task breakdown.
</review_request>

</step>

<step number="12" subagent="file-creator" name="create_tasks">

### Step 12: Create tasks.md - Python Enhanced

Use the file-creator subagent to await user approval from step 11 and then create file: tasks.md with Python-specific task patterns.

<python_task_structure>
  <major_tasks>
    - count: 1-5
    - format: numbered checklist
    - grouping: by Python component (models, API, UI)
    - python_patterns: SQLModel → FastAPI → NiceGUI flow
  </major_tasks>
  <subtasks>
    - count: up to 8 per major task
    - format: decimal notation (1.1, 1.2)
    - first_subtask: typically write tests (pytest)
    - python_specific: model tests, API tests, UI tests
    - last_subtask: verify all tests pass
  </subtasks>
</python_task_structure>

<python_task_template>
  ## Tasks

  - [ ] 1. [DATABASE_MODELS_TASK]
    - [ ] 1.1 Write SQLModel tests for [MODELS]
    - [ ] 1.2 Implement SQLModel classes
    - [ ] 1.3 Create database migrations
    - [ ] 1.4 Verify model tests pass

  - [ ] 2. [API_ENDPOINTS_TASK]
    - [ ] 2.1 Write FastAPI endpoint tests
    - [ ] 2.2 Implement FastAPI routes
    - [ ] 2.3 Add request/response validation
    - [ ] 2.4 Verify API tests pass

  - [ ] 3. [UI_COMPONENTS_TASK]
    - [ ] 3.1 Write NiceGUI component tests
    - [ ] 3.2 Implement UI components
    - [ ] 3.3 Add event handlers and data binding
    - [ ] 3.4 Verify UI tests pass
</python_task_template>

</step>

<step number="13" name="decision_documentation">

### Step 13: Decision Documentation (Conditional)

Evaluate strategic impact without loading decisions.md and update it only if there's significant deviation from mission/roadmap and user approves.

<conditional_reads>
  IF mission-lite.md NOT in context:
    USE: context-fetcher subagent
    REQUEST: "Get product pitch from mission-lite.md"
  IF roadmap.md NOT in context:
    USE: context-fetcher subagent
    REQUEST: "Get current development phase from roadmap.md"
</conditional_reads>

<decision_analysis>
  <review_against>
    - @.agent-os/product/mission-lite.md (conditional)
    - @.agent-os/product/roadmap.md (conditional)
    - @plugins/python/standards/python-tech-stack.md (Python alignment)
  </review_against>
</decision_analysis>

</step>

<step number="14" name="execution_readiness">

### Step 14: Execution Readiness Check - Python Enhanced

Evaluate readiness to begin Python implementation after completing all previous steps.

<python_readiness_summary>
  <present_to_user>
    - Spec name and description
    - Python tech stack confirmation (NiceGUI, FastAPI, SQLModel)
    - First task summary from tasks.md
    - Estimated complexity/scope
    - Key Python deliverables for task 1
  </present_to_user>
</python_readiness_summary>

<execution_flow>
  IF user_confirms_yes:
    REFERENCE: @~/.agent-os/instructions/core/execute-tasks.md
    APPLY: Python-specific coding standards from @plugins/python/standards/python-style.md
    FOCUS: Only Task 1 and its subtasks
    CONSTRAINT: Do not proceed to additional tasks without explicit user request
  ELSE:
    WAIT: For user clarification or modifications
</execution_flow>

</step>

</process_flow>

## Python Execution Standards

<python_standards>
  <follow>
    - @plugins/python/standards/python-tech-stack.md
    - @plugins/python/standards/python-style.md
    - @.agent-os/product/dev-best-practices.md
  </follow>
  <python_specific>
    - Use Python 3.12+ features
    - Follow NiceGUI component patterns
    - Implement FastAPI async patterns
    - Use SQLModel for type-safe database operations
    - Apply pytest for comprehensive testing
  </python_specific>
  <maintain>
    - Consistency with product mission
    - Alignment with roadmap
    - Python technical coherence
  </maintain>
</python_standards>

<final_checklist>
  <verify>
    - [ ] Python project detection confirmed
    - [ ] Python tech stack loaded from plugin
    - [ ] Spec folder created with correct date prefix
    - [ ] spec.md contains Python implementation notes
    - [ ] Python-specific sub-specs created as needed
    - [ ] User approved documentation
    - [ ] tasks.md created with Python TDD approach
    - [ ] Python coding standards referenced
  </verify>
</final_checklist>