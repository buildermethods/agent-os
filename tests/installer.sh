#!/usr/bin/env bash
#
# Functional tests for the hardened Agent OS installer family:
# scripts/project-install.sh, scripts/doctor.sh and scripts/uninstall.sh.
#
# Portable across macOS Bash 3.2 and Linux Bash 4/5. Each test builds its own
# throwaway base install and project under a temp directory.

set -Eeuo pipefail
LC_ALL=C
export LC_ALL

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
SCRIPTS="$REPO/scripts"

ROOT=$(mktemp -d "${TMPDIR:-/tmp}/agent-os-tests.XXXXXX")
cleanup_root() {
    if [ -n "$ROOT" ] && [ -d "$ROOT" ]; then
        rm -rf "$ROOT"
    fi
    return 0
}
trap cleanup_root EXIT

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf 'ok   %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf 'FAIL %s\n' "$1"; }

# ---------------------------------------------------------------------------
# Assertions (return non-zero on failure so the test subshell aborts)
# ---------------------------------------------------------------------------

eq() { [ "$1" = "$2" ] || { printf '  eq failed: [%s] != [%s]\n' "$1" "$2"; return 1; }; }
exists() { [ -e "$1" ] || { printf '  expected to exist: %s\n' "$1"; return 1; }; }
absent() { [ ! -e "$1" ] || { printf '  expected to be absent: %s\n' "$1"; return 1; }; }
file_eq() { cmp -s "$1" "$2" || { printf '  files differ: %s vs %s\n' "$1" "$2"; return 1; }; }
contains() { printf '%s' "$1" | grep -qF -- "$2" || { printf '  expected to contain: %s\n' "$2"; return 1; }; }

expect_fail() {
    if "$@" >/dev/null 2>&1; then
        printf '  expected failure but command succeeded: %s\n' "$*"
        return 1
    fi
    return 0
}

# ---------------------------------------------------------------------------
# Harness
#
# Each test runs in its own subshell with errexit active, and its status is
# captured without an enclosing conditional, so a failing intermediate
# assertion aborts and fails the test instead of being silently ignored.
# ---------------------------------------------------------------------------

t() {
    local name=$1 out rc
    shift
    set +e
    out=$( ( set -e; "$@" ) 2>&1 )
    rc=$?
    set -e
    if [ "$rc" -eq 0 ]; then
        pass "$name"
    else
        fail "$name"
        printf '%s\n' "$out" | sed 's/^/     /'
    fi
}

new_env() {
    NAME=$1
    BASE="$ROOT/$NAME/base"
    PROJ="$ROOT/$NAME/proj"
    mkdir -p "$BASE" "$PROJ"
    cp -R "$SCRIPTS" "$BASE/scripts"
    cp -R "$REPO/profiles" "$BASE/profiles"
    cp -R "$REPO/commands" "$BASE/commands"
    cp "$REPO/config.yml" "$BASE/config.yml"
}

# Every script under test is launched with "$BASH" (the interpreter running the
# harness), not a bare shebang lookup, so `/bin/bash tests/installer.sh` really
# exercises every script under that same Bash (3.2 on macOS).
install() { "$BASH" "$BASE/scripts/project-install.sh" --project-dir "$PROJ" "$@"; }
doctor() { "$BASH" "$BASE/scripts/doctor.sh" --project-dir "$PROJ" "$@"; }
uninstall() { "$BASH" "$BASE/scripts/uninstall.sh" --project-dir "$PROJ" "$@"; }

# Deterministic content fingerprint of a project tree.
snapdir() {
    (
        cd "$1" || return 1
        find . -type f | LC_ALL=C sort | while IFS= read -r f; do
            printf '%s %s\n' "$f" "$(cksum <"$f")"
        done
    )
}

backup_has() {
    [ -d "$1" ] || return 1
    [ -n "$(find "$1" -name "$2" 2>/dev/null)" ]
}

# SHA-256 of a file's *content*, fed on stdin and portable across
# sha256sum/shasum/openssl, so it can be compared against the installer's
# recorded hash regardless of which tool is present.
content_sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum <"$1" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 <"$1" | cut -d' ' -f1
    elif command -v openssl >/dev/null 2>&1; then
        openssl dgst -sha256 <"$1" | sed 's/.* //'
    else
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Harness self-test: without this the suite could report a false pass if the
# runner ever stopped propagating intermediate failures.
# ---------------------------------------------------------------------------

