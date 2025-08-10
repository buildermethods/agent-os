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
    print_status "Found Python version: $python_version"
}

# Check pip and venv availability
check_python_tools() {
    if ! python3 -m pip --version &> /dev/null; then
        print_error "pip not found for python3."
        echo "  - Ubuntu/Debian: install with: sudo apt update && sudo apt install -y python3-pip"
        echo "  - CentOS/RHEL: install with: sudo yum install python3-pip"
        echo "  - macOS: install with: brew install python"
        exit 1
    else
        print_status "pip is available for python3"
    fi

    # Check that venv module works
    if ! python3 -c "import venv" &> /dev/null; then
        print_error "Python venv module not available."
        echo "  - Ubuntu/Debian: install with: sudo apt install -y python3-venv"
        echo "  - CentOS/RHEL: venv is included with python3"
        echo "  - macOS: venv is included with python"
        exit 1
    elif ! python3 -m venv --help &> /dev/null; then
        print_error "python3 -m venv is present but not usable."
        echo "  - Ubuntu/Debian: install with: sudo apt install -y python3-venv"
        exit 1
    else
        print_status "venv is available for python3"
    fi
}

# Setup virtual environment and install dependencies
setup_environment() {
    VENV_DIR="$(pwd)/test_venv"
    
    print_status "Setting up Python virtual environment..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "$VENV_DIR" ]; then
        print_status "Creating virtual environment in $VENV_DIR..."
        if ! python3 -m venv "$VENV_DIR"; then
            print_error "Failed to create virtual environment."
            exit 1
        fi
        print_success "Virtual environment created"
    else
        print_status "Virtual environment already exists in $VENV_DIR"
    fi
    
    # Activate virtual environment
    print_status "Activating virtual environment..."
    source "$VENV_DIR/bin/activate"
    
    # Upgrade pip and install packages
    print_status "Installing required packages..."
    python -m pip install --upgrade pip
    pip install fastapi uvicorn nicegui
    
    print_success "Dependencies installed successfully"
}



# Main function
main() {
    echo "================================================"
    echo "Agent OS Test Environment"
    echo "================================================"
    echo ""
    
    # Change to testing directory
    cd "$(dirname "$0")"
    
    # Run checks and setup
    check_python
    check_python_tools
    setup_environment
    
    echo ""
    print_status "Test environment ready!"
    print_status "You can test the setup scripts using:"
    echo ""
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup.sh | bash"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup-cursor.sh | bash"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup-claude-code.sh | bash"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup-github-copilot.sh | bash"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup-kilocode.sh | bash"
    echo "  curl -sSL http://localhost:8080/agent-os/api/setup-gemini-cli.sh | bash"
    echo ""
    
    # Start the website
    print_status "Starting Agent OS mock website..."
    print_status "Website will be available at: http://localhost:8080/agent-os"
    print_status "API endpoints will be available at: http://localhost:8080/agent-os/api/"
    echo ""
    print_warning "Press Ctrl+C to stop the server"
    echo ""
    
    # Run the website with uvicorn using the activated virtual environment
    cd mock_website
    uvicorn website:app --host 0.0.0.0 --port 8080 --log-level info
}

# Handle cleanup on exit
cleanup() {
    echo ""
    print_status "Shutting down test environment..."
    print_success "Test environment stopped"
}

# Set up trap for cleanup
trap cleanup EXIT

# Run main function
main