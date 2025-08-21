---
description: Rules to execute a task and its sub-tasks using Agent OS with mandatory specification awareness
globs:
alwaysApply: false
version: 2.0
encoding: UTF-8
---

# Task Execution Rules

## Overview

Execute a specific task along with its sub-tasks systematically following a TDD development workflow.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>


<process_flow>

<step number="1" name="specification_discovery" priority="MANDATORY">

### Step 1: Specification Discovery

BEFORE reading task details, discover and catalog ALL available specifications and requirements documentation.

<specification_locations>
  <search_directories>
    - .agent-os/specs/
    - .agent-os/specifications/  
    - specs/
    - docs/
    - requirements/
    - architecture/
    - design/
  </search_directories>
  
  <search_patterns>
    - *-spec.md, *-specification.md
    - requirements.md, *-requirements.md
    - schema.md, *-schema.md
    - architecture.md, design.md
    - api-*.md, interface-*.md
    - business-*.md, logic-*.md
    - README.md files in relevant directories
  </search_patterns>
</specification_locations>

<discovery_process>
  1. Search for specification files using patterns above
  2. Catalog found specifications with brief descriptions
  3. Identify which specs are relevant to the current task domain
  4. Note any missing specifications for critical areas
</discovery_process>

<instructions>
  ACTION: Search project for ALL specification files
  CATALOG: Create index of available specs and their purposes
  IDENTIFY: Specs relevant to current task domain
  DOCUMENT: Available specifications before proceeding
</instructions>

</step>

<step number="2" name="task_understanding_with_specs">

### Step 2: Task Understanding with Specification Context

Read and analyze tasks from tasks.md while mapping requirements to discovered specifications.

<task_analysis_enhanced>
  <read_from_tasks_md>
    - Parent task description
    - All sub-task descriptions  
    - Task dependencies
    - Expected outcomes
  </read_from_tasks_md>
  
  <specification_mapping>
    For each task requirement:
    - Search for corresponding spec sections
    - Extract relevant constraints and rules
    - Note any requirements without spec coverage
    - Document spec-to-requirement relationships
  </specification_mapping>
</task_analysis_enhanced>

<instructions>
  ACTION: Read tasks AND map to relevant specifications
  ANALYZE: Requirements in context of available specs
  EXTRACT: All constraints, rules, and expectations from specs
  IDENTIFY: Any gaps between tasks and specifications
</instructions>

</step>

<step number="2" name="technical_spec_review">

### Step 2: Technical Specification Review

Search and extract relevant sections from technical-spec.md to understand the technical implementation approach for this task.

<selective_reading>
  <search_technical_spec>
    FIND sections in technical-spec.md related to:
    - Current task functionality
    - Implementation approach for this feature
    - Integration requirements
    - Performance criteria
  </search_technical_spec>
</selective_reading>

<instructions>
  ACTION: Search technical-spec.md for task-relevant sections
  EXTRACT: Only implementation details for current task
  SKIP: Unrelated technical specifications
  FOCUS: Technical approach for this specific feature
</instructions>

</step>

<step number="3" subagent="context-fetcher" name="best_practices_review">

### Step 3: Best Practices Review

Use the context-fetcher subagent to retrieve relevant sections from @.agent-os/standards/best-practices.md that apply to the current task's technology stack and feature type.

<selective_reading>
  <search_best_practices>
    FIND sections relevant to:
    - Task's technology stack
    - Feature type being implemented
    - Testing approaches needed
    - Code organization patterns
  </search_best_practices>
</selective_reading>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Find best practices sections relevant to:
            - Task's technology stack: [CURRENT_TECH]
            - Feature type: [CURRENT_FEATURE_TYPE]
            - Testing approaches needed
            - Code organization patterns"
  PROCESS: Returned best practices
  APPLY: Relevant patterns to implementation
</instructions>

</step>

<step number="4" subagent="context-fetcher" name="code_style_review">

### Step 4: Code Style Review

Use the context-fetcher subagent to retrieve relevant code style rules from @.agent-os/standards/code-style.md for the languages and file types being used in this task.

