#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common-functions.sh
source "$SCRIPT_DIR/common-functions.sh"

PROJECT_DIR="$(pwd)"
ASSUME_YES="false"
DRY_RUN="false"

while (($#)); do
    case "$1" in
        --project-dir)
            require_option_value "$1" "${2:-}" || exit 2
            PROJECT_DIR="$2"
            shift 2
            ;;
        --yes) ASSUME_YES="true"; shift ;;
        --dry-run) DRY_RUN="true"; shift ;;
        *) print_error "Usage: $0 [--project-dir <path>] [--yes] [--dry-run]"; exit 2 ;;
    esac
done

PROJECT_DIR="$(canonical_path "$PROJECT_DIR")"
manifest="$PROJECT_DIR/agent-os/install-manifest.tsv"
[[ -f "$manifest" ]] || {
    print_error "No Agent OS 3.1 installation manifest found; refusing broad removal."
    exit 1
}
require_no_symlink_components "$PROJECT_DIR" "$PROJECT_DIR/agent-os"

echo "Managed Agent OS files will be removed from: $PROJECT_DIR"
if [[ "$DRY_RUN" == "true" ]]; then
    awk -F '\t' '$1 == "standard" { print "  agent-os/standards/" $2 }' "$manifest"
    exit 0
fi
if [[ "$ASSUME_YES" != "true" ]]; then
    [[ -t 0 ]] || {
        print_error "Non-interactive uninstall requires --yes."
        exit 1
    }
    read -r -p "Continue? (y/N) " reply
    [[ "$reply" =~ ^[Yy]$ ]] || exit 0
fi

while IFS=$'\t' read -r kind path _; do
    [[ "$kind" == "standard" ]] || continue
    target="$PROJECT_DIR/agent-os/standards/$path"
    require_path_within "$PROJECT_DIR/agent-os/standards" "$target"
    rm -f -- "$target"
done < "$manifest"
rm -f -- "$manifest" "$PROJECT_DIR/agent-os/standards/index.yml"

for adapter in \
    "$PROJECT_DIR/.claude/commands/agent-os" \
    "$PROJECT_DIR/.cursor/commands/agent-os" \
    "$PROJECT_DIR/.agent/workflows/agent-os"; do
    require_path_within "$PROJECT_DIR" "$adapter"
    [[ -d "$adapter" ]] && rm -rf -- "$adapter"
done
if [[ -d "$PROJECT_DIR/.agents/skills" ]]; then
    find "$PROJECT_DIR/.agents/skills" -mindepth 1 -maxdepth 1 \
        -type d -name 'agent-os-*' -exec rm -rf -- {} +
fi

print_success "Removed manifest-managed Agent OS files. Unmanaged project files were preserved."
