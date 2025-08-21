---
description: Debug Spec Rules for Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Debug Spec Rules

## Overview

Debug integration issues, test failures, or systemic problems across multiple tasks within a spec implementation.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="context-fetcher" name="spec_context_loading">

### Step 1: Spec Context Loading

Use the context-fetcher subagent to load the complete spec context and current implementation status.

<spec_context>
  <technical_spec>
    READ: .agent-os/specs/[spec-name]/technical-spec.md
    EXTRACT:
      - Spec overview and goals
      - Technical architecture
      - Integration requirements
      - Acceptance criteria
      - Component interactions
  </technical_spec>
  
  <user_stories>
    READ: .agent-os/specs/[spec-name]/user-stories.md
    UNDERSTAND:
      - Expected user flows
      - Feature requirements
      - Success criteria
      - Use cases
  </user_stories>
  
  <task_status>
    READ: .agent-os/tasks/[spec-name]/tasks.md
    ANALYZE:
      - Completed tasks
      - In-progress tasks
      - Blocked tasks
      - Task dependencies
      - Overall completion status
  </task_status>
</spec_context>

<spec_identification>
  IF spec_not_specified:
    ASK: "Which spec are you debugging? Please provide:
          1. Spec name
          2. Overall issue description
          3. Which tasks are affected
          4. When issues started appearing"
    WAIT for user response
</spec_identification>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Load full context for spec: [SPEC_NAME]
            Read technical-spec.md completely
            Read user-stories.md for requirements
            Analyze tasks.md for implementation status"
  DOCUMENT: Spec context and status
  IDENTIFY: Potential problem areas
</instructions>

</step>

<step number="2" subagent="debug-helper" name="spec_wide_investigation">

### Step 2: Spec-Wide Investigation

Use the debug-helper subagent to investigate issues across the entire spec implementation.

<investigation_scope>
  <integration_testing>
    - Run all spec-related tests
    - Identify failing test patterns
    - Check integration test failures
    - Verify end-to-end flows
  </integration_testing>
  
  <cross_task_analysis>
    - Review task interactions
    - Check data flow between tasks
    - Verify shared components
    - Analyze state management
  </cross_task_analysis>
  
  <architecture_validation>
    - Verify architectural decisions
    - Check component boundaries
    - Validate API contracts
    - Review error propagation
  </architecture_validation>
</investigation_scope>

<common_spec_issues>
  <integration_failures>
    - Mismatched interfaces
    - Incompatible data formats
    - Missing error handling
    - State synchronization issues
  </integration_failures>
  
  <architectural_problems>
    - Circular dependencies
    - Tight coupling
    - Missing abstractions
    - Performance bottlenecks
  </architectural_problems>
  
  <requirement_gaps>
    - Incomplete implementations
    - Misunderstood requirements
    - Missing edge cases
    - Untested scenarios
  </requirement_gaps>
</common_spec_issues>

<instructions>
  ACTION: Use debug-helper subagent
  REQUEST: "Investigate spec-wide issues for: [SPEC_NAME]
            Run all integration tests
            Check task interactions and dependencies
            Analyze component integration
            Identify systemic problems"
  DOCUMENT: All findings
  PRIORITIZE: Issues by impact
</instructions>

</step>

<step number="3" subagent="test-runner" name="comprehensive_spec_testing">

### Step 3: Comprehensive Spec Testing

Use the test-runner subagent to run all tests related to the spec and categorize failures.

<test_categories>
  <unit_tests>
    - Individual component tests
    - Task-specific tests
    - Utility function tests
    - Isolated logic tests
  </unit_tests>
  
  <integration_tests>
    - Cross-component tests
    - Task interaction tests
    - API integration tests
    - Data flow tests
  </integration_tests>
  
  <end_to_end_tests>
    - User flow tests
    - Feature acceptance tests
    - Performance tests
    - Edge case scenarios
  </end_to_end_tests>
</test_categories>

<failure_analysis>
  <categorize_failures>
    - Group by task
    - Group by component
    - Group by test type
    - Group by error type
  </categorize_failures>
  
  <pattern_identification>
    - Common failure causes
    - Systematic issues
    - Environmental factors
    - Timing dependencies
  </pattern_identification>
</failure_analysis>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run comprehensive tests for spec: [SPEC_NAME]
            Include: unit, integration, e2e tests
            Categorize failures by type and component
            Identify failure patterns"
  ANALYZE: Test results
  MAP: Failures to tasks and components
</instructions>

</step>

<step number="4" name="root_cause_mapping">

### Step 4: Root Cause Mapping

Map identified issues to their root causes across the spec implementation.

