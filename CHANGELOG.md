# Changelog

Get notified of major releases by subscribing here:
https://buildermethods.com/qa-agent-os

## [2.1.1] - 2025-10-29

- Replaced references to 'spec-researcher' (depreciated agent name) with 'spec-shaper'.
- Clarified --dry-run output to user to reassure we're in dry-run mode
- Tightened up template and istructions for writing spec.md, aiming to keep it shorter, easier to scan, and covering only the essentials.
- Tweaked create-task-list workflow for consistency.
- When planning product roadmap, removed instruction to limit it to 12 items.
- Clarified instructions in implement-tasks in regards to useage of Playwright and screenshots.

## [2.1.0] - 2025-10-21

Version 2.1 implemented a round of significant changes to how things work in Agent OS.  Here is a summary of what's new in version 2.1.0:

### TL;DR

Here's the brief overview. It's all detailed below and the [docs](https://buildermethods.com/qa-agent-os) have been updated to reflect all of this.

- Option to leverage Claude Code's new "Skills" feature for reading standards
- Option to enable or disable delegating to Claude Code subagents
- Replaced "single/multi-agent modes" with more flexible configuration options
- Retired the short-lived "roles" system. Too complex, and better handled with standard tooling (more below).
- Removed documentation & verification bloat
- Went from 4 to 6 more specific development phases (use 'em all or pick and choose!):
  1. plan-product -- (no change) Plan your product's mission & roadmap
  2. shape-spec -- For shaping and planning a feature before writing it up
  3. write-spec -- For writing your spec.md
  4. create-tasks -- For creating your tasks.md
  5. implement-tasks -- Simple single-agent implementation of tasks.md
  6. orchestrate-tasks -- For more advanced, fine-grain control and multi-agent orchestration of tasks.md.
- Simplified & improved project upgrade script

Let's unpack these updates in detail:

### Claude Code Skills support

2.1 adds official support for [Claude Code Skills](https://docs.claude.com/en/docs/claude-code/skills).

When the config option standards_as_claude_code_skills is true, this will convert all of your standards into Claude Code Skills and _not_ inject references to those Standards like Agent OS normally would.

2.1 also provides a Claude Code command, `improve-skills` which you **definitely should** run after installing Agent OS in your project with the skills option turned on.  This command is designed to improve and rewrite each of your Claude Code Skills descriptions to make them more useable and discoverable by Claude Code.

### Enable/Disable delegation to Claude Code subagents

2.1 introduces an config option to enable or disable delegating tasks to Claude Code subagents.  You can disable subagents by setting use_claude_code_subagents to false.

When set to false, and when using Claude Code, you can still run Agent OS commands in Claude Code, and instead of delegating most tasks to subagents, Claude Code's main agent will execute everything.

While you lose some context efficiency of using subagents, you can token efficiency and some speed gains without the use of subagents.

### Replaced "single-agent & multi-agent modes" with new config options

2.0.x had introduced the concepts of multi-agent and single-agent modes, where multi-agent mode was designed for using Claude Code with subagents.  This naming and configuration design proved suboptimal and inflexible, so 2.1.0 does away with the terms "single-agent mode" and "multi-agent mode".

Now we configure Agent OS using these boolean options in your base ~/qa-agent-os/config.yml:

claude_code_commands: true/false
use_claude_code_subagents: true/false
agent_os_commands: true/false

The benefits of this new configuration approach are:

- Now you can use Agent OS with Claude Code *with* or *without* delegating to subagents.  (subagents bring many benefits like context efficiency, but also come with some tradeoffs—higher token usage, less transparency, slower to finish tasks).

- Before, when you had *both* single-agent and multi-agent modes enabled, your project's agent-os/commands/ folder ended up with "multi-agent/" and "single-agent/" subfolders for each command, which is confusing and clumsy to use.  Now in 2.1.0, your project's agent-os/commands/ folder will not have these additional "modes" subfolders.

- Easier to integrate additional feature configurations as they become available, so that you can mix and match the exact set of features that fit your preferred coding tools and workflow style.  For example, we're also introducing an option to make use of the new Claude Code Skills feature (or you can opt out).  More on this below.

### Retired (short-lived) "Roles" system

2.0.x had introduced a concept of "Roles", where your roles/implementers.yml and roles/verifiers.yml contained convoluted lists of agents that could be assigned to implement tasks.  It also had a script for adding additional "roles".

All of that is removed in 2.1.0.  That system added no real benefit over simply using available tooling (like Claude Code's own subagent generator) for spinning up your subagents.

2.1.0 introduces an 'orchestrate-tasks' phase, which achieves the same thing that the old "Roles" system intended:  Advanced orchestration of multiple specialized subagents to carry out a complex implementation.  More on this below.

### Removed documentation & verification bloat

2.0.x had introduced a bunch of "bloat" that quickly proved unnecessary and inefficient.  These bits have been removed in 2.1.0:

- Verification of your spec (although the spec-verifier Claude Code subagent is still available for you to call on, if/when you want)
- Documentation of every task's implementation
- Specialized verifiers (backend-verifier, frontend-verifier)

The final overall verification step for a spec's implementation remains intact.

### From 4 to 6 more specific development phases

While some users use all of Agent OS' workflow for everything, many have been picking the parts they find useful and discarding those that don't fit their workflow—AS THEY SHOULD!

2.1.0 establishes this as a core principle of Agent OS:  You can use as much or as little of it as you want!

With that in mind, we've moved from 4 to 6 different phases of development that can _potentially_ be powered by Agent OS:

1. `plan-product` -- No changes here.  This is for establishing your product's mission, roadmap and tech-stack.

2. `shape-spec` -- Use this when you need to take your rough idea for a feature and shape it into a well-scoped and strategized plan, before officially writing it up.  This is where the agent asks you clarifying questions and ends up producing your requirements.md.
  - Already got your requirements shaped?  Skip this and drop those right into your spec's requirements.md 👍

3. `write-spec` -- Takes your requirements.md and formalizes it into a clear and concise spec.md.

4. `create-tasks` -- Takes your spec.md and breaks it down into a tasks list, grouped, prioritized and ready for implementation.

5. `implement-tasks` -- Just want to build right now(!), then use this to implement your tasks.md with your main agent.

6. `orchestrate-tasks` -- Got a big complex feature and want to orchestrate multiple agents, with more fine-grain control over their contexts?  Use this.  It provides a structure to delegate your task groups to any Claude Code subagents you've created.  Or if you're not using Claude Code, it generates targeted prompt files (as was established in 2.0.x).

### Simplified & improved project upgrade script

Now whenever you need to upgrade your Agent OS project installation (to a new version or to push configuration changes or standards changes to a project), now when you run project-install.sh or project-update.sh, the system will:

- Check and compare your incoming version & configs to your current project's
- Show you what will stay intact or be removed & re-installed
- Ask you to confirm to proceed.


## [2.0.5] - 2025-10-16

- Updated base installation update options to include a "Full update" option, which is the easiest way to pull and update the latest Agent OS stuff (default profile, scripts) without losing your base installation's custom profiles.
- The "Full update" option also dynamically updates your base install config.yml version number without changing your configurations.

## [2.0.4] - 2025-10-14

- Fixed multi-agent-mode not installing the roles/ files in the project agent-os folder.
- Clarified spec-research instructions.
- In single-agent mode, added verification prompt generation to the implementation phase.

## [2.0.3] - 2025-10-10

- Updated instructions and default standards to reduce excessive tests writing and test running during feature development to improve speed and token useage.
- For Claude Code users:
  - Replaced hard-coding of 'opus' model setting on agents with 'inherit' so that it inherits whichever model your Claude Code is currently using.
  - Updated create-role script to add the "Inherit" option when creating new agents.

## [2.0.2] - 2025-10-09

- Clarified /create-spec command so that task list creation doesn't begin until spec.md has been written.
- Clarified spec-writer workflow to ensure actual code isn't written in spec.md.
- Fixed instructions to ensure spec-verification.md is stored in the spec's verication folder.
- Ensured Claude Code subagents are installed to a project's .claude/agents/qa-agent-os and not sub-folders within that.
- Fixed compilation of Claude Code implementer and verifier agents not replacing their dynamic tags.
- Added instruction in single-agent mode to inform user of next command to run during spec creation process.

## [2.0.1] - 2025-10-08

### Fixed

#### Installation Script Compatibility Issues

Fixed bugs in the project installation scripts (`project-install.sh`, `project-update.sh`, and `common-functions.sh`) that caused installations to fail in certain bash environments. These issues were triggered by stricter bash implementations and configurations, particularly when `set -e` (exit on error) was enabled.

## [2.0.0] - 2025-10-07

Agent OS 2.0 is a major new release that brings several core architectural changes and improvements.

The big headline here is the dual mode architecture for supporting both multi-agent tools (Claude Code) and single-agent tools (every other tool).

[this page](https://buildermethods.com/qa-agent-os/version-2) documents:

- The new features in Agent OS 2.0
- Architectural changes in 2.0
- What changed from 1.x
- Updating guide

[The Agent OS docs](https://buildermethods.com/qa-agent-os) also received a complete overhaul and expansion.  It's now broken out into multiple pages that document every detail of how to install, use and customize Agent OS.

## [1.4.2] - 2025-08-24

### Enforced full three-phase task execution

- Updated `instructions/core/execute-tasks.md` to strictly require all three phases (pre-execution, execution loop, post-execution) and to invoke `instructions/core/post-execution-tasks.md` after task completion.

### Post-execution process overhaul

- Renamed `instructions/core/complete-tasks.md` to `instructions/core/post-execution-tasks.md`.
- Improved the post-execution workflow by adding clarity and removing bloat in instructions.

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
  `curl -sSL https://raw.githubusercontent.com/buildermethods/qa-agent-os/main/setup/base.sh | bash -s -- --claude-code`
  - Agent OS with Cursor support:
  `curl -sSL https://raw.githubusercontent.com/buildermethods/qa-agent-os/main/setup/base.sh | bash -s -- --cursor`
  - Agent OS with Claude Code & Cursor support:
  `curl -sSL https://raw.githubusercontent.com/buildermethods/qa-agent-os/main/setup/base.sh | bash -s -- --claude-code --cursor`

3. Customize your /standards (just like earlier versions)

**Project installation**

- Now each project codebase gets it's own self-contained installation of Agent OS.  It no longer references instructions or standards that reside elsewhere on your system.  These all get installed directly into your project's .agent-os folder, which brings several benefits:
  - No external references = more reliable Agent OS commands & workflows.
  - You can commit your instructions, standards, Claude Code commands and agents to your project's github repo for team access.
  - You can customize standards differently per project than what's in your base installation.

Your project installation command will be based on where you installed the Agent OS base installation.
- If you've installed it to your system's home folder, then your project installation command will be `~/.agent-os/setup/project.sh`.
- If you've installed it elsewhere, your command will be `/path/to/qa-agent-os/setup/project.sh`
(after your base installation, it will show you _your_ project installation command. It's a good idea to save it or make an alias if you work on many projects.)

If (for whatever reason) you didn't install the base installation, you can still install Agent OS directly into a project, by pulling it directly off of the public github repo using the following command.
- Note: This means your standards folder won't inherit your defaults from a base installation. You'd need to customize the files in the standards folder for this project.
`curl -sSL https://raw.githubusercontent.com/buildermethods/qa-agent-os/main/setup/project.sh | bash -s -- --no-base --claude-code --cursor`

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
`curl -sSL https://raw.githubusercontent.com/buildermethods/qa-agent-os/main/setup/base.sh | bash -s -- --overwrite-instructions --claude-code --cursor`

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

[1.4.1]: https://github.com/buildermethods/qa-agent-os/compare/v1.4.0...v1.4.1
[1.4.2]: https://github.com/buildermethods/qa-agent-os/compare/v1.4.1...v1.4.2
[1.4.0]: https://github.com/buildermethods/qa-agent-os/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/buildermethods/qa-agent-os/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/buildermethods/qa-agent-os/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/buildermethods/qa-agent-os/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/buildermethods/qa-agent-os/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/buildermethods/qa-agent-os/releases/tag/v1.0.0
