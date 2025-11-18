#!/bin/bash

# QA Agent OS Base Installation Script
# Installs QA Agent OS from GitHub repository to ~/qa-agent-os

set -e

# Repository configuration
REPO_URL="https://github.com/figuedmundo/qa-agent-os"

# Installation paths
BASE_DIR="$HOME/qa-agent-os"
TEMP_DIR=$(mktemp -d)
COMMON_FUNCTIONS_TEMP="$TEMP_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Bootstrap Functions (before common-functions.sh is available)
# -----------------------------------------------------------------------------

# Minimal color codes for bootstrap
BLUE='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Bootstrap print functions
bootstrap_print() {
    echo -e "${BLUE}$1${NC}"
}

bootstrap_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Download common-functions.sh first
download_common_functions() {
    local functions_url="${REPO_URL}/raw/main/scripts/common-functions.sh"

    if curl -sL --fail "$functions_url" -o "$COMMON_FUNCTIONS_TEMP"; then
        # Source the common functions
        source "$COMMON_FUNCTIONS_TEMP"
        return 0
    else
        bootstrap_error "Failed to download common-functions.sh"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Initialize common functions
# -----------------------------------------------------------------------------

bootstrap_print "Initializing..."
download_common_functions

# Clean up temp directory on exit and restore cursor
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    # Always restore cursor on exit
    tput cnorm 2>/dev/null || true
}
trap cleanup EXIT

# -----------------------------------------------------------------------------
# Version Functions
# -----------------------------------------------------------------------------

# Get latest version from GitHub
get_latest_version() {
    local config_url="${REPO_URL}/raw/main/config.yml"
    curl -sL "$config_url" | grep "^version:" | sed 's/version: *//' | tr -d '\r\n'
}

# -----------------------------------------------------------------------------
# Download Functions
# -----------------------------------------------------------------------------

# Download file from GitHub
download_file() {
    local relative_path=$1
    local dest_path=$2
    local file_url="${REPO_URL}/raw/main/${relative_path}"

    mkdir -p "$(dirname "$dest_path")"

    if curl -sL --fail "$file_url" -o "$dest_path"; then
        return 0
    else
        return 1
    fi
}

# Define exclusion patterns
EXCLUSIONS=(
    "scripts/base-install.sh"
    "old-versions/*"
    ".git*"
    ".github/*"
)

# Check if a file should be excluded
should_exclude() {
    local file_path=$1

    for pattern in "${EXCLUSIONS[@]}"; do
        # Check exact match
        if [[ "$file_path" == "$pattern" ]]; then
            return 0
        fi
        # Check wildcard patterns
        if [[ "$pattern" == *"*"* ]]; then
            local prefix="${pattern%\*}"
            if [[ "$file_path" == "$prefix"* ]]; then
                return 0
            fi
        fi
    done

    return 1
}

# Get all files from GitHub repo using the tree API
get_all_repo_files() {
    # Get the default branch (usually main or master)
    local branch="main"

    # Extract owner and repo name from URL
    # From: https://github.com/owner/repo to owner/repo
    local repo_path=$(echo "$REPO_URL" | sed 's|^https://github.com/||')

    print_verbose "Repository path: $repo_path"

    # Build API URL
    local tree_url="https://api.github.com/repos/${repo_path}/git/trees/${branch}?recursive=true"

    print_verbose "Fetching from: $tree_url"

    local response=$(curl -sL "$tree_url")

    # Check if we got a valid response
    if [[ -z "$response" ]]; then
        print_verbose "Empty response from GitHub API"
        return 1
    fi

    # Debug: Show first 500 chars of response
    print_verbose "Response preview: ${response:0:500}"

    if echo "$response" | grep -q '"message"'; then
        local error_msg=$(echo "$response" | grep -o '"message":"[^"]*"' | sed 's/"message":"//' | sed 's/"$//')
        print_verbose "GitHub API error: $error_msg"
        return 1
    fi

    # Check if we have tree data (use grep -c to avoid broken pipe)
    if [[ $(echo "$response" | grep -c '"tree"' 2>/dev/null || true) -eq 0 ]]; then
        print_verbose "No tree data in response"
        return 1
    fi

    # Use jq if available, otherwise use python
    if command -v jq &> /dev/null; then
        print_verbose "Using jq to parse JSON"
        echo "$response" | jq -r '.tree[] | select(.type=="blob") | .path' | while read -r file_path; do
            if ! should_exclude "$file_path"; then
                echo "$file_path"
            fi
        done
    elif command -v python3 &> /dev/null; then
        print_verbose "Using python to parse JSON"
        echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data.get('tree', []):
    if item.get('type') == 'blob':
        print(item.get('path', ''))
" | while read -r file_path; do
            if [[ -n "$file_path" ]] && ! should_exclude "$file_path"; then
                echo "$file_path"
            fi
        done
    else
        print_verbose "Using sed/awk to parse JSON (less reliable)"
        # Parse JSON using sed and awk - less reliable but works for simple cases
        echo "$response" | awk -F'"' '/"type":"blob"/{blob=1} blob && /"path":/{print $4; blob=0}' | while read -r file_path; do
            if ! should_exclude "$file_path"; then
                echo "$file_path"
            fi
        done
    fi
}

