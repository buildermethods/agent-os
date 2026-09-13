#!/usr/bin/env bash
#
# Agent OS uninstaller.
#
# Removes only the files that are listed in agent-os/install-manifest.tsv and
# are still unchanged. Modified files are retained by default and reported as a
# non-zero exit status; with --force they are backed up and removed. Symlinks are
# never followed or deleted. Every managed path is preflighted (including its
# parent directories and the manifest itself) before any file is removed, so a
# redirected parent component cannot make the uninstaller delete outside files.

set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

# shellcheck source=scripts/installer-common.sh
. "$SCRIPT_DIR/installer-common.sh"

PROGRAM=$(basename "$0")
PROJECT_DIR=""
FORCE=false

# Global so the EXIT trap can still see it after main() returns.
UNINSTALL_TMP=""

show_help() {
    cat <<EOF
Usage: $PROGRAM [OPTIONS]

Remove the Agent OS files that were recorded in agent-os/install-manifest.tsv,
leaving modified files and unrelated files untouched.

Options:
    --project-dir <dir>   Project directory to clean (default: current directory)
    --force               Back up and remove files that drifted from the manifest
    -h, --help            Show this help message
EOF
    exit 0
}

parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --project-dir)
                [ $# -ge 2 ] && [ -n "$2" ] && [ "${2#-}" = "$2" ] || ico_die "option --project-dir requires a value"
                PROJECT_DIR="$2"
                shift 2
                ;;
            --force)
                FORCE=true
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

cleanup_tmp() {
    if [ -n "$UNINSTALL_TMP" ] && [ -d "$UNINSTALL_TMP" ]; then
        rm -rf "$UNINSTALL_TMP"
    fi
    return 0
}

main() {
    parse_arguments "$@"
    PROJECT_DIR=$(ico_resolve_project_dir "${PROJECT_DIR:-$PWD}")

    local manifest="$PROJECT_DIR/$ICO_MANIFEST_REL"
    if [ ! -e "$manifest" ] && [ ! -L "$manifest" ]; then
        ico_err "no install manifest found at $ICO_MANIFEST_REL (nothing to uninstall)"
        exit 1
    fi

    # Full preflight (manifest + every path and its parents) before any mutation.
    ico_preflight_managed_paths "$PROJECT_DIR" "$manifest"

    local keep backup_dir="" drift=0
    UNINSTALL_TMP=$(mktemp -d "${TMPDIR:-/tmp}/agent-os-uninstall.XXXXXX")
    trap cleanup_tmp EXIT
    keep="$UNINSTALL_TMP/keep.tsv"
    : >"$keep"

    if [ "$FORCE" = true ]; then
        backup_dir=$(ico_make_backup_dir "$PROJECT_DIR" "$(date -u +%Y%m%dT%H%M%SZ)-uninstall")
    fi

    local removed=0 retained=0 missing=0 hash path dest cur
    while IFS=$'\t' read -r hash path; do
        [ -n "$hash" ] || continue
        dest="$PROJECT_DIR/$path"
        if [ -L "$dest" ]; then
            ico_warn "retaining drifted (symlink; never followed): $path"
            printf '%s\t%s\n' "$hash" "$path" >>"$keep"
            retained=$((retained + 1)); drift=$((drift + 1))
        elif [ ! -e "$dest" ]; then
            missing=$((missing + 1))
        elif [ ! -f "$dest" ]; then
            ico_warn "retaining drifted (not a regular file): $path"
            printf '%s\t%s\n' "$hash" "$path" >>"$keep"
            retained=$((retained + 1)); drift=$((drift + 1))
        else
            cur=$(ico_hash_file "$dest")
            if [ "$cur" = "$hash" ]; then
                if [ -n "$backup_dir" ]; then
                    mkdir -p "$backup_dir/$(dirname "$path")"
                    cp -p "$dest" "$backup_dir/$path"
                fi
                rm -f "$dest"
                removed=$((removed + 1))
            elif [ "$FORCE" = true ]; then
                ico_warn "backing up and removing drifted file: $path"
                mkdir -p "$backup_dir/$(dirname "$path")"
                cp -p "$dest" "$backup_dir/$path"
                rm -f "$dest"
                removed=$((removed + 1))
            else
                ico_warn "retaining drifted (modified): $path"
                printf '%s\t%s\n' "$hash" "$path" >>"$keep"
                retained=$((retained + 1)); drift=$((drift + 1))
            fi
        fi
    done < <(ico_manifest_each "$manifest")

    if [ -s "$keep" ]; then
        {
            printf '%s\n' "$ICO_MANIFEST_HEADER"
            sort "$keep"
        } >"$manifest"
        ico_warn "retained $retained tracked file(s); manifest rewritten at $ICO_MANIFEST_REL"
    else
        rm -f "$manifest"
    fi

    ico_ok "removed $removed file(s), skipped $missing missing, retained $retained drifted"
    if [ -n "$backup_dir" ]; then
        ico_ok "backups written to ${backup_dir#"$PROJECT_DIR"/}/"
    fi
    if [ "$drift" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
