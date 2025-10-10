#!/bin/bash

# Agent OS Project Installation Script
# This script installs Agent OS in a project directory with embedded instructions

set -e  # Exit on error

# Initialize flags
NO_BASE=false
OVERWRITE_INSTRUCTIONS=false
OVERWRITE_STANDARDS=false
CLAUDE_CODE=false
CURSOR=false
PROJECT_TYPE=""
WITH_HOOKS=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-base)
            NO_BASE=true
            shift
            ;;
        --overwrite-instructions)
            OVERWRITE_INSTRUCTIONS=true
            shift
            ;;
        --overwrite-standards)
            OVERWRITE_STANDARDS=true
            shift
            ;;
        --claude-code|--claude|--claude_code)
            CLAUDE_CODE=true
            shift
            ;;
        --cursor|--cursor-cli)
            CURSOR=true
            shift
            ;;
        --with-hooks)
            WITH_HOOKS=true
            shift
            ;;
        --project-type=*)
            PROJECT_TYPE="${1#*=}"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-base                   Install from GitHub (not from a base Agent OSinstallation on your system)"
            echo "  --overwrite-instructions    Overwrite existing instruction files"
            echo "  --overwrite-standards       Overwrite existing standards files"
            echo "  --claude-code               Add Claude Code support (with embedded instructions)"
            echo "  --cursor                    Add Cursor support"
            echo "  --with-hooks                Add optional validation hooks for state management"
            echo "  --project-type=TYPE         Use specific project type for installation"
            echo "  -h, --help                  Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo ""
echo "🚀 Agent OS Project Installation"
echo "================================"
echo ""

# Get project directory info
CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")
INSTALL_DIR="./.agent-os"

echo "📍 Installing Agent OS to this project's root directory ($PROJECT_NAME)"
echo ""

# Determine if running from base installation or GitHub
if [ "$NO_BASE" = true ]; then
    IS_FROM_BASE=false
    echo "📦 Installing directly from GitHub (no base installation)"
    # Set BASE_URL for GitHub downloads
    BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"
    # Download and source functions when running from GitHub
    TEMP_FUNCTIONS="/tmp/agent-os-functions-$$.sh"
    curl -sSL "${BASE_URL}/setup/functions.sh" -o "$TEMP_FUNCTIONS"
    source "$TEMP_FUNCTIONS"
    rm "$TEMP_FUNCTIONS"
else
    IS_FROM_BASE=true
    # Get the base Agent OS directory
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    BASE_AGENT_OS="$(dirname "$SCRIPT_DIR")"
    echo "✓ Using Agent OS base installation at $BASE_AGENT_OS"
    # Source shared functions from base installation
    source "$SCRIPT_DIR/functions.sh"
fi

echo ""
echo "📁 Creating project directories..."
echo ""
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/state/recovery"
mkdir -p "$INSTALL_DIR/standards"

# Configure tools and project type based on installation type
if [ "$IS_FROM_BASE" = true ]; then
    # Auto-enable tools based on base config if no flags provided
    if [ "$CLAUDE_CODE" = false ]; then
        # Check if claude_code is enabled in base config
        if grep -q "claude_code:" "$BASE_AGENT_OS/config.yml" && \
           grep -A1 "claude_code:" "$BASE_AGENT_OS/config.yml" | grep -q "enabled: true"; then
            CLAUDE_CODE=true
            echo "  ✓ Auto-enabling Claude Code support (from Agent OS config)"
        fi
    fi

    if [ "$CURSOR" = false ]; then
        # Check if cursor is enabled in base config
        if grep -q "cursor:" "$BASE_AGENT_OS/config.yml" && \
           grep -A1 "cursor:" "$BASE_AGENT_OS/config.yml" | grep -q "enabled: true"; then
            CURSOR=true
            echo "  ✓ Auto-enabling Cursor support (from Agent OS config)"
        fi
    fi

    # Read project type from config or use flag
    if [ -z "$PROJECT_TYPE" ] && [ -f "$BASE_AGENT_OS/config.yml" ]; then
        # Try to read default_project_type from config
        PROJECT_TYPE=$(grep "^default_project_type:" "$BASE_AGENT_OS/config.yml" | cut -d' ' -f2 | tr -d ' ')
        if [ -z "$PROJECT_TYPE" ]; then
            PROJECT_TYPE="default"
        fi
    elif [ -z "$PROJECT_TYPE" ]; then
        PROJECT_TYPE="default"
    fi

    echo ""
    echo "📦 Using project type: $PROJECT_TYPE"

    # Determine source paths based on project type
    INSTRUCTIONS_SOURCE=""
    STANDARDS_SOURCE=""

    if [ "$PROJECT_TYPE" = "default" ]; then
        INSTRUCTIONS_SOURCE="$BASE_AGENT_OS/instructions"
        STANDARDS_SOURCE="$BASE_AGENT_OS/standards"
    else
        # Look up project type in config
        if grep -q "^  $PROJECT_TYPE:" "$BASE_AGENT_OS/config.yml"; then
            # Extract paths for this project type
            INSTRUCTIONS_PATH=$(awk "/^  $PROJECT_TYPE:/{f=1} f&&/instructions:/{print \$2; exit}" "$BASE_AGENT_OS/config.yml")
            STANDARDS_PATH=$(awk "/^  $PROJECT_TYPE:/{f=1} f&&/standards:/{print \$2; exit}" "$BASE_AGENT_OS/config.yml")

            # Expand tilde in paths
            INSTRUCTIONS_SOURCE=$(eval echo "$INSTRUCTIONS_PATH")
            STANDARDS_SOURCE=$(eval echo "$STANDARDS_PATH")

            # Check if paths exist
            if [ ! -d "$INSTRUCTIONS_SOURCE" ] || [ ! -d "$STANDARDS_SOURCE" ]; then
                echo "  ⚠️  Project type '$PROJECT_TYPE' paths not found, falling back to default instructions and standards"
                INSTRUCTIONS_SOURCE="$BASE_AGENT_OS/instructions"
                STANDARDS_SOURCE="$BASE_AGENT_OS/standards"
            fi
        else
            echo "  ⚠️  Project type '$PROJECT_TYPE' not found in config, using default instructions and standards"
            INSTRUCTIONS_SOURCE="$BASE_AGENT_OS/instructions"
            STANDARDS_SOURCE="$BASE_AGENT_OS/standards"
        fi
    fi

    # Copy only standards from determined sources (instructions are now embedded in commands)
    echo ""
    echo "📥 Installing standards files to $INSTALL_DIR/standards/"
    copy_directory "$STANDARDS_SOURCE" "$INSTALL_DIR/standards" "$OVERWRITE_STANDARDS"
    
    # Note: Instructions are now embedded in commands, no need to copy separately