<selective_reading>
  <search_code_style>
    FIND style rules for:
    - Languages used in this task
    - File types being modified
    - Component patterns being implemented
    - Testing style guidelines
  </search_code_style>
</selective_reading>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Find code style rules for:
            - Languages: [LANGUAGES_IN_TASK]
            - File types: [FILE_TYPES_BEING_MODIFIED]
            - Component patterns: [PATTERNS_BEING_IMPLEMENTED]
            - Testing style guidelines"
  PROCESS: Returned style rules
  APPLY: Relevant formatting and patterns
</instructions>

</step>

<step number="5" name="approach_design_and_validation">

### Step 5: Approach Design and Specification Validation

Document implementation approach and validate against specifications BEFORE coding.

<approach_documentation>
  <design_summary>
    ## Implementation Approach
    
    ### Specification Alignment
    - Relevant specs: [list spec files and sections consulted]
    - Key requirements: [extracted from specifications]
    - Constraints: [from specs and requirements]
    
    ### Implementation Strategy
    - Approach: [high-level implementation method]
    - Expected inputs: [format, structure, constraints]
    - Expected outputs: [format, structure, validation criteria]
    - Dependencies: [external systems, libraries, data sources]
    
    ### Validation Criteria
    - Success metrics: [from specifications]
    - Acceptance criteria: [from requirements]
    - Error handling: [from specs or best practices]
  </design_summary>
</approach_documentation>

<pre_implementation_validation>
  VERIFY approach against specifications:
  ✓ Implementation strategy aligns with architectural specs
  ✓ Expected outputs match specification requirements
  ✓ Dependencies and interfaces follow defined contracts
  ✓ Error handling covers specified scenarios
  
  HALT if approach conflicts with specifications
</pre_implementation_validation>

<instructions>
  ACTION: Document implementation approach BEFORE coding
  VALIDATE: Approach against all relevant specifications
  CONFIRM: Expected outcomes align with spec requirements
  PROCEED: Only after validation confirms spec compliance
</instructions>

</step>

<step number="6" name="task_execution">

### Step 6: Task and Sub-task Execution with Specification Compliance

Execute the parent task and all sub-tasks in order using test-driven development (TDD) approach with specification compliance checks.

<typical_task_structure>
  <first_subtask>Write tests for [feature]</first_subtask>
  <middle_subtasks>Implementation steps</middle_subtasks>
  <final_subtask>Verify all tests pass</final_subtask>
</typical_task_structure>

<execution_order>
  <subtask_1_tests>
    IF sub-task 1 is "Write tests for [feature]":
      - Write tests based on specification requirements
      - Include unit tests, integration tests, edge cases from specs
      - Add tests for specification compliance
      - Run tests to ensure they fail appropriately
      - Mark sub-task 1 complete
  </subtask_1_tests>

  <middle_subtasks_implementation>
    FOR each implementation sub-task (2 through n-1):
      - Implement functionality according to specifications
      - Reference spec sections in code comments
      - Make relevant tests pass
      - Validate outputs against spec expectations during development
      - Update any adjacent/related tests if needed
      - Refactor while keeping tests green
      - Mark sub-task complete
  </middle_subtasks_implementation>

  <final_subtask_verification>
    IF final sub-task is "Verify all tests pass":
      - Run entire test suite
      - Fix any remaining failures
      - Ensure specification compliance tests pass
      - Ensure no regressions
      - Mark final sub-task complete
  </final_subtask_verification>
</execution_order>

<specification_compliance_during_implementation>
  <during_coding>
    - Reference specification sections in code comments
    - Add runtime validation for spec requirements where appropriate
    - Log specification compliance checkpoints
    - Implement spec violation exceptions/warnings
  </during_coding>
  
  <testing_with_specs>
    - Write tests that validate specification compliance
    - Test edge cases defined in specifications
    - Verify error handling matches spec requirements
    - Test integration points as documented
  </testing_with_specs>
</specification_compliance_during_implementation>

<test_management>
  <new_tests>
    - Written in first sub-task
    - Cover all aspects of parent feature
    - Include edge cases and error handling
  </new_tests>
  <test_updates>
    - Made during implementation sub-tasks
    - Update expectations for changed behavior
    - Maintain backward compatibility
  </test_updates>
