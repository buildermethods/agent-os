#!/usr/bin/env bash
#
# Agent OS project installer (hardened).
#
# Installs Agent OS standards from a profile (optionally inherited) into a
# project's agent-os/standards directory and, for the claude target, the
# agent-os slash commands into .claude/commands/agent-os.
#
# Every write is tracked in agent-os/install-manifest.tsv so that later runs,
# doctor.sh and uninstall.sh can detect drift and never clobber user edits.

set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
BASE_DIR=$(cd "$SCRIPT_DIR/.." && pwd -P)

# shellcheck source=scripts/installer-common.sh
. "$SCRIPT_DIR/installer-common.sh"

PROGRAM=$(basename "$0")

# Option state -----------------------------------------------------------------
TARGET="claude"
PROFILE=""
PROJECT_DIR=""
COMMANDS_ONLY=false
DRY_RUN=false
ASSUME_YES=false
FORCE=false
VERBOSE=false

# Resolved state ---------------------------------------------------------------
CHAIN=""
MANIFEST=""
MANIFEST_REL="$ICO_MANIFEST_REL"
TARGET_PATHS=""
CONFLICTS=""
EXISTING=0
SUPPLIED_INDEX=""
COVERS_STANDARDS=true
COVERS_COMMANDS=true

WORK_DIR=""
STAGE=""
ROLLBACK_ARMED=false
COMMIT_TMP=""
commit_count=0
SNAP_COUNT=0
CREATED_DIR_COUNT=0
CREATED_DIRS=()

SNAP_PATHS=()
SNAP_BACKUPS=()
SNAP_HAD=()

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------

show_help() {
    cat <<EOF
Usage: $PROGRAM [OPTIONS]

Install Agent OS standards (and commands) into a project.

Options:
    --project-dir <dir>   Target project directory (default: current directory)
    --profile <name>      Profile to install (default: default_profile in config.yml)
    --target <target>     "claude" installs .claude/commands/agent-os, "none" installs
                          standards only (default: claude)
    --commands-only       Update only commands, leave existing standards untouched
    --dry-run             Print the plan without changing the project
    --yes                 Assume yes for any confirmation prompt
    --force               Overwrite unmanaged/modified files, backing them up first
    --verbose             Show detailed progress
    -h, --help            Show this help message

Examples:
    $PROGRAM
    $PROGRAM --profile rails --target none
    $PROGRAM --project-dir ../app --commands-only --yes
    $PROGRAM --dry-run
EOF
    exit 0
}

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------

parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --project-dir)
                if [ $# -lt 2 ] || [ -z "${2:-}" ] || [ "${2#-}" != "$2" ]; then
                    ico_die "option --project-dir requires a value"
                fi
                PROJECT_DIR="$2"
                shift 2
                ;;
            --profile)
                if [ $# -lt 2 ] || [ -z "${2:-}" ] || [ "${2#-}" != "$2" ]; then
                    ico_die "option --profile requires a value"
                fi
                PROFILE="$2"
                shift 2
                ;;
            --target)
                if [ $# -lt 2 ] || [ -z "${2:-}" ] || [ "${2#-}" != "$2" ]; then
                    ico_die "option --target requires a value"
                fi
                TARGET="$2"
                shift 2
                ;;
            --commands-only)
                COMMANDS_ONLY=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --yes|-y)
                ASSUME_YES=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            -*)
                ico_die "unknown option: $1"
                ;;
            *)
                ico_die "unexpected argument: $1"
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------

validate_options() {
    case "$TARGET" in
        claude|none) ;;
        *) ico_die "invalid --target: $TARGET (expected 'claude' or 'none')" ;;
    esac
    if [ "$COMMANDS_ONLY" = true ] && [ "$TARGET" = "none" ]; then
        ico_die "--commands-only cannot be combined with --target none (nothing would be installed)"
    fi
    if [ -n "$PROFILE" ]; then
        ico_profile_name_ok "$PROFILE" || ico_die "invalid profile name: $PROFILE"
    fi
}

