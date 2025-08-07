#!/bin/bash

# Start the Agent OS test environment with mock website

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check Python installation
check_python() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Please install Python 3.8 or higher."
        exit 1
    fi
    
    # Check Python version
    python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    print_status "Python version: $python_version"
}

# Install uv if not present
install_uv() {
    if ! command -v uv &> /dev/null; then
        print_status "Installing uv (modern Python package manager)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        
        # Add uv to PATH for current session
        export PATH="$HOME/.cargo/bin:$PATH"
        
        # Verify installation
        if ! command -v uv &> /dev/null; then
            print_error "Failed to install uv. Please install it manually from https://github.com/astral-sh/uv"
            exit 1
        fi
        
        print_success "uv installed successfully"
    else
        print_status "uv is already installed"
    fi
}

# Install dependencies using uv
install_dependencies() {
    print_status "Setting up Python environment with uv..."
    
    # Create virtual environment with uv if it doesn't exist
    VENV_DIR="$(pwd)/test_venv"
    if [ ! -d "$VENV_DIR" ]; then
        print_status "Creating virtual environment in $VENV_DIR..."
        uv venv "$VENV_DIR"
    fi
    
    # Install packages with uv
    print_status "Installing required packages with uv..."
    uv pip install --python "$VENV_DIR/bin/python" nicegui fastapi uvicorn
    
    print_success "Dependencies installed successfully with uv"
}



# Main function
main() {
    echo "================================================"
    echo "Agent OS Test Environment"
    echo "================================================"
    echo ""
    
    # Change to testing directory
    cd "$(dirname "$0")"
    # curl -sSL http://localhost:8080/agent-os/api/setup.sh | bash
    # Run checks and setup
    check_python
    install_uv
    install_dependencies
    
    
    echo ""
    print_status "Test environment ready!"
    print_status "You can test the setup scripts using:"
    echo ""
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup.sh | bash"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup-cursor.sh | bash"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup-claude-code.sh | bash"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup-github-copilot.sh | bash"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup-kilocode.sh | bash"
    echo ""
    # Start the website
    print_status "Starting Agent OS mock website..."
    print_status "Website will be available at: http://localhost:8080/agent-os"
    print_status "API endpoints will be available at: http://localhost:8080/agent-os/api/"
    echo ""
    print_warning "Press Ctrl+C to stop the server"
    echo ""
    
    # Run the website with uvicorn and activated virtual environment
    cd mock_website
    "$VENV_DIR/bin/uvicorn" website:app --host 0.0.0.0 --port 8080 --log-level info
}

# Handle cleanup on exit
cleanup() {
    echo ""
    print_status "Shutting down test environment..."
    # Deactivate virtual environment if active
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        deactivate
    fi
    print_success "Test environment stopped"
}

# Set up trap for cleanup
trap cleanup EXIT

# Run main function
main