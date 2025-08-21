---
description: Debug Issue Rules for Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Debug Issue Rules

## Overview

Systematically debug and fix issues in the application using a structured investigation and resolution workflow.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="issue_identification">

### Step 1: Issue Identification

Gather complete information about the issue from the user or error reports.

<issue_gathering>
  <required_information>
    - Error message or unexpected behavior description
    - Steps to reproduce (if available)
    - Expected vs actual behavior
    - When the issue started occurring
    - Any recent changes that might be related
    - Related spec/task (if during implementation)
  </required_information>
  
  <context_check>
    IF issue_during_spec_implementation:
      - Note current spec name
      - Identify affected task(s)
      - Consider using @commands/debug-task.md or @commands/debug-spec.md
    ELSE:
      - Proceed with general debugging
  </context_check>
</issue_gathering>

<clarification_questions>
  IF information_incomplete:
    ASK numbered questions:
    1. What specific error message or behavior are you seeing?
    2. What steps lead to this issue?
    3. What should happen instead?
    4. When did this start happening?
    5. Were there any recent changes to the code?
  WAIT for user response
</clarification_questions>

<instructions>
  ACTION: Gather all available issue information
  DOCUMENT: Clear problem statement
  IDENTIFY: Reproduction steps if possible
  NOTE: Any patterns or timing information
</instructions>

</step>

<step number="2" subagent="debug-helper" name="initial_investigation">

### Step 2: Initial Investigation

Use the debug-helper subagent to perform initial investigation and identify potential problem areas.

<investigation_scope>
  <examine>
    - Error stack traces
    - Related log files
    - Recent git commits
    - Test failures
    - Console output
  </examine>
</investigation_scope>

<instructions>
  ACTION: Use debug-helper subagent
  REQUEST: "Investigate issue: [ISSUE_DESCRIPTION]
            Check error logs, stack traces, and recent changes
            Identify files and components potentially involved"
  PROCESS: Returned investigation findings
  IDENTIFY: Likely problem areas
</instructions>

</step>

<step number="3" name="reproduction_attempt">

### Step 3: Reproduction Attempt

Attempt to reproduce the issue locally to confirm the problem.

<reproduction_methods>
  <option_a>
    IF unit_test_exists:
      - Run specific failing test
      - Examine test output
      - Note failure details
  </option_a>
  
  <option_b>
    IF manual_steps_provided:
      - Follow reproduction steps
      - Document actual behavior
      - Capture error messages
  </option_b>
  
  <option_c>
    IF no_clear_reproduction:
      - Create minimal test case
      - Isolate problem area
      - Add debugging output
  </option_c>
</reproduction_methods>

<verification>
  <success>
    - Issue reproduced successfully
    - Error captured and understood
    - Ready to investigate root cause
  </success>
  <failure>
    - Cannot reproduce issue
    - Request more information
    - Check environment differences
  </failure>
</verification>

<instructions>
  ACTION: Attempt to reproduce the issue
  DOCUMENT: Exact reproduction steps
  CAPTURE: All error messages and output
  VERIFY: Issue is consistently reproducible
</instructions>

</step>

<step number="4" subagent="debug-helper" name="root_cause_analysis">

### Step 4: Root Cause Analysis

Use the debug-helper subagent to perform deep analysis and identify the root cause.

<analysis_techniques>
  <code_inspection>
    - Review suspect code sections
    - Check recent changes (git diff)
    - Examine data flow
    - Verify assumptions
  </code_inspection>
  
  <debugging_tools>
    - Add console.log/print statements
    - Use debugger breakpoints
    - Inspect variable values
    - Trace execution flow
  </debugging_tools>
  
  <pattern_analysis>
    - Check for similar issues
    - Review related components
    - Identify common factors
    - Consider edge cases
  </pattern_analysis>
</analysis_techniques>

<instructions>
  ACTION: Use debug-helper subagent
  REQUEST: "Perform root cause analysis for: [ISSUE]
            Examine code in: [SUSPECT_FILES]
            Check for: logic errors, state issues, race conditions
            Review recent changes that might have introduced the bug"
  PROCESS: Analysis results
  IDENTIFY: Root cause and affected code
</instructions>

</step>

<step number="5" name="solution_development">

### Step 5: Solution Development

Develop and implement a fix for the identified root cause.

