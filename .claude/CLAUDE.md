# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent OS is a development framework that installs into other projects to provide structured AI-assisted software development workflows. All command instructions are embedded within command files (~250-636 lines each) to ensure 99% reliable execution.

**Critical**: This is the Agent OS **source repository**. Changes here affect all projects that install Agent OS. This is a meta-repository - files here are templates that get copied to target projects during installation.

## Development Commands

```bash
# Test installation in a separate test project
./setup/project.sh --claude-code                 # Basic installation (7 default skills)
./setup/project.sh --claude-code --full-skills   # Full installation (11 skills)
./setup/project.sh --claude-code --with-hooks    # With validation hooks
./setup/project.sh --cursor                      # Cursor support
```

**Workflow**: Make changes → Test in test project → Update SYSTEM-OVERVIEW.md → Update CHANGELOG.md → Commit

## Source Repository Structure

```
agent-os/
├── commands/              # Source command files → copied to .claude/commands/
├── claude-code/
│   ├── agents/            # Source subagent files → copied to .claude/agents/
│   └── skills/            # Source skill files → copied to .claude/skills/
├── setup/                 # Installation scripts
│   ├── project.sh         # Main installer
│   ├── base.sh
│   └── functions.sh
├── standards/             # Development standards → copied to .agent-os/standards/
├── config.yml             # Configuration template
└── SYSTEM-OVERVIEW.md     # Comprehensive system documentation
```

## Commands & Subagents

**Commands** (source: `commands/*.md`):
- `plan-product` / `analyze-product` - Product initialization
- `create-spec` → `create-tasks` → `execute-tasks` - Feature development pipeline
- `index-codebase` - Code reference management
- `debug` - Context-aware debugging with git integration

**Subagents** (source: `claude-code/agents/*.md`):

| Subagent | Purpose |
|----------|---------|
| git-workflow | Branch management, commits, PRs |
| codebase-indexer | Code reference updates |
| project-manager | Task/roadmap updates |

**Skills** (source: `claude-code/skills/*.md`) - Model-invoked, auto-triggered:

| Skill | Purpose |
|-------|---------|
| build-check | Auto-invoke before commits to verify build and classify errors |
| test-check | Auto-invoke after code changes to run and analyze tests |
| codebase-names | Auto-invoke when writing code to validate existing function/variable names |
| systematic-debugging | Auto-invoke when debugging to enforce 4-phase root cause analysis |
| tdd | Auto-invoke before implementing features to enforce RED-GREEN-REFACTOR |
| brainstorming | Invoke during spec creation for Socratic design refinement |
| writing-plans | Invoke during task breakdown for detailed micro-task planning |

**Optional Skills** (source: `claude-code/skills/optional/*.md`) - Installed with `--full-skills`:

| Skill | Purpose |
|-------|---------|
| code-review | Pre-review checklists and feedback integration |
| verification | Evidence-based completion verification |
| skill-creator | Guide for creating custom Agent OS skills |
| mcp-builder | Guide for creating MCP servers |

**Native Claude Code Features Used:**
- **Explore agent**: Specification discovery, document retrieval (replaces spec-cache-manager, context-fetcher)
- **Write tool**: File creation (replaces file-creator)
- **Environment context**: Date/time utilities (replaces date-checker)

## Making Changes

### Modifying Commands
1. Edit `commands/[command-name].md` (all instructions embedded)
2. Test: Install in test project and run the command
3. Update `SYSTEM-OVERVIEW.md` if adding new features

### Adding New Subagents
1. Create `claude-code/agents/[agent-name].md`
2. Add to installation list in `setup/project.sh`
3. Document in `SYSTEM-OVERVIEW.md`

### Adding New Skills
1. Create `claude-code/skills/[skill-name].md` with YAML frontmatter (name, description, allowed-tools)
2. Add to installation list in `setup/project.sh`
3. Document in `SYSTEM-OVERVIEW.md`
4. Skills are model-invoked (Claude decides when to use them based on description)

### Command Structure Pattern
All commands follow this structure:
1. Quick Navigation
2. Description & Parameters
3. Dependencies
4. Task Tracking (TodoWrite examples)
5. For Claude Code (meta instructions)
6. Core Instructions (embedded)
7. State Management
8. Error Handling
9. Subagent Integration

## State Management

**Atomic writes**: All state operations write to temp file first, then atomic rename.

**Session cache** (`.agent-os/state/session-cache.json`):
- 5-minute expiration with auto-extension (max 12 extensions = 1 hour)
- Stores spec cache, context cache, metadata

**Recovery**: Auto-backups in `.agent-os/state/recovery/` (keeps last 5 versions)

## Content Mapping

For features referencing external content (images, data files), create `content-mapping.md` in specs. See `docs/content-mapping-pattern.md` for full documentation.

## References

- **Comprehensive docs**: `SYSTEM-OVERVIEW.md`
- **Version history**: `CHANGELOG.md`
- **Official site**: https://buildermethods.com/agent-os
