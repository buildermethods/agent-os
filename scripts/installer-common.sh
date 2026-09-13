#!/usr/bin/env bash
#
# Shared helpers for the hardened Agent OS installer family:
#   scripts/project-install.sh, scripts/doctor.sh, scripts/uninstall.sh
#
# Written for portability across macOS Bash 3.2 and Linux Bash 4/5:
#   - no associative arrays, no mapfile, no GNU-only tools
#   - SHA-256 via sha256sum, shasum -a 256, or openssl
#   - project roots are canonicalised with cd/pwd -P (never realpath)

set -Eeuo pipefail
LC_ALL=C
export LC_ALL

# ---------------------------------------------------------------------------
# Manifest contract
# ---------------------------------------------------------------------------

ICO_MANIFEST_HEADER="# agent-os install manifest v1"
ICO_STANDARDS_PREFIX="agent-os/standards/"
ICO_COMMANDS_PREFIX=".claude/commands/agent-os/"

# Shared constants consumed by the scripts that source this file.
# shellcheck disable=SC2034
ICO_MANIFEST_REL="agent-os/install-manifest.tsv"
# shellcheck disable=SC2034
ICO_DEFAULT_DESCRIPTION="Needs description - run /index-standards"

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

if [ -z "${NO_COLOR:-}" ] && { [ -t 1 ] || [ -t 2 ]; }; then
    ICO_RED=$'\033[31m'
    ICO_GREEN=$'\033[32m'
    ICO_YELLOW=$'\033[33m'
    ICO_BLUE=$'\033[34m'
    ICO_NC=$'\033[0m'
else
    ICO_RED=""; ICO_GREEN=""; ICO_YELLOW=""; ICO_BLUE=""; ICO_NC=""
fi

ico_info() { printf '%s==>%s %s\n' "$ICO_BLUE" "$ICO_NC" "$*"; }
ico_ok()   { printf '%s ok %s %s\n' "$ICO_GREEN" "$ICO_NC" "$*"; }
ico_warn() { printf '%swarn%s %s\n' "$ICO_YELLOW" "$ICO_NC" "$*" >&2; }
ico_err()  { printf '%sfail%s %s\n' "$ICO_RED" "$ICO_NC" "$*" >&2; }
ico_die()  { ico_err "$*"; exit 1; }

# ---------------------------------------------------------------------------
# Paths and hashing
# ---------------------------------------------------------------------------

# Canonicalise an existing directory to an absolute, physically-resolved path.
ico_resolve_project_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        ico_die "project directory does not exist: $dir"
    fi
    ( cd "$dir" && pwd -P )
}

# Print the SHA-256 of a file as 64 lowercase hex characters. The file is fed
# on stdin (never as a filename argument) so paths containing backslashes,
# newlines or a leading "-" can never be misparsed by the hashing tool. The
# result is validated and any tool failure propagates (never masked into an
# empty or malformed value).
ico_hash_file() {
    local file=$1 out
    if command -v sha256sum >/dev/null 2>&1; then
        out=$(sha256sum <"$file") || return 1
        out=${out%% *}
    elif command -v shasum >/dev/null 2>&1; then
        out=$(shasum -a 256 <"$file") || return 1
        out=${out%% *}
    elif command -v openssl >/dev/null 2>&1; then
        out=$(openssl dgst -sha256 <"$file") || return 1
        out=${out##* }
    else
        ico_die "no SHA-256 tool found (need sha256sum, shasum or openssl)"
    fi
    ico_is_sha256 "$out" || return 1
    printf '%s\n' "$out"
}

ico_is_sha256() {
    case "$1" in
        *[!0-9a-f]*) return 1 ;;
    esac
    [ "${#1}" -eq 64 ]
}