_selftest_bad() { false; true; }
_selftest_good() { true; }

test_harness_selfcheck() {
    local f0=$FAIL p0=$PASS
    t harness_probe_should_fail _selftest_bad
    if [ "$FAIL" -ne $((f0 + 1)) ]; then
        printf '  harness masked a failure followed by success\n'
        return 1
    fi
    t harness_probe_should_pass _selftest_good
    if [ "$PASS" -ne $((p0 + 1)) ]; then
        printf '  harness failed to record a passing test\n'
        return 1
    fi
    FAIL=$f0
    PASS=$p0
    return 0
}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test_flat_standard_install() {
    new_env flat
    install --yes
    exists "$PROJ/agent-os/standards/global/tech-stack.md"
    file_eq "$PROJ/agent-os/standards/global/tech-stack.md" "$BASE/profiles/default/global/tech-stack.md"
    exists "$PROJ/agent-os/standards/index.yml"
    exists "$PROJ/.claude/commands/agent-os/discover-standards.md"
    exists "$PROJ/agent-os/install-manifest.tsv"
    contains "$(cat "$PROJ/agent-os/standards/index.yml")" "global:"
    contains "$(cat "$PROJ/agent-os/standards/index.yml")" "tech-stack:"
    contains "$(cat "$PROJ/agent-os/install-manifest.tsv")" "agent-os/standards/global/tech-stack.md"
    # manifest itself is bookkeeping, not a managed file
    if grep -q "install-manifest" "$PROJ/agent-os/install-manifest.tsv"; then
        printf '  manifest must not list itself\n'
        return 1
    fi
    # no invented skills / optimizer / router artefacts
    absent "$PROJ/agent-os/skills"
    [ -z "$(find "$PROJ" -name 'agent-os-*' 2>/dev/null)" ] || { printf '  unexpected agent-os-* artefacts\n'; return 1; }
}

test_index_preservation_and_inheritance() {
    new_env idx
    mkdir -p "$BASE/profiles/child"
    printf '# Extra standard\n' >"$BASE/profiles/child/extra.md"
    cat >"$BASE/profiles/child/index.yml" <<'YAML'
root:
  extra:
    description: Curated description
    tags:
      - one
      - two
YAML
    cat >>"$BASE/config.yml" <<'YAML'

profiles:
  child:
    inherits_from: default
YAML
    install --profile child --yes
    # supplied index is copied byte-for-byte, structured metadata included
    file_eq "$PROJ/agent-os/standards/index.yml" "$BASE/profiles/child/index.yml"
    contains "$(cat "$PROJ/agent-os/standards/index.yml")" "tags:"
    exists "$PROJ/agent-os/standards/extra.md"
    # inherited standard from the parent profile is present too
    exists "$PROJ/agent-os/standards/global/tech-stack.md"
}

test_index_description_preservation() {
    new_env idxdesc
    install --yes
    cat >"$PROJ/agent-os/standards/index.yml" <<'YAML'
# Agent OS Standards Index

global:
  tech-stack:
    description: Custom curated description
YAML
    install --force --yes
    contains "$(cat "$PROJ/agent-os/standards/index.yml")" "Custom curated description"
}

test_index_quoting_special_names() {
    new_env idxquote
    mkdir -p "$BASE/profiles/default/weird"
    printf '# Colon standard\n' >"$BASE/profiles/default/weird/colon:name.md"
    printf '# Hash standard\n' >"$BASE/profiles/default/weird/hash#name.md"
    install --yes
    exists "$PROJ/agent-os/standards/weird/colon:name.md"
    exists "$PROJ/agent-os/standards/weird/hash#name.md"
    contains "$(cat "$PROJ/agent-os/standards/index.yml")" '"colon:name":'
    contains "$(cat "$PROJ/agent-os/standards/index.yml")" '"hash#name":'
}

test_option_errors() {
    new_env opts
    expect_fail install --target bogus
    expect_fail install --profile
    expect_fail install --project-dir
    expect_fail install --unknown
    expect_fail install --profile ../evil
    expect_fail install --project-dir "$ROOT/does-not-exist"
    expect_fail install extra-arg
    absent "$PROJ/agent-os"
}

