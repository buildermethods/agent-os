#!/bin/bash

# =============================================================================
# Agent OS — Build Commands From Skills
#
# plugins/agent-os/skills/ is the single source of truth. This script
# regenerates plugins/agent-os/commands/ from it.
#
# Both directories ship inside the plugin. Claude Code and Codex read
# commands/ as plugin commands; pi reads it as prompt templates. All three
# use the same "markdown + frontmatter + $ARGUMENTS" format.
#
# Usage:
#   scripts/build-commands.sh            # regenerate
#   scripts/build-commands.sh --check    # fail if the generated files are stale
# =============================================================================

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
PLUGIN_DIR="$BASE_DIR/plugins/agent-os"
SKILLS_DIR="$PLUGIN_DIR/skills"
COMMANDS_DIR="$PLUGIN_DIR/commands"

source "$SCRIPT_DIR/common-functions.sh"

CHECK_ONLY="false"
[[ "${1:-}" == "--check" ]] && CHECK_ONLY="true"

# -----------------------------------------------------------------------------
# Frontmatter helpers
# -----------------------------------------------------------------------------

# Read a top-level or metadata key out of a SKILL.md frontmatter block.
# Usage: read_frontmatter_key <file> <key>
read_frontmatter_key() {
    local file="$1"
    local key="$2"

    awk -v key="$key" '
        NR == 1 && $0 == "---" { in_fm = 1; next }
        in_fm && $0 == "---" { exit }
        !in_fm { next }
        {
            line = $0
            sub(/^[ \t]+/, "", line)
            idx = index(line, ":")
            if (idx == 0) next
            k = substr(line, 1, idx - 1)
            if (k != key) next
            v = substr(line, idx + 1)
            sub(/^[ \t]+/, "", v)
            sub(/[ \t]+$/, "", v)
            # strip one layer of matching quotes
            if (v ~ /^".*"$/ || v ~ /^'"'"'.*'"'"'$/) v = substr(v, 2, length(v) - 2)
            print v
            exit
        }
    ' "$file"
}

# Print everything after the closing --- of the frontmatter block.
read_body() {
    awk '
        NR == 1 && $0 == "---" { in_fm = 1; next }
        in_fm && $0 == "---" { in_fm = 0; started = 1; next }
        started { print }
    ' "$1"
}

# YAML-quote a scalar for the generated frontmatter.
yaml_quote() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    printf '"%s"' "$value"
}

# -----------------------------------------------------------------------------
# Generation
# -----------------------------------------------------------------------------

generate_command() {
    local skill_file="$1"
    local dest="$2"

    local skill_name command summary argument_hint description
    skill_name=$(read_frontmatter_key "$skill_file" "name")
    command=$(read_frontmatter_key "$skill_file" "agent-os-command")
    summary=$(read_frontmatter_key "$skill_file" "agent-os-summary")
    argument_hint=$(read_frontmatter_key "$skill_file" "agent-os-argument-hint")
    description=$(read_frontmatter_key "$skill_file" "description")

    [[ -z "$command" ]] && { print_error "Missing metadata.agent-os-command in $skill_file"; return 1; }
    [[ -z "$summary" ]] && summary="$description"

    {
        echo "---"
        echo "description: $(yaml_quote "$summary")"
        [[ -n "$argument_hint" ]] && echo "argument-hint: $(yaml_quote "$argument_hint")"
        echo "---"
        echo ""
        echo "<!-- GENERATED FILE — do not edit."
        echo "     Source: plugins/agent-os/skills/${skill_name}/SKILL.md"
        echo "     Regenerate with: scripts/build-commands.sh -->"
        echo ""
        echo "Arguments (may be empty): \$ARGUMENTS"
        read_body "$skill_file"
    } > "$dest"
}

main() {
    if [[ ! -d "$SKILLS_DIR" ]]; then
        print_error "No skills/ directory found at $SKILLS_DIR"
        exit 1
    fi

    local work_dir
    if [[ "$CHECK_ONLY" == "true" ]]; then
        work_dir=$(mktemp -d)
        trap 'rm -rf "$work_dir"' EXIT
    else
        work_dir="$COMMANDS_DIR"
        mkdir -p "$work_dir"
    fi

    local count=0
    local skill_file
    for skill_file in "$SKILLS_DIR"/*/SKILL.md; do
        [[ -f "$skill_file" ]] || continue
        local command
        command=$(read_frontmatter_key "$skill_file" "agent-os-command")
        [[ -n "$command" ]] || continue
        generate_command "$skill_file" "$work_dir/${command}.md"
        count=$((count + 1))
    done

    if [[ $count -eq 0 ]]; then
        print_error "No skills with metadata.agent-os-command found"
        exit 1
    fi

    if [[ "$CHECK_ONLY" == "true" ]]; then
        if diff -ru "$COMMANDS_DIR" "$work_dir" > /dev/null 2>&1; then
            print_success "plugins/agent-os/commands/ is up to date ($count commands)"
        else
            print_error "plugins/agent-os/commands/ is out of date. Run scripts/build-commands.sh"
            diff -ru "$COMMANDS_DIR" "$work_dir" || true
            exit 1
        fi
    else
        print_success "Generated $count commands into plugins/agent-os/commands/"
    fi
}

main
