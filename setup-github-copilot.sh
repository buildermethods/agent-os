#!/bin/bash

# Agent OS GitHub Copilot Setup Script
# This script installs Agent OS commands for GitHub Copilot in VS Code in the current project

set -e  # Exit on error

echo "🚀 Agent OS GitHub Copilot Setup"
echo "================================="
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
echo "📁 Creating .github/instructions directory..."
mkdir -p .github/instructions

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"

echo ""
echo "📥 Downloading and setting up GitHub Copilot instruction files..."

# Function to process a command file
process_command_file() {
    local cmd="$1"
    local temp_file="/tmp/${cmd}.md"
    local target_file=".github/instructions/${cmd}.instructions.md"

    # Download the file
    if curl -s -o "$temp_file" "${BASE_URL}/commands/${cmd}.md"; then
        # Create the instruction file with proper formatting for GitHub Copilot
        cat > "$target_file" << EOF
# ${cmd^} Instructions for GitHub Copilot

This file contains instructions for GitHub Copilot to help with Agent OS workflows.

## Instructions

EOF

        # Append the original content
        cat "$temp_file" >> "$target_file"

        # Clean up temp file
        rm "$temp_file"

        echo "  ✓ .github/instructions/${cmd}.instructions.md"
    else
        echo "  ❌ Failed to download ${cmd}.md"
        return 1
    fi
}

# Process each command file
for cmd in plan-product create-spec execute-tasks analyze-product; do
    process_command_file "$cmd"
done

echo ""
echo "✅ Agent OS GitHub Copilot setup complete!"
echo ""
echo "📍 Files installed to:"
echo "   .github/instructions/     - GitHub Copilot instruction files"
echo ""
echo "Next steps:"
echo ""
echo "Use Agent OS commands in VS Code with GitHub Copilot:"
echo "  Ask: 'Use plan-product to initiate Agent OS in a new product's codebase'"
echo "  Ask: 'Use analyze-product to initiate Agent OS in an existing product's codebase'"
echo "  Ask: 'Use create-spec to initiate a new feature (or simply ask what's next?)'"
echo "  Ask: 'Use execute-tasks to build and ship code'"
echo ""
echo "GitHub Copilot will automatically reference these instruction files when working"
echo "with your Agent OS-enabled Python project using NiceGUI, FastAPI, and SQLModel."
echo ""
echo "Learn more at https://buildermethods.com/agent-os"
echo ""