test_target_none() {
    new_env none
    install --target none --yes
    exists "$PROJ/agent-os/standards/global/tech-stack.md"
    absent "$PROJ/.claude"
    # --commands-only with no commands target is a rejected no-op, not a silent success
    new_env noneco
    expect_fail install --target none --commands-only --yes
    absent "$PROJ/agent-os"
}

test_verbose_and_self_install_guard() {
    new_env verbose
    install --verbose --yes
    exists "$PROJ/agent-os/standards/global/tech-stack.md"
    # installing into the base installation itself is refused
    expect_fail "$BASH" "$BASE/scripts/project-install.sh" --project-dir "$BASE" --yes
    absent "$BASE/agent-os"
}

test_dry_run_side_effect_free() {
    new_env dry
    install --dry-run --yes
    absent "$PROJ/agent-os"
    absent "$PROJ/.claude"

    install --yes
    before=$(snapdir "$PROJ")
    install --dry-run --yes
    after=$(snapdir "$PROJ")
    eq "$after" "$before"
}

test_commands_only_ownership() {
    new_env co
    install --yes
    printf 'user edit\n' >>"$PROJ/agent-os/standards/global/tech-stack.md"
    # commands-only must not touch (or abort on) the drifted standards
    install --commands-only --yes
    contains "$(cat "$PROJ/agent-os/standards/global/tech-stack.md")" "user edit"
    contains "$(cat "$PROJ/agent-os/install-manifest.tsv")" "agent-os/standards/global/tech-stack.md"
    exists "$PROJ/.claude/commands/agent-os/discover-standards.md"
}

test_unchanged_updates() {
    new_env upd
    install --yes
    before=$(snapdir "$PROJ")
    install --yes
    eq "$(snapdir "$PROJ")" "$before"
    printf '\nnew body\n' >>"$BASE/profiles/default/global/tech-stack.md"
    install --yes
    file_eq "$PROJ/agent-os/standards/global/tech-stack.md" "$BASE/profiles/default/global/tech-stack.md"
}

test_stale_rows_retained() {
    new_env stale
    install --yes
    # a managed standard disappears from the source tree
    rm -f "$BASE/profiles/default/global/tech-stack.md"
    install --yes
    # the on-disk file (and its manifest row) is retained, not silently dropped
    exists "$PROJ/agent-os/standards/global/tech-stack.md"
    contains "$(cat "$PROJ/agent-os/install-manifest.tsv")" "agent-os/standards/global/tech-stack.md"
    doctor
}

test_unmanaged_and_drift_protection() {
    new_env prot
    # unmanaged file at a managed path, no manifest yet
    mkdir -p "$PROJ/agent-os/standards/global"
    printf 'user file\n' >"$PROJ/agent-os/standards/global/tech-stack.md"
    expect_fail install --yes
    eq "$(cat "$PROJ/agent-os/standards/global/tech-stack.md")" "user file"
    # --yes alone must not override the protection
    expect_fail install --yes
    # --force backs up and overwrites
    install --force --yes
    file_eq "$PROJ/agent-os/standards/global/tech-stack.md" "$BASE/profiles/default/global/tech-stack.md"
    backup_has "$PROJ/agent-os/.backups" "tech-stack.md"

    # managed file modified after install
    new_env prot2
    install --yes
    printf 'tampered\n' >>"$PROJ/agent-os/standards/global/tech-stack.md"
    expect_fail install --yes
    install --force --yes
    bk=$(find "$PROJ/agent-os/.backups" -name tech-stack.md | head -n 1)
    contains "$(cat "$bk")" "tampered"
}

test_backup_unique_dirs() {
    new_env bkp
    mkdir -p "$PROJ/agent-os/standards/global"
    printf 'user file\n' >"$PROJ/agent-os/standards/global/tech-stack.md"
    install --force --yes
    printf 'user file 2\n' >"$PROJ/agent-os/standards/global/tech-stack.md"
    install --force --yes
    # two backups in the same second must not overwrite each other
    count=$(find "$PROJ/agent-os/.backups" -name tech-stack.md | wc -l | tr -d ' ')
    eq "$count" "2"
}

