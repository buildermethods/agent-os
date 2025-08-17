#!/bin/bash

# Agent OS Gemini CLI Setup Script
# This script installs Agent OS commands for Google Gemini Code Assist CLI

set -e  # Exit on error

echo "🚀 Agent OS Gemini CLI Setup"
echo "============================"
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

# Check if Gemini CLI is installed
if ! command -v gemini &> /dev/null; then
    echo "⚠️  Gemini CLI not found!"
    echo ""
    echo "Please install Google Gemini CLI first:"
    echo ""
    echo "1. Install the Gemini CLI:"
    echo "   curl -o- https://raw.githubusercontent.com/google/generative-ai-cli/main/install.sh | bash"
    echo ""
    echo "2. Authenticate with your Google Cloud account:"
    echo "   gemini auth login"
    echo ""
    echo "3. Set your project (if using Google Cloud):"
    echo "   gemini config set project YOUR_PROJECT_ID"
    echo ""
    echo "Learn more: https://cloud.google.com/gemini/docs/codeassist/use-agentic-chat-pair-programmer"
    echo ""
    exit 1
fi

echo ""
echo "📁 Creating .gemini directory..."
mkdir -p .gemini/prompts
mkdir -p .gemini/context

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"

echo ""
echo "📥 Downloading and setting up Gemini CLI prompt files..."

# Function to process a command file for Gemini CLI
process_command_file() {
    local cmd="$1"
    local temp_file="/tmp/${cmd}.md"
    local target_file=".gemini/prompts/${cmd}.md"

    # Download the file
    if curl -s -o "$temp_file" "${BASE_URL}/commands/${cmd}.md"; then
        # Create the prompt file with Gemini CLI format
        cat > "$target_file" << EOF
# ${cmd^} Prompt for Gemini CLI

This file contains Agent OS workflow prompts for Google Gemini Code Assist CLI.

## Agent OS ${cmd^} Command

You are an AI assistant helping with Agent OS workflows. Use the following instructions:

EOF

        # Append the original content
        cat "$temp_file" >> "$target_file"

        # Add Gemini-specific instructions
        cat >> "$target_file" << EOF

## Gemini CLI Usage

When using this prompt with Gemini CLI:

1. Load this prompt: \`gemini chat --prompt-file .gemini/prompts/${cmd}.md\`
2. Provide project context from .gemini/context/ files
3. Follow Agent OS methodology for ${cmd}
4. Use Agent OS standards and best practices

## Context Files

Reference these context files when available:
- .gemini/context/project-structure.md - Project file structure
- .gemini/context/tech-stack.md - Technology stack information
- .gemini/context/requirements.md - Project requirements

EOF

        # Clean up temp file
        rm "$temp_file"

        echo "  ✓ .gemini/prompts/${cmd}.md"
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
echo "📝 Creating Gemini CLI context files..."

# Create project structure context file
cat > .gemini/context/project-structure.md << 'EOF'
# Project Structure Context

This file provides context about the current project structure for Gemini CLI.

## Directory Structure

```
[Run: find . -type f -name "*.py" -o -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" | head -20]
```

## Key Files

- Configuration files: pyproject.toml, requirements.txt, setup.py
- Main application files: main.py, app.py, __init__.py
- Documentation: README.md, docs/
- Tests: tests/, test_*.py

## Agent OS Integration

This project uses Agent OS methodology with:
- Standards in standards/ directory
- Instructions in instructions/ directory  
- Commands available via Agent OS workflows

EOF

# Create tech stack context file
cat > .gemini/context/tech-stack.md << 'EOF'
# Technology Stack Context

This file provides technology stack information for Gemini CLI.

## Agent OS Default Stack

When working with Agent OS projects, use these defaults:

### Python Projects
- **Python**: 3.12+
- **Web Framework**: FastAPI 0.116.1+
- **UI Framework**: NiceGUI 2.21.1+
- **Database**: SQLModel 0.0.24+ with SQLite/PostgreSQL
- **Testing**: pytest
- **Code Quality**: black, isort, flake8

### Web Projects
- **Frontend**: HTML5, CSS3, JavaScript ES6+
- **Styling**: Tailwind CSS or custom CSS
- **Build Tools**: Vite, Webpack, or native ES modules

## Project-Specific Stack

[Update this section with your specific technology choices]

EOF

# Create requirements context file
cat > .gemini/context/requirements.md << 'EOF'
# Requirements Context

This file provides project requirements context for Gemini CLI.

## Functional Requirements

[Add your functional requirements here]

## Non-Functional Requirements

[Add your non-functional requirements here]

## Agent OS Methodology

This project follows Agent OS methodology:

1. **Plan Product**: Define product vision and architecture
2. **Analyze Product**: Understand existing codebase and requirements
3. **Create Spec**: Generate detailed specifications for features
4. **Execute Tasks**: Implement features following specifications

## Quality Standards

- Follow Agent OS coding standards
- Implement comprehensive testing
- Maintain clear documentation
- Use consistent code formatting

EOF

echo "  ✓ .gemini/context/project-structure.md"
echo "  ✓ .gemini/context/tech-stack.md"
echo "  ✓ .gemini/context/requirements.md"

echo ""
echo "✅ Agent OS Gemini CLI setup complete!"
echo ""
echo "📍 Files installed to:"
echo "   .gemini/prompts/           - Gemini CLI prompt files"
echo "   .gemini/context/           - Project context files"
echo ""
echo "Next steps:"
echo ""
echo "Use Agent OS commands with Gemini CLI:"
echo ""
echo "1. Plan a new product:"
echo "   gemini chat --prompt-file .gemini/prompts/plan-product.md"
echo ""
echo "2. Analyze existing product:"
echo "   gemini chat --prompt-file .gemini/prompts/analyze-product.md"
echo ""
echo "3. Create feature specification:"
echo "   gemini chat --prompt-file .gemini/prompts/create-spec.md"
echo ""
echo "4. Execute development tasks:"
echo "   gemini chat --prompt-file .gemini/prompts/execute-tasks.md"
echo ""
echo "💡 Tips:"
echo "- Update .gemini/context/ files with your project-specific information"
echo "- Use 'gemini chat --help' for more CLI options"
echo "- Reference context files in your conversations for better results"
echo ""
echo "Learn more:"
echo "- Agent OS: https://buildermethods.com/agent-os"
echo "- Gemini Code Assist: https://cloud.google.com/gemini/docs/codeassist"
echo ""