# Agent OS Testing Environment

This directory contains a comprehensive local testing environment for Agent OS setup scripts and plugin installation. It provides a complete mock website that serves Agent OS installation scripts with full plugin support.

## Purpose

The testing environment allows you to:
- Test complete Agent OS installation locally including Python and TypeScript plugins
- Develop and debug setup scripts for all AI tools (Cursor, Claude Code, GitHub Copilot, KiloCode)
- Verify installation workflows with plugin support
- Mock the Agent OS website experience for development
- Test curl-based installation scripts without external dependencies

## Structure

```
testing/
├── README.md                    # This file
├── start_localhost.sh           # Main script to start the test environment
├── mock_website/                # Mock Agent OS website
│   └── website.py               # FastAPI application with HTML interface
├── setups_local/                # Local setup scripts with plugin support
│   ├── setup.sh                 # Main setup script (includes plugins)
│   ├── setup-cursor.sh          # Cursor AI editor integration
│   ├── setup-claude-code.sh     # Claude Code integration
│   ├── setup-github-copilot.sh  # GitHub Copilot integration
│   ├── setup-kilocode.sh        # KiloCode integration
│   └── setup-gemini-cli.sh      # Gemini CLI integration
└── test_venv/                   # Python virtual environment (created automatically)
```

## Requirements

- Python 3.8 or higher
- pip (Python package installer)
- venv (Python virtual environment module)

The required Python packages (fastapi, uvicorn, nicegui) will be installed automatically when you run `start_localhost.sh`.

### System Dependencies

If you encounter issues, install the required dependencies:

- **Ubuntu/Debian**: `sudo apt update && sudo apt install -y python3 python3-pip python3-venv`
- **CentOS/RHEL**: `sudo yum install python3 python3-pip` (venv included with python3)
- **macOS**: `brew install python` (pip and venv included)

## Usage

1. **Start the test environment:**
   ```bash
   ./testing/start_localhost.sh
   ```

2. **Access the mock website:**
   Open your browser to: http://localhost:8080/agent-os
   
   The website provides a complete Agent OS installation interface with:
   - Step-by-step installation instructions
   - All AI tool integration options
   - Responsive design with Tailwind CSS

3. **Test complete Agent OS installation with plugins:**
   ```bash
   # Install Agent OS base + Python & TypeScript plugins
   curl -sSL http://localhost:8080/agent-os/api/setup.sh | bash
   ```
   
   This will install:
   - Core Agent OS files to `~/.agent-os/`
   - Python plugin with language-specific instructions and standards
   - TypeScript plugin with language-specific instructions and standards

4. **Test AI tool integrations:**

   ```bash
   # Test individual AI tool setups
   curl -sSL http://localhost:8080/agent-os/api/setup-cursor.sh | bash
   curl -sSL http://localhost:8080/agent-os/api/setup-claude-code.sh | bash
   curl -sSL http://localhost:8080/agent-os/api/setup-github-copilot.sh | bash
   curl -sSL http://localhost:8080/agent-os/api/setup-kilocode.sh | bash
   curl -sSL http://localhost:8080/agent-os/api/setup-gemini-cli.sh | bash
   ```

5. **Verify installation:**

   ```bash
   tree ~/.agent-os
   ```
   
   You should see:

   ```text
   ~/.agent-os/
   ├── instructions/
   ├── standards/
   └── plugins/
       ├── python/
       └── typescript/
   ```

6. **Stop the server:**
   Press `Ctrl+C` to stop the test environment.

## Key Features

### Complete Plugin Support

- **Python Plugin**: Includes Python-specific instructions and coding standards
- **TypeScript Plugin**: Includes TypeScript-specific instructions and tech stack guidelines
- **Automatic Installation**: Plugins are included in the base setup.sh script

### AI Tool Integration Testing

- **Cursor**: Creates `.cursor/rules/` directory with Agent OS command rules
- **Claude Code**: Installs commands to `~/.claude/commands/` and agents to `~/.claude/agents/`
- **GitHub Copilot**: Creates `.github/instructions/` for Copilot integration
- **KiloCode**: Sets up `.kilocode/rules/` for KiloCode AI assistant
- **Gemini CLI**: Adds `.gemini/prompts/` and `.gemini/context/` for Gemini Code Assist CLI

### Production-Ready Architecture

- **Pure FastAPI**: Replaced NiceGUI with stable FastAPI for better deployment
- **Responsive UI**: Clean HTML interface with Tailwind CSS
- **Uvicorn Server**: Professional ASGI server deployment
- **Local File Serving**: Serves all Agent OS components from project files

## How It Works

1. **Mock Website (`mock_website/website.py`):**
   - Pure FastAPI application with HTML responses
   - Serves Agent OS installation page at `/agent-os`
   - Provides API endpoints at `/agent-os/api/` for script downloads
   - Serves files directly from project root directory

2. **Local Setup Scripts (`setups_local/`):**
   - Enhanced versions of root setup scripts with plugin support
   - Downloads files from local API endpoints instead of GitHub
   - Includes Python and TypeScript plugin installation
   - Maintains compatibility with original setup script structure

3. **Start Script (`start_localhost.sh`):**
   - Checks for Python 3, pip, and venv with clear error messages
   - Creates virtual environment using standard `python3 -m venv`
   - Installs FastAPI, uvicorn, and nicegui dependencies using pip
   - Starts server using uvicorn for production-like deployment
   - Uses proper working directory resolution for reliable execution

## Development

### Adding New Setup Scripts

1. Create a new script in `testing/setups_local/` following the pattern: `setup-{tool-name}.sh`
2. The script will be served at: `http://localhost:8080/agent-os/api/setup-{tool-name}.sh`
3. Update the website interface in `mock_website/website.py` if needed

### Adding New Plugins

1. Create plugin directory structure in project root: `plugins/{language}/`
2. Add plugin files to the main setup.sh script in `setups_local/setup.sh`
3. Plugin files will be served via the API endpoint system

### Testing Changes

- Root setup scripts remain unchanged (for upstream compatibility)
- Test environment uses local versions with plugin support
- All changes are isolated to the `testing/` directory

## Technical Details

- **Port**: Server runs on port 8080
- **Host**: Listens on 0.0.0.0 (all interfaces)
- **Architecture**: FastAPI + Uvicorn deployment
- **Dependencies**: Minimal - only FastAPI and uvicorn
- **File Serving**: Direct file serving from project root via API endpoints

## Troubleshooting

If you encounter issues:

1. **Port already in use**: The server uses port 8080. Stop other services or change the port in `start_localhost.sh`
2. **Python not found**: Ensure Python 3.8+ is installed and available as `python3`
3. **Permission denied**: Make scripts executable:

   ```bash
   chmod +x testing/start_localhost.sh
   chmod +x testing/setups_local/*.sh
   ```

4. **Server stops immediately**: Check that all required files exist and Python environment is properly set up
5. **API endpoints return 404**: Verify that source files exist in the project root directory structure

## Notes

- This testing environment provides complete Agent OS functionality locally
- Plugin support is included in the local setup scripts but not in root scripts (for upstream compatibility)
- The mock website provides the same user experience as the official Agent OS website
- All installation workflows can be tested without external network dependencies
 