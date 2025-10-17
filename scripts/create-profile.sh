#!/bin/bash

# =============================================================================
# Agent OS Create Profile Script
# Creates a new profile for Agent OS
# =============================================================================

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="${BASE_DIR:-$HOME/agent-os}"
PROFILES_DIR="$BASE_DIR/profiles"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Default Values
# -----------------------------------------------------------------------------

PROFILE_NAME=""
INHERIT_FROM=""
COPY_FROM=""
NON_INTERACTIVE=false

# -----------------------------------------------------------------------------
# Validation Functions
# -----------------------------------------------------------------------------

validate_installation() {
    # Check base installation
    validate_base_installation

    if [[ ! -d "$PROFILES_DIR" ]]; then
        print_error "Profiles directory not found at $PROFILES_DIR"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Profile Functions
# -----------------------------------------------------------------------------

get_available_profiles() {
    local profiles=()

    # Find all directories in profiles/
    for dir in "$PROFILES_DIR"/*; do
        if [[ -d "$dir" ]]; then
            profiles+=("$(basename "$dir")")
        fi
    done

    echo "${profiles[@]}"
}

# -----------------------------------------------------------------------------
# Profile Name Input
# -----------------------------------------------------------------------------

get_profile_name() {
    local valid=false

    while [[ "$valid" == "false" ]]; do
        echo ""
        echo ""
        echo ""
        print_status "Enter a name for the new profile:"
        echo "Example names: 'rails', 'python', 'react', 'wordpress'"
        echo ""

        read -p "$(echo -e "${BLUE}Profile name: ${NC}")" profile_input

        # Normalize the name
        PROFILE_NAME=$(normalize_name "$profile_input")

        if [[ -z "$PROFILE_NAME" ]]; then
            print_error "Profile name cannot be empty"
            continue
        fi

        # Check if profile already exists
        if [[ -d "$PROFILES_DIR/$PROFILE_NAME" ]]; then
            print_error "Profile '$PROFILE_NAME' already exists"
            echo "Please choose a different name"
            continue
        fi

        valid=true
        print_success "Profile name set to: $PROFILE_NAME"
    done
}

# -----------------------------------------------------------------------------
# Inheritance Selection
# -----------------------------------------------------------------------------

select_inheritance() {
    local profiles=($(get_available_profiles))

    if [[ ${#profiles[@]} -eq 0 ]]; then
        print_warning "No existing profiles found to inherit from"
        INHERIT_FROM=""
        return
    fi

    echo ""
    echo ""
    echo ""

    if [[ ${#profiles[@]} -eq 1 ]]; then
        # Only one profile exists
        print_status "Should this profile inherit from the '${profiles[0]}' profile?"
        echo ""
        read -p "$(echo -e "${BLUE}Inherit from '${profiles[0]}'? (y/n): ${NC}")" inherit_choice

        if [[ "$inherit_choice" == "y" ]] || [[ "$inherit_choice" == "Y" ]]; then
            INHERIT_FROM="${profiles[0]}"
            print_success "Profile will inherit from: $INHERIT_FROM"
        else
            INHERIT_FROM=""
            print_status "Profile will not inherit from any profile"
        fi
    else
        # Multiple profiles exist
        print_status "Select a profile to inherit from:"
        echo ""
        echo "  1) Don't inherit from any profile"

        local index=2
        for profile in "${profiles[@]}"; do
            echo "  $index) $profile"
            ((index++))
        done

        echo ""
        read -p "$(echo -e "${BLUE}Enter selection (1-$((${#profiles[@]}+1))): ${NC}")" selection

        if [[ "$selection" == "1" ]]; then
            INHERIT_FROM=""
            print_status "Profile will not inherit from any profile"
        elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 2 ]] && [[ "$selection" -le $((${#profiles[@]}+1)) ]]; then
            INHERIT_FROM="${profiles[$((selection-2))]}"
            print_success "Profile will inherit from: $INHERIT_FROM"
        else
            print_error "Invalid selection"
            exit 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# Copy Selection
# -----------------------------------------------------------------------------

select_copy_source() {
    # Only ask about copying if not inheriting
    if [[ -n "$INHERIT_FROM" ]]; then
        COPY_FROM=""
        return
    fi

    local profiles=($(get_available_profiles))

    if [[ ${#profiles[@]} -eq 0 ]]; then
        print_warning "No existing profiles found to copy from"
        COPY_FROM=""
        return
    fi

    echo ""
    echo ""
    echo ""

    if [[ ${#profiles[@]} -eq 1 ]]; then
        # Only one profile exists
        print_status "Do you want to copy the contents from the '${profiles[0]}' profile?"
        echo ""
        read -p "$(echo -e "${BLUE}Copy from '${profiles[0]}'? (y/n): ${NC}")" copy_choice

        if [[ "$copy_choice" == "y" ]] || [[ "$copy_choice" == "Y" ]]; then
            COPY_FROM="${profiles[0]}"
            print_success "Will copy contents from: $COPY_FROM"
        else
            COPY_FROM=""
            print_status "Will create empty profile structure"
        fi
    else
        # Multiple profiles exist
        print_status "Select a profile to copy from:"
        echo ""
        echo "  1) Don't copy from any profile"

        local index=2
        for profile in "${profiles[@]}"; do
            echo "  $index) $profile"
            ((index++))
        done

        echo ""
        read -p "$(echo -e "${BLUE}Enter selection (1-$((${#profiles[@]}+1))): ${NC}")" selection

        if [[ "$selection" == "1" ]]; then
            COPY_FROM=""
            print_status "Will create empty profile structure"
        elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 2 ]] && [[ "$selection" -le $((${#profiles[@]}+1)) ]]; then
            COPY_FROM="${profiles[$((selection-2))]}"
            print_success "Will copy contents from: $COPY_FROM"
        else
            print_error "Invalid selection"
            exit 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# Profile Creation
# -----------------------------------------------------------------------------

create_profile_structure() {
    local profile_path="$PROFILES_DIR/$PROFILE_NAME"

    print_status "Creating profile structure..."

    if [[ -n "$COPY_FROM" ]]; then
        # Copy from existing profile
        print_status "Copying from profile: $COPY_FROM"
        cp -r "$PROFILES_DIR/$COPY_FROM" "$profile_path"

        # Update profile-config.yml
        cat > "$profile_path/profile-config.yml" << EOF
inherits_from: false

# Profile configuration for $PROFILE_NAME
# Copied from: $COPY_FROM
EOF

        print_success "Profile copied and configured"

    else
        # Create new structure
        mkdir -p "$profile_path"

        # Create standard directories
        mkdir -p "$profile_path/standards/"
        mkdir -p "$profile_path/workflows/implementation"
        mkdir -p "$profile_path/workflows/planning"
        mkdir -p "$profile_path/workflows/specification"

        # Create profile-config.yml
        if [[ -n "$INHERIT_FROM" ]]; then
            cat > "$profile_path/profile-config.yml" << EOF
inherits_from: $INHERIT_FROM

# Uncomment and modify to exclude specific inherited files:
# exclude_inherited_files:
#   - standards/backend/api/*
#   - standards/backend/database/migrations.md
#   - workflows/implementation/specific-workflow.md
EOF
        else
            cat > "$profile_path/profile-config.yml" << EOF
inherits_from: false

# Profile configuration for $PROFILE_NAME
EOF
        fi

        print_success "Profile structure created"
    fi
}

# -----------------------------------------------------------------------------
# Help Message
# -----------------------------------------------------------------------------

show_help() {
    cat << EOF
Usage: create-profile.sh [OPTIONS]

Create a new Agent OS profile with custom standards, roles, and workflows.

OPTIONS:
    --name NAME              Profile name (required in non-interactive mode)
    --inherit-from PROFILE   Inherit from existing profile (e.g., 'default')
    --copy-from PROFILE      Copy structure from existing profile
    --base-dir PATH          Base directory for Agent OS (default: $HOME/agent-os)
    --non-interactive        Run without prompts (requires --name)
    -h, --help              Show this help message

EXAMPLES:
    # Interactive mode (default)
    ./create-profile.sh

    # Non-interactive with inheritance
    ./create-profile.sh --name rails-api --inherit-from default --non-interactive

    # Non-interactive with copy
    ./create-profile.sh --name python-ml --copy-from default --non-interactive

    # Non-interactive standalone
    ./create-profile.sh --name wordpress --non-interactive

NOTES:
    - Profile names are normalized (lowercase, hyphens)
    - Cannot use both --inherit-from and --copy-from
    - In non-interactive mode, defaults to standalone if no inheritance specified

EOF
}

# -----------------------------------------------------------------------------
# Argument Parsing
# -----------------------------------------------------------------------------

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                PROFILE_NAME="$2"
                shift 2
                ;;
            --inherit-from)
                INHERIT_FROM="$2"
                shift 2
                ;;
            --copy-from)
                COPY_FROM="$2"
                shift 2
                ;;
            --base-dir)
                BASE_DIR="$2"
                PROFILES_DIR="$BASE_DIR/profiles"
                shift 2
                ;;
            --non-interactive)
                NON_INTERACTIVE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    # Validate non-interactive requirements
    if [[ "$NON_INTERACTIVE" == true ]]; then
        if [[ -z "$PROFILE_NAME" ]]; then
            print_error "Non-interactive mode requires --name"
            echo "Use --help for usage information"
            exit 1
        fi

        if [[ -n "$INHERIT_FROM" && -n "$COPY_FROM" ]]; then
            print_error "Cannot use both --inherit-from and --copy-from"
            exit 1
        fi

        # Normalize the profile name
        PROFILE_NAME=$(normalize_name "$PROFILE_NAME")

        # Check if profile already exists
        if [[ -d "$PROFILES_DIR/$PROFILE_NAME" ]]; then
            print_error "Profile '$PROFILE_NAME' already exists"
            exit 1
        fi

        # Validate inherit-from profile exists
        if [[ -n "$INHERIT_FROM" && ! -d "$PROFILES_DIR/$INHERIT_FROM" ]]; then
            print_error "Profile to inherit from does not exist: $INHERIT_FROM"
            exit 1
        fi

        # Validate copy-from profile exists
        if [[ -n "$COPY_FROM" && ! -d "$PROFILES_DIR/$COPY_FROM" ]]; then
            print_error "Profile to copy from does not exist: $COPY_FROM"
            exit 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    # Parse command line arguments
    parse_arguments "$@"

    if [[ "$NON_INTERACTIVE" == false ]]; then
        clear
    fi

    echo ""
    echo -e "${BLUE}=== Agent OS - Create Profile Utility ===${NC}"
    echo ""

    # Validate installation
    validate_installation

    # Interactive mode: prompt for inputs
    if [[ "$NON_INTERACTIVE" == false ]]; then
        # Get profile name
        get_profile_name

        # Select inheritance
        select_inheritance

        # Select copy source (if not inheriting)
        select_copy_source
    else
        # Non-interactive mode: use provided values
        print_status "Creating profile in non-interactive mode..."
        echo ""
        print_status "Profile name: $PROFILE_NAME"

        if [[ -n "$INHERIT_FROM" ]]; then
            print_status "Inheriting from: $INHERIT_FROM"
        elif [[ -n "$COPY_FROM" ]]; then
            print_status "Copying from: $COPY_FROM"
        else
            print_status "Creating standalone profile"
        fi
        echo ""
    fi

    # Create the profile
    create_profile_structure

    # Success message
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo ""
    print_success "Profile '$PROFILE_NAME' has been successfully created!"
    echo ""
    print_status "Location: $PROFILES_DIR/$PROFILE_NAME"

    if [[ -n "$INHERIT_FROM" ]]; then
        echo ""
        print_status "This profile inherits from: $INHERIT_FROM"
    elif [[ -n "$COPY_FROM" ]]; then
        echo ""
        print_status "This profile was copied from: $COPY_FROM"
    fi

    echo ""
    print_status "Next steps:"
    echo "  1. Customize standards, workflows, and configurations in your profile"
    echo "  2. Use ~/agent-os/scripts/create-role.sh to add agent roles to this profile"
    echo "  3. Install Agent OS in a project using this profile with: ~/agent-os/scripts/project-install.sh --profile $PROFILE_NAME"
    echo ""
    echo -e "${GREEN}Visit the docs on customizing your profile: https://buildermethods.com/agent-os/profiles${NC}"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo ""
}

# Run main function with all arguments
main "$@"
