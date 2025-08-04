#!/bin/bash

# Agent OS Setup Script
# This script installs Agent OS files to your system

set -e  # Exit on error

# Initialize flags
OVERWRITE_INSTRUCTIONS=false
OVERWRITE_STANDARDS=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --overwrite-instructions)
            OVERWRITE_INSTRUCTIONS=true
            shift
            ;;
        --overwrite-standards)
            OVERWRITE_STANDARDS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --overwrite-instructions    Overwrite existing instruction files"
            echo "  --overwrite-standards       Overwrite existing standards files"
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

echo "🚀 Agent OS Setup Script"
echo "========================"
echo ""

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"

# Create directories
echo "📁 Creating directories..."
mkdir -p "$HOME/.agent-os/standards"
mkdir -p "$HOME/.agent-os/standards/code-style"
mkdir -p "$HOME/.agent-os/instructions"
mkdir -p "$HOME/.agent-os/instructions/core"
mkdir -p "$HOME/.agent-os/instructions/meta"

# Download standards files
echo ""
echo "📥 Downloading standards files to ~/.agent-os/standards/"

# tech-stack.md
if [ -f "$HOME/.agent-os/standards/tech-stack.md" ] && [ "$OVERWRITE_STANDARDS" = false ]; then
    echo "  ⚠️  ~/.agent-os/standards/tech-stack.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/standards/tech-stack.md" "${BASE_URL}/standards/tech-stack.md"
    if [ -f "$HOME/.agent-os/standards/tech-stack.md" ] && [ "$OVERWRITE_STANDARDS" = true ]; then
        echo "  ✓ ~/.agent-os/standards/tech-stack.md (overwritten)"
    else
        echo "  ✓ ~/.agent-os/standards/tech-stack.md"
    fi
fi

# code-style.md
if [ -f "$HOME/.agent-os/standards/code-style.md" ] && [ "$OVERWRITE_STANDARDS" = false ]; then
    echo "  ⚠️  ~/.agent-os/standards/code-style.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/standards/code-style.md" "${BASE_URL}/standards/code-style.md"
    if [ -f "$HOME/.agent-os/standards/code-style.md" ] && [ "$OVERWRITE_STANDARDS" = true ]; then
        echo "  ✓ ~/.agent-os/standards/code-style.md (overwritten)"
    else
        echo "  ✓ ~/.agent-os/standards/code-style.md"
    fi
fi

# best-practices.md
if [ -f "$HOME/.agent-os/standards/best-practices.md" ] && [ "$OVERWRITE_STANDARDS" = false ]; then
    echo "  ⚠️  ~/.agent-os/standards/best-practices.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/standards/best-practices.md" "${BASE_URL}/standards/best-practices.md"
    if [ -f "$HOME/.agent-os/standards/best-practices.md" ] && [ "$OVERWRITE_STANDARDS" = true ]; then
        echo "  ✓ ~/.agent-os/standards/best-practices.md (overwritten)"
    else
        echo "  ✓ ~/.agent-os/standards/best-practices.md"
    fi
fi

# Download code-style subdirectory files
echo ""
echo "📥 Downloading code style files to ~/.agent-os/standards/code-style/"

# css-style.md
if [ -f "$HOME/.agent-os/standards/code-style/css-style.md" ] && [ "$OVERWRITE_STANDARDS" = false ]; then
    echo "  ⚠️  ~/.agent-os/standards/code-style/css-style.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/standards/code-style/css-style.md" "${BASE_URL}/standards/code-style/css-style.md"
    if [ -f "$HOME/.agent-os/standards/code-style/css-style.md" ] && [ "$OVERWRITE_STANDARDS" = true ]; then
        echo "  ✓ ~/.agent-os/standards/code-style/css-style.md (overwritten)"
    else
        echo "  ✓ ~/.agent-os/standards/code-style/css-style.md"
    fi
fi

# html-style.md
if [ -f "$HOME/.agent-os/standards/code-style/html-style.md" ] && [ "$OVERWRITE_STANDARDS" = false ]; then
    echo "  ⚠️  ~/.agent-os/standards/code-style/html-style.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/standards/code-style/html-style.md" "${BASE_URL}/standards/code-style/html-style.md"
    if [ -f "$HOME/.agent-os/standards/code-style/html-style.md" ] && [ "$OVERWRITE_STANDARDS" = true ]; then
        echo "  ✓ ~/.agent-os/standards/code-style/html-style.md (overwritten)"
    else
        echo "  ✓ ~/.agent-os/standards/code-style/html-style.md"
    fi
fi

# javascript-style.md
if [ -f "$HOME/.agent-os/standards/code-style/javascript-style.md" ] && [ "$OVERWRITE_STANDARDS" = false ]; then
    echo "  ⚠️  ~/.agent-os/standards/code-style/javascript-style.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/standards/code-style/javascript-style.md" "${BASE_URL}/standards/code-style/javascript-style.md"
    if [ -f "$HOME/.agent-os/standards/code-style/javascript-style.md" ] && [ "$OVERWRITE_STANDARDS" = true ]; then
        echo "  ✓ ~/.agent-os/standards/code-style/javascript-style.md (overwritten)"
    else
        echo "  ✓ ~/.agent-os/standards/code-style/javascript-style.md"
    fi
fi

# Download instruction files
echo ""
echo "📥 Downloading instruction files to ~/.agent-os/instructions/"

