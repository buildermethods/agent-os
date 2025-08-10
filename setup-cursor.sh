#!/bin/bash

# Agent OS Cursor Setup Script
# This script installs Agent OS commands for Cursor in the current project

set -e  # Exit on error

# Flags
USE_LOCAL=false
REPO_PATH=""

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --local)
      USE_LOCAL=true
      shift
      ;;
    --repo-path)
      REPO_PATH="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--local] [--repo-path <path>]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "🚀 Agent OS Cursor Setup"
echo "========================"
echo ""

# Check if Agent OS base installation is present
if [ ! -d "$HOME/.agent-os/instructions" ] || [ ! -d "$HOME/.agent-os/standards" ]; then
    echo "⚠️  Agent OS base installation not found!"
    echo ""
    echo "Please install the Agent OS base installation first:"
    echo ""
    echo "Option 1 - Automatic installation:"
    echo "  curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup.sh | bash"
    echo ""
    echo "Option 2 - Manual installation:"
    echo "  Follow instructions at https://buildermethods.com/agent-os"
    echo ""
    exit 1
fi

echo ""
echo "📁 Creating .cursor/rules directory..."
mkdir -p .cursor/rules

# Determine source
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"
if [ "$USE_LOCAL" = true ]; then
  if [ -z "$REPO_PATH" ]; then
    REPO_PATH="$SCRIPT_DIR"
  fi
  echo "📦 Using local source: $REPO_PATH"
else
  echo "🌐 Using remote source: $BASE_URL"
fi

# Helper to fetch a file from local or remote
fetch_to() {
  local dest="$1"
  local rel="$2"
  if [ "$USE_LOCAL" = true ]; then
    cp "$REPO_PATH/$rel" "$dest"
  else
    curl -s -o "$dest" "${BASE_URL}/$rel"
  fi
}

echo ""
echo "📥 Downloading and setting up Cursor command files..."

# Function to process a command file
process_command_file() {
    local cmd="$1"
    local temp_file="/tmp/${cmd}.md"
    local target_file=".cursor/rules/${cmd}.mdc"

    # Download the file
    if fetch_to "$temp_file" "commands/${cmd}.md"; then
        # Create the front-matter and append original content
        cat > "$target_file" << EOF
---
alwaysApply: false
---

EOF

        # Append the original content
        cat "$temp_file" >> "$target_file"

        # Clean up temp file
        rm "$temp_file"

        echo "  ✓ .cursor/rules/${cmd}.mdc"
    else
        echo "  ❌ Failed to fetch ${cmd}.md"
        return 1
    fi
}

# Process each command file
for cmd in plan-product create-spec execute-tasks analyze-product; do
    process_command_file "$cmd"
done

echo ""
echo "✅ Agent OS Cursor setup complete!"
echo ""
echo "📍 Files installed to:"
echo "   .cursor/rules/             - Cursor command rules"
echo ""
echo "Next steps:"
echo ""
echo "Use Agent OS commands in Cursor with @ prefix:"
echo "  @plan-product    - Initiate Agent OS in a new product's codebase"
echo "  @analyze-product - Initiate Agent OS in an existing product's codebase"
echo "  @create-spec     - Initiate a new feature (or simply ask 'what's next?')"
echo "  @execute-tasks    - Build and ship code"
echo ""
echo "Learn more at https://buildermethods.com/agent-os"
echo ""