validate_base_installation() {
    [ -d "$BASE_DIR" ] || ico_die "Agent OS base installation not found: $BASE_DIR"
    [ -f "$BASE_DIR/config.yml" ] || ico_die "missing config.yml in $BASE_DIR"
    [ -d "$BASE_DIR/profiles" ] || ico_die "missing profiles directory in $BASE_DIR"
}

# Reject symlinked live source roots so a profile/command tree cannot be
# redirected outside the base installation.
validate_source_roots() {
    local p
    for p in profiles commands commands/agent-os; do
        if [ -L "$BASE_DIR/$p" ]; then
            ico_die "source root is a symlink: $p"
        fi
    done
}

resolve_project() {
    local dir=${PROJECT_DIR:-$PWD}
    PROJECT_DIR=$(ico_resolve_project_dir "$dir")
    if [ "$PROJECT_DIR" = "$BASE_DIR" ]; then
        ico_die "cannot install into the Agent OS base installation directory: $BASE_DIR"
    fi
    MANIFEST="$PROJECT_DIR/$MANIFEST_REL"
    if [ -e "$MANIFEST" ] || [ -L "$MANIFEST" ]; then
        ico_manifest_validate "$MANIFEST"
    fi
}

load_profile_chain() {
    local default_profile
    default_profile=$(ico_config_default_profile "$BASE_DIR/config.yml")
    if [ -z "$PROFILE" ]; then
        PROFILE="$default_profile"
    fi
    ico_profile_name_ok "$PROFILE" || ico_die "invalid profile name: $PROFILE"
    if [ -L "$BASE_DIR/profiles/$PROFILE" ]; then
        ico_die "profile directory is a symlink: $PROFILE"
    fi
    if [ ! -d "$BASE_DIR/profiles/$PROFILE" ]; then
        ico_die "profile not found: $PROFILE"
    fi
    CHAIN=$(ico_profile_chain "$BASE_DIR/config.yml" "$BASE_DIR/profiles" "$PROFILE")

    COVERS_STANDARDS=true
    COVERS_COMMANDS=true
    if [ "$COMMANDS_ONLY" = true ]; then
        COVERS_STANDARDS=false
    fi
    if [ "$TARGET" = "none" ]; then
        COVERS_COMMANDS=false
    fi
}

# -----------------------------------------------------------------------------
# Staging
# -----------------------------------------------------------------------------

setup_workdir() {
    WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/agent-os-install.XXXXXX")
    STAGE="$WORK_DIR/stage"
    mkdir -p "$STAGE"
}

