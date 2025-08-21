---
description: Fix Regression Rules for Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Fix Regression Rules

## Overview

Quickly identify and fix regressions that have broken previously working functionality.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="regression_identification">

### Step 1: Regression Identification

Confirm that the issue is indeed a regression of previously working functionality.

<regression_criteria>
  <confirmation_needed>
    - Feature was previously working
    - Specific version/commit where it worked
    - Current broken state
    - No intentional changes to remove feature
  </confirmation_needed>
  
  <information_gathering>
    - When did it last work?
    - What changed since then?
    - Who noticed the regression?
    - What is the impact?
  </information_gathering>
</regression_criteria>

<initial_questions>
  IF regression_not_confirmed:
    ASK:
    1. When did this feature last work correctly?
    2. Do you know which version/commit it was working in?
    3. What specific functionality is broken?
    4. Has anyone intentionally modified this feature?
  WAIT for confirmation
</initial_questions>

<instructions>
  ACTION: Confirm regression status
  IDENTIFY: Last known working state
  DOCUMENT: Broken functionality
  ASSESS: Impact and urgency
</instructions>

</step>

<step number="2" subagent="debug-helper" name="commit_bisection">

### Step 2: Commit Bisection

Use the debug-helper subagent to identify the commit that introduced the regression.

<bisection_process>
  <git_bisect>
    - Identify good commit (last working)
    - Identify bad commit (current broken)
    - Use git bisect to find breaking commit
    - Review changes in that commit
  </git_bisect>
  
  <manual_review>
    IF git_bisect_not_possible:
      - Review commit history manually
      - Check recent PRs/merges
      - Look for related changes
      - Examine deployment history
  </manual_review>
</bisection_process>

<commit_analysis>
  <identify>
    - Breaking commit hash
    - Author and date
    - Change description
    - Files modified
  </identify>
  
  <examine>
    - Specific changes made
    - Intent of changes
    - Side effects introduced
    - Dependencies affected
  </examine>
</commit_analysis>

<instructions>
  ACTION: Use debug-helper subagent
  REQUEST: "Find regression source:
            Last working: [COMMIT/DATE]
            Currently broken: [CURRENT_STATE]
            Use git bisect or review commits
            Identify breaking change"
  DOCUMENT: Breaking commit details
  ANALYZE: Changes that caused regression
</instructions>

</step>

<step number="3" subagent="test-runner" name="regression_test_creation">

### Step 3: Create Regression Test

Use the test-runner subagent to create a test that captures the regression before fixing it.

<test_creation>
  <regression_test>
    - Write test for expected behavior
    - Verify test fails with current code
    - Ensure test would pass with previous working version
    - Make test specific to regression
  </regression_test>
  
  <test_characteristics>
    - Clear name indicating regression
    - Minimal and focused
    - Documents expected behavior
    - Prevents future regressions
  </test_characteristics>
</test_creation>

<test_verification>
  <confirm_failure>
    - Run test with current broken code
    - Verify it fails as expected
    - Capture failure output
  </confirm_failure>
  
  <document_expectation>
    - What should happen
    - What actually happens
    - Why this is wrong
  </document_expectation>
</test_verification>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Create regression test for: [BROKEN_FUNCTIONALITY]
            Test should fail with current code
            Test name should indicate regression"
  VERIFY: Test fails appropriately
  DOCUMENT: Expected vs actual behavior
</instructions>

</step>

<step number="4" name="root_cause_analysis">

### Step 4: Rapid Root Cause Analysis

Quickly analyze why the breaking change caused the regression.

<analysis_focus>
  <direct_causes>
    - Logic changes
    - Removed code
    - Modified dependencies
    - Changed assumptions
  </direct_causes>
  
  <indirect_causes>
    - Side effects
    - Timing changes
    - State modifications
    - Integration impacts
  </indirect_causes>
  
  <quick_assessment>
    - Was change intentional?
    - Was side effect overlooked?
    - Was test coverage missing?
    - Was dependency not considered?
  </quick_assessment>
</analysis_focus>

<understanding_verification>
  - Can explain why regression occurred
  - Understand original change intent
  - Know what fix should preserve
  - Identified all affected areas
</understanding_verification>

<instructions>
  ACTION: Analyze breaking changes
  IDENTIFY: Direct cause of regression
  UNDERSTAND: Original change intent
  DETERMINE: Fix approach
</instructions>

</step>

<step number="5" name="fix_implementation">

### Step 5: Implement Regression Fix

Implement a fix that restores functionality while preserving intended changes.

<fix_strategies>
  <option_a_revert>
    IF original_change_not_critical:
      - Revert entire breaking commit
      - Verify regression fixed
      - Plan proper reimplementation
  </option_a_revert>
  
  <option_b_surgical_fix>
    IF original_change_needed:
      - Fix specific regression issue
      - Preserve intended changes
      - Minimize code changes
      - Add protective conditions
  </option_b_surgical_fix>
  
  <option_c_redesign>
    IF conflict_fundamental:
      - Redesign approach
      - Satisfy both requirements
      - May need more time
  </option_c_redesign>
</fix_strategies>