# Core instruction files
echo "  📂 Core instructions:"

# plan-product.md
if [ -f "$HOME/.agent-os/instructions/core/plan-product.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = false ]; then
    echo "    ⚠️  ~/.agent-os/instructions/core/plan-product.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/instructions/core/plan-product.md" "${BASE_URL}/instructions/core/plan-product.md"
    if [ -f "$HOME/.agent-os/instructions/core/plan-product.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = true ]; then
        echo "    ✓ ~/.agent-os/instructions/core/plan-product.md (overwritten)"
    else
        echo "    ✓ ~/.agent-os/instructions/core/plan-product.md"
    fi
fi

# create-spec.md
if [ -f "$HOME/.agent-os/instructions/core/create-spec.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = false ]; then
  echo "    ⚠️  ~/.agent-os/instructions/core/create-spec.md already exists - skipping"
else
  curl -s -o "$HOME/.agent-os/instructions/core/create-spec.md" "${BASE_URL}/instructions/core/create-spec.md"
  if [ -f "$HOME/.agent-os/instructions/core/create-spec.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = true ]; then
    echo "    ✓ ~/.agent-os/instructions/core/create-spec.md (overwritten)"
  else
    echo "    ✓ ~/.agent-os/instructions/core/create-spec.md"
  fi
fi

# execute-tasks.md
if [ -f "$HOME/.agent-os/instructions/core/execute-tasks.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = false ]; then
    echo "    ⚠️  ~/.agent-os/instructions/core/execute-tasks.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/instructions/core/execute-tasks.md" "${BASE_URL}/instructions/core/execute-tasks.md"
    if [ -f "$HOME/.agent-os/instructions/core/execute-tasks.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = true ]; then
        echo "    ✓ ~/.agent-os/instructions/core/execute-tasks.md (overwritten)"
    else
        echo "    ✓ ~/.agent-os/instructions/core/execute-tasks.md"
    fi
fi

# execute-task.md
if [ -f "$HOME/.agent-os/instructions/core/execute-task.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = false ]; then
    echo "    ⚠️  ~/.agent-os/instructions/core/execute-task.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/instructions/core/execute-task.md" "${BASE_URL}/instructions/core/execute-task.md"
    if [ -f "$HOME/.agent-os/instructions/core/execute-task.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = true ]; then
        echo "    ✓ ~/.agent-os/instructions/core/execute-task.md (overwritten)"
    else
        echo "    ✓ ~/.agent-os/instructions/core/execute-task.md"
    fi
fi

# analyze-product.md
if [ -f "$HOME/.agent-os/instructions/core/analyze-product.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = false ]; then
    echo "    ⚠️  ~/.agent-os/instructions/core/analyze-product.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/instructions/core/analyze-product.md" "${BASE_URL}/instructions/core/analyze-product.md"
    if [ -f "$HOME/.agent-os/instructions/core/analyze-product.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = true ]; then
        echo "    ✓ ~/.agent-os/instructions/core/analyze-product.md (overwritten)"
    else
        echo "    ✓ ~/.agent-os/instructions/core/analyze-product.md"
    fi
fi

# Meta instruction files
echo ""
echo "  📂 Meta instructions:"

# pre-flight.md
if [ -f "$HOME/.agent-os/instructions/meta/pre-flight.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = false ]; then
    echo "    ⚠️  ~/.agent-os/instructions/meta/pre-flight.md already exists - skipping"
else
    curl -s -o "$HOME/.agent-os/instructions/meta/pre-flight.md" "${BASE_URL}/instructions/meta/pre-flight.md"
    if [ -f "$HOME/.agent-os/instructions/meta/pre-flight.md" ] && [ "$OVERWRITE_INSTRUCTIONS" = true ]; then
        echo "    ✓ ~/.agent-os/instructions/meta/pre-flight.md (overwritten)"
    else
        echo "    ✓ ~/.agent-os/instructions/meta/pre-flight.md"
    fi
fi

echo ""
echo "✅ Agent OS base installation complete!"
echo ""
echo "📍 Files installed to:"
echo "   ~/.agent-os/standards/     - Your development standards"
echo "   ~/.agent-os/instructions/  - Agent OS instructions"
echo ""
if [ "$OVERWRITE_INSTRUCTIONS" = false ] && [ "$OVERWRITE_STANDARDS" = false ]; then
    echo "💡 Note: Existing files were skipped to preserve your customizations"
    echo "   Use --overwrite-instructions or --overwrite-standards to update specific files"
else
    echo "💡 Note: Some files were overwritten based on your flags"
    if [ "$OVERWRITE_INSTRUCTIONS" = false ]; then
        echo "   Existing instruction files were preserved"
    fi
    if [ "$OVERWRITE_STANDARDS" = false ]; then
        echo "   Existing standards files were preserved"
    fi
fi
echo ""
echo "Next steps:"
echo ""
echo "1. Customize your coding standards in ~/.agent-os/standards/"
echo ""
echo "2. Install commands for your AI coding assistant(s):"
echo ""
echo "   - Using Claude Code? Install the Claude Code commands with:"
echo "     curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup-claude-code.sh | bash"
echo ""
echo "   - Using Cursor? Install the Cursor commands with:"
echo "     curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup-cursor.sh | bash"
echo ""
echo "   - Using something else? See instructions at https://buildermethods.com/agent-os"
echo ""
echo "Learn more at https://buildermethods.com/agent-os"
echo ""