stage_standards() {
    local name proot rel abs src dest idx list
    SUPPLIED_INDEX=""
    while IFS= read -r name; do
        [ -n "$name" ] || continue
        proot="$BASE_DIR/profiles/$name"
        idx="$proot/index.yml"
        if [ -L "$idx" ]; then
            ico_die "profile index is a symlink: $name/index.yml"
        fi
        if [ -f "$idx" ]; then
            SUPPLIED_INDEX="$idx"
        fi
        list="$WORK_DIR/find.standards.$name"
        if ! ( cd "$proot" && find . \( -type f -name '*.md' -o -type l \) -print0 ) >"$list"; then
            ico_die "failed to scan profile '$name' for standards"
        fi
        while IFS= read -r -d '' abs; do
            rel=${abs#./}
            if ! ico_path_ok "$rel"; then
                ico_die "unsafe path in profile '$name': $rel"
            fi
            case "/$rel/" in
                */.backups/*) continue ;;
            esac
            case "$rel" in
                index.yml) continue ;;
            esac
            src="$proot/$rel"
            if [ -L "$src" ]; then
                ico_die "profile file is a symlink: $name/$rel"
            fi
            dest="$STAGE/agent-os/standards/$rel"
            mkdir -p "$(dirname "$dest")"
            cp -p "$src" "$dest"
        done <"$list"
    done <<<"$CHAIN"
}

stage_index() {
    local standards_dir="$STAGE/agent-os/standards"
    local out="$standards_dir/index.yml"
    mkdir -p "$standards_dir"
    if [ -n "$SUPPLIED_INDEX" ]; then
        cp -p "$SUPPLIED_INDEX" "$out"
        ico_info "using profile-supplied index.yml"
    else
        generate_index "$standards_dir" "$PROJECT_DIR/agent-os/standards/index.yml" "$out"
    fi
}

# Build a nested-path-aware index.yml that the existing commands understand.
generate_index() {
    local dir=$1 old=$2 out=$3
    local lookup="$WORK_DIR/index.lookup"
    local entries="$WORK_DIR/index.entries"
    local list="$WORK_DIR/index.files"
    : >"$lookup"
    : >"$entries"

    if [ -f "$old" ] && [ ! -L "$old" ]; then
        if ! index_parse_descriptions "$old" >>"$lookup"; then
            ico_die "unsupported or malformed standards index at $old; refusing to reset descriptions to the default"
        fi
    fi

    if ! find "$dir" -type f -name '*.md' -print0 >"$list"; then
        ico_die "failed to scan staged standards for index generation"
    fi

    local abs rel name dpart label key sk desc
    while IFS= read -r -d '' abs; do
        rel=${abs#"$dir/"}
        name=${rel##*/}
        name=${name%.md}
        dpart=${rel%/*}
        if [ "$dpart" = "$rel" ]; then
            dpart=""
        fi
        if [ -z "$dpart" ]; then
            label="root"; key="root/$name"; sk="0"
        else
            label="$dpart"; key="$dpart/$name"; sk="1"
        fi
        desc=$(index_lookup "$lookup" "$key")
        if [ -z "$desc" ]; then
            desc="$ICO_DEFAULT_DESCRIPTION"
        fi
        case "$desc" in
            *$'\t'*) desc="$ICO_DEFAULT_DESCRIPTION" ;;
        esac
        printf '%s\t%s\t%s\t%s\n' "$sk" "$label" "$name" "$desc" >>"$entries"
    done <"$list"

    {
        printf '# Agent OS Standards Index\n'
        sort -t "$(printf '\t')" -k1,1 -k2,2 -k3,3 "$entries" | {
            local prev=""
            while IFS=$'\t' read -r sk label name desc; do
                if [ "$label" != "$prev" ]; then
                    printf '\n%s:\n' "$(ico_yaml_scalar "$label")"
                    prev="$label"
                fi
                printf '  %s:\n    description: %s\n' "$(ico_yaml_scalar "$name")" "$(ico_yaml_scalar "$desc")"
            done
        }
    } >"$out"
}

# Read an existing generated index back into "folder/name<TAB>description" pairs
# so custom descriptions survive regeneration. Only the simple shape the
# installer itself emits is understood -- folder -> name -> description, with
# two-space name indentation, four-space description indentation and flat
# nested-path folder keys such as api/auth -- where every key and value is a
# plain, single-quoted or double-quoted YAML scalar. Separators and #-comments
# are recognised only outside quotes, so a literal hash#name stays data. The
# file is never sourced or evaluated. Anything the reader cannot fully
# understand is a hard error before any project mutation instead of a silent
# reset to default descriptions: unsupported structure, an unsupported escape
# or malformed quoting, a duplicate folder or name key (which would otherwise
# be silently first-win), a name left without a description before the next
# key or the end of the file, a plain key or value that begins with a YAML
# indicator ([ { ! & * | > and friends), or a literal tab or carriage return
# inside a quoted scalar (which the TSV round-trip and the trailing-CR strip
# would otherwise silently lose). CRLF input is supported by stripping only a
# single trailing carriage return from each line.
index_parse_descriptions() {
    local file="$1" prog="$WORK_DIR/index-parse.awk"
    cat >"$prog" <<'AGENT_OS_AWK'
function fail(msg) {
    if (!failed) print "index parse error: " msg > "/dev/stderr"
    failed = 1
    exit 2
}

function rtrim(s,    n, c) {
    n = length(s)
    while (n > 0) {
        c = substr(s, n, 1)
        if (c == " " || c == TAB) { n--; continue }
        break
    }
    return substr(s, 1, n)
}

# A plain (unquoted) scalar may not begin with a YAML indicator: a flow
# collection ([ ] { } ,), a node property (! &), an alias (*), a block scalar
# (| >), a directive or reserved character ( % @ `) -- or "-", "?" or ":"
# when they stand alone or are followed by whitespace, where the node kind
# would change and the plain reading would lose that meaning.
function bad_plain(s,    c, d) {
    c = substr(s, 1, 1)
    if (c == "[" || c == "]" || c == "{" || c == "}" || c == ",") return 1
    if (c == "&" || c == "*" || c == "!" || c == "|" || c == ">") return 1
    if (c == "%" || c == "@" || c == "`") return 1
    if (c == "-" || c == "?" || c == ":") {
        d = substr(s, 2, 1)
        if (d == "" || d == " " || d == TAB) return 1
    }
    return 0
}

function quoted(s, p,    n, i, c, out) {
    n = length(s)
    out = ""
    if (substr(s, p, 1) == "'") {
        i = p + 1
        while (i <= n) {
            c = substr(s, i, 1)
            if (c == TAB || c == CR) fail("tab or carriage return inside a quoted scalar")
            if (c == "'") {
                if (substr(s, i + 1, 1) == "'") { out = out "'"; i += 2; continue }
                sc_end = i + 1
                return out
            }
            out = out c
            i++
        }
        fail("unterminated single-quoted scalar")
    }
    i = p + 1
    while (i <= n) {
        c = substr(s, i, 1)
        if (c == TAB || c == CR) fail("tab or carriage return inside a quoted scalar")
        if (c == BS) {
            c = substr(s, i + 1, 1)
            if (c == DQ) out = out DQ
            else if (c == BS) out = out BS
            else fail("unsupported escape in double-quoted scalar")
            i += 2
            continue
        }
        if (c == DQ) { sc_end = i + 1; return out }
        out = out c
        i++
    }
    fail("unterminated double-quoted scalar")
}

function tail_ok(s, p,    n, k, c) {
    n = length(s)
    k = p
    while (k <= n) {
        c = substr(s, k, 1)
        if (c == " " || c == TAB) { k++; continue }
        if (c == "#") return
        fail("unexpected trailing content in generated index")
    }
}

function parse_key(s,    n, i) {
    n = length(s)
    if (substr(s, 1, 1) == "'" || substr(s, 1, 1) == DQ) {
        key = quoted(s, 1)
        i = sc_end
        while (i <= n && substr(s, i, 1) == " ") i++
        if (substr(s, i, 1) != ":") fail("expected ':' after key scalar")
        tail_ok(s, i + 1)
        return key
    }
    i = index(s, ":")
    if (i == 0) fail("missing ':' after key")
    key = rtrim(substr(s, 1, i - 1))
    if (key == "" || substr(key, 1, 1) == " " || substr(key, 1, 1) == TAB) fail("empty or malformed key")
    if (bad_plain(key)) fail("unsupported YAML indicator in plain key: " key)
    if (index(key, TAB) > 0) fail("tab in plain key")
    tail_ok(s, i + 1)
    return key
}

function parse_description(s,    n, i, c, val, k) {
    n = length(s)
    if (substr(s, 1, 11) != "description") fail("only a description is supported here")
    i = 12
    while (i <= n && (substr(s, i, 1) == " " || substr(s, i, 1) == TAB)) i++
    if (substr(s, i, 1) != ":") fail("expected ':' after description")
    i++
    while (i <= n && (substr(s, i, 1) == " " || substr(s, i, 1) == TAB)) i++
    if (i > n || substr(s, i, 1) == "#") return ""
    c = substr(s, i, 1)
    if (c == "'" || c == DQ) {
        val = quoted(s, i)
        tail_ok(s, sc_end)
        return val
    }
    if (bad_plain(substr(s, i))) fail("unsupported YAML indicator in plain value")
    val = substr(s, i)
    n = length(val)
    for (k = 2; k <= n; k++) {
        if (substr(val, k, 1) == "#" && (substr(val, k - 1, 1) == " " || substr(val, k - 1, 1) == TAB)) {
            val = substr(val, 1, k - 1)
            break
        }
    }
    val = rtrim(val)
    if (index(val, TAB) > 0) fail("tab in plain value")
    if (index(val, ": ") > 0 || index(val, ":" TAB) > 0 || substr(val, length(val), 1) == ":") {
        fail("unsupported nested value in generated index")
    }
    return val
}

BEGIN {
    TAB = sprintf("%c", 9)
    CR = sprintf("%c", 13)
    DQ = sprintf("%c", 34)
    BS = sprintf("%c", 92)
    folder = ""
    name = ""
}
{
    line = $0
    n = length(line)
    if (n > 0 && substr(line, n, 1) == CR) { line = substr(line, 1, n - 1); n = n - 1 }
    if (index(line, CR) > 0) fail("carriage return in index content")
    i = 1
    while (i <= n) {
        c = substr(line, i, 1)
        if (c == " " || c == TAB) { i++; continue }
        break
    }
    if (i > n) next
    if (substr(line, i, 1) == "#") next
    ind = 0
    while (ind < n && substr(line, ind + 1, 1) == " ") ind++
    if (substr(line, ind + 1, 1) == TAB) fail("tab indentation is not supported")
    rest = substr(line, ind + 1)
    if (ind == 0) {
        if (name != "") fail("name key left without a description before the next folder")
        folder = parse_key(rest)
        if (folder in seen) fail("duplicate folder key: " folder)
        seen[folder] = 1
        name = ""
    } else if (ind == 2) {
        if (folder == "") fail("name key without a preceding folder")
        if (name != "") fail("name key left without a description before the next name")
        name = parse_key(rest)
        nkey = folder SUBSEP name
        if (nkey in seenname) fail("duplicate name key: " folder "/" name)
        seenname[nkey] = 1
    } else if (ind == 4) {
        if (folder == "" || name == "") fail("description without a folder and name")
        desc = parse_description(rest)
        print folder "/" name TAB desc
        name = ""
    } else {
        fail("unsupported indentation level " ind)
    }
}
END {
    if (name != "") fail("name key left without a description at end of index")
}
AGENT_OS_AWK
    awk -f "$prog" <"$file"
}

# Print the description recorded for a "folder/name" key, or nothing. Compared
# with a byte-exact bash string test: passing the key to awk -v would
# escape-process a backslash in a filename and silently mismatch the lookup.
index_lookup() {
    local file="$1" want="$2" key val
    while IFS=$'\t' read -r key val; do
        if [ "$key" = "$want" ]; then
            printf '%s\n' "$val"
            return 0
        fi
    done <"$file"
    return 0
}

stage_commands() {
    local src_dir="$BASE_DIR/commands/agent-os"
    if [ ! -d "$src_dir" ]; then
        ico_warn "no commands directory in base installation; skipping commands"
        return 0
    fi
    local f base dest n=0 list="$WORK_DIR/find.commands"
    if ! find "$src_dir" \( -type f -name '*.md' -o -type l \) -print0 >"$list"; then
        ico_die "failed to scan commands directory"
    fi
    while IFS= read -r -d '' f; do
        if [ -L "$f" ]; then
            ico_die "command source is a symlink: $f"
        fi
        base=${f##*/}
        dest="$STAGE/.claude/commands/agent-os/$base"
        mkdir -p "$(dirname "$dest")"
        cp -p "$f" "$dest"
        n=$((n + 1))
    done <"$list"
    ico_info "staged $n command(s)"
}

