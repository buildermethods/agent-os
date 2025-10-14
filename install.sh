#!/bin/bash
#
# Agent OS Installation Script
# Installs Agent OS base to ~/agent-os and the CLI tool
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/install.sh | bash
#
#   Or for local development:
#   ./install.sh --local
#

set -e

REPO="buildermethods/agent-os"
GITHUB_API="https://api.github.com/repos/$REPO"
GITHUB_RAW="https://raw.githubusercontent.com/$REPO/main"
BASE_DIR="${AGENT_OS_HOME:-$HOME/agent-os}"
LOCAL_MODE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC}  $1"
}

# ASCII Logo
show_logo() {
  echo -e "${RED}"
  cat << "EOF"
   █████╗  ██████╗ ███████╗███╗   ██╗████████╗     ██████╗ ███████╗
  ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝    ██╔═══██╗██╔════╝
  ███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║       ██║   ██║███████╗
  ██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║       ██║   ██║╚════██║
  ██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║       ╚██████╔╝███████║
  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝        ╚═════╝ ╚══════╝
EOF
  echo -e "${NC}"
  echo -e "  ${RED}Collaborative AI Agent Framework${NC}\n"
}

# Detect platform
detect_platform() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Darwin*)
      if [ "$ARCH" = "arm64" ]; then
        BINARY_NAME="agent-os-macos-arm64"
        PLATFORM="macOS (ARM64)"
      else
        BINARY_NAME="agent-os-macos-x64"
        PLATFORM="macOS (Intel)"
      fi
      ;;
    Linux*)
      BINARY_NAME="agent-os-linux-x64"
      PLATFORM="Linux (x64)"
      ;;
    *)
      print_error "Unsupported platform: $OS $ARCH"
      echo "Please visit https://github.com/$REPO/releases for manual installation."
      exit 1
      ;;
  esac
}

# Check if Agent OS is already installed
check_existing() {
  if [ -d "$BASE_DIR" ]; then
    echo ""
    print_warning "Agent OS is already installed at $BASE_DIR"
    echo ""
    read -p "Do you want to reinstall? This will backup your current installation. (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_info "Installation cancelled. Use 'agent-os base-update' to update."
      exit 0
    fi

    # Backup existing installation
    BACKUP_DIR="${BASE_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    print_info "Backing up to $BACKUP_DIR"
    mv "$BASE_DIR" "$BACKUP_DIR"
    print_success "Backup created"
  fi
}

