#!/bin/bash

# Agent OS KiloCode Setup Script
# This script installs Agent OS commands for KiloCode in the current project

set -e  # Exit on error

echo "🚀 Agent OS KiloCode Setup (Local Test Environment)"
echo "===================================================="
echo ""

# Check if Agent OS base installation is present
if [ ! -d "$HOME/.agent-os/instructions" ] || [ ! -d "$HOME/.agent-os/standards" ]; then
    echo "⚠️  Agent OS base installation not found!"
    echo ""
    echo "Please install the Agent OS base installation first:"
    echo ""
    echo "Option 1 - Automatic installation:"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup.sh | bash"
    echo ""
    echo "Option 2 - Manual installation:"
    echo "  Follow instructions at https://buildermethods.com/agent-os"
    echo ""
    exit 1
fi

echo ""
echo "📁 Creating .kilocode/rules directory..."
mkdir -p .kilocode/rules

# Base URL for local test environment
BASE_URL="http://localhost:8080/agent-os/api"

echo ""
echo "📥 Downloading and setting up KiloCode rule files..."

# Function to process a command file
process_command_file() {
    local cmd="$1"
    local temp_file="/tmp/${cmd}.md"
    local target_file=".kilocode/rules/${cmd}.md"

    # Download the file
    if curl -s -o "$temp_file" "${BASE_URL}/commands/${cmd}.md"; then
        # Create the rule file with KiloCode format
        cat > "$target_file" << EOF
# ${cmd^} Rules for KiloCode

This file contains Agent OS workflow rules for KiloCode AI assistant.

## Agent OS ${cmd^} Command

EOF

        # Append the original content
        cat "$temp_file" >> "$target_file"

        # Clean up temp file
        rm "$temp_file"

        echo "  ✓ .kilocode/rules/${cmd}.md"
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
echo "✅ Agent OS KiloCode setup complete!"
echo ""
echo "📍 Files installed to:"
echo "   .kilocode/rules/           - KiloCode custom rules"
echo ""
echo "Next steps:"
echo ""
echo "Use Agent OS commands in KiloCode:"
echo "  Ask: 'Use plan-product to initiate Agent OS in a new product's codebase'"
echo "  Ask: 'Use analyze-product to initiate Agent OS in an existing product's codebase'"
echo "  Ask: 'Use create-spec to initiate a new feature (or simply ask what's next?)'"
echo "  Ask: 'Use execute-tasks to build and ship code'"
echo ""
echo "KiloCode will automatically reference these rule files when working"
echo "with your Agent OS-enabled project."
echo ""
echo "Test environment running at http://localhost:8080/agent-os"
echo ""