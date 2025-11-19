#!/bin/bash

# =============================================================================
# Agent OS Project Update Script
# Updates Agent OS installation in a project
# =============================================================================

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$HOME/qa-agent-os"
PROJECT_DIR="$(pwd)"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Default Values
# -----------------------------------------------------------------------------

DRY_RUN="false"
VERBOSE="false"
PROFILE=""
CLAUDE_CODE_COMMANDS=""
USE_CLAUDE_CODE_SUBAGENTS=""
AGENT_OS_COMMANDS=""
STANDARDS_AS_CLAUDE_CODE_SKILLS=""
RE_INSTALL="false"
OVERWRITE_ALL="false"
OVERWRITE_AGENTS="false"
OVERWRITE_COMMANDS="false"
OVERWRITE_STANDARDS="false"
SKIPPED_FILES=()
UPDATED_FILES=()
NEW_FILES=()

# -----------------------------------------------------------------------------
# Help Function
# -----------------------------------------------------------------------------

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Update Agent OS installation in the current project directory.

Options:
    --profile PROFILE                        Use specified profile (default: from project config)
    --claude-code-commands [BOOL]            Install Claude Code commands (true/false)
    --use-claude-code-subagents [BOOL]       Use Claude Code subagents with delegation (true/false)
    --agent-os-commands [BOOL]               Install agent-os commands for other tools (true/false)
    --standards-as-claude-code-skills [BOOL] Use Claude Code Skills for standards (true/false)
    --re-install                             Delete and reinstall Agent OS
    --overwrite-all                          Overwrite all existing files
    --overwrite-agents                       Overwrite existing agent files
    --overwrite-commands                     Overwrite existing command files
    --overwrite-standards                    Overwrite existing standards files
    --dry-run                                Show what would be done without doing it
    --verbose                                Show detailed output
    -h, --help                               Show this help message

Note: Flags accept both hyphens and underscores (e.g., --use-claude-code-subagents or --use_claude_code_subagents)

Examples:
    $0
    $0 --overwrite-agents
    $0 --claude-code-commands true --use-claude-code-subagents true
    $0 --dry-run --verbose

EOF
    exit 0
}

# -----------------------------------------------------------------------------
# Parse Command Line Arguments
# -----------------------------------------------------------------------------

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        # Normalize flag by replacing underscores with hyphens
        local flag="${1//_/-}"

        case $flag in
            --profile)
                PROFILE="$2"
                shift 2
                ;;
            --claude-code-commands)
                read CLAUDE_CODE_COMMANDS shift_count <<< "$(parse_bool_flag "$CLAUDE_CODE_COMMANDS" "$2")"
                shift $shift_count
                ;;
            --use-claude-code-subagents)
                read USE_CLAUDE_CODE_SUBAGENTS shift_count <<< "$(parse_bool_flag "$USE_CLAUDE_CODE_SUBAGENTS" "$2")"
                shift $shift_count
                ;;
            --agent-os-commands)
                read AGENT_OS_COMMANDS shift_count <<< "$(parse_bool_flag "$AGENT_OS_COMMANDS" "$2")"
                shift $shift_count
                ;;
            --standards-as-claude-code-skills)
                read STANDARDS_AS_CLAUDE_CODE_SKILLS shift_count <<< "$(parse_bool_flag "$STANDARDS_AS_CLAUDE_CODE_SKILLS" "$2")"
                shift $shift_count
                ;;
            --re-install)
                RE_INSTALL="true"
                shift
                ;;
            --overwrite-all)
                OVERWRITE_ALL="true"
                shift
                ;;
            --overwrite-agents)
                OVERWRITE_AGENTS="true"
                shift
                ;;
            --overwrite-commands)
                OVERWRITE_COMMANDS="true"
                shift
                ;;
            --overwrite-standards)
                OVERWRITE_STANDARDS="true"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
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
}

# -----------------------------------------------------------------------------
# Validation Functions
# -----------------------------------------------------------------------------