else
    # Running directly from GitHub - download from GitHub
    if [ -z "$PROJECT_TYPE" ]; then
        PROJECT_TYPE="default"
    fi

    echo "📦 Using project type: $PROJECT_TYPE (default when installing from GitHub)"

    # Install instructions and standards from GitHub (no commands folder needed)
    install_from_github "$INSTALL_DIR" "$OVERWRITE_INSTRUCTIONS" "$OVERWRITE_STANDARDS" false
fi

# Handle Claude Code installation for project
if [ "$CLAUDE_CODE" = true ]; then
    echo ""
    echo "📥 Installing Claude Code support..."
    mkdir -p "./.claude/commands"
    mkdir -p "./.claude/agents"

    if [ "$IS_FROM_BASE" = true ]; then
        # Copy from base installation
        echo "  📂 Commands:"
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product index-codebase debug; do
            if [ -f "$BASE_AGENT_OS/commands/${cmd}.md" ]; then
                copy_file "$BASE_AGENT_OS/commands/${cmd}.md" "./.claude/commands/${cmd}.md" "false" "commands/${cmd}.md"
            else
                echo "  ⚠️  Warning: ${cmd}.md not found in base installation"
            fi
        done

        echo ""
        echo "  📂 Agents:"
        for agent in context-fetcher date-checker file-creator git-workflow project-manager test-runner spec-cache-manager codebase-indexer build-checker; do
            if [ -f "$BASE_AGENT_OS/claude-code/agents/${agent}.md" ]; then
                copy_file "$BASE_AGENT_OS/claude-code/agents/${agent}.md" "./.claude/agents/${agent}.md" "false" "agents/${agent}.md"
            else
                echo "  ⚠️  Warning: ${agent}.md not found in base installation"
            fi
        done
    else
        # Download from GitHub when using --no-base
        echo "  Downloading Claude Code files from GitHub..."
        echo ""
        echo "  📂 Commands:"
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            download_file "${BASE_URL}/commands/${cmd}.md" \
                "./.claude/commands/${cmd}.md" \
                "false" \
                "commands/${cmd}.md"
        done

        echo ""
        echo "  📂 Agents:"
        for agent in context-fetcher date-checker file-creator git-workflow project-manager test-runner spec-cache-manager codebase-indexer build-checker; do
            download_file "${BASE_URL}/claude-code/agents/${agent}.md" \
                "./.claude/agents/${agent}.md" \
                "false" \
                "agents/${agent}.md"
        done
    fi
fi