collect_paths() {
    local raw="$WORK_DIR/paths.raw" abs list
    : >"$raw"
    if [ -d "$STAGE/agent-os/standards" ]; then
        list="$WORK_DIR/find.coll.stds"
        if ! find "$STAGE/agent-os/standards" -type f -print0 >"$list"; then
            ico_die "failed to scan staged standards"
        fi
        while IFS= read -r -d '' abs; do
            printf '%s\n' "${abs#"$STAGE/"}"
        done <"$list" >>"$raw"
    fi
    if [ -d "$STAGE/.claude/commands/agent-os" ]; then
        list="$WORK_DIR/find.coll.cmds"
        if ! find "$STAGE/.claude/commands/agent-os" -type f -print0 >"$list"; then
            ico_die "failed to scan staged commands"
        fi
        while IFS= read -r -d '' abs; do
            printf '%s\n' "${abs#"$STAGE/"}"
        done <"$list" >>"$raw"
    fi
    TARGET_PATHS=$(sort "$raw")
}

# -----------------------------------------------------------------------------
# Preflight and plan
# -----------------------------------------------------------------------------

preflight() {
    CONFLICTS=""
    EXISTING=0
    local rel dest mh ch
    ico_assert_dest_safe "$PROJECT_DIR" "$MANIFEST_REL"
    while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        if ! ico_path_owned "$rel"; then
            ico_die "refusing to write outside owned prefixes: $rel"
        fi
        ico_assert_dest_safe "$PROJECT_DIR" "$rel"
        dest="$PROJECT_DIR/$rel"
        if [ -e "$dest" ]; then
            EXISTING=$((EXISTING + 1))
            mh=""
            if [ -f "$MANIFEST" ]; then
                mh=$(ico_manifest_hash "$MANIFEST" "$rel") || mh=""
            fi
            if [ -z "$mh" ]; then
                CONFLICTS="${CONFLICTS}unmanaged: $rel"$'\n'
            else
                ch=$(ico_hash_file "$dest")
                if [ "$ch" != "$mh" ]; then
                    CONFLICTS="${CONFLICTS}modified: $rel"$'\n'
                fi
            fi
        fi
    done <<<"$TARGET_PATHS"
}