test_symlink_rejection() {
    # source leaf symlink in the profile
    new_env symsrc
    ln -s "$BASE/profiles/default/global/tech-stack.md" "$BASE/profiles/default/evil.md"
    expect_fail install --yes
    absent "$PROJ/agent-os/standards/evil.md"

    # destination symlink for agent-os/standards
    new_env symdst
    mkdir -p "$PROJ/agent-os" "$ROOT/elsewhere"
    ln -s "$ROOT/elsewhere" "$PROJ/agent-os/standards"
    expect_fail install --yes
    absent "$ROOT/elsewhere/global/tech-stack.md"

    # symlinked manifest
    new_env symmanifest
    mkdir -p "$PROJ/agent-os"
    ln -s "$ROOT/missing-manifest.tsv" "$PROJ/agent-os/install-manifest.tsv"
    expect_fail install --yes
    expect_fail doctor
}

test_source_root_symlinks() {
    new_env rootsymprofiles
    mv "$BASE/profiles" "$BASE/profiles.real"
    ln -s "$BASE/profiles.real" "$BASE/profiles"
    expect_fail install --yes

    new_env rootsymcommands
    mv "$BASE/commands" "$BASE/commands.real"
    ln -s "$BASE/commands.real" "$BASE/commands"
    expect_fail install --yes
}

test_bad_manifest() {
    ZERO_HASH="0000000000000000000000000000000000000000000000000000000000000000"
    HEADER="# agent-os install manifest v1"

    # traversal path
    new_env trav
    mkdir -p "$PROJ/agent-os"
    { printf '%s\n' "$HEADER"; printf '%s\t%s\n' "$ZERO_HASH" "../escape"; } >"$PROJ/agent-os/install-manifest.tsv"
    expect_fail doctor

    # path outside the owned prefixes
    new_env trav2
    mkdir -p "$PROJ/agent-os"
    { printf '%s\n' "$HEADER"; printf '%s\t%s\n' "$ZERO_HASH" "agent-os/product/evil.md"; } >"$PROJ/agent-os/install-manifest.tsv"
    expect_fail doctor

    # extra tab in a row
    new_env trav3
    mkdir -p "$PROJ/agent-os"
    { printf '%s\n' "$HEADER"; printf '%s\t%s\t%s\n' "$ZERO_HASH" "agent-os/standards/a.md" "extra"; } >"$PROJ/agent-os/install-manifest.tsv"
    expect_fail doctor

    # non-hex hash
    new_env trav4
    mkdir -p "$PROJ/agent-os"
    { printf '%s\n' "$HEADER"; printf '%s\t%s\n' "nothex" "agent-os/standards/a.md"; } >"$PROJ/agent-os/install-manifest.tsv"
    expect_fail doctor

    # wrong header
    new_env trav5
    mkdir -p "$PROJ/agent-os"
    { printf '%s\n' "# wrong header"; printf '%s\t%s\n' "$ZERO_HASH" "agent-os/standards/a.md"; } >"$PROJ/agent-os/install-manifest.tsv"
    expect_fail doctor

    # empty manifest (no header)
    new_env trav6
    mkdir -p "$PROJ/agent-os"
    : >"$PROJ/agent-os/install-manifest.tsv"
    expect_fail doctor

    # duplicate rows
    new_env trav7
    mkdir -p "$PROJ/agent-os"
    { printf '%s\n' "$HEADER"; printf '%s\t%s\n' "$ZERO_HASH" "agent-os/standards/a.md"; printf '%s\t%s\n' "$ZERO_HASH" "agent-os/standards/a.md"; } >"$PROJ/agent-os/install-manifest.tsv"
    expect_fail doctor
}

test_filenames_with_spaces() {
    new_env space
    mkdir -p "$BASE/profiles/default/global"
    printf '# Spaced standard\n' >"$BASE/profiles/default/global/my standard.md"
    install --yes
    exists "$PROJ/agent-os/standards/global/my standard.md"
    contains "$(cat "$PROJ/agent-os/install-manifest.tsv")" "agent-os/standards/global/my standard.md"
    doctor
    uninstall
    absent "$PROJ/agent-os/standards/global/my standard.md"
}

test_inheritance_guards() {
    # circular inheritance
    new_env inhcycle
    mkdir -p "$BASE/profiles/a" "$BASE/profiles/b"
    cat >>"$BASE/config.yml" <<'YAML'

profiles:
  a:
    inherits_from: b
  b:
    inherits_from: a
YAML
    expect_fail install --profile a --yes

    # invalid parent name
    new_env inhbad
    mkdir -p "$BASE/profiles/a"
    cat >>"$BASE/config.yml" <<'YAML'

profiles:
  a:
    inherits_from: ../evil
YAML
    expect_fail install --profile a --yes

    # missing profile
    new_env inhmissing
    expect_fail install --profile ghost --yes

    # symlinked profile directory
    new_env inhlink
    ln -s "$BASE/profiles/default" "$BASE/profiles/link"
    expect_fail install --profile link --yes
}