# Initialize state management
echo ""
echo "📥 Initializing state management..."
cat > "$INSTALL_DIR/state/workflow.json" << 'EOF'
{
  "state_version": "1.0.0",
  "current_workflow": null,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Handle optional hooks installation
if [ "$WITH_HOOKS" = true ]; then
    echo ""
    echo "📥 Installing validation hooks..."
    mkdir -p "./.claude/hooks"
    
    # Pre-write hook for JSON validation
    cat > "./.claude/hooks/pre-write.sh" << 'EOF'
#!/bin/bash
# Validates JSON state files before writing
if [[ "$1" == *".agent-os/state/"*.json ]]; then
    jq empty "$1" 2>/dev/null || {
        echo "ERROR: Invalid JSON in state file"
        exit 1
    }
fi
EOF
    
    # Post-command hook for cache cleanup
    cat > "./.claude/hooks/post-command.sh" << 'EOF'
#!/bin/bash
# Clean expired caches after command execution
find .agent-os/state -name "session-cache.json" -mmin +60 \
    -exec rm {} \; 2>/dev/null
EOF
    
    chmod +x ./.claude/hooks/*.sh
    echo "  ✓ Installed pre-write validation hook"
    echo "  ✓ Installed post-command cleanup hook"
fi

# Update .gitignore for state and cache files
if [ -f .gitignore ]; then
    # Check if Agent-OS section already exists
    if ! grep -q "# Agent-OS cache and state files" .gitignore; then
        echo "" >> .gitignore
        echo "# Agent-OS cache and state files" >> .gitignore
        echo ".agent-os/state/session-cache.json" >> .gitignore
        echo ".agent-os/state/command-state.json" >> .gitignore
        echo ".agent-os/state/recovery/" >> .gitignore
        echo ".agent-os/state/.lock" >> .gitignore
        echo ".agent-os/cache/" >> .gitignore
        echo ".agent-os/debugging/" >> .gitignore
        echo ".agent-os/**/*.cache" >> .gitignore
        echo ".agent-os/**/*.tmp" >> .gitignore
        echo "  ✓ Updated .gitignore with state exclusions"
    fi
else
    # Create new .gitignore with Agent-OS entries
    cat > .gitignore << 'EOF'
# Agent-OS cache and state files
.agent-os/state/session-cache.json
.agent-os/state/command-state.json
.agent-os/state/recovery/
.agent-os/state/.lock
.agent-os/cache/
.agent-os/debugging/
.agent-os/**/*.cache
.agent-os/**/*.tmp
EOF
    echo "  ✓ Created .gitignore with state exclusions"
fi

# Handle Cursor installation for project
if [ "$CURSOR" = true ]; then
    echo ""
    echo "📥 Installing Cursor support..."
    mkdir -p "./.cursor/rules"

    echo "  📂 Rules:"

    if [ "$IS_FROM_BASE" = true ]; then
        # Convert commands from base installation to Cursor rules
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            if [ -f "$BASE_AGENT_OS/commands/${cmd}.md" ]; then
                convert_to_cursor_rule "$BASE_AGENT_OS/commands/${cmd}.md" "./.cursor/rules/${cmd}.mdc"
            else
                echo "  ⚠️  Warning: ${cmd}.md not found in base installation"
            fi
        done
    else
        # Download from GitHub and convert when using --no-base
        echo "  Downloading and converting from GitHub..."
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            TEMP_FILE="/tmp/${cmd}.md"
            curl -s -o "$TEMP_FILE" "${BASE_URL}/commands/${cmd}.md"
            if [ -f "$TEMP_FILE" ]; then
                convert_to_cursor_rule "$TEMP_FILE" "./.cursor/rules/${cmd}.mdc"
                rm "$TEMP_FILE"
            fi
        done
    fi
fi

# Success message
echo ""
echo "✅ Agent OS has been installed in your project ($PROJECT_NAME)!"
echo ""
echo "📍 Project-level files installed to:"
echo "   .agent-os/standards/       - Development standards"
echo "   .agent-os/state/           - State management and caching"

if [ "$CLAUDE_CODE" = true ]; then
    echo "   .claude/commands/          - Claude Code commands (with embedded instructions)"
    echo "   .claude/agents/            - Claude Code specialized subagents"
fi

if [ "$WITH_HOOKS" = true ]; then
    echo "   .claude/hooks/             - Validation and cleanup hooks"
fi

if [ "$CURSOR" = true ]; then
    echo "   .cursor/rules/             - Cursor command rules"
fi

echo ""
echo "--------------------------------"
echo ""
echo "Next steps:"
echo ""

if [ "$CLAUDE_CODE" = true ]; then
    echo "Claude Code useage:"
    echo "  /plan-product    - Set the mission & roadmap for a new product"
    echo "  /analyze-product - Set up the mission and roadmap for an existing product"
    echo "  /create-spec     - Create a spec for a new feature"
    echo "  /execute-tasks   - Build and ship code for a new feature"
    echo ""
fi

if [ "$CURSOR" = true ]; then
    echo "Cursor useage:"
    echo "  @plan-product    - Set the mission & roadmap for a new product"
    echo "  @analyze-product - Set up the mission and roadmap for an existing product"
    echo "  @create-spec     - Create a spec for a new feature"
    echo "  @execute-tasks   - Build and ship code for a new feature"
    echo ""
fi

echo "--------------------------------"
echo ""
echo "Refer to the official Agent OS docs at:"
echo "https://buildermethods.com/agent-os"
echo ""
echo "Keep building! 🚀"
echo ""