validate_installations() {
    # Check base installation using common function
    validate_base_installation

    # Check project installation
    if [[ ! -f "$PROJECT_DIR/qa-agent-os/config.yml" ]]; then
        print_error "QA Agent OS not installed in this project"
        echo ""
        print_status "Please run project-install.sh first"
        exit 1
    fi

    print_verbose "Project installation found at: $PROJECT_DIR/qa-agent-os"
}

# -----------------------------------------------------------------------------
# Configuration Functions
# -----------------------------------------------------------------------------

load_configurations() {
    # Load base and project configurations using common functions
    load_base_config
    load_project_config

    # Set effective values
    # For update, base config is the "incoming" config (what we're updating TO)
    # Command line flags override base config
    EFFECTIVE_PROFILE="${PROFILE:-$BASE_PROFILE}"
    EFFECTIVE_CLAUDE_CODE_COMMANDS="${CLAUDE_CODE_COMMANDS:-$BASE_CLAUDE_CODE_COMMANDS}"
    EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS="${USE_CLAUDE_CODE_SUBAGENTS:-$BASE_USE_CLAUDE_CODE_SUBAGENTS}"
    EFFECTIVE_AGENT_OS_COMMANDS="${AGENT_OS_COMMANDS:-$BASE_AGENT_OS_COMMANDS}"
    EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS="${STANDARDS_AS_CLAUDE_CODE_SKILLS:-$BASE_STANDARDS_AS_CLAUDE_CODE_SKILLS}"
    EFFECTIVE_VERSION="$BASE_VERSION"

    # Validate config but suppress warnings (will show after user confirms update)
    validate_config "$EFFECTIVE_CLAUDE_CODE_COMMANDS" "$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS" "$EFFECTIVE_AGENT_OS_COMMANDS" "$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS" "$EFFECTIVE_PROFILE" "false"

    print_verbose "Base configuration:"
    print_verbose "  Version: $BASE_VERSION"
    print_verbose "  Profile: $BASE_PROFILE"
    print_verbose "  Claude Code commands: $BASE_CLAUDE_CODE_COMMANDS"
    print_verbose "  Use Claude Code subagents: $BASE_USE_CLAUDE_CODE_SUBAGENTS"
    print_verbose "  QA Agent OS commands: $BASE_AGENT_OS_COMMANDS"
    print_verbose "  Standards as Claude Code Skills: $BASE_STANDARDS_AS_CLAUDE_CODE_SKILLS"

    print_verbose "Project configuration:"
    print_verbose "  Version: $PROJECT_VERSION"
    print_verbose "  Profile: $PROJECT_PROFILE"
    print_verbose "  Claude Code commands: $PROJECT_CLAUDE_CODE_COMMANDS"
    print_verbose "  Use Claude Code subagents: $PROJECT_USE_CLAUDE_CODE_SUBAGENTS"
    print_verbose "  QA Agent OS commands: $PROJECT_AGENT_OS_COMMANDS"
    print_verbose "  Standards as Claude Code Skills: $PROJECT_STANDARDS_AS_CLAUDE_CODE_SKILLS"

    print_verbose "Effective configuration:"
    print_verbose "  Profile: $EFFECTIVE_PROFILE"
    print_verbose "  Claude Code commands: $EFFECTIVE_CLAUDE_CODE_COMMANDS"
    print_verbose "  Use Claude Code subagents: $EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS"
    print_verbose "  QA Agent OS commands: $EFFECTIVE_AGENT_OS_COMMANDS"
    print_verbose "  Standards as Claude Code Skills: $EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS"
}

# -----------------------------------------------------------------------------
# Version Compatibility Check
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Configuration Matching
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# User Prompts
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Update Functions
# -----------------------------------------------------------------------------