# Download all files from the repository
download_all_files() {
    local dest_base=$1
    local file_count=0

    print_verbose "Fetching repository file list..."

    # Get list of all files (excluding our exclusion list)
    local all_files=$(get_all_repo_files)

    if [[ -z "$all_files" ]]; then
        echo "0"  # Return 0 to indicate no files downloaded
        return 1
    fi

    # Download each file (using process substitution to avoid subshell variable issue)
    while IFS= read -r file_path; do
        if [[ -n "$file_path" ]]; then
            local dest_file="${dest_base}/${file_path}"

            # Create directory if needed
            local dir_path=$(dirname "$dest_file")
            [[ -d "$dir_path" ]] || mkdir -p "$dir_path"

            if download_file "$file_path" "$dest_file"; then
                ((file_count++)) || true
                print_verbose "  Downloaded: ${file_path}"
            else
                print_verbose "  Failed to download: ${file_path}"
            fi
        fi
    done <<< "$all_files"

    echo "$file_count"
}

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

# Print status message without newline
print_status_no_newline() {
    echo -ne "${BLUE}$1${NC}"
}

# Animated spinner for long-running operations
spinner() {
    local delay=0.5
    while true; do
        for dot_count in "" "." ".." "..."; do
            echo -ne "\r${BLUE}Installing Agent OS files${dot_count}${NC}   "
            sleep $delay
        done
    done
}

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------

# Install all files from repository
install_all_files() {
    if [[ "$DRY_RUN" != "true" ]]; then
        # Start spinner in background
        spinner_pid=""
        if [[ "$VERBOSE" != "true" ]]; then
            # Hide cursor before starting spinner
            tput civis 2>/dev/null || true
            spinner &
            spinner_pid=$!
        else
            print_status "Installing QA Agent OS files..."
        fi
    fi

    # Download all files (excluding those in exclusion list)
    local file_count
    file_count=$(download_all_files "$BASE_DIR")
    local download_status=$?

    # Stop spinner if running
    if [[ -n "$spinner_pid" ]]; then
        kill $spinner_pid 2>/dev/null
        wait $spinner_pid 2>/dev/null
        # Clear the line and restore cursor
        echo -ne "\r\033[K"
        tput cnorm 2>/dev/null || true  # Show cursor again
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $download_status -eq 0 && $file_count -gt 0 ]]; then
            echo "✓ Installed $file_count files to ~/qa-agent-os"
        else
            print_error "No files were downloaded"
            return 1
        fi
    fi

    # Make scripts executable
    if [[ -d "$BASE_DIR/scripts" ]]; then
        chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Overwrite Functions
# -----------------------------------------------------------------------------

