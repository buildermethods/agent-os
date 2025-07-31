# Task Execution for GitHub Copilot

## Purpose
Execute development tasks from feature specifications in a systematic, test-driven manner. This ensures quality code delivery with proper git workflow and progress tracking.

## When to Use
- Feature specification is complete with task breakdown
- Ready to begin implementation of specific tasks
- Continuing work on an existing specification
- User requests to "execute tasks" or similar

## What This Does
- Executes tasks from `tasks.md` in specification folder
- Updates task status and progress tracking
- Follows git workflow (branching, commits, PRs)
- Runs tests to ensure quality
- Provides completion summary

## Prerequisites

Before executing tasks:
- [ ] Feature specification exists with `tasks.md`
- [ ] Tasks are properly broken down (2-4 hours each)
- [ ] Technical specifications are clear
- [ ] Development environment is ready

## Step-by-Step Process

### 1. Identify Tasks to Execute

**Option A: User specifies exact tasks**
- Execute the specified parent task(s) and subtasks

**Option B: User asks to continue/execute tasks**
- Check `tasks.md` for next uncompleted parent task
- Confirm task selection with user

### 2. Load Context

Gather necessary context from:
- **tasks.md**: Current task breakdown and status
- **spec-lite.md**: Feature overview (if needed)
- **technical-spec.md**: Implementation details (if needed)
- **@.agent-os/product/mission-lite.md**: Product context (if needed)

### 3. Check Development Environment

- **Stop running servers**: Ask user to stop any development servers
- **Git branch management**: 
  - Create feature branch from main (e.g., `feature-name`)
  - Switch to appropriate branch if exists
  - Handle any uncommitted changes

### 4. Execute Task Implementation Loop

For each parent task:

#### A. Task Planning
- Review subtasks and acceptance criteria
- Understand technical requirements
- Plan implementation approach

#### B. Implementation
- Write code following project patterns
- Follow established coding standards
- Implement features incrementally
- Test functionality as you build

#### C. Testing
- Write tests for new functionality
- Run existing test suite
- Fix any broken tests
- Ensure 100% test pass rate

#### D. Status Updates
- Mark completed subtasks in `tasks.md`
- Update parent task status when complete
- Document any issues or changes

### 5. Quality Assurance

After each task completion:
- [ ] All tests passing
- [ ] Code follows project standards
- [ ] Functionality works as specified
- [ ] No regressions introduced

### 6. Git Workflow

Once all assigned tasks complete:

#### A. Commit Changes
- Review all changes made
- Create descriptive commit message
- Commit all related changes together

#### B. Push and Create PR
- Push feature branch to GitHub
- Create pull request with:
  - Descriptive title
  - Summary of changes made
  - Testing notes
  - Reference to specification

### 7. Final Testing

- Run complete test suite one final time
- Verify all tests pass
- Fix any remaining issues before completion

## Task Status Management

Update `tasks.md` throughout execution:

```markdown
## Parent Task 1: [Name]
**Status**: ✅ Complete
**Actual Time**: X hours

### Subtasks:
- [x] **Subtask 1.1**: Description - Complete
- [x] **Subtask 1.2**: Description - Complete

## Parent Task 2: [Name]  
**Status**: 🔄 In Progress
**Actual Time**: X hours so far

### Subtasks:
- [x] **Subtask 2.1**: Description - Complete
- [ ] **Subtask 2.2**: Description - In Progress
```

## Error Handling

### Common Issues
- **Test failures**: Fix before proceeding
- **Merge conflicts**: Resolve carefully
- **Technical roadblocks**: Try 3 approaches, then document
- **Scope changes**: Update spec and get approval

### Blocking Issues
- Document in tasks.md with ⚠️ emoji
- Include in completion summary
- Seek user guidance for resolution

## Completion Summary

Provide structured summary:

```markdown
## ✅ What's been done
1. **[Feature 1]** - [Description]
2. **[Feature 2]** - [Description]

## ⚠️ Issues encountered
[Only if applicable]
- **[Issue 1]** - [Description and status]

## 👀 Ready to test
[If applicable]
1. [Step to test feature]
2. [Expected behavior]

## 📦 Pull Request
View PR: [GitHub PR URL]
```

## Best Practices

### Code Quality
- Follow existing project patterns
- Write meaningful comments
- Keep functions small and focused
- Handle edge cases appropriately

### Testing
- Test happy path and error cases
- Maintain or improve test coverage
- Use descriptive test names
- Test integration points

### Git Practices
- Make atomic commits
- Write clear commit messages
- Keep feature branches focused
- Create detailed pull requests

## Integration with Agent OS

Task execution integrates with:
- **Specifications**: Implements planned features
- **Standards**: Follows coding practices
- **Product mission**: Delivers user value
- **Roadmap**: Advances product goals

This systematic approach ensures quality delivery while maintaining clear progress tracking and documentation.
