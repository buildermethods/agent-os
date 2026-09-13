#!/usr/bin/env bash
#
# Agent OS install doctor.
#
# Verifies that every file recorded in agent-os/install-manifest.tsv still
# exists and matches its recorded SHA-256. Any missing, modified or symlinked
# managed file is reported as drift, and the exit status is non-zero. A
# symlinked parent directory along any managed path is refused outright so drift
# can never be hidden behind a redirected path component.

set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

# shellcheck source=scripts/installer-common.sh
. "$SCRIPT_DIR/installer-common.sh"

PROGRAM=$(basename "$0")
PROJECT_DIR=""

show_help() {
    cat <<EOF
Usage: $PROGRAM [OPTIONS]

Check an Agent OS installation for drift between the project files and the
recorded manifest (agent-os/install-manifest.tsv).

Options:
    --project-dir <dir>   Project directory to check (default: current directory)
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

main() {
    parse_arguments "$@"
    PROJECT_DIR=$(ico_resolve_project_dir "${PROJECT_DIR:-$PWD}")

    local manifest="$PROJECT_DIR/$ICO_MANIFEST_REL"
    if [ ! -e "$manifest" ] && [ ! -L "$manifest" ]; then
        ico_err "no install manifest found at $ICO_MANIFEST_REL (is Agent OS installed?)"
        exit 1
    fi

    # Refuse symlinked parents (and a symlinked manifest) before reading paths.
    ico_preflight_managed_paths "$PROJECT_DIR" "$manifest"

    local drift=0 total=0 hash path dest cur
    while IFS=$'\t' read -r hash path; do
        [ -n "$hash" ] || continue
        total=$((total + 1))
        dest="$PROJECT_DIR/$path"
        if [ -L "$dest" ]; then
            ico_err "drift: $path is a symlink"
            drift=$((drift + 1))
        elif [ ! -e "$dest" ]; then
            ico_err "drift: $path is missing"
            drift=$((drift + 1))
        elif [ ! -f "$dest" ]; then
            ico_err "drift: $path is not a regular file"
            drift=$((drift + 1))
        else
            cur=$(ico_hash_file "$dest")
            if [ "$cur" != "$hash" ]; then
                ico_err "drift: $path has been modified"
                drift=$((drift + 1))
            fi
        fi
    done < <(ico_manifest_each "$manifest")

    if [ "$drift" -gt 0 ]; then
        ico_err "$drift of $total managed file(s) have drifted"
        exit 1
    fi
    ico_ok "all $total managed file(s) match the manifest"
}

main "$@"
