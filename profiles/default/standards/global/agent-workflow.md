# Agent Workflow: Pause-for-Review Strategy

## Overview

This document defines the **pause-for-review** workflow strategy for Agent OS implementations. The goal is to prevent massive, uncommittable changesets by introducing natural pause points during implementation where users can review, test, and commit code incrementally.

## Core Principle

**AI-assisted development is iterative, not monolithic.** Breaking large specs into reviewable checkpoints improves code quality, reduces risk, and makes the development process more manageable and collaborative.

## When to Pause for Review

Agents should pause and return control to the user at these natural milestones:

### 1. After Each Task Group
- **Primary pause point**: After completing a task group (parent task + all sub-tasks)
- Allows review of a cohesive unit of functionality
- Natural checkpoint in the implementation workflow

### 2. After Significant Infrastructure Changes
- Database migrations or schema changes
- Authentication/authorization system modifications
- Build configuration or dependency updates
- API contract changes that affect multiple consumers

### 3. Before Breaking Changes
- Changes that affect existing functionality
- Modifications to public APIs or interfaces
- Refactoring that impacts multiple components

### 4. After Substantial File Changes
- After creating/modifying 5-10 files
- After adding 200-300 lines of code (cumulative)
- When multiple components have been touched

### 5. Before Verification Phases
- Before running comprehensive test suites
- Before delegating to verification agents
- Allows committing implementation before verification findings

## How to Pause Effectively

When pausing for review, provide the user with actionable information:

### 1. Clear Summary
- What was accomplished in this session
- Which task(s) or sub-task(s) were completed
- Brief description of the approach taken

### 2. Files Changed
List all files with brief descriptions:
```
Created:
- path/to/new/file.ts - User authentication service
- path/to/test.spec.ts - Tests for authentication

Modified:
- path/to/existing.ts - Added login endpoint
- path/to/config.ts - Added auth configuration

Deleted:
- path/to/old/file.ts - Replaced by new auth service
```

### 3. Git Status Context
- Provide output of `git status` if possible
- Mention number of files changed
- Note any untracked files that should be committed

### 4. Explicit Prompt for Action and Commit
Ask the user to:
- Review the changes
- Run tests if desired
- Approve commit creation
- **Orchestrator creates the commit** after approval

Example:
```
Ready for review! Please:
1. Review the changes above
2. Test the authentication flow if desired
3. Reply 'yes' to approve and I'll create the commit
4. Or provide feedback for adjustments

Suggested commit message:
feat(auth): implement user authentication service
```

**After user approves**: The orchestrator creates the commit and confirms to user before proceeding.

## Commit Strategy Guidance

Help users make informed decisions about commits:

### Single Commit Strategy
**When to use**:
- Task group is small and cohesive
- Changes are tightly coupled
- All changes serve one logical purpose

**Example**:
```
feat(auth): add login endpoint and validation

- Create LoginController with email/password validation
- Add JWT token generation
- Include tests for success and error cases
```

### Multiple Commits Strategy
**When to use**:
- Task group spans multiple independent concerns
- Database migrations should be separate
- Test files can be committed separately
- Infrastructure changes are distinct from features

**Example sequence**:
```
1. chore(db): add users table migration
2. feat(auth): implement user authentication service
3. test(auth): add authentication service tests
4. docs(auth): update API documentation for auth endpoints
```

### Commit Message Format
Follow conventional commits format:
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## What NOT to Do (Anti-Patterns)

### ❌ Massive Changesets
**Bad**: Implementing 10 task groups and 50 files before pausing
**Why**: Impossible to review, test, or debug effectively
**Impact**: Increases risk, makes rollback difficult

### ❌ Steamrolling Through Tasks
**Bad**: "I'll implement all tasks and pause at the end"
**Why**: Violates the iterative development principle
**Impact**: Creates monolithic commits, no incremental feedback

### ❌ Assuming User Intent
**Bad**: "I'll just commit everything with a generic message"
**Why**: User may want to review before committing
**Impact**: Removes user control, may commit unwanted changes

### ❌ Skipping Pause Points
**Bad**: Continuing to next task without explicit user approval
**Why**: User may want to test, modify, or reject changes
**Impact**: Compounds issues across multiple task groups

## Examples

### ✅ Good Pause Pattern

```
**Task Group 1 Complete: User Authentication**

Implemented:
- User login endpoint with JWT tokens
- Password validation and hashing
- Session management

Files Changed (4):
Created:
- src/controllers/AuthController.ts - Login/logout endpoints
- src/services/TokenService.ts - JWT token generation
- src/middleware/AuthMiddleware.ts - Request authentication

Modified:
- src/routes/api.ts - Added /auth routes

All tests passing (12 new tests added).

Ready for review! Please:
1. Review the authentication implementation
2. Test login/logout if desired
3. Reply 'yes' to approve and I'll create the commit
4. Or provide feedback for adjustments

Suggested commit message:
feat(auth): implement user authentication with JWT

- Add login/logout endpoints
- Implement JWT token generation and validation
- Add authentication middleware
- Include comprehensive tests
```

**After user approves**, orchestrator creates the commit:
```
✓ Commit created: feat(auth): implement user authentication with JWT
  4 files changed, 287 insertions(+)

Ready to proceed to Task Group 2: User Profile Management
```

### ❌ Bad Pause Pattern

```
I've implemented tasks 1 through 8. Created 47 files and modified 23 others. Everything is working. Ready to commit?
```

**Problems**:
- No summary of what was actually built
- No list of files or changes
- No guidance on commit strategy
- No checkpoint for review
- Assumes user wants to commit everything at once

## Integration with Multi-Agent Workflow

### Orchestrator Responsibilities
The orchestrating agent (main conversation) must:
1. Pause after each task group delegation
2. Summarize subagent's work
3. Show files changed and git status
4. Provide suggested commit message
5. Wait for explicit user approval
6. **Create the commit** after user approves (using suggested or user-modified message)
7. Confirm commit creation to user
8. Proceed to next task group
9. Pause before verification phases and ensure all work is committed

### Subagent Responsibilities
Implementer and verifier subagents must:
1. Complete assigned work
2. Provide clear summary of accomplishments
3. List files created/modified
4. Return control cleanly
5. NOT proceed to other task groups
6. NOT make assumptions about next steps

## Integration with Single-Agent Workflow

In single-agent mode:
- User manually runs prompts one-by-one
- Natural pause points between prompts
- After each prompt completes, the agent should:
  1. Summarize what was implemented
  2. List files changed
  3. Provide suggested commit message
  4. Ask for approval to create commit
  5. **Create the commit** after user approves
  6. User then decides when to run the next prompt

This maintains the same review-then-commit pattern as multi-agent mode, just with manual prompt progression.

## Benefits of This Approach

1. **Reduced Risk**: Smaller changesets are easier to review and test
2. **Better Quality**: Incremental feedback catches issues early
3. **Clearer History**: Logical commits tell the story of development
4. **Easier Debugging**: Smaller commits are easier to bisect
5. **User Control**: Users maintain agency over their codebase
6. **Collaboration Ready**: Clean commits facilitate team reviews

## Relationship to Git Workflow Configuration

This workflow establishes the foundation for future enhancements:
- **Configurable git behavior** (auto-commit, auto-push, auto-PR)
- **Branch management** (feature branches per spec)
- **Team workflows** (review processes, approval gates)

For now, pause-for-review is a **manual checkpoint system** that gives users control while maintaining development momentum.
