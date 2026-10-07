# Agent OS installer

The hardened installer family is made of three small, dependency-free Bash
scripts plus one shared helper:

| Script | Purpose |
| --- | --- |
| `scripts/project-install.sh` | Install/update standards and commands into a project |
| `scripts/doctor.sh` | Verify a project against its install manifest |
| `scripts/uninstall.sh` | Remove only the files the installer owns |
| `scripts/installer-common.sh` | Shared manifest, hashing, path and profile helpers |

Every script uses `set -Eeuo pipefail` and begins with `cd/pwd -P`
canonicalisation (never `realpath`), so they run on macOS Bash 3.2 and Linux
Bash 4/5. SHA-256 comes from `sha256sum`, `shasum -a 256` or `openssl`,
whichever is present.

## Install

```sh
scripts/project-install.sh [options]
```

| Option | Meaning |
| --- | --- |
| `--project-dir <dir>` | Project to install into (default: current directory) |
| `--profile <name>` | Profile to install (default: `default_profile` in `config.yml`) |
| `--target <claude\|none>` | `claude` installs `.claude/commands/agent-os`, `none` installs standards only (default: `claude`) |
| `--commands-only` | Update commands only; leave existing standards untouched |
| `--dry-run` | Print the plan without changing the project |
| `--yes` | Assume yes for any confirmation prompt |
| `--force` | Overwrite unmanaged/modified files, backing them up first |
| `--verbose` | Show detailed progress (accepted for upstream compatibility) |
| `-h`, `--help` | Usage |

Unknown options, missing option values, a `--target` other than
`claude`/`none`, profile names containing path separators, and the no-op
combination `--commands-only --target none` are rejected. Installing into the
base installation directory itself is refused.

### What gets installed

* Standards: every `*.md` file under `profiles/<name>/` is copied to
  `agent-os/standards/` at the same relative path. `profiles/default/global/tech-stack.md`
  therefore lands at `agent-os/standards/global/tech-stack.md`.
* Index: if the profile supplies `profiles/<name>/index.yml` it is **opaque** and
  copied **byte-for-byte** (structured metadata included, never parsed or
  rewritten). Otherwise a nested-path-aware index is generated in the format the
  existing `/index-standards` and `/inject-standards` commands read. On update,
  the project's own `agent-os/standards/index.yml` is read back so existing
  descriptions carry across the regenerated index: for each `folder/name` key
  (folder keys are flat, e.g. `api/auth`) the `description` value is decoded and
  reused. The reader understands the simple scalar styles the installer itself
  emits — plain scalars, single-quoted strings (`''` for an apostrophe) and
  double-quoted strings (`\"` and `\\` escapes) — with two-space name and
  four-space description indentation, so a description containing `:`, `#`,
  quotes or backslashes is preserved and `#`/`:` are treated as a comment or
  separator only **outside** quotes (a literal `hash#name` stays data). It is
  deliberately not a general YAML parser and never sources, imports or evaluates
  the file: any other structure, an unsupported escape or malformed quoting, a
  duplicate folder or name key, a name left without a description before the
  next key or the end of the file, a plain key or value that begins with a YAML
  indicator (a flow collection `[` `]` `{` `}` `,`, a node tag, anchor or alias
  `!` `&` `*`, a block scalar `|` `>`, or another reserved character) or a
  literal tab or carriage return inside a quoted scalar is a hard error **before
  any project mutation**, so a project index the installer cannot fully
  understand is never silently reset back to default descriptions. A CRLF file
  is accepted, because only a single trailing carriage return is stripped from
  each line.
  Descriptions are not carried across profiles, and a supplied profile index is
  never consulted for them. Regenerated keys and decoded descriptions are
  re-quoted (via the same safe scalar emitter) when they contain
  YAML-significant characters such as `:` or `#`.
* Commands: for `--target claude`, `commands/agent-os/*.md` is copied to
  `.claude/commands/agent-os/`.

The installer deliberately does not invent any other structure: no
`agent-os-*` skills, no optimizer, router or adapters.

### Profiles and inheritance

Inheritance is read from the `profiles:` section of `config.yml`
(`inherits_from`), never by sourcing profile content. The chain is applied
base-first so a child profile overrides its parents. Invalid parent names,
missing profiles, symlinked profile directories and inheritance cycles are
rejected before anything is written.

## The manifest

All writes are recorded in `agent-os/install-manifest.tsv`, a versioned,
tab-separated `hash<TAB>path` file:

```
# agent-os install manifest v1
b2d7847...f6960f6	agent-os/standards/global/tech-stack.md
334ff2a...f5cb6e5	.claude/commands/agent-os/inject-standards.md
```

