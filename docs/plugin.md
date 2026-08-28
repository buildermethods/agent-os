# Agent OS as a Plugin

Agent OS ships as a plugin for three coding harnesses — **Claude Code**, **OpenAI Codex**, and **pi** — from a single set of files.

## How the portability works

| Piece | Format | Read by |
|-------|--------|---------|
| `skills/agent-os-*/SKILL.md` | [Agent Skills standard](https://agentskills.io) | Claude Code, Codex, pi |
| `commands/agent-os/*.md` | Markdown + frontmatter + `$ARGUMENTS` | Claude Code slash commands, pi prompt templates, Codex custom prompts |
| `.claude-plugin/plugin.json` | Claude Code plugin manifest | Claude Code |
| `package.json` → `pi` key | pi package manifest | pi |

The skills are the single source of truth. `commands/agent-os/*.md` is generated from them by `scripts/build-commands.sh` — edit the skills, never the commands.

Whichever harness you use, Agent OS reads and writes the same project files under `agent-os/` (`standards/`, `product/`, `specs/`), so a spec shaped in Claude Code is picked up by Codex or pi unchanged.

## Install

### Claude Code

As a plugin (recommended — updates come with the marketplace):

```
/plugin marketplace add slurpyb/agent-os
/plugin install agent-os@agent-os
```

Or copy into the project:

```bash
git clone https://github.com/slurpyb/agent-os.git ~/agent-os
cd /path/to/your/project
~/agent-os/scripts/install-plugin.sh --target claude
```

Commands are namespaced by the plugin: `/agent-os:shape-spec`, `/agent-os:discover-standards`, and so on. The skills also load on their own when a task matches.

### OpenAI Codex

```bash
cd /path/to/your/project
~/agent-os/scripts/install-plugin.sh --target codex
```

This writes to `.agents/skills/`, which Codex scans from the working directory up to the repository root. Codex loads a skill when your request matches its description — just describe the task.

For a user-wide install (adds `$CODEX_HOME/prompts/` so you can invoke a workflow explicitly with `/prompts:agent-os-shape-spec`):

```bash
~/agent-os/scripts/install-plugin.sh --target codex --global
```

### pi

As a pi package (recommended):

```bash
pi install git:github.com/slurpyb/agent-os
```

Or into the project:

```bash
cd /path/to/your/project
~/agent-os/scripts/install-plugin.sh --target pi
```

Invoke a workflow with `/skill:agent-os-shape-spec` (loads the skill) or `/agent-os-shape-spec` (expands the prompt template). Project-level skills load once you've trusted the project with `/trust`.

### All three at once

```bash
cd /path/to/your/project
~/agent-os/scripts/install-plugin.sh
```

Codex and pi both read `.agents/skills/`, so the installer writes the skills there once rather than duplicating them into `.pi/skills/`.

Add `--link` to symlink instead of copy, so `git pull` in your Agent OS clone updates every project.

## Installer reference

```
scripts/install-plugin.sh [--target <t>]... [--global] [--link] [--verbose]
```

| Target | Project scope | User scope (`--global`) |
|--------|---------------|-------------------------|
| `claude` | `.claude/skills/`, `.claude/commands/agent-os/` | `~/.claude/skills/`, `~/.claude/commands/agent-os/` |
| `codex` | `.agents/skills/` | `$CODEX_HOME/skills/`, `$CODEX_HOME/prompts/` |
| `pi` | `.pi/skills/`, `.pi/prompts/` | `~/.pi/agent/skills/`, `~/.pi/agent/prompts/` |
| `agents` | `.agents/skills/` | `~/.agents/skills/` |
| `all` (default) | `claude` + `codex` + `pi` | same |

`scripts/project-install.sh` installs standards *and* calls this installer; pass `--agents claude,codex,pi` to cover every harness:

```bash
~/agent-os/scripts/project-install.sh --agents claude,codex,pi
```

## The workflows

| Skill | Claude Code | pi | Codex |
|-------|-------------|----|-------|
| `agent-os-discover-standards` | `/agent-os:discover-standards` | `/agent-os-discover-standards` | `/prompts:agent-os-discover-standards` |
| `agent-os-inject-standards` | `/agent-os:inject-standards` | `/agent-os-inject-standards` | `/prompts:agent-os-inject-standards` |
| `agent-os-index-standards` | `/agent-os:index-standards` | `/agent-os-index-standards` | `/prompts:agent-os-index-standards` |
| `agent-os-plan-product` | `/agent-os:plan-product` | `/agent-os-plan-product` | `/prompts:agent-os-plan-product` |
| `agent-os-shape-spec` | `/agent-os:shape-spec` | `/agent-os-shape-spec` | `/prompts:agent-os-shape-spec` |

In every harness you can also just describe the task and let the agent load the matching skill on its own.

## Contributing to the workflows

Edit `skills/agent-os-*/SKILL.md`, then regenerate the commands:

```bash
scripts/build-commands.sh
```

CI runs `scripts/build-commands.sh --check` and fails if `commands/agent-os/` is stale.

Each skill's frontmatter carries the metadata the generator needs:

```yaml
---
name: agent-os-shape-spec
description: <what it does and when to use it — this is what the agent matches on>
metadata:
  agent-os-command: shape-spec          # generated filename / slash command
  agent-os-summary: <one line for the command palette>
  agent-os-argument-hint: "[what we're building]"
---
```

Keep skill bodies harness-neutral: no hard requirement on a tool that only one harness has. Where a workflow wants a structured question or a plan mode, name the Claude Code feature as an example and give the fallback for harnesses without it.