test_inheritance_override() {
    new_env ovr
    mkdir -p "$BASE/profiles/child/global"
    printf '# Child stack\n' >"$BASE/profiles/child/global/tech-stack.md"
    cat >>"$BASE/config.yml" <<'YAML'

profiles:
  child:
    inherits_from: default
YAML
    install --profile child --yes
    contains "$(cat "$PROJ/agent-os/standards/global/tech-stack.md")" "Child stack"
}

test_project_dir_canonicalization() {
    new_env canon
    ln -s "$PROJ" "$ROOT/canon/link"
    "$BASH" "$BASE/scripts/project-install.sh" --project-dir "$ROOT/canon/link" --yes
    exists "$PROJ/agent-os/standards/global/tech-stack.md"
}

test_doctor() {
    new_env doc
    install --yes
    doctor
    printf 'tampered\n' >>"$PROJ/agent-os/standards/global/tech-stack.md"
    expect_fail doctor
    rm -f "$PROJ/.claude/commands/agent-os/discover-standards.md"
    expect_fail doctor

    new_env doc2
    expect_fail doctor
}

test_doctor_parent_symlink() {
    new_env docparent
    install --yes
    outside="$ROOT/docparent/outside"
    mkdir -p "$outside"
    cp -R "$PROJ/agent-os/standards/." "$outside/"
    rm -rf "$PROJ/agent-os/standards"
    ln -s "$outside" "$PROJ/agent-os/standards"
    # a symlinked parent must never be reported as healthy
    expect_fail doctor
}

test_uninstall_preserves_unrelated() {
    new_env un
    install --yes
    printf 'notes\n' >"$PROJ/agent-os/notes.txt"
    printf 'keep\n' >"$PROJ/agent-os/standards/mine.md"
    printf 'root\n' >"$PROJ/README.md"
    uninstall
    absent "$PROJ/agent-os/standards/global/tech-stack.md"
    absent "$PROJ/.claude/commands/agent-os/discover-standards.md"
    absent "$PROJ/agent-os/install-manifest.tsv"
    exists "$PROJ/agent-os/notes.txt"
    exists "$PROJ/agent-os/standards/mine.md"
    exists "$PROJ/README.md"

    # drifted files are retained, stay tracked and make the run non-zero
    new_env un2
    install --yes
    printf 'edit\n' >>"$PROJ/agent-os/standards/global/tech-stack.md"
    expect_fail uninstall
    exists "$PROJ/agent-os/standards/global/tech-stack.md"
    exists "$PROJ/agent-os/install-manifest.tsv"
    contains "$(cat "$PROJ/agent-os/install-manifest.tsv")" "agent-os/standards/global/tech-stack.md"
    absent "$PROJ/.claude/commands/agent-os/discover-standards.md"

    # --force backs up removed files
    new_env un3
    install --yes
    uninstall --force
    absent "$PROJ/agent-os/standards/global/tech-stack.md"
    backup_has "$PROJ/agent-os/.backups" "tech-stack.md"
}

test_uninstall_force_drift() {
    new_env undrift
    install --yes
    printf 'edit\n' >>"$PROJ/agent-os/standards/global/tech-stack.md"
    # normal uninstall retains the modification and reports failure
    expect_fail uninstall
    contains "$(cat "$PROJ/agent-os/standards/global/tech-stack.md")" "edit"
    # --force backs up and removes the drifted regular file
    uninstall --force
    absent "$PROJ/agent-os/standards/global/tech-stack.md"
    bk=$(find "$PROJ/agent-os/.backups" -name tech-stack.md | head -n 1)
    contains "$(cat "$bk")" "edit"
}

test_uninstall_never_follows_symlinks() {
    new_env unsym
    install --yes
    printf 'secret\n' >"$ROOT/unsym/secret.txt"
    rm -f "$PROJ/agent-os/standards/global/tech-stack.md"
    ln -s "$ROOT/unsym/secret.txt" "$PROJ/agent-os/standards/global/tech-stack.md"
    # even --force must refuse to remove the symlink and never touch its target
    expect_fail uninstall --force
    [ -L "$PROJ/agent-os/standards/global/tech-stack.md" ] || { printf '  symlink was removed\n'; return 1; }
    exists "$ROOT/unsym/secret.txt"
}

