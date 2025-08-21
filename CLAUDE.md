# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent OS is a spec-driven agentic development system that transforms AI coding agents into productive developers through structured workflows. It provides instructions, standards, and commands that guide AI agents to write quality code following established patterns and best practices.

## Architecture

Agent OS uses a modular, file-based architecture organized into:

- **Instructions** (`instructions/`): Step-by-step workflows for common development tasks
  - `core/`: Main product development and debugging workflows
    - Development: plan-product, create-spec, execute-tasks
    - Debugging: debug (smart context-aware), investigate, fix-regression
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

#### Debugging Workflows (Simplified)

Agent OS uses only 3 smart debugging commands:

1. **Debug**: Use `@commands/debug.md` - Auto-detects context (task, spec, or general) and applies appropriate workflow
2. **Investigate**: Use `@commands/investigate.md` - Analyze issues without fixing for complex problems
3. **Fix Regressions**: Use `@commands/fix-regression.md` - Quick fixes for previously working functionality

Debug reports are automatically organized by detected scope:
- Task debugging: `.agent-os/debugging/tasks/`
- Spec debugging: `.agent-os/debugging/specs/`
- General debugging: `.agent-os/debugging/`
- Investigations: `.agent-os/debugging/investigations/`
- Regressions: `.agent-os/debugging/regressions/`

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
   - Smart context auto-detection (task, spec, or general scope)
   - Single `debug` command adapts to any situation
   - Structured investigation and root cause analysis
   - Regression tests to prevent recurrence
   - Automatic report organization by scope

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