target_has_path() {
    printf '%s\n' "$TARGET_PATHS" | grep -Fqx -- "$1"
}

# Build the new manifest. Every previously tracked row that this run does not
# rewrite is retained (ownership of stale files is never silently dropped), and
# fresh hashes are recorded for everything staged this run.
build_manifest() {
    local out="$STAGE/$MANIFEST_REL"
    local rows="$WORK_DIR/manifest.rows"
    mkdir -p "$(dirname "$out")"
    : >"$rows"

    local hash path rel h
    if [ -f "$MANIFEST" ]; then
        while IFS=$'\t' read -r hash path; do
            [ -n "$hash" ] || continue
            if target_has_path "$path"; then
                continue
            fi
            printf '%s\t%s\n' "$hash" "$path" >>"$rows"
        done < <(ico_manifest_each "$MANIFEST")
    fi

    while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        h=$(ico_hash_file "$STAGE/$rel") || ico_die "failed to hash staged file: $rel"
        if [ -z "$h" ]; then
            ico_die "empty hash for staged file: $rel"
        fi
        printf '%s\t%s\n' "$h" "$rel" >>"$rows"
    done <<<"$TARGET_PATHS"

    {
        printf '%s\n' "$ICO_MANIFEST_HEADER"
        sort "$rows"
    } >"$out"
}