# Prompt for overwrite choice
prompt_overwrite_choice() {
    local current_version=$1
    local latest_version=$2

    echo ""
    echo -e "${YELLOW}=== ⚠️  Existing Installation Detected ===${NC}"
    echo ""

    echo "You already have a base installation of QA Agent OS"

    if [[ -n "$current_version" ]]; then
        echo -e "  Your installed version: ${YELLOW}$current_version${NC}"
    else
        echo "  Your installed version: (unknown)"
    fi

    if [[ -n "$latest_version" ]]; then
        echo -e "  Latest available version: ${YELLOW}$latest_version${NC}"
    else
        echo "  Latest available version: (unable to determine)"
    fi

    echo ""
    print_status "What would you like to do?"
    echo ""

    echo -e "${YELLOW}1) Full update${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/qa-agent-os/profiles/default/*"
    echo "    - ~/qa-agent-os/scripts/*"
    echo "    - ~/qa-agent-os/CHANGELOG.md"
    echo ""
    echo "    Updates your version number in ~/qa-agent-os/config.yml but doesn't change anything else in this file."
    echo ""
    echo "    Everything else in your ~/qa-agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}2) Update default profile only${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/qa-agent-os/profiles/default/*"
    echo ""
    echo "    Everything else in your ~/qa-agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}3) Update scripts only${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/qa-agent-os/scripts/*"
    echo ""
    echo "    Everything else in your ~/qa-agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}4) Update config.yml only${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/qa-agent-os/config.yml"
    echo ""
    echo "    Everything else in your ~/qa-agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}5) Delete & reinstall fresh${NC}"
    echo ""
    echo "    - Makes a backup of your current ~/qa-agent-os folder at ~/qa-agent-os.backup"
    echo "    - Deletes your current ~/qa-agent-os folder and all of its contents."
    echo "    - Installs a fresh ~/qa-agent-os base installation"
    echo ""

    echo -e "${YELLOW}6) Cancel and abort${NC}"
    echo ""

    read -p "Enter your choice (1-6): " choice < /dev/tty

    case $choice in
        1)
            echo ""
            print_status "Performing full update..."
            full_update "$latest_version"
            ;;
        2)
            echo ""
            print_status "Updating default profile..."
            create_backup
            overwrite_profile
            ;;
        3)
            echo ""
            print_status "Updating scripts..."
            create_backup
            overwrite_scripts
            ;;
        4)
            echo ""
            print_status "Updating config.yml..."
            create_backup
            overwrite_config
            ;;
        5)
            echo ""
            print_status "Deleting & reinstalling fresh..."
            overwrite_all
            ;;
        6)
            echo ""
            print_warning "Installation cancelled"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Installation cancelled."
            exit 1
            ;;
    esac
}

# Create backup of existing installation
create_backup() {
    # Backup existing installation
    if [[ -d "$BASE_DIR.backup" ]]; then
        rm -rf "$BASE_DIR.backup"
    fi
    cp -R "$BASE_DIR" "$BASE_DIR.backup"
    echo "✓ Backed up existing installation to ~/qa-agent-os.backup"
    echo ""
}

# Full update - updates profile, scripts, CHANGELOG.md, and version number in config.yml
full_update() {
    local latest_version=$1

    # Create backup first
    create_backup

    # Update default profile
    print_status "Updating default profile..."
    rm -rf "$BASE_DIR/profiles/default"
    local file_count=0
    local all_files=$(get_all_repo_files | grep "^profiles/default/")
    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"
                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Downloaded: ${file_path}"
                fi
            fi
        done <<< "$all_files"
    fi
    echo "✓ Updated default profile ($file_count files)"
    echo ""

    # Update scripts
    print_status "Updating scripts..."
    rm -rf "$BASE_DIR/scripts"
    file_count=0
    all_files=$(get_all_repo_files | grep "^scripts/")
    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"
                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Downloaded: ${file_path}"
                fi
            fi
        done <<< "$all_files"
        chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    fi
    echo "✓ Updated scripts ($file_count files)"
    echo ""

    # Update CHANGELOG.md
    print_status "Updating CHANGELOG.md..."
    if download_file "CHANGELOG.md" "$BASE_DIR/CHANGELOG.md"; then
        echo "✓ Updated CHANGELOG.md"
    fi
    echo ""

    # Update version number in config.yml (without overwriting the entire file)
    print_status "Updating version number in config.yml..."
    if [[ -f "$BASE_DIR/config.yml" ]] && [[ -n "$latest_version" ]]; then
        # Use sed to update only the version line
        sed -i.bak "s/^version:.*/version: $latest_version/" "$BASE_DIR/config.yml"
        rm -f "$BASE_DIR/config.yml.bak"
        echo "✓ Updated version to $latest_version in config.yml"
    fi
    echo ""

    print_success "Full update completed!"
}

