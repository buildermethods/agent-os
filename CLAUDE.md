# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QA Agent OS is a distributable, spec-driven system that provides AI coding assistants with structured context to perform production-quality QA tasks. It transforms generic AI capabilities into a specialized QA assistant tailored to a specific project's needs using a 3-layer context system: **Standards** (how we test), **Product** (what we're testing and why), and **Features** (what we're testing next).

## Core Architecture

The system is built on **four main components**:

### 1. Engine (`scripts/`)
Shell scripts that read configuration and process knowledge into final outputs:
- `project-install.sh` — Main entry point; installs QA Agent OS into a target project
- `project-update.sh` — Updates existing installation
- `common-functions.sh` — Shared utilities for parsing YAML, processing Markdown, compiling commands
- `base-install.sh` — One-time installation to `~/qa-agent-os`
- `create-profile.sh` — Utility for creating custom profiles

**Key concept:** The engine is separate from content. It processes Markdown files from the knowledge core and compiles them into structured outputs for AI agents.

### 2. Configuration (`config.yml`)
Central control panel defining:
- AI agent target (currently "Claude Code")
- Single-agent vs. multi-agent setup
- Profile selection (default or custom)
- Output paths and behavior (Claude Code commands, subagents, skills)

Current defaults target Claude Code with subagents enabled, standards injected as file references.

### 3. Knowledge & Personality (`profiles/default/`)
The content layer containing:

**`standards/`** — QA guidelines and conventions
- `global/` — Applies to all tasks (bugs.md, testcases.md, conventions.md)
- `bugs/` — Bug reporting standards, templates, severity rules, analysis checklists
- `requirement-analysis/` — BRD analysis, acceptance criteria, priority rules, requirement checklists
- `testcases/` — Test case structure, generation standards, test case templates
- `testing/` — API testing, exploratory testing, test plan templates

**`workflows/`** — Multi-step processes for complex tasks
- `planning/` — Product planning (gather info, create mission)
- `testing/` — Feature initialization, requirement analysis, test case generation
- `bug-tracking/` — Bug reporting process
- `implementation/` — Task list creation

**`commands/`** — Discrete AI agent commands (compiled into `.claude/commands/qa-agent-os/`)
- `plan-product/` — Create product mission documentation (Phase 1: gather concepts, Phase 2: create mission)
- `analise-requirements/` — Analyze requirements and generate test cases (Phase 1: init feature, Phase 2: requirement analysis, Phase 3: generate test cases)
- `init-feature/` — Initialize directory structure for new feature + ticket
- `generate-testcases/` — Generate test cases from analyzed requirements
- `improve-skills/` — Enhance AI agent capabilities (Claude Code Skills)
- `integrations/` — Jira and Testmo integration commands

**`agents/`** — Roles for multi-agent setups (currently not used in default single-agent config)
- product-planner.md, requirement-analyst.md, testcase-writer.md, bug-writer.md, etc.

### 4. Installation Output (End-user project)
After running `project-install.sh`, a project contains:
```
project/
├── .claude/
│   ├── commands/qa-agent-os/       ← Compiled Claude Code commands
│   └── agents/qa-agent-os/         ← Claude Code subagents (if enabled)
├── qa-agent-os/
│   ├── standards/                  ← Compiled standards from profiles/default/standards/
│   ├── product/                    ← User-created product context (mission.md)
│   └── features/                   ← User-created feature specs (ticket-based structure)
└── src/                            ← Actual project code
```

## Data Flow

1. User runs `project-install.sh` → reads `config.yml`
2. Script accesses `profiles/default/` for standards, workflows, commands
3. `common-functions.sh` compiles Markdown files:
   - Processes phase tags (`@qa-agent-os/...`)
   - Injects standards references
   - Normalizes paths
4. Output: `.claude/commands/qa-agent-os/` and `qa-agent-os/standards/`
5. AI agent uses compiled commands + product context + standards to perform tasks

## Common Development Tasks

### Adding a New Command
1. Create directory: `profiles/default/commands/[command-name]/single-agent/`
2. Create phase files (e.g., `1-step.md`, `2-step.md`) if multi-phase
3. Create orchestrator file: `[command-name].md` with phase tags: `@qa-agent-os/commands/[command-name]/1-step.md`
4. Run `project-install.sh` to compile

### Adding a New Standard
1. Create file: `profiles/default/standards/[category]/[standard-name].md`
2. Run `project-install.sh` to copy into project's `qa-agent-os/standards/`
3. Reference in commands using path tags or inline content

### Modifying Installation Logic
Edit `scripts/project-install.sh` or `scripts/common-functions.sh`. Key functions:
- `load_configuration()` — Read config.yml
- `compile_commands()` — Process command Markdown and phase tags
- `process_phase_tags()` — Replace `@qa-agent-os/` references with actual paths
- `process_standards()` — Inject standard file references

### Testing Installation Locally
```bash
# Create a test project directory
mkdir /tmp/test-project
cd /tmp/test-project

# Run installation with current source
/path/to/qa-agent-os/scripts/project-install.sh

# Verify output
ls -la .claude/commands/qa-agent-os/
ls -la qa-agent-os/standards/
```

## Key Technical Details

### Phase Tags in Commands
Commands use phase tags to reference sub-steps:
```markdown
# Phase 1 Command

@qa-agent-os/commands/my-command/1-phase.md

# Phase 2 Command

@qa-agent-os/commands/my-command/2-phase.md
```

The `process_phase_tags()` function replaces these with actual file paths during compilation. This allows modular command construction while maintaining clean source files.

### Standards Injection
Standards can be injected into commands two ways:
1. **File references** (default): Include path like `@qa-agent-os/standards/bugs/severity-rules.md`
2. **Direct embedding** (if skills enabled): Full standard content embedded in command

### YAML Configuration Parsing
`common-functions.sh` provides robust YAML parsing:
- Handles tabs and variable spacing
- Supports quoted values
- Defaults to config values if not overridden

## Entry Points for Development

- **Modifying defaults:** Edit `config.yml`
- **Adding QA standards:** Create files in `profiles/default/standards/`
- **Creating commands:** Create files in `profiles/default/commands/`
- **Fixing installation logic:** Edit `scripts/project-install.sh` or `scripts/common-functions.sh`
- **Creating custom profiles:** Use `scripts/create-profile.sh` or manually create `profiles/[name]/`

## Git Workflow

The project uses a feature branch approach. Current branch is `update-structure`. Key files frequently modified:
- `README.md` — User documentation
- `VISION.md` — Core vision document
- `IMPLEMENTATION_PLAN.md` — Tracks implementation progress
- `profiles/default/` — All standard content and commands
- `scripts/` — Installation and compilation logic

Recent changes focused on aligning installation scripts with the 3-layer context system and fixing broken commands.