print_plan() {
    ico_info "profile '$PROFILE' -> target '$TARGET' (commands-only: $COMMANDS_ONLY, dry-run: $DRY_RUN)"
    local rel dest state
    while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        dest="$PROJECT_DIR/$rel"
        if [ -e "$dest" ]; then
            state="update"
        else
            state="create"
        fi
        printf '  %-6s %s\n' "$state" "$rel"
    done <<<"$TARGET_PATHS"
    printf '  %-6s %s\n' "update" "$MANIFEST_REL"
    if [ -n "$CONFLICTS" ]; then
        ico_warn "conflicts detected:"
        printf '%s' "$CONFLICTS" | sed 's/^/    /' >&2
    fi
}

confirm_or_abort() {
    if [ "$ASSUME_YES" = true ]; then
        return 0
    fi
    if [ ! -t 0 ]; then
        return 0
    fi
    if [ "$EXISTING" -eq 0 ]; then
        return 0
    fi
    printf 'Existing Agent OS files will be updated. Continue? (y/N) ' >&2
    local reply=""
    if ! read -r reply; then
        reply=""
    fi
    case "$reply" in
        [Yy]*) return 0 ;;
        *) ico_die "installation cancelled" ;;
    esac
}

backup_conflicts() {
    [ -n "$CONFLICTS" ] || return 0
    local dir line rel n=0
    dir=$(ico_make_backup_dir "$PROJECT_DIR" "$(date -u +%Y%m%dT%H%M%SZ)")
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        rel=${line#*: }
        mkdir -p "$dir/$(dirname "$rel")"
        cp -p "$PROJECT_DIR/$rel" "$dir/$rel"
        n=$((n + 1))
    done <<<"$CONFLICTS"
    ico_warn "backed up $n conflicting file(s) to ${dir#"$PROJECT_DIR"/}/"
}

# -----------------------------------------------------------------------------
# Commit with rollback
# -----------------------------------------------------------------------------

# Record the directories that do not yet exist along a destination path, so a
# failed commit can remove directories it created.
record_created_dirs() {
    local target=$1 root=$PROJECT_DIR rel cur part rest
    case "$target" in
        "$root"/*) rel=${target#"$root"/} ;;
        *) return 0 ;;
    esac
    cur=$root
    rest=$rel
    while [ -n "$rest" ]; do
        case "$rest" in
            */*) part=${rest%%/*}; rest=${rest#*/} ;;
            *) part=$rest; rest="" ;;
        esac
        cur="$cur/$part"
        if [ ! -e "$cur" ]; then
            CREATED_DIRS[CREATED_DIR_COUNT]="$cur"
            CREATED_DIR_COUNT=$((CREATED_DIR_COUNT + 1))
        fi
    done
}