test_parent_symlink_deletion_exploit() {
    new_env exploit
    install --yes
    # replace the standards directory with a symlink to a tree copied outside
    outside="$ROOT/exploit/outside"
    mkdir -p "$outside"
    cp -R "$PROJ/agent-os/standards/." "$outside/"
    rm -rf "$PROJ/agent-os/standards"
    ln -s "$outside" "$PROJ/agent-os/standards"
    exists "$outside/global/tech-stack.md"
    expect_fail doctor
    expect_fail uninstall --force
    # nothing outside the project may have been deleted
    exists "$outside/global/tech-stack.md"
    exists "$outside/index.yml"
}

test_rollback_mid_commit() {
    new_env rb
    install --target none --yes
    before=$(snapdir "$PROJ")
    # a modified standard and a new standard so the re-run both updates and creates
    printf '\nchanged body\n' >>"$BASE/profiles/default/global/tech-stack.md"
    printf '# Extra\n' >"$BASE/profiles/default/global/extra.md"
    export AGENT_OS_INSTALL_FAIL_AFTER=2
    expect_fail install --target none --yes
    unset AGENT_OS_INSTALL_FAIL_AFTER
    eq "$(snapdir "$PROJ")" "$before"
    absent "$PROJ/agent-os/standards/global/extra.md"

    # failure after the very first write also rolls back cleanly
    export AGENT_OS_INSTALL_FAIL_AFTER=1
    expect_fail install --target none --yes
    unset AGENT_OS_INSTALL_FAIL_AFTER
    eq "$(snapdir "$PROJ")" "$before"
}

test_rollback_removes_created_dirs() {
    new_env rbdir
    install --target none --yes
    before=$(snapdir "$PROJ")
    # a brand new nested directory tree that only this run creates
    mkdir -p "$BASE/profiles/default/newdir/deep"
    printf '# Deep\n' >"$BASE/profiles/default/newdir/deep/file.md"
    export AGENT_OS_INSTALL_FAIL_AFTER=1
    expect_fail install --target none --yes
    unset AGENT_OS_INSTALL_FAIL_AFTER
    absent "$PROJ/agent-os/standards/newdir"
    eq "$(snapdir "$PROJ")" "$before"
}

test_help() {
    new_env help
    out=$("$BASH" "$BASE/scripts/project-install.sh" --help)
    contains "$out" "Usage:"
    contains "$out" "--verbose"
    out=$(doctor --help)
    contains "$out" "Usage:"
    out=$(uninstall --help)
    contains "$out" "Usage:"
}

test_backslash_filename_hash() {
    new_env bslash
    mkdir -p "$BASE/profiles/default/global"
    bs="$BASE/profiles/default/global/back\\slash.md"
    printf '# Backslash standard\n' >"$bs"
    install --yes
    dest="$PROJ/agent-os/standards/global/back\\slash.md"
    exists "$dest"
    # The recorded hash must equal the content hash (the hashing tool is fed on
    # stdin, never the raw backslash-bearing filename).
    want=$(content_sha256 "$bs")
    row=$(grep -F "$want" "$PROJ/agent-os/install-manifest.tsv")
    contains "$row" "back\\slash.md"
    doctor
    uninstall
    absent "$dest"
}

test_index_quoting_reserved_and_numeric() {
    new_env idxres
    mkdir -p "$BASE/profiles/default/weird" "$BASE/profiles/default/1st"
    for n in true false yes no on off null 2024; do
        printf '# %s\n' "$n" >"$BASE/profiles/default/weird/$n.md"
    done
    printf '# Plain\n' >"$BASE/profiles/default/weird/plainname.md"
    printf '# One\n' >"$BASE/profiles/default/1st/plain.md"
    install --yes
    idx=$(cat "$PROJ/agent-os/standards/index.yml")
    # reserved words and digit-leading names stay quoted strings
    for n in true false yes no on off null 2024; do
        contains "$idx" "\"$n\":"
    done
    # a digit-leading folder label is quoted too
    contains "$idx" '"1st":'
    # a plainly-safe name stays an unquoted plain scalar
    contains "$idx" '  plainname:'
}

