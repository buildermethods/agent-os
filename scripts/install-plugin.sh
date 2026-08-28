#!/bin/bash

# =============================================================================
# Agent OS — Cross-Agent Plugin Installer
#
# Installs the Agent OS skills and commands into the directories that
# Claude Code, OpenAI Codex, and pi read from.
#
# Skills follow the Agent Skills standard (https://agentskills.io), so the
# same SKILL.md files work in every harness. Commands are markdown prompts
# with frontmatter and $ARGUMENTS, which all three harnesses also share.
#
# Usage:
#   scripts/install-plugin.sh [--target <t>]... [--global] [--link] [--verbose]
#
# Targets:
#   claude   Claude Code       .claude/skills/     + .claude/commands/agent-os/
#   codex    OpenAI Codex      .agents/skills/     + $CODEX_HOME/prompts/ (global only)
#   pi       pi                .pi/skills/         + .pi/prompts/
#   agents   Shared standard   .agents/skills/     (read by Codex and pi)
#   all      Every target above
#
# Options:
#   --global   Install for the current user instead of the current project
#   --link     Symlink instead of copy, so `git pull` updates the install
#   --verbose  Show each file installed
# =============================================================================

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(pwd)"

source "$SCRIPT_DIR/common-functions.sh"

SKILLS_SRC="$BASE_DIR/skills"
COMMANDS_SRC="$BASE_DIR/commands/agent-os"

VERBOSE="false"
GLOBAL="false"
LINK="false"
TARGETS=()

# Set once .agents/skills has been written, so pi does not also get its own
# copy under .pi/skills — pi reads both locations and would warn about the
# duplicate skill names.
SHARED_SKILLS_INSTALLED="false"

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------

show_help() {
    sed -n '3,27p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
}