<implementation_guidelines>
  - Make minimal necessary changes
  - Preserve original change benefits
  - Add comments explaining fix
  - Consider edge cases
</implementation_guidelines>

<fix_verification>
  - Regression test now passes
  - Original functionality restored
  - New functionality still works (if applicable)
  - No new issues introduced
</fix_verification>

<instructions>
  ACTION: Implement regression fix
  STRATEGY: Choose appropriate approach
  VERIFY: Regression test passes
  ENSURE: Original intent preserved where possible
</instructions>

</step>

<step number="6" subagent="test-runner" name="comprehensive_verification">

### Step 6: Comprehensive Test Verification

Use the test-runner subagent to ensure fix resolves regression without breaking other functionality.

<test_execution>
  <immediate_tests>
    - New regression test (must pass)
    - Related unit tests
    - Integration tests for area
    - Original feature tests
  </immediate_tests>
  
  <extended_tests>
    - Full test suite
    - Performance tests
    - End-to-end tests
    - Manual verification
  </extended_tests>
</test_execution>

<verification_checklist>
  - [ ] Regression test passes
  - [ ] Original tests still pass
  - [ ] No new test failures
  - [ ] Performance unchanged
  - [ ] Integration points work
</verification_checklist>

<rollback_plan>
  IF new_issues_found:
    - Document new issues
    - Assess severity
    - Decide on approach
    - May need to iterate
</rollback_plan>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run comprehensive tests after regression fix
            Priority: regression test and related tests
            Then: full test suite"
  VERIFY: All tests pass
  CONFIRM: No new regressions
</instructions>

</step>

<step number="7" subagent="file-creator" name="regression_documentation">

### Step 7: Document Regression and Fix

Use the file-creator subagent to document the regression for future prevention.

<documentation_content>
  <regression_report>
    # Regression Report
    
    **Date:** [TIMESTAMP]
    **Regression:** [DESCRIPTION]
    **Breaking Commit:** [COMMIT_HASH]
    **Fix Commit:** [FIX_COMMIT_HASH]
    
    ## Summary
    - What broke: [FUNCTIONALITY]
    - When introduced: [DATE/COMMIT]
    - Root cause: [CAUSE]
    - Fix applied: [FIX_DESCRIPTION]
    
    ## Timeline
    - Last working: [VERSION/DATE]
    - Regression introduced: [COMMIT/DATE]
    - Discovered: [DATE]
    - Fixed: [DATE]
    
    ## Impact
    - Users affected: [NUMBER/DESCRIPTION]
    - Features impacted: [LIST]
    - Duration: [TIME_BROKEN]
    
    ## Root Cause
    [Detailed explanation of why regression occurred]
    
    ## Fix Details
    [How the regression was fixed]
    
    ## Prevention
    - Testing gaps identified
    - Process improvements needed
    - Monitoring recommendations
    
    ## Lessons Learned
    [Key takeaways to prevent similar issues]
  </regression_report>
</documentation_content>

<post_mortem_questions>
  - Why wasn't this caught by tests?
  - How can we prevent similar regressions?
  - What testing improvements needed?
  - Should we add monitoring/alerts?
</post_mortem_questions>

<instructions>
  ACTION: Use file-creator subagent
  REQUEST: "Create regression report at .agent-os/debugging/regressions/[TIMESTAMP]-[ISSUE].md
            Document cause, fix, and prevention"
  INCLUDE: Lessons learned
  FOCUS: Prevention strategies
</instructions>

</step>

<step number="8" subagent="git-workflow" name="commit_and_communicate">

### Step 8: Commit Fix and Communicate

Use the git-workflow subagent to commit the regression fix with clear messaging.

<commit_structure>
  <message_format>
    fix: restore [functionality] broken in [commit_ref]
    
    Regression introduced by: [breaking_commit]
    - Root cause: [brief_explanation]
    - Fix: [what_was_done]
    - Tests: Added regression test
    
    Fixes regression from [date/version]
  </message_format>
  
  <files_included>
    - Fix implementation
    - Regression test
    - Documentation updates
    - Any related changes
  </files_included>
</commit_structure>

<communication>
  <notify_stakeholders>
    - Regression fixed
    - Functionality restored
    - Testing completed
    - Deployment ready
  </notify_stakeholders>
  
  <update_tracking>
    - Close regression ticket
    - Update status boards
    - Notify affected users
    - Document in changelog
  </update_tracking>
</communication>

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Commit regression fix with detailed message
            Reference breaking commit
            Indicate regression fixed"
  COMMUNICATE: Fix completed
  UPDATE: Relevant documentation
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>

<regression_prevention>

## Regression Prevention Strategies

### Testing Coverage
- Comprehensive test suites
- Regression test collection
- Integration testing
- Automated test runs

### Code Review
- Review for side effects
- Check test coverage
- Verify assumptions
- Consider dependencies

### Monitoring
- Feature usage tracking
- Error rate monitoring
- Performance metrics
- User feedback channels

### Process Improvements
- Regression test requirements
- Breaking change documentation
- Rollback procedures
- Communication protocols

</regression_prevention>