<fix_approach>
  <planning>
    - Design minimal fix
    - Consider side effects
    - Plan test coverage
    - Document approach
  </planning>
  
  <implementation>
    - Write failing test first (if none exists)
    - Implement the fix
    - Verify test passes
    - Check for regressions
  </implementation>
  
  <code_quality>
    - Follow existing patterns
    - Maintain consistency
    - Add necessary comments
    - Update documentation
  </code_quality>
</fix_approach>

<fix_validation>
  IF fix_implemented:
    - Run original failing scenario
    - Verify issue is resolved
    - Check no new issues introduced
  ELSE:
    - Document why fix not possible
    - Suggest alternative approaches
</fix_validation>

<instructions>
  ACTION: Implement the bug fix
  WRITE: Test case for the bug (if missing)
  FIX: The root cause issue
  VERIFY: Original issue is resolved
  CHECK: No regressions introduced
</instructions>

</step>

<step number="6" subagent="test-runner" name="comprehensive_testing">

### Step 6: Comprehensive Testing

Use the test-runner subagent to verify the fix and ensure no regressions.

<test_scope>
  <immediate>
    - New test for the bug
    - Original failing test (if any)
    - Related unit tests
  </immediate>
  
  <extended>
    - Integration tests
    - Component tests
    - Full test suite
  </extended>
</test_scope>

<regression_check>
  - Run tests for affected components
  - Verify related functionality
  - Check edge cases
  - Confirm performance unchanged
</regression_check>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run comprehensive tests for bug fix
            Focus on: [AFFECTED_COMPONENTS]
            Include: unit, integration, and regression tests"
  VERIFY: All tests pass
  CONFIRM: No new failures introduced
</instructions>

</step>

<step number="7" subagent="file-creator" name="documentation">

### Step 7: Document the Fix

Use the file-creator subagent to create or update debugging documentation.

<documentation_items>
  <bug_report>
    IF not_exists .agent-os/debugging/:
      CREATE: .agent-os/debugging/
    
    CREATE: .agent-os/debugging/[TIMESTAMP]-[ISSUE_NAME].md
    INCLUDE:
      - Issue description
      - Root cause
      - Solution implemented
      - Prevention strategies
      - Related files changed
  </bug_report>
  
  <code_comments>
    - Add explanatory comments if fix is non-obvious
    - Document any workarounds
    - Note potential future improvements
  </code_comments>
  
  <update_changelog>
    IF exists CHANGELOG.md:
      - Add bug fix entry
      - Reference issue number
      - Describe user impact
  </update_changelog>
</documentation_items>

<instructions>
  ACTION: Use file-creator subagent
  REQUEST: "Create debugging report at .agent-os/debugging/[TIMESTAMP]-[ISSUE].md
            Include: issue, cause, fix, prevention"
  UPDATE: Add clarifying code comments if needed
  DOCUMENT: Lessons learned for future reference
</instructions>

</step>

<step number="8" subagent="git-workflow" name="commit_fix">

### Step 8: Commit the Fix

Use the git-workflow subagent to commit the bug fix with appropriate message.

<commit_guidelines>
  <message_format>
    fix: [component] resolve [issue description]
    
    - Root cause: [brief explanation]
    - Solution: [what was changed]
    - Testing: [how it was verified]
    
    Fixes: [issue reference if applicable]
  </message_format>
  
  <files_to_commit>
    - Bug fix implementation
    - New or updated tests
    - Documentation updates
    - Any related changes
  </files_to_commit>
</commit_guidelines>

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Commit bug fix with message format:
            fix: [description]
            Include all changed files"
  VERIFY: Changes committed successfully
  CONFIRM: Commit message is descriptive
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>

<debugging_best_practices>

## Best Practices

### Systematic Approach
- Always gather complete information first
- Reproduce before attempting to fix
- Understand root cause before coding
- Test thoroughly after fixing

### Communication
- Keep user informed of progress
- Explain the issue and fix clearly
- Document for future reference
- Share learnings with team

### Prevention
- Add tests for bugs found
- Consider similar issues elsewhere
- Improve error handling
- Update documentation

### Tools and Techniques
- Use appropriate debugging tools
- Add temporary logging when needed
- Leverage version control for investigation
- Clean up debug code after fixing

</debugging_best_practices>