test_dotted_profile_inheritance() {
    new_env dotted
    mkdir -p "$BASE/profiles/parent/global" "$BASE/profiles/foo.bar/global" "$BASE/profiles/fooXbar/global"
    printf '# Parent stack\n' >"$BASE/profiles/parent/global/tech-stack.md"
    printf '# Parent only\n' >"$BASE/profiles/parent/global/parent-only.md"
    printf '# Dotted stack\n' >"$BASE/profiles/foo.bar/global/tech-stack.md"
    printf '# X stack\n' >"$BASE/profiles/fooXbar/global/tech-stack.md"
    cat >>"$BASE/config.yml" <<'YAML'

profiles:
  foo.bar:
    inherits_from: parent
  fooXbar:
    inherits_from: ghost
YAML
    # If "foo.bar" were matched as a regex it would resolve to the fooXbar stanza
    # and die on the nonexistent "ghost" parent.
    install --profile foo.bar --yes
    # exact dotted parent override: foo.bar replaces its parent's standard
    file_eq "$PROJ/agent-os/standards/global/tech-stack.md" "$BASE/profiles/foo.bar/global/tech-stack.md"
    # the parent's other standard still arrives through the exact chain
    exists "$PROJ/agent-os/standards/global/parent-only.md"
}

test_rollback_pipe_space_dirs() {
    new_env rbpipe
    # Both the project directory name and the created standards directory name
    # carry a literal "|" and a space, so rollback cannot rely on a pipe- or
    # whitespace-delimited list of created directories.
    PROJ="$ROOT/rbpipe/proj with|pipe"
    mkdir -p "$PROJ"
    install --target none --yes
    before=$(snapdir "$PROJ")
    # The new directory sorts first, so the first commit creates it (and its
    # parent) before the injected failure.
    mkdir -p "$BASE/profiles/default/aaa b|c/deep"
    printf '# Pipe dir\n' >"$BASE/profiles/default/aaa b|c/deep/file.md"
    export AGENT_OS_INSTALL_FAIL_AFTER=1
    expect_fail install --target none --yes
    unset AGENT_OS_INSTALL_FAIL_AFTER
    absent "$PROJ/agent-os/standards/aaa b|c"
    eq "$(snapdir "$PROJ")" "$before"
}

test_colon_space_force_backup() {
    new_env colonspace
    mkdir -p "$BASE/profiles/default/weird"
    printf '# Colon space\n' >"$BASE/profiles/default/weird/colon: name.md"
    # Pre-existing unmanaged file: the conflict line becomes
    # "unmanaged: agent-os/standards/weird/colon: name.md". The embedded ": "
    # must not be mistaken for the conflict "reason: " separator.
    mkdir -p "$PROJ/agent-os/standards/weird"
    printf 'user colon file\n' >"$PROJ/agent-os/standards/weird/colon: name.md"
    expect_fail install --yes
    install --force --yes
    file_eq "$PROJ/agent-os/standards/weird/colon: name.md" "$BASE/profiles/default/weird/colon: name.md"
    bk=$(find "$PROJ/agent-os/.backups" -name "colon: name.md" | head -n 1)
    [ -n "$bk" ] || { printf '  no backup for the colon-space file\n'; return 1; }
    contains "$(cat "$bk")" "user colon file"
    doctor
}

test_hash_tool_failure_no_writes() {
    new_env hashfail
    fake="$ROOT/hashfail/fakebin"
    mkdir -p "$fake"
    for tool in sha256sum shasum openssl; do
        printf '#!/bin/sh\nexit 1\n' >"$fake/$tool"
        chmod +x "$fake/$tool"
    done
    # With every SHA-256 tool failing, hashing must abort the run before any
    # project mutation rather than recording empty/garbage hashes.
    set +e
    PATH="$fake:$PATH" install --yes >/dev/null 2>&1
    rc=$?
    set -e
    [ "$rc" -ne 0 ] || { printf '  install succeeded despite a failing hash tool\n'; return 1; }
    absent "$PROJ/agent-os"
}

