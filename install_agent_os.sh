#!/usr/bin/env bash

# Bootstrap or update an Agent OS source checkout, then install it into a project.

set -Eeuo pipefail

REPOSITORY="${AGENT_OS_REPOSITORY:-https://github.com/buildermethods/agent-os.git}"
SOURCE_DIR="${AGENT_OS_HOME:-$HOME/agent-os}"
PROJECT_DIR="$(pwd)"
PROFILE=""
TARGETS="claude"
REF=""
UPDATE="false"
DRY_RUN="false"

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
    --source-dir <path>    Agent OS source checkout (default: \$AGENT_OS_HOME or ~/agent-os)
    --project-dir <path>   Project to configure (default: current directory)
    --profile <name>       Profile passed to project-install.sh
    --target <list>        claude,codex,cursor,antigravity
    --ref <git-ref>        Exact tag, branch, or commit to check out
    --update               Fetch and fast-forward an existing checkout
    --dry-run              Validate project installation without changing it
    -h, --help             Show this help

The script never edits shell startup files. Set AGENT_OS_HOME yourself only if
you want a non-default source location to persist across shells.
EOF
}

require_value() {
    [[ -n "${2:-}" && "${2:-}" != --* ]] || {
        echo "Option $1 requires a value." >&2
        exit 2
    }
}

while (($#)); do
    case "$1" in
        --source-dir|--project-dir|--profile|--target|--ref)
            require_value "$1" "${2:-}"
            case "$1" in
                --source-dir) SOURCE_DIR="$2" ;;
                --project-dir) PROJECT_DIR="$2" ;;
                --profile) PROFILE="$2" ;;
                --target) TARGETS="$2" ;;
                --ref) REF="$2" ;;
            esac
            shift 2
            ;;
        --update) UPDATE="true"; shift ;;
        --dry-run) DRY_RUN="true"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    esac
done

if [[ ! -d "$SOURCE_DIR/.git" ]]; then
    [[ ! -e "$SOURCE_DIR" ]] || {
        echo "Source path exists but is not a Git checkout: $SOURCE_DIR" >&2
        exit 1
    }
    git clone --filter=blob:none "$REPOSITORY" "$SOURCE_DIR"
elif [[ "$UPDATE" == "true" ]]; then
    git -C "$SOURCE_DIR" fetch --tags --prune origin
    if [[ -z "$REF" ]]; then
        git -C "$SOURCE_DIR" pull --ff-only
    fi
fi

if [[ -n "$REF" ]]; then
    git -C "$SOURCE_DIR" fetch --tags origin "$REF"
    git -C "$SOURCE_DIR" checkout --detach "$REF"
fi

installer="$SOURCE_DIR/scripts/project-install.sh"
[[ -x "$installer" ]] || {
    echo "Installer is missing or not executable: $installer" >&2
    exit 1
}

args=(--project-dir "$PROJECT_DIR" --target "$TARGETS" --yes)
[[ -n "$PROFILE" ]] && args+=(--profile "$PROFILE")
[[ "$DRY_RUN" == "true" ]] && args+=(--dry-run)
"$installer" "${args[@]}"