Only paths under two owned prefixes may appear: `agent-os/standards/` and
`.claude/commands/agent-os/`. Rows with the wrong field count, a non-hex hash,
a tab, newline or carriage return in the path, a `..`/`.`/empty path segment, a
path outside the prefixes, a missing header, an empty manifest, or duplicate
rows are rejected. A manifest must also be **newline-terminated**: because the
row readers stop at an unterminated final row, such a manifest is rejected
outright rather than being partially trusted (so a truncated manifest can never
make `doctor` report success while ignoring the last file). The manifest lists
files, never directories, and never itself.

On update, the manifest retains prior entries for scopes a run does not cover,
so a `--commands-only` run keeps the tracked standards (and vice versa). It also
retains rows for files that are still on disk but have since disappeared from
the source profile, so ownership of stale files is never silently dropped and
`doctor`/`uninstall` can still account for them.

## Safety model

* **Preflight before writing.** Sources and every destination path component
  are checked; symlinked source roots (`profiles`, `commands/agent-os`),
  destination symlinks (including a symlinked manifest), non-directory parents
  and traversal are refused before any write.
* **No clobbering without consent.** Files that are unmanaged, or tracked but
  modified since install, abort the run. `--yes` does not override this — only
  `--force` does, and `--force` copies each conflicting file to a freshly
  created, symlink-checked `agent-os/.backups/<timestamp>.XXXXXX/` directory
  first (unique per run, so repeated or concurrent runs cannot overwrite an
  earlier backup).
* **Staged, then committed atomically with rollback.** Content is staged in a
  temp directory, preflight runs, then each file is written to a sibling temp
  file on the same filesystem and renamed into place, and the manifest is
  written last. Each snapshot is validated before the corresponding write is
  armed. A failed write, `die`, or `INT`/`TERM`/`HUP` signal restores every
  already-committed file, removes files and directories that did not exist
  before, and never interpolates untrusted paths into trap code.
* **`--dry-run` never touches the project.**

## Doctor

```sh
scripts/doctor.sh [--project-dir <dir>]
```

Recomputes the SHA-256 of every manifest-listed file. Missing, modified or
symlinked managed files are reported as drift and the exit status is non-zero
(zero when everything matches). A missing or malformed manifest is an error, as
is a symlinked parent directory anywhere along the manifest or a managed path
(so drift can never hide behind a redirected path component).

## Uninstall

```sh
scripts/uninstall.sh [--project-dir <dir>] [--force]
```

Before deleting anything, it preflights the manifest and the parents of every
managed path (refusing a symlinked parent), so a redirected path component can
never make it delete files outside the project. It then removes only
manifest-listed files that are still unchanged. Files that were modified since
install are retained, stay tracked in a rewritten manifest, and make the exit
status non-zero. Symlinks are never followed or deleted. Unrelated files are
never touched and directories are never removed recursively. With `--force`,
files that drifted (modified regular files) are copied to a freshly created,
symlink-checked `agent-os/.backups/<timestamp>-uninstall.XXXXXX/` directory and
then removed; symlinks are still never removed.

## Examples

```sh
# Default install into the current project
scripts/project-install.sh --yes

# Preview without changing anything
scripts/project-install.sh --dry-run

# Standards only, no Claude commands
scripts/project-install.sh --target none --yes

# Refresh commands after editing a standard by hand
scripts/project-install.sh --commands-only --yes

# Take over files that were edited or created by hand (keeps a backup)
scripts/project-install.sh --force --yes

# Check for drift, then clean up
scripts/doctor.sh
scripts/uninstall.sh --force
```

## Testing

`tests/installer.sh` builds throwaway base installs and projects and exercises
flat installs, index preservation/inheritance/quoting, decoded index scalar
round-trip across special keys and quote/backslash/escape styles, fail-closed
rejection of an unsupported project index (leaving the project fingerprint
unchanged), option errors, dry-run, commands-only ownership, unchanged updates,
stale-row retention, unmanaged/drift protection, unique force backups,
source-root/leaf symlink and traversal rejection, manifest integrity (including
rejection of an unterminated or otherwise malformed manifest with no project
mutation), backslash and colon-space filename handling, dotted-profile
inheritance, a failing hash tool aborting before any write, doctor, uninstall
preservation, `--force` drift removal, symlinked-parent deletion and mid-commit
rollback (including created directories whose names contain spaces or a literal
`|`).
Each test runs in an isolated subshell with errexit active, and a harness
self-test fails the suite if a failure followed by a success were ever reported
as a pass:

```sh
bash tests/installer.sh
```

CI (`.github/workflows/installer.yml`) runs the suite and ShellCheck on all
installer scripts on Linux and macOS. On macOS it invokes the suite through the
system `/bin/bash` so the Bash 3.2 code path is exercised.