# A safe manifest path is relative, free of tabs/newlines/carriage returns and
# free of any empty, "." or ".." segment (so it cannot escape the project).
ico_path_ok() {
    local p=$1
    [ -n "$p" ] || return 1
    case "$p" in
        /*) return 1 ;;
        *$'\t'*|*$'\n'*|*$'\r'*) return 1 ;;
    esac
    case "/$p/" in
        *"/../"*|*"/./"*|*"//"*) return 1 ;;
    esac
    return 0
}

# Only files under these two prefixes are ever owned by the manifest.
ico_path_owned() {
    case "$1" in
        "$ICO_STANDARDS_PREFIX"*) return 0 ;;
        "$ICO_COMMANDS_PREFIX"*) return 0 ;;
    esac
    return 1
}

# Scope of an owned path: "standards" or "commands" (empty when unowned).
ico_scope_of() {
    case "$1" in
        "$ICO_STANDARDS_PREFIX"*) printf 'standards\n' ;;
        "$ICO_COMMANDS_PREFIX"*) printf 'commands\n' ;;
        *) return 1 ;;
    esac
}

# Refuse to read or write through a symlink anywhere along a project-relative
# path, and refuse non-directory parents / non-regular-file destinations.
ico_assert_dest_safe() {
    local root=$1
    local cur=$root part rest=$2
    while :; do
        case "$rest" in
            */*) part=${rest%%/*}; rest=${rest#*/} ;;
            *)   part=$rest; rest="" ;;
        esac
        cur="$cur/$part"
        if [ -L "$cur" ]; then
            ico_die "refusing to use symlink path component: $cur"
        fi
        if [ -n "$rest" ]; then
            if [ -e "$cur" ] && [ ! -d "$cur" ]; then
                ico_die "path component is not a directory: $cur"
            fi
        else
            if [ -e "$cur" ] && [ ! -f "$cur" ]; then
                ico_die "destination is not a regular file: $cur"
            fi
        fi
        [ -n "$rest" ] || break
    done
}

# Assert that every *parent* directory component of a project-relative path is
# a real directory (never a symlink). The final leaf is intentionally ignored so
# callers can still report leaf-level drift. Dies before any mutation.
ico_assert_parent_safe() {
    local root=$1
    local cur=$root part rest=$2
    while :; do
        case "$rest" in
            */*) part=${rest%%/*}; rest=${rest#*/} ;;
            *)   break ;;
        esac
        cur="$cur/$part"
        if [ -L "$cur" ]; then
            ico_die "refusing to use symlink path component: $cur"
        fi
        if [ -e "$cur" ] && [ ! -d "$cur" ]; then
            ico_die "path component is not a directory: $cur"
        fi
    done
}

# ---------------------------------------------------------------------------
# Backups
# ---------------------------------------------------------------------------

# Create and print a fresh, uniquely named backup directory under
# agent-os/.backups. Refuses symlinked backup components and never reuses a
# name, so concurrent or repeated runs cannot clobber earlier backups.
ico_make_backup_dir() {
    local root=$1 label=$2 rel="agent-os/.backups"
    ico_assert_parent_safe "$root" "$rel/placeholder"
    mkdir -p "$root/$rel"
    mktemp -d "$root/$rel/$label.XXXXXX"
}

# ---------------------------------------------------------------------------
# YAML scalar emission
# ---------------------------------------------------------------------------

# True when a value can be emitted as an unquoted YAML plain scalar. Anything
# containing a ": ", "#", quote, backslash, comma, bracket, indicator character,
# leading/trailing whitespace or tab is rejected and will be quoted instead.
# So are the reserved YAML words (true/false/yes/no/on/off/null, matched
# case-insensitively) and any value starting with a digit, so filenames such as
# "true.md" or "2024-01-01.md" are never read back as booleans, numbers or
# dates. Ordinary names (global, root, tech-stack) stay plain.
ico_yaml_plain_ok() {
    local v=$1 lower
    [ -n "$v" ] || return 1
    case "$v" in
        [A-Za-z]*) : ;;
        *) return 1 ;;
    esac
    case "$v" in
        *[!A-Za-z0-9\ ./_-]*) return 1 ;;
    esac
    case "$v" in
        *' '|*$'\t'*) return 1 ;;
    esac
    lower=$(printf '%s' "$v" | tr '[:upper:]' '[:lower:]')
    case "$lower" in
        true|false|yes|no|on|off|null) return 1 ;;
    esac
    return 0
}

