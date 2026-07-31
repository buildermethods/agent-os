#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck source=scripts/common-functions.sh
source "$SCRIPT_DIR/common-functions.sh"

PROJECT_DIR="$(pwd)"
ERRORS=0
WARNINGS=0

error() { print_error "$1"; ((ERRORS+=1)); }
warn() { print_warning "$1"; ((WARNINGS+=1)); }

if [[ "${1:-}" == "--project-dir" ]]; then
    require_option_value "$1" "${2:-}" || exit 2
    PROJECT_DIR="$2"
elif (($#)); then
    print_error "Usage: $0 [--project-dir <path>]"
    exit 2
fi

PROJECT_DIR="$(canonical_path "$PROJECT_DIR")"
default_profile="$(get_yaml_value "$BASE_DIR/config.yml" default_profile default)"

validate_profile_name "$default_profile" ||
    error "Invalid default profile name: $default_profile"
[[ -d "$BASE_DIR/profiles/$default_profile/standards" ]] ||
    error "Default profile standards are missing: profiles/$default_profile/standards"

if [[ -d "$PROJECT_DIR/agent-os" ]]; then
    require_no_symlink_components "$PROJECT_DIR" "$PROJECT_DIR/agent-os" ||
        error "Project Agent OS path contains an unsafe symbolic link."
    [[ -f "$PROJECT_DIR/agent-os/install-manifest.tsv" ]] ||
        warn "Project has no installation manifest; it may predate Agent OS 3.1."
else
    warn "Agent OS is not installed in $PROJECT_DIR."
fi

for command in bash awk find sort sha256sum realpath; do
    command -v "$command" >/dev/null || error "Required command not found: $command"
done

if ((ERRORS)); then
    print_error "Doctor found $ERRORS error(s) and $WARNINGS warning(s)."
    exit 1
fi
print_success "Doctor found no errors ($WARNINGS warning(s))."
