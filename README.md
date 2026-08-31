# Agent OS

Agent OS keeps product context, engineering standards, and implementation plans
inside a repository so coding agents can work consistently without relying on a
single chat history.

It provides:

- reusable standards with profile inheritance;
- project product and specification documents;
- adapters for Claude Code, Codex, Cursor, and Antigravity;
- safe installation, profile synchronization, diagnostics, and removal.
- provider-neutral LLM education and cost/quality/privacy optimization with an
  execution manifest for
  [`cco-llm-router`](https://github.com/Cloud-Computing-Oy/cco-llm-router).

## Optimize LLM use

```bash
./scripts/llm-optimize.sh lesson
./scripts/llm-optimize.sh recommend \
  --task coding --risk high --strategy balanced \
  --input-tokens 30000 --output-tokens 5000 \
  --budget-usd 0.50 --data-class internal \
  --router cco --format json
```

The optimizer chooses planner, worker, and critic roles under hard context,
modality, data-class, and budget constraints. It does not call providers or
read credentials. `cco-llm-router` resolves the emitted selectors and remains
responsible for runtime availability, usage, and provider budgets. See
[the LLM operating guide](docs/llm-optimization.md) and the
[complete English usage guide](docs/USAGE_GUIDE.md).

## Requirements

- Bash 4 or newer
- `awk`, `find`, `sort`, `sha256sum`, and `realpath`
- Git when using the bootstrap installer

## Install into a project

From an Agent OS checkout:

```bash
./scripts/project-install.sh \
  --project-dir /path/to/project \
  --profile default \
  --target claude,codex \
  --yes
```

Use `--dry-run` first to validate the profile, paths, and target adapters
without changing the project.

The target adapters install to:

| Target | Project location |
| --- | --- |
| Claude Code | `.claude/commands/agent-os/` |
| Codex | `.agents/skills/agent-os-*/SKILL.md` |
| Cursor | `.cursor/commands/agent-os/` |
| Antigravity | `.agent/workflows/agent-os/` |

Only the adapter directories listed above are managed by Agent OS. Standards
are tracked individually in `agent-os/install-manifest.tsv`.

## Bootstrap a checkout

```bash
./install_agent_os.sh \
  --project-dir /path/to/project \
  --target claude,codex \
  --ref v3.1.0
```

Use an exact release tag or commit with `--ref` for reproducible installation.
The bootstrap script does not modify `.bashrc`, `.zshrc`, or `PATH`.

## Profiles

Profiles live under:

```text
profiles/<profile-name>/standards/
```

Profile names are restricted to lowercase letters, numbers, hyphens, and
underscores. Configure inheritance in `config.yml`:

```yaml
version: 3.1
default_profile: team
profiles:
  team:
    inherits_from: default
```

Parent profiles are applied first. Child files with the same relative path
override parent files.

## Update an installation

Run the same `project-install.sh` command again. Agent OS:

1. stages and validates the complete result;
2. preserves unmanaged standards;
3. detects local edits to manifest-managed standards;
4. replaces the standards directory atomically;
5. updates the installation manifest.

If a managed standard was changed locally, the update stops. Review the change
and either move it into a profile or use `--force` intentionally.

`--commands-only` updates adapters without changing standards.

## Sync project standards to a profile

Preview:

```bash
./scripts/sync-to-profile.sh \
  --project-dir /path/to/project \
  --profile team \
  --all \
  --dry-run
```

Apply and back up replaced profile content:

```bash
./scripts/sync-to-profile.sh \
  --project-dir /path/to/project \
  --profile team \
  --all \
  --overwrite
```

Without `--overwrite`, differing existing standards stop the sync. Backups are
stored below `profiles/<name>/.backups/`.

## Diagnose or remove

```bash
./scripts/doctor.sh --project-dir /path/to/project
./scripts/uninstall.sh --project-dir /path/to/project --dry-run
./scripts/uninstall.sh --project-dir /path/to/project --yes
```

Uninstall requires an Agent OS 3.1 manifest and removes only manifest-managed
standards and Agent OS-owned adapter directories. It refuses broad removal of
older installations without a manifest.

## Standards index

`agent-os/standards/index.yml` preserves complete relative paths:

```yaml
version: 1
standards:
  - path: "api/error-handling.md"
    description: "Error response and logging conventions"
  - path: "api/v2/error-handling.md"
    description: "Version 2 API error behavior"
```

The installer quotes values, sorts by full path, and supports nested folders
without duplicate-key collisions.

## Development and validation

```bash
bash -n scripts/*.sh install_agent_os.sh
./tests/run.sh
```

CI also runs ShellCheck when available. Functional tests use isolated temporary
directories and never write into the repository's profiles.

See [CHANGELOG.md](CHANGELOG.md) for release history and
[CONTRIBUTING.md](.github/CONTRIBUTING.md) for contribution guidance.