snapshot_path() {
    local rel=$1
    local dest="$PROJECT_DIR/$rel" idx=$SNAP_COUNT backup
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$WORK_DIR/rollback"
        backup="$WORK_DIR/rollback/$idx"
        cp -p "$dest" "$backup" || return 1
        if [ ! -f "$backup" ]; then
            return 1
        fi
        SNAP_HAD[idx]="1"
        SNAP_BACKUPS[idx]="$backup"
    else
        SNAP_HAD[idx]="0"
        SNAP_BACKUPS[idx]=""
    fi
    SNAP_PATHS[idx]="$rel"
    SNAP_COUNT=$((SNAP_COUNT + 1))
}

# Write one file atomically: stage a sibling temp file on the same filesystem,
# snapshot first, then rename it into place.
commit_one() {
    local rel=$1 staged=$2
    local dest="$PROJECT_DIR/$rel" d tmp
    d=$(dirname "$dest")
    record_created_dirs "$d"
    mkdir -p "$d"
    if ! snapshot_path "$rel"; then
        ico_die "could not snapshot $rel before writing"
    fi
    ROLLBACK_ARMED=true
    ico_assert_dest_safe "$PROJECT_DIR" "$rel"
    tmp=$(mktemp "$d/.agent-os-staging.XXXXXX") || ico_die "could not create staging file for $rel"
    COMMIT_TMP="$tmp"
    cp -p "$staged" "$tmp"
    mv -f "$tmp" "$dest"
    COMMIT_TMP=""
}

rollback_commit() {
    local i=0 p b had
    while [ "$i" -lt "$SNAP_COUNT" ]; do
        p=${SNAP_PATHS[$i]}
        b=${SNAP_BACKUPS[$i]}
        had=${SNAP_HAD[$i]}
        if [ "$had" = "1" ]; then
            cp -p "$b" "$PROJECT_DIR/$p" || ico_warn "rollback: could not restore $p"
        else
            rm -f "$PROJECT_DIR/$p" || ico_warn "rollback: could not remove $p"
        fi
        i=$((i + 1))
    done
    SNAP_PATHS=(); SNAP_BACKUPS=(); SNAP_HAD=(); SNAP_COUNT=0
}