# -----------------------------------------------------------------------------
# Arguments
# -----------------------------------------------------------------------------

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target)
                TARGETS+=("$2")
                shift 2
                ;;
            --global)
                GLOBAL="true"
                shift
                ;;
            --link)
                LINK="true"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                ;;
        esac
    done

    if [[ ${#TARGETS[@]} -eq 0 ]]; then
        TARGETS=("all")
    fi

    for target in "${TARGETS[@]}"; do
        case "$target" in
            claude|codex|pi|agents|all) ;;
            *)
                print_error "Unknown target: $target (expected claude, codex, pi, agents, or all)"
                exit 1
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------

validate_sources() {
    if [[ ! -d "$SKILLS_SRC" ]]; then
        print_error "Skills not found at $SKILLS_SRC"
        exit 1
    fi

    if [[ ! -d "$COMMANDS_SRC" ]]; then
        print_error "Commands not found at $COMMANDS_SRC. Run scripts/build-commands.sh first."
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Install Helpers
# -----------------------------------------------------------------------------

# install_path <source> <destination>
# Copies, or symlinks when --link was passed. Replaces whatever was there.
install_path() {
    local source="$1"
    local dest="$2"

    rm -rf "$dest"

    if [[ "$LINK" == "true" ]]; then
        ln -s "$source" "$dest"
        print_verbose "linked $dest -> $source"
    else
        cp -R "$source" "$dest"
        print_verbose "copied $dest"
    fi
}

# install_skills <destination directory>
install_skills() {
    local dest_dir="$1"
    ensure_dir "$dest_dir"

    local count=0
    local skill_dir
    for skill_dir in "$SKILLS_SRC"/*/; do
        [[ -f "$skill_dir/SKILL.md" ]] || continue
        local name
        name=$(basename "$skill_dir")
        install_path "${skill_dir%/}" "$dest_dir/$name"
        count=$((count + 1))
    done

    print_success "Installed $count skills to ${dest_dir/#$HOME/\~}"
}

# install_commands <destination directory> <filename prefix>
install_commands() {
    local dest_dir="$1"
    local prefix="$2"
    ensure_dir "$dest_dir"

    local count=0
    local file
    for file in "$COMMANDS_SRC"/*.md; do
        [[ -f "$file" ]] || continue
        local name
        name=$(basename "$file")
        install_path "$file" "$dest_dir/${prefix}${name}"
        count=$((count + 1))
    done

    print_success "Installed $count commands to ${dest_dir/#$HOME/\~}"
}

# -----------------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------------

install_claude() {
    print_section "Claude Code"

    local root
    if [[ "$GLOBAL" == "true" ]]; then
        root="$HOME/.claude"
    else
        root="$PROJECT_DIR/.claude"
    fi

    install_skills "$root/skills"
    # Nested under agent-os/ so the commands read as /agent-os:discover-standards
    install_commands "$root/commands/agent-os" ""

    echo ""
    echo "  Use: /agent-os:shape-spec"
    echo ""
    echo "  Prefer the plugin? From this repo's marketplace:"
    echo "    /plugin marketplace add slurpyb/agent-os"
    echo "    /plugin install agent-os@agent-os"
}

install_codex() {
    print_section "OpenAI Codex"

    if [[ "$GLOBAL" == "true" ]]; then
        local codex_home="${CODEX_HOME:-$HOME/.codex}"
        install_skills "$codex_home/skills"
        # Codex custom prompts are deprecated in favour of skills, but still
        # useful for invoking a workflow explicitly.
        install_commands "$codex_home/prompts" "agent-os-"
        echo ""
        echo "  Use: describe the task, or /prompts:agent-os-shape-spec"
    else
        # Codex scans .agents/skills in cwd and every ancestor up to the repo root.
        install_skills "$PROJECT_DIR/.agents/skills"
        SHARED_SKILLS_INSTALLED="true"
        echo ""
        echo "  Use: describe the task — Codex loads a matching skill on its own."
        echo "  Codex reads project prompts from \$CODEX_HOME only; add them with --global."
    fi
}

install_pi() {
    print_section "pi"

    local skills_dir prompts_dir
    if [[ "$GLOBAL" == "true" ]]; then
        skills_dir="$HOME/.pi/agent/skills"
        prompts_dir="$HOME/.pi/agent/prompts"
    else
        skills_dir="$PROJECT_DIR/.pi/skills"
        prompts_dir="$PROJECT_DIR/.pi/prompts"
    fi

    if [[ "$GLOBAL" != "true" && "$SHARED_SKILLS_INSTALLED" == "true" ]]; then
        print_status "Skills already in .agents/skills, which pi also reads — skipping .pi/skills"
    else
        install_skills "$skills_dir"
    fi
    install_commands "$prompts_dir" "agent-os-"

    echo ""
    echo "  Use: /skill:agent-os-shape-spec or /agent-os-shape-spec"
    echo ""
    echo "  Prefer a pi package? pi install git:github.com/slurpyb/agent-os"
    if [[ "$GLOBAL" != "true" ]]; then
        echo "  Project skills load once the project is trusted (/trust)."
    fi
}

install_agents() {
    print_section "Agent Skills standard (.agents/skills)"

    local dest
    if [[ "$GLOBAL" == "true" ]]; then
        dest="$HOME/.agents/skills"
    else
        dest="$PROJECT_DIR/.agents/skills"
    fi

    install_skills "$dest"
    [[ "$GLOBAL" == "true" ]] || SHARED_SKILLS_INSTALLED="true"

    echo ""
    echo "  Read by Codex and pi from this one location."
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    parse_arguments "$@"
    validate_sources

    print_section "Agent OS Plugin Installation"
    if [[ "$GLOBAL" == "true" ]]; then
        echo "Scope:  user (\$HOME)"
    else
        echo "Scope:  project ($PROJECT_DIR)"
    fi
    echo "Mode:   $([[ "$LINK" == "true" ]] && echo "symlink" || echo "copy")"
    echo "Source: $BASE_DIR"

    local selected=("${TARGETS[@]}")
    if [[ " ${TARGETS[*]} " == *" all "* ]]; then
        selected=(claude codex pi)
    fi

    local target
    for target in "${selected[@]}"; do
        case "$target" in
            claude) install_claude ;;
            codex)  install_codex ;;
            pi)     install_pi ;;
            agents) install_agents ;;
        esac
    done

    # project-install.sh prints its own closing summary.
    if [[ "${AGENT_OS_SKIP_SUMMARY:-}" != "true" ]]; then
        echo ""
        print_success "Agent OS installed"
        echo ""
        echo "Standards, product docs and specs are written to agent-os/ in your project,"
        echo "so every agent reads and writes the same files."
        echo ""
    fi
}

main "$@"
