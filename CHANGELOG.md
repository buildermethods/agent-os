# Changelog

All notable changes to Agent OS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.7.0] - 2025-12-08

### Progress Log System (Cross-Session Memory)

Based on Anthropic's "Effective Harnesses for Long-Running Agents" research, this release implements persistent progress logging for cross-session memory.

**Reference**: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

**New Features:**

| Feature | Description |
|---------|-------------|
| **Progress Log** | Permanent chronological log of accomplishments (`progress.json`) |
| **Human-Readable Log** | Auto-generated markdown version (`progress.md`) |
| **Archive System** | Automatic archival of entries older than 30 days |
| **Cross-Session Context** | New sessions can read previous accomplishments |

**Problem Solved:**

Previously, session cache expired after 1 hour max, losing all context between sessions. Now progress persists indefinitely, enabling:
- Context continuity across unlimited sessions
- Blocker tracking visible across sessions
- Team visibility via version-controlled progress files

**Integration Points:**

| Step | Event Logged | When |
|------|-------------|------|
| Step 6.5 | `session_started` | After Phase 1 (environment verified) |
| Step 7.10 | `task_completed` | After each parent task |
| Step 15 | `session_ended` | After Phase 3 (workflow complete) |

**New Files:**

- `shared/progress-log.md` - Canonical patterns for progress logging
- `shared/task-json.md` - Patterns for JSON task tracking
- `claude-code/skills/session-startup.md` - Session startup protocol skill
- `.agent-os/progress/progress.json` - Machine-readable progress data
- `.agent-os/progress/progress.md` - Human-readable progress log
- `.agent-os/progress/archive/` - Archived old entries
- `tests/progress-log-validation.md` - Validation procedures

### Session Startup Protocol (New Skill)

New `session-startup` skill auto-invokes at execute-tasks start:

| Step | Purpose |
|------|---------|
| 1. Directory verification | Confirm project root |
| 2. Progress context load | Read recent accomplishments |
| 3. Git state review | Check branch, uncommitted changes |
| 4. Task status check | Current spec progress |
| 5. Environment health | Dev server, config files |
| 6. Session focus confirmation | Confirm task selection |

**Benefits**: Cross-session context automatically loaded, blockers highlighted, environment issues caught early.

### Scope Constraint Logic

New Step 1.5 in execute-tasks warns when multiple parent tasks selected:

- Displays research-backed recommendation for single-task focus
- User can override with explicit confirmation
- Overrides logged to progress log for analysis

### JSON Task Format

New `tasks.json` generated alongside `tasks.md`:

```json
{
  "tasks": [{
    "id": "1.1",
    "status": "pass",
    "attempts": 2,
    "duration_minutes": 45
  }],
  "summary": {
    "completed": 5,
    "total_tasks": 10,
    "overall_percent": 50
  }
}
```

**Benefits**: Programmatic task queries, attempt tracking, duration metrics.

**Installation:**

All features automatically available on new installations:
```bash
./setup/project.sh --claude-code
```

Existing installations get new features on upgrade:
```bash
./setup/project.sh --claude-code --upgrade
```

**Skills Total:** 8 default + 4 optional = 12 skills

---

## [1.6.0] - 2025-12-05

### Extended Skills Library

Major skills expansion integrating battle-tested development workflow skills from the community (obra/superpowers) and official Anthropic skills.

**New Tier 1 Skills (Default - Always Installed):**

| Skill | Purpose | Source |
|-------|---------|--------|
| systematic-debugging | 4-phase root cause analysis before fixes | obra/superpowers |
| tdd | RED-GREEN-REFACTOR cycle enforcement | obra/superpowers |
| brainstorming | Socratic design refinement through questioning | obra/superpowers |
| writing-plans | Detailed micro-task breakdown (2-5 min tasks) | obra/superpowers |

**New Tier 2 Skills (Optional - `--full-skills` flag):**