</test_management>

<instructions>
  ACTION: Execute sub-tasks in their defined order
  RECOGNIZE: First sub-task typically writes all tests
  IMPLEMENT: Middle sub-tasks build functionality
  VERIFY: Final sub-task ensures all tests pass
  UPDATE: Mark each sub-task complete as finished
</instructions>

</step>

<step number="6" subagent="test-runner" name="task_test_verification">

### Step 6: Task-Specific Test Verification

Use the test-runner subagent to run and verify only the tests specific to this parent task (not the full test suite) to ensure the feature is working correctly.

<focused_test_execution>
  <run_only>
    - All new tests written for this parent task
    - All tests updated during this task
    - Tests directly related to this feature
  </run_only>
  <skip>
    - Full test suite (done later in execute-tasks.md)
    - Unrelated test files
  </skip>
</focused_test_execution>

<final_verification>
  IF any test failures:
    - Debug and fix the specific issue
    - Re-run only the failed tests
  ELSE:
    - Confirm all task tests passing
    - Ready to proceed
</final_verification>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run tests for [this parent task's test files]"
  WAIT: For test-runner analysis
  PROCESS: Returned failure information
  VERIFY: 100% pass rate for task-specific tests
  CONFIRM: This feature's tests are complete
</instructions>

</step>

<step number="8" name="output_validation" priority="MANDATORY">

### Step 8: Output Validation Against Specifications

Validate ALL outputs against specifications before marking tasks complete.

<validation_checklist>
  <specification_compliance>
    ✓ Output format matches specification requirements
    ✓ Data structure follows defined schemas
    ✓ Business rules and constraints properly enforced
    ✓ Interface contracts correctly implemented
    ✓ Error handling covers specified scenarios
  </specification_compliance>
  
  <quality_checks>
    ✓ Expected functionality delivered
    ✓ Edge cases handled as specified
    ✓ Dependencies work as documented
    ✓ Performance meets specified criteria
    ✓ No specification requirements missed
  </quality_checks>
  
  <anomaly_detection>
    RED FLAGS requiring investigation:
    - Outputs significantly different from spec expectations
    - Missing functionality described in specifications
    - Behavior contradicting documented requirements
    - Dependencies not working as specified
    - Test results not matching acceptance criteria
  </anomaly_detection>
</validation_checklist>

<validation_process>
  1. Compare implementation against each relevant specification
  2. Verify all requirements from specs are addressed
  3. Test edge cases and error scenarios from specifications
  4. Confirm outputs match expected formats and constraints
  5. Validate integration points work as documented
</validation_process>

<failure_handling>
  IF validation fails:
    1. Document specific specification violations
    2. Return to appropriate step (design, implementation, or testing)
    3. Correct violations and re-validate
    4. Do not mark complete until all validations pass
</failure_handling>

<instructions>
  ACTION: Validate ALL outputs against specifications
  COMPARE: Implementation behavior with spec requirements
  TEST: Edge cases and scenarios from specifications
  DOCUMENT: Validation results and compliance status
  HALT: If any specification requirements are violated
</instructions>

</step>

<step number="9" name="task_status_updates">

### Step 9: Mark this task and sub-tasks complete

ONLY after output validation passes, mark this task and its sub-tasks complete by updating each task checkbox to [x] in tasks.md.

<update_format>
  <completed>- [x] Task description</completed>
  <incomplete>- [ ] Task description</incomplete>
  <blocked>
    - [ ] Task description
    ⚠️ Blocking issue: [DESCRIPTION]
  </blocked>
</update_format>

<blocking_criteria>
  <attempts>maximum 3 different approaches</attempts>
  <action>document blocking issue</action>
  <emoji>⚠️</emoji>
</blocking_criteria>

<instructions>
  ACTION: Update tasks.md after each task completion
  MARK: [x] for completed items immediately
  DOCUMENT: Blocking issues with ⚠️ emoji
  LIMIT: 3 attempts before marking as blocked
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