# Update standards files
update_standards() {
    print_status "Updating standards"

    local standards_updated=0
    local standards_skipped=0
    local standards_new=0

    while read file; do
        if [[ "$file" == standards/* ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            local dest="$PROJECT_DIR/qa-agent-os/$file"

            if [[ -f "$source" ]]; then
                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_STANDARDS" "standard"; then
                    SKIPPED_FILES+=("$dest")
                    ((standards_skipped++)) || true
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        ((standards_updated++)) || true
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        ((standards_new++)) || true
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        copy_file "$source" "$dest" > /dev/null
                    fi
                fi
            fi
        fi
    done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "standards")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $standards_new -gt 0 ]]; then
            echo "✓ Added $standards_new standards in agent-os/standards"
        fi
        if [[ $standards_updated -gt 0 ]]; then
            echo "✓ Updated $standards_updated standards in agent-os/standards"
        fi
        if [[ $standards_skipped -gt 0 ]]; then
            echo -e "${YELLOW}$standards_skipped files in agent-os/standards were not updated and overwritten. To update and overwrite these, re-run with --overwrite-standards flag.${NC}"
        fi
    fi
}

# Update single-agent commands
update_single_agent_commands() {
    print_status "Updating single-agent commands..."
    local commands_updated=0
    local commands_skipped=0
    local commands_new=0

    while read file; do
        # Process single-agent command files OR orchestrate-tasks special case
        if [[ "$file" == commands/*/single-agent/* ]] || [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                # Handle orchestrate-tasks specially (preserve folder structure)
                if [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
                    local dest="$PROJECT_DIR/qa-agent-os/commands/orchestrate-tasks/orchestrate-tasks.md"
                else
                    # Strip the single-agent/ subfolder for agent-os/commands structure
                    local dest_file=$(echo "$file" | sed 's/\/single-agent//')
                    local dest="$PROJECT_DIR/qa-agent-os/$dest_file"
                fi

                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_COMMANDS" "command"; then
                    SKIPPED_FILES+=("$dest")
                    ((commands_skipped++)) || true
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        ((commands_updated++)) || true
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        ((commands_new++)) || true
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        # Compile with PHASE embedding (mode="embed")
                        compile_command "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" "embed"
                    fi
                fi
            fi
        fi
    done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "commands")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $commands_new -gt 0 ]]; then
            echo "✓ Added $commands_new single-agent commands"
        fi
        if [[ $commands_updated -gt 0 ]]; then
            echo "✓ Updated $commands_updated single-agent commands"
        fi
        if [[ $commands_skipped -gt 0 ]]; then
            echo -e "${YELLOW}$commands_skipped commands were not updated and overwritten. To update and overwrite these, re-run with --overwrite-commands flag.${NC}"
        fi
    fi
}

# Update Claude Code agents and commands
update_claude_code_files() {
    print_status "Updating Claude Code tools"

    local commands_updated=0
    local commands_skipped=0
    local commands_new=0
    local agents_updated=0
    local agents_skipped=0
    local agents_new=0

    # Update commands in .claude/commands/qa-agent-os/
    # Determine which command mode to use based on subagents setting
    if [[ "$PROJECT_USE_CLAUDE_CODE_SUBAGENTS" == "true" ]]; then
        # Process multi-agent command files
        while read file; do
            if [[ "$file" == commands/*/multi-agent/* ]] || [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
                local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
                if [[ -f "$source" ]]; then
                    # Extract command name
                    if [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
                        local command_name="orchestrate-tasks"
                    else
                        local command_name=$(echo "$file" | sed 's/commands\///' | sed 's/\/multi-agent.*//')
                    fi
                    local dest="$PROJECT_DIR/.claude/commands/qa-agent-os/${command_name}.md"

                    if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_COMMANDS" "command"; then
                        SKIPPED_FILES+=("$dest")
                        ((commands_skipped++)) || true
                        print_verbose "Skipped: $dest"
                    else
                        if [[ -f "$dest" ]]; then
                            UPDATED_FILES+=("$dest")
                            ((commands_updated++)) || true
                            print_verbose "Updated: $dest"
                        else
                            NEW_FILES+=("$dest")
                            ((commands_new++)) || true
                            print_verbose "New file: $dest"
                        fi
                        if [[ "$DRY_RUN" != "true" ]]; then
                            # Compile with workflow and standards injection (includes conditional compilation)
                            compile_command "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" ""
                        fi
                    fi
                fi
            fi
        done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "commands")
    else
        # Process single-agent command files (only non-numbered files, with PHASE embedding)
        while read file; do
            if [[ "$file" == commands/*/single-agent/* ]] || [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
                local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
                if [[ -f "$source" ]]; then
                    # Handle orchestrate-tasks specially
                    if [[ "$file" == commands/orchestrate-tasks/orchestrate-tasks.md ]]; then
                        local dest="$PROJECT_DIR/.claude/commands/qa-agent-os/orchestrate-tasks.md"

                        if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_COMMANDS" "command"; then
                            SKIPPED_FILES+=("$dest")
                            ((commands_skipped++)) || true
                            print_verbose "Skipped: $dest"
                        else
                            if [[ -f "$dest" ]]; then
                                UPDATED_FILES+=("$dest")
                                ((commands_updated++)) || true
                                print_verbose "Updated: $dest"
                            else
                                NEW_FILES+=("$dest")
                                ((commands_new++)) || true
                                print_verbose "New file: $dest"
                            fi
                            if [[ "$DRY_RUN" != "true" ]]; then
                                compile_command "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" ""
                            fi
                        fi
                    else
                        # Only process non-numbered files
                        local filename=$(basename "$file")
                        if [[ ! "$filename" =~ ^[0-9]+-.*\.md$ ]]; then
                            local cmd_name=$(echo "$file" | sed 's|commands/\([^/]*\)/single-agent/.*|\1|')
                            local dest="$PROJECT_DIR/.claude/commands/qa-agent-os/$cmd_name.md"

                            if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_COMMANDS" "command"; then
                                SKIPPED_FILES+=("$dest")
                                ((commands_skipped++)) || true
                                print_verbose "Skipped: $dest"
                            else
                                if [[ -f "$dest" ]]; then
                                    UPDATED_FILES+=("$dest")
                                    ((commands_updated++)) || true
                                    print_verbose "Updated: $dest"
                                else
                                    NEW_FILES+=("$dest")
                                    ((commands_new++)) || true
                                    print_verbose "New file: $dest"
                                fi
                                if [[ "$DRY_RUN" != "true" ]]; then
                                    # Compile with PHASE embedding (mode="embed")
                                    compile_command "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" "embed"
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "commands")
    fi

    # Update static agents
    get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "agents" | while read file; do
        if [[ "$file" == agents/*.md ]] && [[ "$file" != agents/templates/* ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                local agent_name=$(basename "$file" .md)
                local dest="$PROJECT_DIR/.claude/agents/qa-agent-os/${agent_name}.md"

                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_AGENTS" "agent"; then
                    SKIPPED_FILES+=("$dest")
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        compile_agent "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" ""
                    fi
                fi
            fi
        fi
    done

    # Update specification agents
    get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "agents/specification" | while read file; do
        if [[ "$file" == agents/specification/*.md ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                local agent_name=$(basename "$file" .md)
                local dest="$PROJECT_DIR/.claude/agents/qa-agent-os/${agent_name}.md"

                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_AGENTS" "agent"; then
                    SKIPPED_FILES+=("$dest")
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        compile_agent "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" ""
                    fi
                fi
            fi
        fi
    done

    if [[ "$DRY_RUN" != "true" ]]; then
        # Count commands separately
        local command_pattern=".claude/commands/qa-agent-os"
        local commands_actual_updated=0
        local commands_actual_skipped=0
        local commands_actual_new=0

        for file in "${UPDATED_FILES[@]}"; do
            [[ "$file" == *"$command_pattern"* ]] && ((commands_actual_updated++)) || true
        done

        for file in "${NEW_FILES[@]}"; do
            [[ "$file" == *"$command_pattern"* ]] && ((commands_actual_new++)) || true
        done

        for file in "${SKIPPED_FILES[@]}"; do
            [[ "$file" == *"$command_pattern"* ]] && ((commands_actual_skipped++)) || true
        done

        if [[ $commands_actual_new -gt 0 ]]; then
            echo "✓ Added $commands_actual_new Claude Code commands"
        fi
        if [[ $commands_actual_updated -gt 0 ]]; then
            echo "✓ Updated $commands_actual_updated Claude Code commands"
        fi
        if [[ $commands_actual_skipped -gt 0 ]]; then
            echo -e "${YELLOW}$commands_actual_skipped commands were not updated and overwritten. To update and overwrite these, re-run with --overwrite-commands flag.${NC}"
        fi

        # Count agent files by checking SKIPPED_FILES, UPDATED_FILES, NEW_FILES
        local agent_pattern=".claude/agents/qa-agent-os"
        local agents_updated=0
        local agents_skipped=0
        local agents_new=0

        for file in "${UPDATED_FILES[@]}"; do
            [[ "$file" == *"$agent_pattern"* ]] && ((agents_updated++)) || true
        done

        for file in "${NEW_FILES[@]}"; do
            [[ "$file" == *"$agent_pattern"* ]] && ((agents_new++)) || true
        done

        for file in "${SKIPPED_FILES[@]}"; do
            [[ "$file" == *"$agent_pattern"* ]] && ((agents_skipped++)) || true
        done

        if [[ $agents_new -gt 0 ]]; then
            echo "✓ Added $agents_new Claude Code agents"
        fi
        if [[ $agents_updated -gt 0 ]]; then
            echo "✓ Updated $agents_updated Claude Code agents"
        fi
        if [[ $agents_skipped -gt 0 ]]; then
            echo -e "${YELLOW}$agents_skipped agents were not updated and overwritten. To update and overwrite these, re-run with --overwrite-agents flag.${NC}"
        fi
    fi
}

# Update agent-os folder and configuration
update_agent_os_folder() {
    print_status "Updating agent-os folder"

    # Update the configuration file
    write_project_config "$EFFECTIVE_VERSION" "$PROJECT_PROFILE" \
        "$PROJECT_CLAUDE_CODE_COMMANDS" "$PROJECT_USE_CLAUDE_CODE_SUBAGENTS" \
        "$PROJECT_AGENT_OS_COMMANDS" "$PROJECT_STANDARDS_AS_CLAUDE_CODE_SKILLS"

    if [[ "$DRY_RUN" != "true" ]]; then
        echo "✓ Updated agent-os folder"
        echo "✓ Updated agent-os project configuration"
    fi
}

# Perform update
perform_update() {
    # Display configuration at the top
    echo ""
    print_status "Configuration:"
    echo -e "  Profile: ${YELLOW}$PROJECT_PROFILE${NC}"
    echo -e "  Claude Code commands: ${YELLOW}$PROJECT_CLAUDE_CODE_COMMANDS${NC}"
    echo -e "  Use Claude Code subagents: ${YELLOW}$PROJECT_USE_CLAUDE_CODE_SUBAGENTS${NC}"
    echo -e "  Standards as Claude Code Skills: ${YELLOW}$PROJECT_STANDARDS_AS_CLAUDE_CODE_SKILLS${NC}"
    echo -e "  QA Agent OS commands: ${YELLOW}$PROJECT_AGENT_OS_COMMANDS${NC}"
    echo ""

    # Update agent-os folder and configuration
    update_agent_os_folder
    echo ""

    # Update components based on enabled flags
    update_standards
    echo ""

    # Update Claude Code files if enabled
    if [[ "$PROJECT_CLAUDE_CODE_COMMANDS" == "true" ]]; then
        if [[ "$PROJECT_USE_CLAUDE_CODE_SUBAGENTS" == "true" ]]; then
            update_claude_code_files
            echo ""
        else
            # Update commands without delegation
            # TODO: Need to implement this update function
            update_claude_code_files
            echo ""
        fi
        # Install/update Claude Code Skills (uses install function since directory was cleaned)
        install_claude_code_skills
        install_improve_skills_command
        echo ""
    fi

    # Update agent-os commands if enabled
    if [[ "$PROJECT_AGENT_OS_COMMANDS" == "true" ]]; then
        update_single_agent_commands
        echo ""
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN - No files were actually modified"
        echo ""

        if [[ ${#NEW_FILES[@]} -gt 0 ]]; then
            print_status "New files that would be added:"
            for file in "${NEW_FILES[@]}"; do
                echo "  + $file"
            done
            echo ""
        fi

        if [[ ${#UPDATED_FILES[@]} -gt 0 ]]; then
            print_status "Files that would be updated:"
            for file in "${UPDATED_FILES[@]}"; do
                echo "  ~ $file"
            done
            echo ""
        fi

        if [[ ${#SKIPPED_FILES[@]} -gt 0 ]]; then
            print_status "Files that would be skipped:"
            for file in "${SKIPPED_FILES[@]}"; do
                echo "  - $file"
            done
            echo ""
        fi

        read -p "Proceed with actual update? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            DRY_RUN="false"
            SKIPPED_FILES=()
            UPDATED_FILES=()
            NEW_FILES=()
            perform_update
        fi
    else
        print_success "QA Agent OS has been successfully updated!"
        echo ""
        echo -e "${GREEN}Visit the docs for guides on how to use QA Agent OS"
        echo ""
    fi
}

# Handle re-installation

# Handle recompilation with new config

# -----------------------------------------------------------------------------
# Migration Functions for v2.1.0
# -----------------------------------------------------------------------------

# Prompt user for update/migration - unified for all scenarios
prompt_update_confirmation() {
    local current_version=$1
    local has_version_diff=$2
    local has_config_diff=$3

    local target_version="$BASE_VERSION"

    # Determine if there are differences
    if [[ "$has_version_diff" == "true" ]] || [[ "$has_config_diff" == "true" ]]; then
        echo ""
        print_color "$PURPLE" "=== Version/Configuration Update Required ==="
        echo ""
        if [[ "$DRY_RUN" == "true" ]]; then
            print_warning "Dry run simulation"
        fi
        echo ""
        print_status "Your project's Agent OS version and/or configuration is different than the version you're trying to install."
    else
        echo ""
        print_color "$PURPLE" "=== Confirm Update ==="
        echo ""
        if [[ "$DRY_RUN" == "true" ]]; then
            print_warning "Dry run simulation"
        fi
        echo ""
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "Confirm you'd like to proceed with a DRY RUN update simulation."
        else
            print_status "Confirm you'd like to proceed with an update."
        fi
    fi
    echo ""

    # Display current project config
    print_status "Current project's Agent OS:"
    if [[ -n "$current_version" ]]; then
        echo "  Version: $current_version"
    else
        echo "  Version: (not specified)"
    fi

    # Show old config values if they exist
    if [[ -n "${MULTI_AGENT_MODE:-}" ]] || [[ -n "${SINGLE_AGENT_MODE:-}" ]] || [[ -n "${MULTI_AGENT_TOOL:-}" ]]; then
        echo "  Config format: Legacy (multi_agent_mode, single_agent_mode, multi_agent_tool)"
    elif [[ -n "$PROJECT_CLAUDE_CODE_COMMANDS" ]]; then
        echo "  Profile: ${PROJECT_PROFILE:-default}"
        echo "  Claude Code commands: ${PROJECT_CLAUDE_CODE_COMMANDS:-false}"
        echo "  Use Claude Code subagents: ${PROJECT_USE_CLAUDE_CODE_SUBAGENTS:-false}"
        echo "  Agent OS commands: ${PROJECT_AGENT_OS_COMMANDS:-false}"
        echo "  Standards as Claude Code Skills: ${PROJECT_STANDARDS_AS_CLAUDE_CODE_SKILLS:-false}"
    else
        echo "  Config: Unable to read current configuration"
    fi
    echo ""

    # Display incoming config
    print_status "Incoming Agent OS:"
    echo "  Version: $target_version"
    echo "  Profile: $EFFECTIVE_PROFILE"
    echo "  Claude Code commands: $EFFECTIVE_CLAUDE_CODE_COMMANDS"
    echo "  Use Claude Code subagents: $EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS"
    echo "  Agent OS commands: $EFFECTIVE_AGENT_OS_COMMANDS"
    echo "  Standards as Claude Code Skills: $EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS"
    echo ""

    # Show what will happen
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "Here's what WOULD happen if this were a real update (but it's a DRY RUN):"
    else
        print_status "Here's what will happen if you proceed:"
    fi
    echo ""
    echo -e "${GREEN}✔ These will remain intact:${NC}"
    echo ""
    echo "  - agent-os/features/*"
    echo "  - agent-os/product/*"
    echo ""
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}⚠️  These WOULD BE deleted and re-installed to match the new version and configurations if this were a real update (but it's a DRY RUN):${NC}"
    else
        echo -e "${YELLOW}⚠️  These will be deleted and re-installed to match the new version and configurations:${NC}"
    fi
    echo ""
    echo "  - agent-os/config.yml"
    echo "  - agent-os/standards/"
    if [[ "$EFFECTIVE_AGENT_OS_COMMANDS" == "true" ]] || [[ -d "$PROJECT_DIR/qa-agent-os/commands" ]]; then
        echo "  - agent-os/commands/"
    fi
    if [[ "$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS" == "true" ]] || [[ -d "$PROJECT_DIR/.claude/agents/qa-agent-os" ]]; then
        echo "  - .claude/agents/qa-agent-os/"
    fi
    if [[ "$EFFECTIVE_CLAUDE_CODE_COMMANDS" == "true" ]] || [[ -d "$PROJECT_DIR/.claude/commands/qa-agent-os" ]]; then
        echo "  - .claude/commands/qa-agent-os/"
    fi
    if [[ "$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS" == "true" ]] || [[ -d "$PROJECT_DIR/.claude/skills" ]]; then
        echo "  - .claude/skills/ (Agent OS skills)"
    fi
    echo ""

    read -p "Do you want to proceed? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0  # user confirmed
    else
        return 1  # user declined
    fi
}

# Perform cleanup before update - delete everything except features/ and product/
perform_update_cleanup() {
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "Dry run: Would prepare for update..."
        echo ""
    else
        print_status "Preparing for update..."
        echo ""
    fi

    # Delete agent-os/standards/ (will be reinstalled)
    if [[ -d "$PROJECT_DIR/qa-agent-os/standards" ]]; then
        print_status "Removing agent-os/standards/"
        if [[ "$DRY_RUN" != "true" ]]; then
            rm -rf "$PROJECT_DIR/qa-agent-os/standards"
        fi
    fi

    # Delete agent-os/commands/ if exists
    if [[ -d "$PROJECT_DIR/qa-agent-os/commands" ]]; then
        print_status "Removing agent-os/commands/"
        if [[ "$DRY_RUN" != "true" ]]; then
            rm -rf "$PROJECT_DIR/qa-agent-os/commands"
        fi
    fi

    # Delete .claude/agents/qa-agent-os/ if exists
    if [[ -d "$PROJECT_DIR/.claude/agents/qa-agent-os" ]]; then
        print_status "Removing .claude/agents/qa-agent-os/"
        if [[ "$DRY_RUN" != "true" ]]; then
            rm -rf "$PROJECT_DIR/.claude/agents/qa-agent-os"
        fi
    fi

    # Delete .claude/commands/qa-agent-os/ if exists
    if [[ -d "$PROJECT_DIR/.claude/commands/qa-agent-os" ]]; then
        print_status "Removing .claude/commands/qa-agent-os/"
        if [[ "$DRY_RUN" != "true" ]]; then
            rm -rf "$PROJECT_DIR/.claude/commands/qa-agent-os"
        fi
    fi

    # Delete old .claude/skills/qa-agent-os/ if exists (legacy location)
    if [[ -d "$PROJECT_DIR/.claude/skills/qa-agent-os" ]]; then
        print_status "Removing legacy .claude/skills/qa-agent-os/"
        if [[ "$DRY_RUN" != "true" ]]; then
            rm -rf "$PROJECT_DIR/.claude/skills/qa-agent-os"
        fi
    fi

    # Delete individual Agent OS skills (new location: .claude/skills/[skill-name]/)
    # Find all skills that match standards files from the profile
    if [[ -d "$PROJECT_DIR/.claude/skills" ]]; then
        while read file; do
            if [[ "$file" == standards/* ]] && [[ "$file" == *.md ]]; then
                local skill_name=$(echo "$file" | sed 's|^standards/||' | sed 's|\.md$||' | sed 's|/|-|g')
                if [[ -d "$PROJECT_DIR/.claude/skills/$skill_name" ]]; then
                    print_status "Removing .claude/skills/$skill_name/"
                    if [[ "$DRY_RUN" != "true" ]]; then
                        rm -rf "$PROJECT_DIR/.claude/skills/$skill_name"
                    fi
                fi
            fi
        done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "standards")
    fi

    # Delete agent-os/roles/ if exists (legacy)
    if [[ -d "$PROJECT_DIR/qa-agent-os/roles" ]]; then
        print_status "Removing legacy agent-os/roles/"
        if [[ "$DRY_RUN" != "true" ]]; then
            rm -rf "$PROJECT_DIR/qa-agent-os/roles"
        fi
    fi

    echo ""
    if [[ "$DRY_RUN" == "true" ]]; then
        print_success "Dry run: Cleanup would be complete!"
    else
        print_success "Cleanup complete!"
    fi
    echo ""
    print_status "Proceeding with update..."
    echo ""
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    # Parse command line arguments
    parse_arguments "$@"

    # Check if we're trying to update in the base installation directory
    check_not_base_installation

    # Validate installations
    validate_installations

    # Load configurations
    load_configurations

    # Check for version differences
    local has_version_diff="false"
    if [[ "$PROJECT_VERSION" != "$BASE_VERSION" ]] || check_needs_migration "$PROJECT_VERSION"; then
        has_version_diff="true"
    fi

    # Check for config differences
    local has_config_diff="false"
    if [[ "$PROJECT_PROFILE" != "$EFFECTIVE_PROFILE" ]] || \
       [[ "$PROJECT_CLAUDE_CODE_COMMANDS" != "$EFFECTIVE_CLAUDE_CODE_COMMANDS" ]] || \
       [[ "$PROJECT_USE_CLAUDE_CODE_SUBAGENTS" != "$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS" ]] || \
       [[ "$PROJECT_AGENT_OS_COMMANDS" != "$EFFECTIVE_AGENT_OS_COMMANDS" ]] || \
       [[ "$PROJECT_STANDARDS_AS_CLAUDE_CODE_SKILLS" != "$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS" ]]; then
        has_config_diff="true"
    fi

    # Always prompt for confirmation (whether there are differences or not)
    if prompt_update_confirmation "$PROJECT_VERSION" "$has_version_diff" "$has_config_diff"; then
        # User confirmed - show any config validation warnings
        echo ""
        validate_config "$EFFECTIVE_CLAUDE_CODE_COMMANDS" "$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS" "$EFFECTIVE_AGENT_OS_COMMANDS" "$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS" "$EFFECTIVE_PROFILE" "true"
        echo ""

        # Perform cleanup and update
        perform_update_cleanup

        # Set PROJECT_* variables to match EFFECTIVE_* for perform_update to use
        PROJECT_PROFILE="$EFFECTIVE_PROFILE"
        PROJECT_CLAUDE_CODE_COMMANDS="$EFFECTIVE_CLAUDE_CODE_COMMANDS"
        PROJECT_USE_CLAUDE_CODE_SUBAGENTS="$EFFECTIVE_USE_CLAUDE_CODE_SUBAGENTS"
        PROJECT_AGENT_OS_COMMANDS="$EFFECTIVE_AGENT_OS_COMMANDS"
        PROJECT_STANDARDS_AS_CLAUDE_CODE_SKILLS="$EFFECTIVE_STANDARDS_AS_CLAUDE_CODE_SKILLS"

        # Proceed with update
        perform_update
        exit 0
    else
        print_status "Update cancelled by user"
        exit 0
    fi
}

# Run main function
main "$@"