# Remove, deepest first (reverse recording order), any directories created
# during a failed commit. An indexed array plus an explicit counter (Bash 3.2
# nounset-safe) carries directory names containing spaces or a literal "|"
# through untouched, unlike a pipe- or whitespace-delimited list.
rollback_created_dirs() {
    [ "$CREATED_DIR_COUNT" -gt 0 ] || return 0
    local i=$CREATED_DIR_COUNT d
    while [ "$i" -gt 0 ]; do
        i=$((i - 1))
        d=${CREATED_DIRS[$i]}
        [ -n "$d" ] || continue
        if rmdir "$d" 2>/dev/null; then
            ico_info "rollback: removed created directory ${d#"$PROJECT_DIR"/}"
        fi
    done
    CREATED_DIRS=()
    CREATED_DIR_COUNT=0
}

commit_all() {
    local rel
    while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        commit_one "$rel" "$STAGE/$rel"
        commit_count=$((commit_count + 1))
        if [ -n "${AGENT_OS_INSTALL_FAIL_AFTER:-}" ] && [ "$commit_count" -ge "$AGENT_OS_INSTALL_FAIL_AFTER" ]; then
            ico_die "test hook: injected failure after $commit_count committed file(s)"
        fi
    done <<<"$TARGET_PATHS"
    commit_one "$MANIFEST_REL" "$STAGE/$MANIFEST_REL"
    ROLLBACK_ARMED=false
}

cleanup_workdir() {
    if [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR"
    fi
    return 0
}

on_exit() {
    local rc=$?
    trap - EXIT
    if [ "$ROLLBACK_ARMED" = true ]; then
        ico_warn "installation failed; rolling back partial changes"
        rollback_commit
        rollback_created_dirs
    fi
    if [ -n "$COMMIT_TMP" ]; then
        rm -f "$COMMIT_TMP"
    fi
    cleanup_workdir
    exit "$rc"
}

on_signal() {
    ROLLBACK_ARMED=true
    exit 130
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    parse_arguments "$@"
    validate_options
    validate_base_installation
    validate_source_roots
    resolve_project
    load_profile_chain
    setup_workdir

    if [ "$VERBOSE" = true ]; then
        ico_info "base installation: $BASE_DIR"
        ico_info "project directory: $PROJECT_DIR"
        ico_info "inheritance chain: $(printf '%s' "$CHAIN" | tr '\n' ' ')"
    fi

    if [ "$COVERS_STANDARDS" = true ]; then
        stage_standards
        stage_index
    fi
    if [ "$COVERS_COMMANDS" = true ]; then
        stage_commands
    fi
    collect_paths

    if [ -z "$TARGET_PATHS" ]; then
        ico_info "nothing to install for profile '$PROFILE' (target '$TARGET')"
        return 0
    fi

    preflight
    build_manifest
    # Fail closed: never commit a manifest this run could not prove well-formed.
    ico_manifest_validate "$STAGE/$MANIFEST_REL"
    print_plan

    if [ "$DRY_RUN" = true ]; then
        ico_ok "dry run complete; no changes written"
        return 0
    fi

    if [ -n "$CONFLICTS" ] && [ "$FORCE" != true ]; then
        ico_err "refusing to overwrite locally modified or unmanaged files:"
        printf '%s' "$CONFLICTS" | sed 's/^/    /' >&2
        ico_err "re-run with --force to back them up and overwrite"
        exit 1
    fi

    confirm_or_abort
    if [ "$FORCE" = true ]; then
        backup_conflicts
    fi
    commit_all
    ico_ok "installed $(printf '%s\n' "$TARGET_PATHS" | wc -l | tr -d ' ') file(s); manifest: $MANIFEST_REL"
}

trap on_exit EXIT
trap on_signal INT TERM HUP

main "$@"
