---
description: Rules to execute adhoc development tasks using Agent OS methodology
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Adhoc Task Execution Rules

## Overview

Execute an adhoc development task with proper context loading, testing, and git workflow management without requiring a full spec.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="task_clarification">

### Step 1: Task Clarification

Understand and clarify the adhoc task requirements with the user.

<task_analysis>
  <understand>
    - What needs to be built/fixed/changed
    - Expected outcome
    - Any specific constraints
    - Testing requirements
  </understand>
  <clarify_if_needed>
    - Ask for clarification if task is ambiguous
    - Confirm understanding with user
  </clarify_if_needed>
</task_analysis>

<instructions>
  ACTION: Analyze the user's adhoc request
  CLARIFY: Any ambiguous requirements
  CONFIRM: Understanding of the task
  IDENTIFY: Technology stack and affected areas
</instructions>

</step>

<step number="2" subagent="context-fetcher" name="smart_context_loading">

### Step 2: Smart Context Loading

Use the context-fetcher subagent to load minimal but sufficient context based on task requirements.

<context_strategy>
  <analyze_task_type>
    - Model changes → Load migration patterns, model patterns
    - Controller changes → Load controller patterns, routing
    - View changes → Load view patterns, helpers
    - API changes → Load API patterns, authentication
    - Bug fix → Load error catalog, troubleshooting
  </analyze_task_type>
</context_strategy>

<conditional_loading>
  <if_wheels_framework>
    LOAD relevant sections from:
    - @.agent-os/project_types/wheels/standards/wheels-framework/wheels-framework.md (dispatcher)
    - Task-specific pattern files
  </if_wheels_framework>
  <if_other_framework>
    LOAD relevant framework standards
  </if_other_framework>
</conditional_loading>

<instructions>
  ACTION: Use context-fetcher subagent
  REQUEST: "Load context for [TASK_TYPE]:
            - Relevant patterns from standards
            - Best practices for this feature type
            - Code style rules for affected files"
  PROCESS: Returned context
  APPLY: To task implementation
</instructions>

</step>

<step number="3" name="development_server_check">

### Step 3: Check for Development Server

Check for any running development server and handle appropriately.

<server_check_flow>
  <if_running>
    ASK: "A development server is running. Should I shut it down? (yes/no)"
    WAIT: For user response
  </if_running>
  <if_not_running>
    PROCEED: Continue immediately
  </if_not_running>
</server_check_flow>

<instructions>
  ACTION: Check for running local development server
  CONDITIONAL: Ask permission only if server is running
  PROCEED: Immediately if no server detected
</instructions>

</step>

<step number="4" subagent="git-workflow" name="git_setup">

### Step 4: Git Branch Setup

Use the git-workflow subagent to create or switch to an appropriate branch.

<branch_naming>
  <format>feature/[task-description] or fix/[bug-description]</format>
  <examples>
    - feature/user-validation
    - fix/qr-code-generation-bug
    - feature/api-endpoint-products
  </examples>
</branch_naming>

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Setup git branch for adhoc task:
            - Branch name: [SUGGESTED_BRANCH_NAME]
            - Handle any uncommitted changes
            - Create from main/develop as appropriate"
  WAIT: For branch setup completion
</instructions>

</step>

<step number="5" name="test_first_approach">

### Step 5: Write Tests First (if applicable)

For feature additions or bug fixes, write tests first following TDD principles.

<test_strategy>
  <feature_addition>
    WRITE: New tests for the feature
    RUN: Tests to ensure they fail appropriately
  </feature_addition>
  <bug_fix>
    WRITE: Failing test that reproduces the bug
    VERIFY: Test fails as expected
  </bug_fix>
  <refactoring>
    VERIFY: Existing tests cover the code
    ADD: Tests if coverage insufficient
  </refactoring>
</test_strategy>

<instructions>
  ACTION: Determine if tests are needed
  WRITE: Appropriate tests first
  RUN: Tests to verify they fail
  PROCEED: To implementation
</instructions>

</step>

<step number="6" name="implementation">

### Step 6: Implement the Task

Execute the adhoc task following loaded patterns and best practices.