# Download and extract base Agent OS files
install_base() {
  print_info "Installing Agent OS base to $BASE_DIR..."

  # Create base directory
  mkdir -p "$BASE_DIR"

  if [ "$LOCAL_MODE" = true ]; then
    # Local installation from current repo
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    print_info "Installing from local repository: $SCRIPT_DIR"

    # Copy files, excluding cli/, .git*, build artifacts
    rsync -a --exclude='cli/' --exclude='.git*' --exclude='.github/' --exclude='node_modules/' --exclude='dist/' "$SCRIPT_DIR/" "$BASE_DIR/"

    # Make scripts executable
    chmod +x "$BASE_DIR"/scripts/*.sh 2>/dev/null || true
  else
    # Remote installation from GitHub
    # Get latest release tag
    LATEST_TAG=$(curl -sSL "$GITHUB_API/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$LATEST_TAG" ]; then
      LATEST_TAG="main"
    fi

    # Download archive
    ARCHIVE_URL="https://github.com/$REPO/archive/refs/heads/main.tar.gz"
    TMP_ARCHIVE="/tmp/agent-os-$$.tar.gz"

    curl -fsSL "$ARCHIVE_URL" -o "$TMP_ARCHIVE"

    # Extract files (excluding cli/ and .git*)
    tar -xzf "$TMP_ARCHIVE" -C /tmp
    EXTRACT_DIR=$(tar -tzf "$TMP_ARCHIVE" | head -1 | cut -f1 -d"/")

    # Copy files, excluding cli/ directory
    rsync -a --exclude='cli/' --exclude='.git*' --exclude='.github/' "/tmp/$EXTRACT_DIR/" "$BASE_DIR/"

    # Make scripts executable
    chmod +x "$BASE_DIR"/scripts/*.sh

    # Cleanup
    rm -rf "$TMP_ARCHIVE" "/tmp/$EXTRACT_DIR"
  fi

  print_success "Base installation complete"
}

# Install CLI binary
install_cli() {
  print_info "Installing agent-os CLI tool..."

  CLI_PATH="$BASE_DIR/cli"

  if [ "$LOCAL_MODE" = true ]; then
    # Build CLI locally
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CLI_DIR="$SCRIPT_DIR/cli"

    if [ ! -d "$CLI_DIR" ]; then
      print_error "CLI directory not found at $CLI_DIR"
      exit 1
    fi

    # Check if Bun is installed
    if ! command -v bun &> /dev/null; then
      print_error "Bun is not installed. Please install Bun: https://bun.sh"
      exit 1
    fi

    print_info "Building CLI with Bun..."
    cd "$CLI_DIR"

    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
      print_info "Installing dependencies..."
      bun install
    fi

    # Build the CLI
    bun run build

    # Copy built CLI to base directory
    if [ -f "dist/agent-os" ]; then
      cp "dist/agent-os" "$CLI_PATH"
      chmod +x "$CLI_PATH"
      print_success "CLI built and installed from local repository"
    else
      print_error "Build failed: dist/agent-os not found"
      exit 1
    fi

    cd - > /dev/null
  else
    # Download CLI binary from GitHub
    BINARY_URL="https://github.com/$REPO/releases/latest/download/$BINARY_NAME"

    curl -fsSL "$BINARY_URL" -o "$CLI_PATH"
    chmod +x "$CLI_PATH"

    print_success "CLI tool installed to $CLI_PATH"
  fi
}

# Main installation
main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --local)
        LOCAL_MODE=true
        shift
        ;;
      --install-dir)
        BASE_DIR="$2"
        shift 2
        ;;
      --install-dir=*)
        BASE_DIR="${1#*=}"
        shift
        ;;
      *)
        # Unknown option
        shift
        ;;
    esac
  done

  # Auto-detect if running from git repository (for local development)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ "$LOCAL_MODE" = false ] && [ -d "$SCRIPT_DIR/.git" ] && [ -f "$SCRIPT_DIR/cli/package.json" ]; then
    print_info "Detected git repository, enabling local development mode"
    LOCAL_MODE=true
    # If no custom install dir specified, use the repo directory
    if [ "$BASE_DIR" = "$HOME/agent-os" ]; then
      BASE_DIR="$SCRIPT_DIR"
    fi
  fi

  # Expand ~ in BASE_DIR if present
  if [[ "$BASE_DIR" == ~* ]]; then
    BASE_DIR="${HOME}${BASE_DIR:1}"
  fi

  clear
  show_logo

  if [ "$LOCAL_MODE" = true ]; then
    echo "🚀 Installing Agent OS from local repository"
  else
    echo "🚀 Installing Agent OS for $PLATFORM"
  fi
  echo ""
  print_info "Installation directory: $BASE_DIR"
  echo ""

  detect_platform
  check_existing
  install_base
  install_cli

  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
  print_success "Agent OS installation complete!"
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
  echo ""

  # Show immediate next steps based on installation type
  if [ "$LOCAL_MODE" = true ] && [ "$BASE_DIR" != "$HOME/agent-os" ]; then
    print_info "Quick Start (Local Development Mode):"
    echo ""
    echo "  Run the CLI directly:"
    echo -e "     ${YELLOW}$BASE_DIR/cli${NC}"
    echo ""
    echo "  Or set environment variable and run:"
    echo -e "     ${YELLOW}export AGENT_OS_HOME=\"$BASE_DIR\" && \$AGENT_OS_HOME/cli${NC}"
    echo ""
    echo -e "  ${BLUE}💡 Tip: Add to your shell profile for persistent access:${NC}"
    echo -e "     ${YELLOW}echo 'export AGENT_OS_HOME=\"$BASE_DIR\"' >> ~/.zshrc${NC}"
    echo -e "     ${YELLOW}echo 'alias agent-os=\"\$AGENT_OS_HOME/cli\"' >> ~/.zshrc${NC}"
    echo -e "     ${YELLOW}source ~/.zshrc${NC}"
    echo ""
  else
    print_info "Next steps:"
    echo ""
    echo "  1. Customize your profile's standards:"
    echo -e "     ${YELLOW}$BASE_DIR/profiles/default/standards${NC}"
    echo ""
    echo "  2. Navigate to a project directory:"
    echo -e "     ${YELLOW}cd path/to/your-project${NC}"
    echo ""
    echo "  3. Install Agent OS in your project:"
    echo -e "     ${YELLOW}$BASE_DIR/cli${NC}"
    echo ""
    echo "  Or run the interactive menu:"
    echo -e "     ${YELLOW}$BASE_DIR/cli${NC}"
    echo ""
    echo -e "💡 ${BLUE}Tip: For easier access, add an alias:${NC}"
    echo -e "     ${YELLOW}echo 'alias agent-os=\"$BASE_DIR/cli\"' >> ~/.zshrc${NC}"
    echo ""
    echo -e "   ${BLUE}Or add to your PATH:${NC}"
    echo -e "     ${YELLOW}echo 'export PATH=\"$BASE_DIR:\$PATH\"' >> ~/.zshrc${NC}"
    echo ""
    if [ "$BASE_DIR" != "$HOME/agent-os" ]; then
      echo -e "   ${BLUE}Set environment variable for custom location:${NC}"
      echo -e "     ${YELLOW}echo 'export AGENT_OS_HOME=\"$BASE_DIR\"' >> ~/.zshrc${NC}"
      echo ""
    fi
    echo -e "   ${BLUE}Then reload your shell:${NC}"
    echo -e "     ${YELLOW}source ~/.zshrc${NC}"
    echo ""
  fi

  echo -e "📚 ${BLUE}Visit the docs: https://buildermethods.com/agent-os${NC}"
  echo ""
}

main "$@"