<issue_mapping>
  <task_level_issues>
    FOR each affected task:
      - Identify specific problems
      - Trace to root cause
      - Note dependencies affected
      - Document fix requirements
  </task_level_issues>
  
  <integration_issues>
    FOR each integration point:
      - Identify contract violations
      - Check data transformations
      - Verify error handling
      - Document gaps
  </integration_issues>
  
  <architectural_issues>
    FOR each architectural problem:
      - Identify design flaws
      - Note scalability issues
      - Check maintainability problems
      - Document refactoring needs
  </architectural_issues>
</issue_mapping>

<priority_matrix>
  <critical>
    - Blocks spec completion
    - Breaks core functionality
    - Data loss or corruption
    - Security vulnerabilities
  </critical>
  
  <high>
    - Major feature broken
    - Multiple tasks affected
    - Performance degradation
    - Poor user experience
  </high>
  
  <medium>
    - Single task affected
    - Workaround available
    - Minor functionality gap
    - Code quality issues
  </medium>
</priority_matrix>

<instructions>
  ACTION: Map all issues to root causes
  CREATE: Issue priority matrix
  IDENTIFY: Fix order and dependencies
  DOCUMENT: Impact assessment
</instructions>

</step>

<step number="5" subagent="project-manager" name="fix_coordination">

### Step 5: Fix Coordination

Use the project-manager subagent to coordinate the fix strategy across affected tasks.

<fix_strategy>
  <sequencing>
    1. Fix blocking issues first
    2. Address integration problems
    3. Resolve task-specific issues
    4. Handle edge cases
    5. Optimize and refactor
  </sequencing>
  
  <task_updates>
    FOR each affected task:
      - Add debug note
      - Update status
      - Mark blockers
      - Note dependencies
  </task_updates>
  
  <coordination_plan>
    - Order of fixes
    - Resource allocation
    - Testing strategy
    - Rollback plan
  </coordination_plan>
</fix_strategy>

<task_management>
  <update_tasks_md>
    ```markdown
    ## Spec Debugging Status
    
    ### Issues Identified
    - [ ] Critical: [issue description]
    - [ ] High: [issue description]
    - [ ] Medium: [issue description]
    
    ### Fix Order
    1. [Task X] - [specific fix needed]
    2. [Task Y] - [integration fix]
    3. [Task Z] - [enhancement]
    ```
  </update_tasks_md>
</task_management>

<instructions>
  ACTION: Use project-manager subagent
  REQUEST: "Coordinate fix strategy for spec: [SPEC_NAME]
            Update all affected tasks with debug status
            Create fix priority order
            Document in tasks.md"
  ENSURE: Clear action plan
  COMMUNICATE: Fix strategy
</instructions>

</step>

<step number="6" name="systematic_fixes">

### Step 6: Implement Systematic Fixes

Implement fixes systematically across the spec, maintaining consistency.

<fix_implementation>
  <critical_fixes>
    FIRST: Address blocking issues
    - Fix data corruption issues
    - Resolve security problems
    - Repair broken integrations
    - Fix core functionality
  </critical_fixes>
  
  <integration_fixes>
    SECOND: Fix integration issues
    - Update interfaces
    - Align data formats
    - Fix state management
    - Improve error handling
  </integration_fixes>
  
  <task_fixes>
    THIRD: Fix task-specific issues
    - Complete missing features
    - Fix edge cases
    - Improve validation
    - Enhance user experience
  </task_fixes>
</fix_implementation>

<consistency_checks>
  - Maintain architectural patterns
  - Follow coding standards
  - Preserve API contracts
  - Keep tests updated
</consistency_checks>

<progressive_validation>
  AFTER each fix:
    1. Run affected tests
    2. Verify integration points
    3. Check dependent tasks
    4. Update documentation
</progressive_validation>

<instructions>
  ACTION: Implement fixes systematically
  FOLLOW: Priority order
  MAINTAIN: Spec consistency
  VALIDATE: Each fix progressively
  UPDATE: Tests and documentation
</instructions>

</step>

<step number="7" subagent="test-runner" name="spec_validation">

### Step 7: Full Spec Validation

Use the test-runner subagent to validate the entire spec implementation after fixes.

<validation_scope>
  <complete_test_suite>
    - All unit tests
    - All integration tests
    - All end-to-end tests
    - Performance benchmarks
    - Edge case scenarios
  </complete_test_suite>
  
  <acceptance_criteria>
    - User stories validated
    - Technical requirements met
    - Performance targets achieved
    - Security requirements satisfied
  </acceptance_criteria>
  
  <regression_check>
    - Previously working features
    - Unrelated components
    - System stability
    - Data integrity
  </regression_check>
