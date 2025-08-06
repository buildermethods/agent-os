# Agent OS Testing Environment

This directory contains a local testing environment for Agent OS setup scripts. It includes a mock website that mimics the official Agent OS website and serves setup scripts from localhost instead of GitHub.

## Purpose

The testing environment allows you to:
- Test setup scripts locally without deploying to GitHub
- Develop and debug new setup scripts
- Verify installation processes work correctly
- Mock the Agent OS website for development

## Structure

```
testing/
├── README.md              # This file
├── start_tests.sh         # Main script to start the test environment
├── mock_website/          # Mock Agent OS website
     └── website.py         # NiceGUI + FastAPI application
```

## Requirements

- Python 3.8 or higher
- uv (modern Python package manager) - will be installed automatically if not present

The required Python packages (nicegui, fastapi, uvicorn) will be installed automatically using `uv` when you run `start_tests.sh`.

## Usage

1. **Start the test environment:**
   ```bash
   cd testing
   ./start_tests.sh
   ```

2. **Access the mock website:**
   Open your browser to: http://localhost:8080

3. **Test setup scripts:**
   The website will display installation commands that use localhost URLs:
   ```bash
   # Install all tools
   curl -sSL http://localhost:8080/api/setup.sh | bash
   
   # Install individual tools
   curl -sSL http://localhost:8080/api/setup-cursor.sh | bash
   curl -sSL http://localhost:8080/api/setup-claude-code.sh | bash
   curl -sSL http://localhost:8080/api/setup-github-copilot.sh | bash
   curl -sSL http://localhost:8080/api/setup-kilocode.sh | bash
   ```

4. **Stop the server:**
   Press `Ctrl+C` to stop the test environment.

## How It Works

1. **Mock Website (`mock_website/website.py`):**
   - Uses NiceGUI to create a UI that mimics buildermethods.com/agent-os
   - Uses FastAPI to serve setup scripts from the `/api` endpoints
   - Replaces GitHub URLs with localhost URLs

2. **Test Setup Scripts (`setups/test_setup-*.sh`):**
   - Modified versions of the real setup scripts
   - Create test files in `~/.agent-os/test/` instead of actual installations
   - Simulate the installation process without making real changes

3. **Start Script (`start_tests.sh`):**
   - Installs uv if not already present
   - Creates a virtual environment using `uv venv test_venv`
   - Installs required dependencies with `uv pip install`
   - Makes setup scripts executable
   - Starts the mock website server

## Development

To add a new setup script:

1. Create a new script in `setups/` following the naming pattern: `test_setup-{tool-name}.sh`
2. The script will automatically be served at: `http://localhost:8080/api/setup-{tool-name}.sh`
3. Update the mock website if you want to add it to the UI

## Notes

- Test installations create files in `~/.agent-os/test/` to avoid conflicts with real installations
- The mock website runs on port 8080 by default
- All test setup scripts include "(TEST MODE)" indicators to distinguish from real installations
- The virtual environment is created in `testing/test_venv/` using uv
- uv is used for faster and more reliable Python package management

## Troubleshooting

If you encounter issues:

1. **Port already in use:** Change the port in `website.py` and `start_tests.sh`
2. **Python not found:** Ensure Python 3.8+ is installed and available as `python3`
3. **Permission denied:** Make scripts executable with `chmod +x start_tests.sh`