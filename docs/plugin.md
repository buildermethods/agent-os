# Agent OS as a Plugin

Agent OS is one plugin, installed from a marketplace in all three harnesses — **Claude Code**, **OpenAI Codex**, and **pi**. Nothing is copied into your home directory: each harness loads the skills and commands from the installed plugin itself.

## Install

### Claude Code

```
/plugin marketplace add slurpyb/agent-os
/plugin install agent-os@agent-os
```

### OpenAI Codex

```
/plugin marketplace add slurpyb/agent-os
/plugin install agent-os
```

Or from the CLI: `codex plugin marketplace add slurpyb/agent-os`, then `codex plugin install agent-os`.

### pi

```bash
pi install git:github.com/slurpyb/agent-os
```

Add `-l` to install into the current project's `.pi/settings.json` instead of your user settings, so the team shares it.

## Repository layout

The layout follows the [openai/plugins](https://github.com/openai/plugins) convention, which Claude Code's marketplace format also supports:

```
.agents/plugins/marketplace.json     # Codex marketplace → ./plugins/agent-os
.claude-plugin/marketplace.json      # Claude Code marketplace → ./plugins/agent-os
package.json → "pi" manifest         # pi package → ./plugins/agent-os/{skills,commands}
plugins/agent-os/
├── .codex-plugin/plugin.json        # Codex plugin manifest
├── .claude-plugin/plugin.json       # Claude Code plugin manifest
├── skills/agent-os-*/SKILL.md       # the workflows — single source of truth
└── commands/*.md                    # generated from skills/
```

Marketplace `source` paths resolve against the marketplace root, which for `<repo>/.agents/plugins/marketplace.json` is the repository root — hence `./plugins/agent-os`.

## Why one set of files works in three harnesses

| Piece | Format | Read by |
|-------|--------|---------|
| `skills/agent-os-*/SKILL.md` | [Agent Skills standard](https://agentskills.io) | Claude Code, Codex, pi |
| `commands/*.md` | Markdown + frontmatter + `$ARGUMENTS` | Claude Code plugin commands, Codex plugin commands, pi prompt templates |

The skills are the single source of truth; `commands/` is generated from them by `scripts/build-commands.sh`. Skill bodies are written harness-neutrally — where a workflow wants a structured question or a plan mode, it names the Claude Code feature as an example and gives the fallback for harnesses without it.

Whichever harness you use, Agent OS reads and writes the same project files under `agent-os/` (`standards/`, `product/`, `specs/`), so a spec shaped in Claude Code is picked up by Codex or pi unchanged.

## The workflows

| Skill | Invoke explicitly |
|-------|-------------------|
| `agent-os-discover-standards` | `/agent-os:discover-standards` |
| `agent-os-inject-standards` | `/agent-os:inject-standards` |
| `agent-os-index-standards` | `/agent-os:index-standards` |
| `agent-os-plan-product` | `/agent-os:plan-product` |
| `agent-os-shape-spec` | `/agent-os:shape-spec` |

Claude Code and Codex namespace plugin commands by plugin name, as shown. In pi the prompt templates are unnamespaced (`/shape-spec`), and the skills are also available as `/skill:agent-os-shape-spec`.

In every harness you can also just describe the task and let the agent load the matching skill on its own.

## Standards without the plugin

`scripts/project-install.sh` is the non-plugin path. It sets up `agent-os/standards/` from a profile and copies the commands into `.claude/commands/agent-os/`. It writes only inside the project — use the plugin for anything else.

## Contributing to the workflows

Edit `plugins/agent-os/skills/agent-os-*/SKILL.md`, then regenerate and validate:

```bash
scripts/build-commands.sh
scripts/validate-plugin.py
```

`scripts/validate-plugin.py` checks the Codex manifest against the field contract from openai/codex's `plugin-creator` skill (allowed keys, strict semver, the required `interface` block), the Claude Code manifest and both marketplaces, the pi manifest, and every skill's frontmatter. CI runs it alongside `build-commands.sh --check`, so the generated commands cannot drift from the skills.

Each skill's frontmatter carries the metadata the generator needs:

```yaml
---
name: agent-os-shape-spec
description: <what it does and when to use it — this is what the agent matches on>
metadata:
  agent-os-command: shape-spec          # generated filename / command name
  agent-os-summary: "<one line for the command palette>"
  agent-os-argument-hint: "[what we're building]"
---
```

Quote any summary or hint containing a colon — Codex rejects a skill whose frontmatter is not valid YAML.