</validation_scope>

<success_criteria>
  - 100% spec tests passing
  - No regression in other specs
  - Performance within targets
  - All tasks completable
</success_criteria>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run full validation for spec: [SPEC_NAME]
            Execute complete test suite
            Verify all acceptance criteria
            Check for regressions"
  CONFIRM: Spec fully functional
  DOCUMENT: Validation results
</instructions>

</step>

<step number="8" subagent="file-creator" name="spec_debug_documentation">

### Step 8: Create Spec Debug Report

Use the file-creator subagent to create comprehensive debugging documentation.

<report_structure>
  <file_location>
    .agent-os/debugging/specs/[SPEC_NAME]-[TIMESTAMP].md
  </file_location>
  
  <report_content>
    # Spec Debug Report: [SPEC_NAME]
    
    **Date:** [TIMESTAMP]
    **Spec:** [SPEC_NAME]
    **Duration:** [TIME_TO_DEBUG]
    
    ## Executive Summary
    - Issues found: [COUNT]
    - Tasks affected: [LIST]
    - Root causes: [SUMMARY]
    - Resolution status: [COMPLETE/PARTIAL]
    
    ## Issues Discovered
    
    ### Critical Issues
    [Detailed list with root causes and fixes]
    
    ### Integration Issues
    [Cross-task problems and resolutions]
    
    ### Task-Specific Issues
    [Individual task problems and fixes]
    
    ## Root Cause Analysis
    [Systematic problems identified]
    
    ## Fixes Applied
    
    ### Code Changes
    - [File]: [Change description]
    
    ### Test Updates
    - [Test file]: [Test additions/changes]
    
    ### Documentation Updates
    - [Doc file]: [Updates made]
    
    ## Validation Results
    - Tests passing: [X/Y]
    - Integration verified: [Yes/No]
    - Performance impact: [Description]
    
    ## Lessons Learned
    
    ### What Went Wrong
    [Analysis of how issues arose]
    
    ### Prevention Strategies
    [How to avoid similar issues]
    
    ### Process Improvements
    [Suggested workflow enhancements]
    
    ## Follow-up Actions
    - [ ] [Any remaining tasks]
    - [ ] [Monitoring needed]
    - [ ] [Documentation updates]
  </report_content>
</report_structure>

<instructions>
  ACTION: Use file-creator subagent
  REQUEST: "Create spec debug report at .agent-os/debugging/specs/[SPEC]-[TIMESTAMP].md
            Include all issues, fixes, and lessons learned
            Document prevention strategies"
  ENSURE: Comprehensive documentation
  PROVIDE: Actionable insights
</instructions>

</step>

<step number="9" subagent="git-workflow" name="commit_spec_fixes">

### Step 9: Commit Spec-Wide Fixes

Use the git-workflow subagent to commit all spec debugging fixes with appropriate context.

<commit_strategy>
  <single_vs_multiple>
    IF fixes_are_related:
      - Single commit for all fixes
      - Comprehensive message
    ELSE:
      - Separate commits by concern
      - Link commits to spec
  </single_vs_multiple>
  
  <commit_message>
    fix: [spec-name] resolve integration and task issues
    
    Spec: [spec-name]
    Issues addressed:
    - [Critical issue 1]
    - [Integration issue 2]
    - [Task issue 3]
    
    Root causes:
    - [Cause 1]
    - [Cause 2]
    
    Changes:
    - Fixed [component] integration
    - Updated [task] implementation
    - Added comprehensive tests
    - Improved error handling
    
    Tasks affected: [task numbers]
    All spec tests now passing
  </commit_message>
</commit_strategy>

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Commit spec-wide debugging fixes
            Reference spec: [SPEC_NAME]
            Include comprehensive change summary
            Link affected tasks"
  ENSURE: Clear spec context
  DOCUMENT: All changes made
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>

<spec_debugging_best_practices>

## Spec Debugging Best Practices

### Holistic Approach
- Consider entire spec context
- Check integration points first
- Validate against requirements
- Test end-to-end flows

### Systematic Investigation
- Run all related tests
- Map failures to components
- Identify patterns and root causes
- Prioritize fixes by impact

### Coordinated Fixes
- Fix blocking issues first
- Maintain architectural consistency
- Update all affected tasks
- Validate progressively

### Comprehensive Documentation
- Document all issues found
- Record fix strategies
- Create prevention plans
- Share lessons learned

### Prevention Focus
- Identify systemic issues
- Improve testing strategy
- Enhance integration tests
- Update development process

</spec_debugging_best_practices>