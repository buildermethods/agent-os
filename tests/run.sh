#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agent-os-tests.XXXXXX")"
PASS=0

cleanup() {
    rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

assert_file() {
    [[ -f "$1" ]] || fail "expected file: $1"
}

assert_dir() {
    [[ -d "$1" ]] || fail "expected directory: $1"
}

assert_not_exists() {
    [[ ! -e "$1" ]] || fail "expected path to be absent: $1"
}

assert_contains() {
    grep -Fq -- "$2" "$1" || fail "expected '$2' in $1"
}

pass() {
    PASS=$((PASS + 1))
    echo "ok $PASS - $1"
}

make_base() {
    local destination="$1"
    mkdir -p -- "$destination"
    cp -a -- \
        "$REPO_DIR/config.yml" \
        "$REPO_DIR/commands" \
        "$REPO_DIR/profiles" \
        "$REPO_DIR/scripts" \
        "$destination/"
}

bash -n "$REPO_DIR"/scripts/*.sh "$REPO_DIR/install_agent_os.sh"
pass "all shell scripts parse"

base="$TEST_ROOT/base"
project="$TEST_ROOT/project"
make_base "$base"
mkdir -p -- "$project"

"$base/scripts/project-install.sh" \
    --project-dir "$project" \
    --target claude,codex,cursor,antigravity \
    --dry-run > "$TEST_ROOT/dry-run.out"
assert_not_exists "$project/agent-os"
assert_contains "$TEST_ROOT/dry-run.out" "no files were changed"
pass "dry run performs no project writes"

legacy="$TEST_ROOT/legacy"
mkdir -p -- "$legacy/agent-os/standards/global"
printf '%s\n' '# Local legacy standard' > \
    "$legacy/agent-os/standards/global/tech-stack.md"
if "$base/scripts/project-install.sh" \
    --project-dir "$legacy" --target claude --yes > "$TEST_ROOT/legacy.out" 2>&1; then
    fail "manifestless conflicting standard was overwritten"
fi
assert_contains "$TEST_ROOT/legacy.out" "not manifest-managed"
pass "manifestless local standards fail closed"

symlink_project="$TEST_ROOT/symlink-project"
mkdir -p -- "$symlink_project/redirected/standards"
ln -s -- "$symlink_project/redirected" "$symlink_project/agent-os"
if "$base/scripts/project-install.sh" \
    --project-dir "$symlink_project" --target claude --yes \
    > "$TEST_ROOT/symlink.out" 2>&1; then
    fail "project symlink was accepted"
fi
assert_contains "$TEST_ROOT/symlink.out" "symbolic link"
pass "installation refuses symlinked managed paths"

"$base/scripts/project-install.sh" \
    --project-dir "$project" \
    --target claude,codex,cursor,antigravity \
    --yes > "$TEST_ROOT/install.out"
assert_file "$project/agent-os/standards/global/tech-stack.md"
assert_file "$project/agent-os/install-manifest.tsv"
assert_file "$project/.claude/commands/agent-os/shape-spec.md"
assert_file "$project/.cursor/commands/agent-os/shape-spec.md"
assert_file "$project/.agent/workflows/agent-os/shape-spec.md"
assert_file "$project/.agents/skills/agent-os-shape-spec/SKILL.md"
pass "default profile and all adapters install"

mkdir -p -- "$project/.agents/skills/user-skill"
printf '%s\n' '# User skill' > "$project/.agents/skills/user-skill/SKILL.md"
"$base/scripts/project-install.sh" \
    --project-dir "$project" --target codex --commands-only --yes > /dev/null
assert_file "$project/.agents/skills/user-skill/SKILL.md"
assert_file "$project/.agents/skills/agent-os-shape-spec/SKILL.md"
pass "Codex adapter preserves unrelated project skills"

mkdir -p -- \
    "$project/agent-os/standards/api/v1" \
    "$project/agent-os/standards/api/v2"
printf '# Errors v1\n' > "$project/agent-os/standards/api/v1/errors.md"
printf '# Errors v2\n' > "$project/agent-os/standards/api/v2/errors.md"
"$base/scripts/project-install.sh" \
    --project-dir "$project" \
    --target claude \
    --yes > /dev/null
assert_contains "$project/agent-os/standards/index.yml" 'path: "api/v1/errors.md"'
assert_contains "$project/agent-os/standards/index.yml" 'path: "api/v2/errors.md"'
[[ "$(grep -c 'path: "api/.*/errors.md"' "$project/agent-os/standards/index.yml")" -eq 2 ]] ||
    fail "nested index paths were collapsed"
pass "index preserves nested paths"

printf '\nLocal edit\n' >> "$project/agent-os/standards/global/tech-stack.md"
if "$base/scripts/project-install.sh" \
    --project-dir "$project" --target claude --yes > "$TEST_ROOT/local-edit.out" 2>&1; then
    fail "managed local edit was overwritten without --force"
fi
assert_contains "$TEST_ROOT/local-edit.out" "has local changes"
pass "managed local edits fail closed"

"$base/scripts/project-install.sh" \
    --project-dir "$project" --target claude --yes --force > /dev/null
pass "force update is explicit and succeeds"

if "$base/scripts/sync-to-profile.sh" \
    --project-dir "$project" \
    --new-profile '../../escaped' \
    --all --overwrite > "$TEST_ROOT/traversal.out" 2>&1; then
    fail "path traversal profile was accepted"
fi
assert_not_exists "$TEST_ROOT/escaped"
pass "profile path traversal is rejected"

"$base/scripts/sync-to-profile.sh" \
    --project-dir "$project" \
    --new-profile project \
    --all --overwrite > "$TEST_ROOT/sync.out"
assert_file "$base/profiles/project/standards/global/tech-stack.md"
assert_contains "$TEST_ROOT/sync.out" "Synced"
pass "profile sync completes successfully"

printf '\nProfile update\n' >> "$project/agent-os/standards/api/v1/errors.md"
"$base/scripts/sync-to-profile.sh" \
    --project-dir "$project" \
    --profile project \
    --all --overwrite > "$TEST_ROOT/resync.out"
find "$base/profiles/project/.backups" -type f -name 'errors.md' |
    grep -q . || fail "overwritten profile content was not backed up"
pass "profile overwrite creates a recoverable backup"

printf '# Keep me\n' > "$project/agent-os/standards/unmanaged.md"
"$base/scripts/uninstall.sh" \
    --project-dir "$project" --yes > "$TEST_ROOT/uninstall.out"
assert_file "$project/agent-os/standards/unmanaged.md"
assert_not_exists "$project/agent-os/standards/global/tech-stack.md"
assert_not_exists "$project/.claude/commands/agent-os"
pass "uninstall removes only managed content"

"$base/scripts/doctor.sh" --project-dir "$project" > "$TEST_ROOT/doctor.out"
assert_contains "$TEST_ROOT/doctor.out" "no errors"
pass "doctor validates the installation layout"

echo "1..$PASS"
