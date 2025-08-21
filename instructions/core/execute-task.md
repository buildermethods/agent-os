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

<step number="1" name="specification_cache_check" priority="MANDATORY">

### Step 1: Use Cached Specification Index

Use the specification cache passed from execute-tasks.md to quickly access relevant specifications without redundant discovery.

<cache_usage>
  IF spec_cache provided from execute-tasks:
    USE: Cached specification index
    SKIP: File system discovery
    ACCESS: Spec locations from cache
  ELSE:
    FALLBACK: Perform specification discovery
    CACHE: Results for subsequent tasks
</cache_usage>

<cached_index_structure>
  Received from execute-tasks Step 2:
  - Spec file paths and locations
  - Section mappings
  - Last modified timestamps
  - Quick lookup index
</cached_index_structure>

<instructions>
  ACTION: Check for spec_cache parameter
  IF EXISTS: Use cached index for instant spec access
  ELSE: Perform discovery and create cache
  BENEFIT: Saves 2-3 seconds per task execution
  PROCEED: With cached spec information
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

<step number="3" subagent="context-fetcher" name="batched_context_retrieval">

### Step 3: Batched Context Retrieval

Use the context-fetcher subagent to retrieve ALL relevant context in a SINGLE batched request, reducing overhead and improving performance.

<batched_request>
  ACTION: Use context-fetcher subagent
  REQUEST: "Batch retrieve the following context for task execution:
  
    FROM technical-spec.md:
    - Sections related to [CURRENT_TASK_FUNCTIONALITY]
    - Implementation approach for this feature
    - Integration requirements
    - Performance criteria
    
    FROM @.agent-os/standards/best-practices.md:
    - Best practices for [TASK_TECH_STACK]
    - Patterns for [FEATURE_TYPE]
    - Testing approaches
    - Code organization patterns
    
    FROM @.agent-os/standards/code-style.md:
    - Style rules for [LANGUAGES_IN_TASK]
    - Formatting for [FILE_TYPES]
    - Component patterns
    - Testing style guidelines
    
    FROM .agent-os/codebase/ (if exists and needed):
    - Function signatures in [RELEVANT_MODULES]
    - Import paths for [NEEDED_COMPONENTS]
    - Related schemas if data operations
    
    Return as structured summary with clear section markers"
</batched_request>

<optimization_benefits>
  BEFORE: 4 sequential subagent calls (12-16 seconds)
  AFTER: 1 batched subagent call (3-4 seconds)
  SAVINGS: 9-12 seconds per task
  CONTEXT: Remains clean and organized
</optimization_benefits>

<cache_strategy>
  CACHE: Response for entire task duration
  REUSE: For all subtasks within parent task
  CLEAR: Cache when moving to next parent task
</cache_strategy>

<instructions>
  ACTION: Make ONE batched request to context-fetcher
  CACHE: Response for task duration
  USE: Cached context throughout subtasks
  BENEFIT: 75% reduction in context retrieval overhead
</instructions>

</step>

<step number="4" name="approach_design_and_validation">

### Step 4: Approach Design and Specification Validation

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

<step number="5" name="task_execution">

### Step 5: Task and Sub-task Execution with Specification Compliance

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

<test_result_caching>
  CACHE: Test results for use in complete-tasks
  STORE: 
    - Test files executed
    - Pass/fail status
    - Timestamp of test run
  BENEFIT: Avoid re-running same tests in complete-tasks
</test_result_caching>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run tests for [this parent task's test files]"
  WAIT: For test-runner analysis
  CACHE: Results for complete-tasks workflow
  PROCESS: Returned failure information
  VERIFY: 100% pass rate for task-specific tests
  CONFIRM: This feature's tests are complete
</instructions>

</step>

<step number="7" subagent="codebase-indexer" name="update_codebase_references">

### Step 7: Update Codebase References

If any new functions, classes, or exports were created during this task, update the codebase references incrementally.

<conditional-block task-condition="code-created-or-modified">
IF new functions/classes/exports were created OR existing ones modified:
  <smart_skip_check>
    CHECK: Git diff for actual code changes
    IF only test files or documentation changed:
      SKIP: No production code to index
      SAVE: 3-5 seconds
    ELSE IF only minor changes (< 5 lines):
      CONSIDER: Skipping if changes don't affect signatures
    ELSE:
      PROCEED: With incremental update
  </smart_skip_check>
  
  <incremental_update>
    ACTION: Use codebase-indexer subagent
    REQUEST: "Update codebase references for changed files:
              - Files modified: [LIST_OF_MODIFIED_FILES]
              - Extract new/updated signatures
              - Update functions.md and imports.md
              - Maintain existing unchanged references"
    SCOPE: Only files changed in this task
    PRESERVE: References for unchanged files
  </incremental_update>
ELSE:
  SKIP: No code changes requiring reference updates
  LOG: "No indexing needed - no code modifications"
</conditional-block>

<update_strategy>
  <changed_files>
    IDENTIFY: Files created or modified in task
    EXTRACT: New function signatures
    EXTRACT: New exports and imports
    UPDATE: Relevant reference sections
  </changed_files>
  
  <efficiency>
    SCAN: Only changed files
    UPDATE: Only affected sections
    SKIP: Unchanged modules
    MAINTAIN: Alphabetical order
  </efficiency>
</update_strategy>

<instructions>
  ACTION: Check if .agent-os/codebase/ exists
  IF exists AND files were modified:
    USE: codebase-indexer for incremental update
    UPDATE: Only changed file references
    PRESERVE: Existing unchanged references
  ELSE IF not exists:
    SKIP: No reference system initialized
    NOTE: Run @commands/index-codebase.md to enable
  ELSE:
    SKIP: No file changes in this task
</instructions>

</step>

<step number="8" name="task_progress_updates">

### Step 8: Task Status Updates

Update task statuses in real-time as work progresses.

</step>

<step number="9" name="output_validation" priority="MANDATORY">

### Step 9: Output Validation Against Specifications

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

<step number="10" name="task_completion_updates">

### Step 10: Mark this task and sub-tasks complete

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