| Skill | Purpose | Source |
|-------|---------|--------|
| code-review | Pre-review checklists, feedback integration | obra/superpowers |
| verification | Evidence-based completion verification | obra/superpowers |
| skill-creator | Guide for creating custom Agent OS skills | anthropics/skills |
| mcp-builder | Guide for creating MCP servers | anthropics/skills |

**Command Integrations:**

| Command | New Skills Integrated |
|---------|----------------------|
| debug.md | systematic-debugging (root cause analysis) |
| create-spec.md | brainstorming (scope exploration) |
| create-tasks.md | tdd, writing-plans (TDD structure) |
| execute-tasks.md | tdd, verification (implementation gates) |

**Installation:**

```bash
# Default (7 skills)
./setup/project.sh --claude-code

# Full (11 skills including optional)
./setup/project.sh --claude-code --full-skills
```

**Skills Total:** 7 default + 4 optional = 11 skills

---

## [1.5.0] - 2025-12-05

### Native Claude Code Integration - BREAKING CHANGE

Major architectural update to leverage Claude Code's native features, reducing complexity while preserving unique value. **This is a breaking change requiring re-installation in existing projects.**

**Component Changes:**
- Subagents reduced from 9 to 3 (56% reduction)
- Added 3 new Skills (model-invoked capabilities)
- Commands simplified to use native Explore agent

### Retired Subagents (6)

| Agent | Replacement |
|-------|-------------|
| date-checker | Native environment context (Claude receives date in every session) |
| file-creator | Native Write tool + embedded templates in commands |
| spec-cache-manager | Native Explore agent (fast enough without caching) |
| context-fetcher | Native Explore agent + codebase-names Skill |
| test-runner | Converted to test-check Skill |
| build-checker | Converted to build-check Skill |

### New Skills (3)

Skills are model-invoked - Claude automatically decides when to use them based on context.

| Skill | Purpose |
|-------|---------|
| build-check | Auto-invoked before git commits to verify build and classify errors |
| test-check | Auto-invoked after code changes to run tests and analyze failures |
| codebase-names | Auto-invoked when writing code to validate existing function/variable names |

### Remaining Subagents (3)

| Agent | Purpose |
|-------|---------|
| git-workflow | Branch management, commits, PRs (unique conventions) |
| codebase-indexer | Code reference updates and compliance tracking |
| project-manager | Task/roadmap state management |

### Key Benefits

- **56% fewer custom components** (9 subagents → 3 subagents + 3 skills)
- **Automatic quality gates** via Skills (tests & builds never forgotten)
- **Faster execution** using native Explore agent
- **Simpler maintenance** (fewer custom components to maintain)
- **Better alignment** with Claude Code's native patterns

### Migration

This is a breaking change. Existing AgentOS installations must re-run the installer:
```bash
./setup/project.sh --claude-code
```

## [1.4.1] - 2025-08-18

### Replaced Decisions with Recaps

Earlier versions added a decisions.md inside a project's .agent-os/product/.  In practice, this was rarely used and didn't help future development.

It's been replaced with a new system for creating "Recaps"—short summaries of what was built—after every feature spec's implementation has been completed.  Similar to a changelog, but more descriptive and context-focused.  These recaps are easy to reference by both humans and AI agents.

Recaps are automatically generated via the new complete-tasks.md process.

### Added Project-Manager Subagent

A goal of this update was to tighten up the processes for creating specs and executing tasks, ensuring these processes are executed reliably.  Sounds like the job for a "project manager".

This update introduces a new subagent (for Claude Code) called project-manager which handles all task completion, status updates, and reporting progress back to you.

### Spec Creation & Task Execution Reliability Improvements

Several changes to the instructions, processes, and executions, all aimed at helping agents follow the process steps consistently.

- Consolidated task execution instructions with clear step-by-step processes
- Added post-flight verification rules to ensure instruction compliance
- Improved subagent delegation tracking and reporting
- Standardized test suite verification and git workflow integration
- Enhanced task completion criteria validation and status management

## [1.4.0] - 2025-08-17

BIG updates in this one!  Thanks for all the feedback, requests and support 🙏