<implementation_guidelines>
  <follow>
    - Loaded code style rules
    - Framework-specific patterns
    - Best practices for this feature type
    - Existing code conventions in the project
  </follow>
  <maintain>
    - Code consistency
    - Test coverage
    - Documentation where needed
  </maintain>
</implementation_guidelines>

<incremental_testing>
  AFTER each significant change:
    RUN: Related tests
    FIX: Any failures immediately
    REFACTOR: While keeping tests green
</incremental_testing>

<instructions>
  ACTION: Implement the required changes
  FOLLOW: All loaded patterns and standards
  TEST: Incrementally as you progress
  REFACTOR: Maintain code quality
</instructions>

</step>

<step number="7" subagent="test-runner" name="test_verification">

### Step 7: Run Tests

Use the test-runner subagent to verify all tests pass.

<test_scope>
  <minimum>
    - All new tests written
    - All modified test files
    - Tests directly related to changes
  </minimum>
  <recommended>
    - Run full test suite if changes are significant
    - Run integration tests if APIs modified
  </recommended>
</test_scope>

<instructions>
  ACTION: Use test-runner subagent
  REQUEST: "Run tests affected by adhoc changes:
            - New test files: [LIST]
            - Modified areas: [LIST]"
  WAIT: For test results
  FIX: Any failures before proceeding
</instructions>

</step>

<step number="8" name="code_quality_check">

### Step 8: Code Quality Verification

Run linting and type checking if applicable.

<quality_checks>
  <if_available>
    RUN: npm run lint (or equivalent)
    RUN: npm run typecheck (or equivalent)
    RUN: Format code if formatter available
  </if_available>
  <manual_check>
    VERIFY: Code follows project conventions
    CHECK: No obvious issues or anti-patterns
  </manual_check>
</quality_checks>

<instructions>
  ACTION: Run available code quality tools
  FIX: Any linting or type errors
  FORMAT: Code according to project standards
  VERIFY: Clean code output
</instructions>

</step>

<step number="9" subagent="git-workflow" name="commit_and_push">

### Step 9: Commit and Push Changes

Use the git-workflow subagent to commit changes with descriptive message.

<commit_guidelines>
  <message_format>
    TYPE: feat|fix|refactor|docs|test|chore
    DESCRIPTION: Clear, concise description
    BODY: Additional context if needed
  </message_format>
  <examples>
    - "feat: add email validation to User model"
    - "fix: resolve QR code generation memory leak"
    - "refactor: optimize authentication controller performance"
  </examples>
</commit_guidelines>

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Commit adhoc task changes:
            - Type: [feat|fix|refactor|etc]
            - Description: [CLEAR_DESCRIPTION]
            - Files: All modified files
            - Push to remote"
  WAIT: For commit completion
</instructions>

</step>

<step number="10" name="optional_pr">

### Step 10: Create Pull Request (Optional)

Ask user if they want a pull request created.

<pr_decision>
  ASK: "Would you like me to create a pull request for these changes? (yes/no)"
  
  IF YES:
    USE: git-workflow subagent
    CREATE: Pull request with summary
  
  IF NO:
    SKIP: PR creation
    NOTE: Changes are committed and pushed
</pr_decision>

<instructions>
  ACTION: Ask user about PR preference
  CONDITIONAL: Create PR only if requested
  INCLUDE: Clear description of changes
</instructions>

</step>

<step number="11" name="completion_summary">

### Step 11: Task Completion Summary

Provide a concise summary of what was done.

<summary_template>
  ## ✅ Adhoc Task Complete
  
  **Task:** [ORIGINAL_REQUEST]
  
  **Changes Made:**
  - [CHANGE_1]
  - [CHANGE_2]
  
  **Tests:** [ADDED/UPDATED/PASSED]
  
  **Branch:** [BRANCH_NAME]
  
  [IF_PR_CREATED]
  **Pull Request:** [PR_URL]
  
  [IF_ISSUES]
  **Notes:** [ANY_IMPORTANT_NOTES]
</summary_template>

<instructions>
  ACTION: Create concise summary
  INCLUDE: Key changes and outcomes
  MENTION: Branch name for reference
  ADD: PR link if created
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>