test_manifest_unterminated_rejected() {
    new_env term
    install --yes
    m="$PROJ/agent-os/install-manifest.tsv"
    # Drop the manifest's final terminating newline — exactly the corruption that
    # previously let doctor exit 0 while silently ignoring the last row.
    printf '%s' "$(cat "$m")" >"$m.tmp" && mv "$m.tmp" "$m"
    [ -n "$(tail -c 1 "$m")" ] || { printf '  setup: manifest still newline-terminated\n'; return 1; }
    before=$(snapdir "$PROJ")

    set +e
    out=$(doctor 2>&1); rc=$?
    set -e
    [ "$rc" -ne 0 ] || { printf '  doctor exited 0 on an unterminated manifest\n'; return 1; }
    case "$out" in
        *"match the manifest"*) printf '  doctor falsely reported success\n'; return 1 ;;
    esac

    expect_fail uninstall
    expect_fail install --yes
    eq "$(snapdir "$PROJ")" "$before"

    # Restoring the terminator makes the manifest valid again.
    printf '\n' >>"$m"
    doctor
}

test_malformed_manifest_no_mutation() {
    ZERO_HASH="0000000000000000000000000000000000000000000000000000000000000000"
    HEADER="# agent-os install manifest v1"

    # traversal row
    new_env badmut1
    mkdir -p "$PROJ/agent-os"
    { printf '%s\n' "$HEADER"; printf '%s\t%s\n' "$ZERO_HASH" "../escape"; } >"$PROJ/agent-os/install-manifest.tsv"
    before=$(snapdir "$PROJ")
    expect_fail install --yes
    expect_fail uninstall
    expect_fail doctor
    eq "$(snapdir "$PROJ")" "$before"

    # duplicate rows
    new_env badmut2
    mkdir -p "$PROJ/agent-os"
    { printf '%s\n' "$HEADER"; printf '%s\t%s\n' "$ZERO_HASH" "agent-os/standards/a.md"; printf '%s\t%s\n' "$ZERO_HASH" "agent-os/standards/a.md"; } >"$PROJ/agent-os/install-manifest.tsv"
    before=$(snapdir "$PROJ")
    expect_fail install --yes
    expect_fail uninstall
    eq "$(snapdir "$PROJ")" "$before"
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

printf 'Agent OS installer tests (bash %s)\n\n' "$BASH_VERSION"

t harness_selfcheck                test_harness_selfcheck
t flat_standard_install            test_flat_standard_install
t index_preservation_and_inheritance test_index_preservation_and_inheritance
t index_description_preservation   test_index_description_preservation
t index_quoting_special_names      test_index_quoting_special_names
t option_errors                    test_option_errors
t target_none                      test_target_none
t verbose_and_self_install_guard   test_verbose_and_self_install_guard
t dry_run_side_effect_free         test_dry_run_side_effect_free
t commands_only_ownership          test_commands_only_ownership
t unchanged_updates                test_unchanged_updates
t stale_rows_retained              test_stale_rows_retained
t unmanaged_and_drift_protection   test_unmanaged_and_drift_protection
t backup_unique_dirs               test_backup_unique_dirs
t symlink_rejection                test_symlink_rejection
t source_root_symlinks             test_source_root_symlinks
t bad_manifest                     test_bad_manifest
t inheritance_guards               test_inheritance_guards
t inheritance_override             test_inheritance_override
t project_dir_canonicalization     test_project_dir_canonicalization
t doctor                           test_doctor
t doctor_parent_symlink            test_doctor_parent_symlink
t uninstall_preserves_unrelated    test_uninstall_preserves_unrelated
t uninstall_force_drift            test_uninstall_force_drift
t uninstall_never_follows_symlinks test_uninstall_never_follows_symlinks
t parent_symlink_deletion_exploit  test_parent_symlink_deletion_exploit
t rollback_mid_commit              test_rollback_mid_commit
t rollback_removes_created_dirs    test_rollback_removes_created_dirs
t rollback_pipe_space_dirs         test_rollback_pipe_space_dirs
t backslash_filename_hash          test_backslash_filename_hash
t index_quoting_reserved_numeric   test_index_quoting_reserved_and_numeric
t dotted_profile_inheritance       test_dotted_profile_inheritance
t colon_space_force_backup         test_colon_space_force_backup
t hash_tool_failure_no_writes      test_hash_tool_failure_no_writes
t manifest_unterminated_rejected   test_manifest_unterminated_rejected
t malformed_manifest_no_mutation   test_malformed_manifest_no_mutation
t help                             test_help

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