### All New Installation Process

The way Agent OS gets installed is structured differently from prior versions.  The new system works as follows:

There are 2 installation processes:
- Your "Base installation" (now optional, but still recommended!)
- Your "Project installation"

**"Base installation"**
- Installs all of the Agent OS files to a location of your choosing on your system where they can be customized (especially your standards) and maintained.
- Project installations copy files from your base installation, so they can be customized and self-contained within each individual project.
- Your base installation now has a config.yml

To install the Agent OS base installation,

1. cd to a location of your choice (your system's home folder is a good choice).

2. Run one of these commands:
  - Agent OS with Claude Code support:
  `curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --claude-code`
  - Agent OS with Cursor support:
  `curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --cursor`
  - Agent OS with Claude Code & Cursor support:
  `curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --claude-code --cursor`

3. Customize your /standards (just like earlier versions)

**Project installation**

- Now each project codebase gets it's own self-contained installation of Agent OS.  It no longer references instructions or standards that reside elsewhere on your system.  These all get installed directly into your project's .agent-os folder, which brings several benefits:
  - No external references = more reliable Agent OS commands & workflows.
  - You can commit your instructions, standards, Claude Code commands and agents to your project's github repo for team access.
  - You can customize standards differently per project than what's in your base installation.

Your project installation command will be based on where you installed the Agent OS base installation.
- If you've installed it to your system's home folder, then your project installation command will be `~/.agent-os/setup/project.sh`.
- If you've installed it elsewhere, your command will be `/path/to/agent-os/setup/project.sh`
(after your base installation, it will show you _your_ project installation command. It's a good idea to save it or make an alias if you work on many projects.)

If (for whatever reason) you didn't install the base installation, you can still install Agent OS directly into a project, by pulling it directly off of the public github repo using the following command.
- Note: This means your standards folder won't inherit your defaults from a base installation. You'd need to customize the files in the standards folder for this project.
`curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/project.sh | bash -s -- --no-base --claude-code --cursor`

### Agent OS config.yml

When you install the Agent OS base installation, that now includes a config.yml file.  Currently this file is used for:
- Tracking the Agent OS version you have installed
- Which coding agents (Claude Code, Cursor) you're using
- Project Types (new! read on...)

### Project Types

If you work on different types of projects, you can define different sets of standards, code style, and instructions for each!

- By default, a new installation of Agent OS into a project will copy its instructions and standards from your base installation's /instructions and /standards.
- You can define additional project types by doing the following:
  - Setup a folder (typically inside your base installation's .agent-os folder, but it can be anywhere on your system) which contains /instructions and /standards folders (copy these from your base install, then customize).
  - Define the project type's folder location on your system in your base install's config.yml
- Using project types:
  - If you've named a project type, 'ruby-on-rails', when running your project install command, add the flag --project-type=ruby-on-rails.
  - To make a project type your default for new projects, set it's name as the value for default_project_type in config.yml

### Removed or changed in version 1.4.0:

This update does away with the old installation script files:
- setup.sh (replaced by /setup/base.sh and /setup/project.sh)
- setup-claude-code.sh (now you add --claude-code flag to the install commands or enable it in your Agent OS config.yml)
- setup-cursor.sh (now you add --cursor flag to the install commands or enable it in your Agent OS config.yml)

Claude Code Agent OS commands now should _not_ be installed in the `~/.agent-os/.claude/commands` folder.  Now, these are copied from ~/.agent-os/commands into each project's `~/.claude/commands` folder (this prevents duplicate commands showing in in Claude Code's commands list).  The same approach applies to Claude Code subagents files.

### Upgrading to version 1.4.0

Follow these steps to update a previous version to 1.4.0:

1. If you've customized any files in /instructions, back those up now. They will be overwritten.

2. Navigate to your home directory (or whichever location you want to have your Agent OS base installation)

3. Run the following to command, which includes flags to overwrite your /instructions (remove the --cursor flag if not using Cursor):
`curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup/base.sh | bash -s -- --overwrite-instructions --claude-code --cursor`

4. If your ~/.claude/commands contain Agent OS commands, remove those and copy the versions that are now in your base installation's commands folder into your _project's_ `.claude/commands` folder.

5. Navigate to your project. Run your project installation command to install Agent OS instructions and standards into your project's installation. If your Agent OS base installation is in your system's home folder (like previous versions), then your project installation will be: `~/.agent-os/setup/project.sh`

## [1.3.1] - 2025-08-02

### Added
- **Date-Checker Subagent** - New specialized Claude Code subagent for accurate date determination using file system timestamps
  - Uses temporary file creation to extract current date in YYYY-MM-DD format
  - Includes context checking to avoid duplication
  - Provides clear validation and error handling

### Changed
- **Create-Spec Instructions** - Updated `instructions/core/create-spec.md` to use the new date-checker subagent
  - Replaced complex inline date determination logic with simple subagent delegation
  - Simplified step 4 (date_determination) by removing 45 lines of validation and fallback code
  - Cleaner instruction flow with specialized agent handling date logic

### Improved
- **Code Maintainability** - Date determination logic centralized in reusable subagent
- **Instruction Clarity** - Simplified create-spec workflow with cleaner delegation pattern
- **Error Handling** - More robust date determination with dedicated validation rules

## [1.3.0] - 2025-08-01

### Added
- **Pre-flight Check System** - New `meta/pre-flight.md` instruction for centralized agent detection and initialization
- **Proactive Agent Usage** - Updated agent descriptions to encourage proactive use when appropriate
- **Structured Instruction Organization** - New folder structure with `core/` and `meta/` subdirectories

### Changed
- **Instruction File Structure** - Reorganized all instruction files into subdirectories:
  - Core instructions moved to `instructions/core/` (plan-product, create-spec, execute-tasks, execute-task, analyze-product)
  - Meta instructions in `instructions/meta/` (pre-flight, more to come)
- **Simplified XML Metadata** - Removed verbose `<ai_meta>` and `<step_metadata>` blocks for cleaner, more readable instructions
- **Subagent Integration** - Replaced manual agent detection with centralized pre-flight check across all instruction files to enforce delegation and preserve main agent's context.
- **Step Definitions** - Added `subagent` attribute to steps for clearer delegation of work to help enforce delegation and preserve main agent's context.
- **Setup Script** - Updated to create subdirectories and download files to new locations

### Improved
- **Code Clarity** - Removed redundant XML instructions in favor of descriptive step purposes
- **Agent Efficiency** - Centralized agent detection reduces repeated checks throughout workflows
- **Maintainability** - Cleaner instruction format with less XML boilerplate
- **User Experience** - Clearer indication of when specialized agents will be used proactively

### Removed
- **CLAUDE.md** - Removed deprecated Claude Code configuration file (functionality moved to pre-flight system, preventing over-reading instructions into context)
- **Redundant Instructions** - Eliminated verbose ACTION/MODIFY/VERIFY instruction blocks

## [1.2.0] - 2025-07-29

### Added
- **Claude Code Specialized Subagents** - New agents to offload specific tasks for improved efficiency:
  - `test-runner.md` - Handles test execution and failure analysis with minimal toolset
  - `context-fetcher.md` - Retrieves information from files while checking context to avoid duplication
  - `git-workflow.md` - Manages git operations, branches, commits, and PR creation
  - `file-creator.md` - Creates files, directories, and applies consistent templates
- **Agent Detection Pattern** - Single check at process start with boolean flags for efficiency
- **Subagent Integration** across all instruction files with automatic fallback for non-Claude Code users

### Changed
- **Instruction Files** - All updated to support conditional agent usage:
  - `execute-tasks.md` - Uses git-workflow (branch management, PR creation), test-runner (full suite), and context-fetcher (loading lite files)
  - `execute-task.md` - Uses context-fetcher (best practices, code style) and test-runner (task-specific tests)
  - `plan-product.md` - Uses file-creator (directory creation) and context-fetcher (tech stack defaults)
  - `create-spec.md` - Uses file-creator (spec folder) and context-fetcher (mission/roadmap checks)
- **Standards Files** - Updated for conditional agent usage:
  - `code-style.md` - Uses context-fetcher for loading language-specific style guides
- **Setup Scripts** - Enhanced to install Claude Code agents:
  - `setup-claude-code.sh` - Downloads all agents to `~/.claude/agents/` directory

### Improved
- **Context Efficiency** - Specialized agents use minimal context for their specific tasks
- **Code Organization** - Complex operations delegated to focused agents with clear responsibilities
- **Error Handling** - Agents provide targeted error analysis and recovery strategies
- **Maintainability** - Cleaner main agent code with operations abstracted to subagents
- **Performance** - Reduced context checks through one-time agent detection pattern

### Technical Details
- Each agent uses only necessary tools (e.g., test-runner uses only Bash, Read, Grep, Glob)
- Automatic fallback ensures compatibility for users without Claude Code
- Consistent `IF has_[agent_name]:` pattern reduces code complexity
- All agents follow Agent OS conventions (branch naming, commit messages, file templates)

## [1.1.0] - 2025-07-29

### Added
- New `mission-lite.md` file generation in product initialization for efficient AI context usage
- New `spec-lite.md` file generation in spec creation for condensed spec summaries
- New `execute-task.md` instruction file for individual task execution with TDD workflow
- Task execution loop in `execute-tasks.md` that calls `execute-task.md` for each parent task
- Language-specific code style guides:
  - `standards/code-style/css-style.md` for CSS and TailwindCSS
  - `standards/code-style/html-style.md` for HTML markup
  - `standards/code-style/javascript-style.md` for JavaScript
- Conditional loading blocks in `best-practices.md` and `code-style.md` to prevent duplicate context loading
- Context-aware file loading throughout all instruction files

### Changed
- Optimized `plan-product.md` to generate condensed versions of documents
- Enhanced `create-spec.md` with conditional context loading for mission-lite and tech-stack files
- Simplified technical specification structure by removing multiple approach options
- Made external dependencies section conditional in technical specifications
- Updated `execute-tasks.md` to use minimal context loading strategy
- Improved `execute-task.md` with selective reading of relevant documentation sections
- Modified roadmap progress check to be conditional and context-aware
- Updated decision documentation to avoid loading decisions.md and use conditional checks
- Restructured task execution to follow typical TDD pattern (tests first, implementation, verification)

### Improved
- Context efficiency by 60-80% through conditional loading and lite file versions
- Reduced duplication when files are referenced multiple times in a workflow
- Clearer separation between task-specific and full test suite execution
- More intelligent file loading that checks current context before reading
- Better organization of code style rules with language-specific files

### Fixed
- Duplicate content loading when instruction files are called in loops
- Unnecessary loading of full documentation files when condensed versions suffice
- Redundant test suite runs between individual task execution and overall workflow

## [1.0.0] - 2025-07-21

### Added
- Initial release of Agent OS framework
- Core instruction files:
  - `plan-product.md` for product initialization
  - `create-spec.md` for feature specification
  - `execute-tasks.md` for task execution
  - `analyze-product.md` for existing codebase analysis
- Standard files:
  - `tech-stack.md` for technology choices
  - `code-style.md` for formatting rules
  - `best-practices.md` for development guidelines
- Product documentation structure:
  - `mission.md` for product vision
  - `roadmap.md` for development phases
  - `decisions.md` for decision logging
  - `tech-stack.md` for technical architecture
- Setup scripts for easy installation
- Integration with AI coding assistants (Claude Code, Cursor)
- Task management with TDD workflow
- Spec creation and organization system

[1.4.1]: https://github.com/buildermethods/agent-os/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/buildermethods/agent-os/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/buildermethods/agent-os/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/buildermethods/agent-os/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/buildermethods/agent-os/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/buildermethods/agent-os/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/buildermethods/agent-os/releases/tag/v1.0.0
