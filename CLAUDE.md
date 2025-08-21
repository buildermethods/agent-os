# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent OS is a spec-driven agentic development system that transforms AI coding agents into productive developers through structured workflows. It provides instructions, standards, and commands that guide AI agents to write quality code following established patterns and best practices.

## Architecture

Agent OS uses a modular, file-based architecture organized into:

- **Instructions** (`instructions/`): Step-by-step workflows for common development tasks
  - `core/`: Main product development and debugging workflows
    - Development: plan-product, create-spec, execute-tasks
    - Debugging: debug-issue, investigate-bug, fix-regression
  - `meta/`: Pre-flight and post-flight check instructions
  
- **Standards** (`standards/`): Coding guidelines and technical requirements
  - Best practices, code style guides (JS, CSS, HTML), tech stack defaults
  
- **Commands** (`commands/`): Entry points for agent workflows
  - Each command references corresponding instruction files
  
- **Setup Scripts** (`setup/`): Bash scripts for installation
  - `base.sh`: Installs Agent OS base files to a system location
  - `project.sh`: Installs Agent OS into individual projects
  - `functions.sh`: Shared installation utilities

- **Claude Code Agents** (`claude-code/agents/`): Specialized subagents
  - `context-fetcher`: Retrieves relevant documentation sections
  - `project-manager`: Manages task completion and status updates
  - `test-runner`: Executes and verifies test suites
  - `file-creator`: Creates new files with templates
  - `git-workflow`: Handles git operations
  - `date-checker`: Manages date-related operations
  - `debug-helper`: Investigates bugs, analyzes errors, and performs root cause analysis

## Common Development Tasks

### Installation Commands

```bash
# Base installation (system-wide customizable files)
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --claude-code

# Project installation (from base)
~/.agent-os/setup/project.sh --claude-code

# Project installation without base
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/project.sh | bash -s -- --no-base --claude-code
```

### Working with Agent OS Projects

When working in a project with Agent OS installed:

#### Development Workflows
1. **Product Planning**: Use `@commands/plan-product.md` to generate mission, tech-stack, and roadmap
2. **Create Specifications**: Use `@commands/create-spec.md` to create detailed technical specs
3. **Execute Tasks**: Use `@commands/execute-tasks.md` to implement features following TDD workflow
4. **Task Management**: Tasks are tracked in `.agent-os/tasks/[spec-name]/tasks.md`

#### Debugging Workflows

##### General Debugging
1. **Debug Issues**: Use `@commands/debug-issue.md` to systematically debug and fix issues
2. **Investigate Bugs**: Use `@commands/investigate-bug.md` to analyze bugs without immediately fixing
3. **Fix Regressions**: Use `@commands/fix-regression.md` to quickly fix broken functionality

##### Spec/Task-Specific Debugging
1. **Debug Task**: Use `@commands/debug-task.md` when debugging issues in a specific task during implementation
2. **Debug Spec**: Use `@commands/debug-spec.md` for integration issues across multiple tasks in a spec

##### Debug Documentation
- General debug reports: `.agent-os/debugging/`
- Task-specific debug reports: `.agent-os/debugging/tasks/`
- Spec-wide debug reports: `.agent-os/debugging/specs/`
- Investigation reports: `.agent-os/debugging/investigations/`
- Regression reports: `.agent-os/debugging/regressions/`

### Key Workflow Patterns

1. **Spec-Driven Development**: 
   - Every feature starts with a technical specification
   - Specs include user stories, technical details, and task breakdowns
   - Located in `.agent-os/specs/[spec-name]/`

2. **Test-Driven Development (TDD)**:
   - First subtask typically writes all tests
   - Middle subtasks implement functionality 
   - Final subtask verifies all tests pass

3. **Systematic Debugging**:
   - Context-aware debugging (general, task-specific, or spec-wide)
   - Structured investigation process with root cause analysis
   - Integration with spec/task workflow for in-progress implementations
   - Regression tests to prevent recurrence
   - Comprehensive documentation at appropriate scope level

4. **Subagent Delegation**:
   - Instructions use specialized subagents for specific tasks
   - Subagents handle context retrieval, file creation, testing, debugging, etc.

5. **Status Management**:
   - Tasks tracked with checkboxes in `tasks.md`
   - Completed tasks generate recaps in `.agent-os/recaps/`
   - Blocking issues documented with ⚠️ emoji
   - Debug reports in `.agent-os/debugging/`

## Configuration

- **config.yml**: Controls Agent OS behavior
  - Enable/disable Claude Code or Cursor support
  - Configure project types with custom instructions/standards
  - Set default project type

- **Version**: Current version is 1.4.1

## Testing & Development

This is the Agent OS framework itself - no application tests to run. For projects using Agent OS:
- Test commands are discovered from package.json or project configuration
- Test-runner subagent handles test execution
- Tests verified at task and spec completion levels

## Git Workflow

Agent OS projects use standard git workflows:
- Feature branches for development
- Commits after task completion (when using git-workflow subagent)
- Main branch as default base for PRs

## Important Notes

- Agent OS files live in `.agent-os/` directory within projects
- Instructions use `@` prefix for file references (e.g., `@.agent-os/instructions/core/create-spec.md`)
- Conditional blocks in instructions optimize context usage
- Pre-flight and post-flight checks ensure process compliance