# Overwrite everything
overwrite_all() {
    # Backup existing installation
    if [[ -d "$BASE_DIR.backup" ]]; then
        rm -rf "$BASE_DIR.backup"
    fi
    mv "$BASE_DIR" "$BASE_DIR.backup"
    echo "✓ Backed up existing installation to ~/qa-agent-os.backup"
    echo ""

    # Perform fresh installation
    perform_fresh_installation
}

# Overwrite only profile
overwrite_profile() {
    # Remove existing default profile
    rm -rf "$BASE_DIR/profiles/default"

    # Download only profile files
    local file_count=0

    # Get all files and filter for profiles/default
    local all_files=$(get_all_repo_files | grep "^profiles/default/")

    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"

                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Downloaded: ${file_path}"
                fi
            fi
        done <<< "$all_files"
    fi

    echo "✓ Updated default profile ($file_count files)"
    echo ""
    print_success "Default profile has been updated!"
}

# Overwrite only scripts
overwrite_scripts() {
    # Remove existing scripts
    rm -rf "$BASE_DIR/scripts"

    # Download only script files
    local file_count=0

    # Get all files and filter for scripts/
    local all_files=$(get_all_repo_files | grep "^scripts/")

    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"

                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Downloaded: ${file_path}"
                fi
            fi
        done <<< "$all_files"

        # Make scripts executable
        chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    fi

    echo "✓ Updated scripts ($file_count files)"
    echo ""
    print_success "Scripts have been updated!"
}

# Overwrite only config
overwrite_config() {
    # Download new config.yml
    if download_file "config.yml" "$BASE_DIR/config.yml"; then
        print_verbose "  Downloaded: config.yml"
    fi

    echo "✓ Updated config.yml"
    echo ""
    print_success "Config has been updated!"
}

# -----------------------------------------------------------------------------
# Main Installation Functions
# -----------------------------------------------------------------------------

# Perform fresh installation
perform_fresh_installation() {
    echo ""
    print_status "Configuration:"
    echo -e "  Repository: ${YELLOW}${REPO_URL}${NC}"
    echo -e "  Target: ${YELLOW}~/qa-agent-os${NC}"
    echo ""

    # Create base directory
    ensure_dir "$BASE_DIR"
    echo "✓ Created base directory: ~/qa-agent-os"
    echo ""

    # Install all files from repository
    if ! install_all_files; then
        print_error "Installation failed"
        exit 1
    fi

    echo ""
    print_success "Agent OS has been successfully installed!"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo ""
    echo -e "${GREEN}1) Customize your profile's standards in ~/qa-agent-os/profiles/default/standards${NC}"
    echo ""
    echo -e "${GREEN}2) Navigate to a project directory${NC}"
    echo -e "   ${YELLOW}cd path/to/project-directory${NC}"
    echo ""
    echo -e "${GREEN}3) Install Agent OS in your project by running:${NC}"
    echo -e "   ${YELLOW}~/qa-agent-os/scripts/project-install.sh${NC}"
    echo ""
    echo -e "${GREEN}Visit the docs for guides on how to use Agent OS: https://buildermethods.com/qa-agent-os${NC}"
    echo ""
}

# Check for existing installation
check_existing_installation() {
    if [[ -d "$BASE_DIR" ]]; then
        # Get current version if available
        local current_version=""
        if [[ -f "$BASE_DIR/config.yml" ]]; then
            current_version=$(get_yaml_value "$BASE_DIR/config.yml" "version" "")
        fi

        # Get latest version from GitHub
        local latest_version=$(get_latest_version)

        # Prompt for overwrite choice
        prompt_overwrite_choice "$current_version" "$latest_version"
    else
        # Fresh installation
        perform_fresh_installation
    fi
}

# -----------------------------------------------------------------------------
# Global Variables
# -----------------------------------------------------------------------------

VERBOSE=false
DRY_RUN=false

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    print_section "Agent OS Base Installation"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -v, --verbose    Show verbose output"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done

    # Check for curl
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed. Please install curl and try again."
        exit 1
    fi

    # Check for existing installation or perform fresh install
    check_existing_installation
}

# Run main function
main "$@"