# Emit a YAML-safe scalar: a bare word when unambiguously safe, otherwise a
# double-quoted, escaped string (so filenames with ":" or "#" stay valid).
ico_yaml_scalar() {
    local v=$1
    if ico_yaml_plain_ok "$v"; then
        printf '%s' "$v"
        return 0
    fi
    v=${v//\\/\\\\}
    v=${v//\"/\\\"}
    printf '"%s"' "$v"
}

# ---------------------------------------------------------------------------
# Profiles and inheritance (read from config.yml, never sourced)
# ---------------------------------------------------------------------------

ico_profile_name_ok() {
    local n=$1
    [ -n "$n" ] || return 1
    case "$n" in
        .|..|-*|*/*|*\\*|*$'\t'*|*$'\n'*) return 1 ;;
    esac
    case "$n" in
        *[!A-Za-z0-9._-]*) return 1 ;;
    esac
    return 0
}

ico_config_default_profile() {
    local file=$1 value
    value=$(sed -n 's/^default_profile:[[:space:]]*//p' "$file" | head -n 1)
    value=$(printf '%s' "$value" | sed 's/[[:space:]]*$//')
    if [ -n "$value" ]; then
        printf '%s\n' "$value"
    else
        printf 'default\n'
    fi
}

# Print the inherits_from value for a profile, or nothing when unset. The target
# stanza is selected by an exact string comparison of the parsed key against the
# requested profile name (never by regex interpolation), so a profile such as
# "foo.bar" can never match an unrelated "fooXbar" stanza.
ico_config_inherits_from() {
    local file=$1 profile=$2
    awk -v profile="$profile" '
        /^profiles:[[:space:]]*$/ { in_profiles = 1; next }
        in_profiles && /^[^[:space:]]/ { in_profiles = 0 }
        !in_profiles { next }
        !in_target {
            line = $0
            if (line ~ /^  [^[:space:]][^:]*:[[:space:]]*$/) {
                key = line
                sub(/^  /, "", key)
                sub(/:[[:space:]]*$/, "", key)
                if (key == profile) { in_target = 1 }
            }
            next
        }
        in_target {
            if ($0 ~ /^  [^[:space:]]/) { in_target = 0; next }
            if ($0 ~ /^[[:space:]]+inherits_from:[[:space:]]*/) {
                line = $0
                sub(/^[[:space:]]*inherits_from:[[:space:]]*/, "", line)
                sub(/[[:space:]]+$/, "", line)
                print line
                exit
            }
        }
    ' "$file"
}

# Build the inheritance chain base-first, rejecting invalid names, symlinked
# profile directories, missing profiles and inheritance cycles.
ico_profile_chain() {
    local config=$1 profiles_dir=$2 start=$3
    local chain="" visited="" current="$start" parent
    while [ -n "$current" ]; do
        if ! ico_profile_name_ok "$current"; then
            ico_die "invalid profile name in inheritance chain: $current"
        fi
        case "$visited" in
            *"|$current|"*) ico_die "circular profile inheritance detected at: $current" ;;
        esac
        if [ -L "$profiles_dir/$current" ]; then
            ico_die "profile directory is a symlink: $current"
        fi
        if [ ! -d "$profiles_dir/$current" ]; then
            ico_die "profile not found: $current"
        fi
        visited="$visited|$current|"
        if [ -n "$chain" ]; then
            chain="$current
$chain"
        else
            chain="$current"
        fi
        parent=$(ico_config_inherits_from "$config" "$current")
        current="$parent"
    done
    printf '%s\n' "$chain"
}

# ---------------------------------------------------------------------------
# Manifest I/O
# ---------------------------------------------------------------------------

# True when a non-empty file's final byte is a newline, using only `tail -c`
# (available on both BSD/macOS and GNU coreutils; no GNU-only option). Every
# manifest consumer reads rows with a plain `while read` loop that silently
# drops an unterminated final row, so such a manifest must be rejected rather
# than partially trusted.
ico_file_ends_with_newline() {
    [ "$(tail -c 1 "$1")" = "" ]
}

# Strictly validate a manifest: non-empty header, TSV shape, lowercase SHA-256
# format, safe/owned path, no duplicate rows and no stray carriage returns. The
# manifest must be newline-terminated so no consumer can silently drop a final
# unterminated row.
ico_manifest_validate() {
    local file=$1 line first=1 lineno=0 hash path seen=$'\n'
    if [ -L "$file" ]; then
        ico_die "refusing to read symlink manifest: $file"
    fi
    if [ ! -e "$file" ]; then
        ico_die "manifest not found: $file"
    fi
    if [ ! -f "$file" ]; then
        ico_die "manifest is not a regular file: $file"
    fi
    if [ -s "$file" ] && ! ico_file_ends_with_newline "$file"; then
        ico_die "manifest is not newline-terminated: $file"
    fi
    while IFS= read -r line || [ -n "$line" ]; do
        lineno=$((lineno + 1))
        if [ "$first" -eq 1 ]; then
            first=0
            if [ "$line" != "$ICO_MANIFEST_HEADER" ]; then
                ico_die "invalid manifest header on line $lineno"
            fi
            continue
        fi
        case "$line" in
            *$'\t'*) ;;
            *) ico_die "invalid manifest row without tab on line $lineno" ;;
        esac
        hash=${line%%$'\t'*}
        path=${line#*$'\t'}
        case "$path" in
            *$'\t'*) ico_die "invalid manifest row with extra tab on line $lineno" ;;
        esac
        if ! ico_is_sha256 "$hash"; then
            ico_die "invalid manifest hash on line $lineno"
        fi
        if ! ico_path_ok "$path"; then
            ico_die "invalid manifest path on line $lineno: $path"
        fi
        if ! ico_path_owned "$path"; then
            ico_die "manifest path outside owned prefixes on line $lineno: $path"
        fi
        if printf '%s\n' "$seen" | grep -Fqx -- "$path"; then
            ico_die "duplicate manifest path on line $lineno: $path"
        fi
        seen="$seen$path"$'\n'
    done < "$file"
    if [ "$first" -eq 1 ]; then
        ico_die "empty manifest (missing header): $file"
    fi
}

# Validate a manifest and prove that the manifest itself, and every managed
# path, is reachable without traversing a symlinked parent directory. The
# manifest's own parent is checked *before* the manifest is read, so a hostile
# parent symlink can never redirect the read; each managed path is then checked
# before the caller performs any mutation.
ico_preflight_managed_paths() {
    local root=$1 manifest=$2 hash path
    ico_assert_parent_safe "$root" "$ICO_MANIFEST_REL"
    ico_manifest_validate "$manifest"
    while IFS=$'\t' read -r hash path; do
        [ -n "$hash" ] || continue
        ico_assert_parent_safe "$root" "$path"
    done < <(ico_manifest_each "$manifest")
}

# Print the data rows (everything after the header).
ico_manifest_each() {
    tail -n +2 "$1"
}

# Print the recorded hash for a path, or nothing when it is not tracked.
ico_manifest_hash() {
    local file=$1 want=$2 hash path
    while IFS=$'\t' read -r hash path; do
        [ -n "$hash" ] || continue
        if [ "$path" = "$want" ]; then
            printf '%s\n' "$hash"
            return 0
        fi
    done < <(ico_manifest_each "$file")
    return 1
}
