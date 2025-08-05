# Agent OS Python Plugin

This directory contains Python-specific extensions and overrides for Agent OS, providing comprehensive support for Python development using modern frameworks.

## Overview

The Python plugin automatically activates when a Python project is detected, providing:

- **Python-specific tech stack defaults** (NiceGUI, FastAPI, SQLModel)
- **Comprehensive Python coding standards** with framework-specific patterns
- **Enhanced instruction overrides** for Python development workflows
- **Seamless integration** with existing Agent OS commands

## Plugin Structure

```
plugins/python/
├── README.md                           # This file
├── PYTHON_VSCODE_IMPLEMENTATION.md     # Implementation details
├── CONTRIBUTION_PLAN.md                # Contribution strategy
├── standards/
│   ├── python-tech-stack.md           # Python technology defaults
│   └── python-style.md                # Python coding standards
└── instructions/core/
    └── create-spec.md                  # Python-enhanced spec creation
```

## Automatic Detection

The Python plugin activates automatically when any of these conditions are met:

### File-based Detection
- `pyproject.toml` exists in project root
- `requirements.txt` exists in project root  
- `main.py` or `app.py` exists in project root

### Manual Override
- "python" specified in `.agent-os/product/tech-stack.md`

## Technology Stack

When the Python plugin is active, projects use:

### Core Technologies
- **Language**: Python 3.12+
- **Backend Framework**: FastAPI 0.116.1+
- **UI Framework**: NiceGUI 2.21.1+

### Database & ORM
- **ORM**: SQLModel 0.0.24+ (Pydantic + SQLAlchemy)
- **Database Migrations**: SQLModel.metadata.create_all()
- **Session Management**: Context managers with SQLModel Session
- **Validation**: Pydantic (via SQLModel) for data validation

### Frontend & Styling
- **CSS Framework**: Tailwind CSS (integrated with NiceGUI)
- **UI Components**: NiceGUI built-in components + Quasar Framework
- **Mobile Design**: Mobile-first responsive (400px × 800px target)
- **Icons**: Material Design Icons (via NiceGUI/Quasar)
- **Dark Mode**: NiceGUI dark mode support

### Development Tools
- **Package Manager**: uv (modern Python package manager)
- **Linting**: Ruff 0.12.5+ (Python linter/formatter)
- **Testing**: Pytest 8.4.1+ with pytest-asyncio

## Enhanced Features

### Python-Specific Spec Creation
- **NiceGUI UI specifications** with component and layout requirements
- **FastAPI endpoint definitions** with async patterns
- **SQLModel database models** with relationship specifications
- **Python implementation notes** section in specs
- **Framework-specific task breakdown** (Models → API → UI flow)

### Coding Standards
- **4-space indentation** (overrides global 2-space rule)
- **88-character line length** (Black formatter standard)
- **Double quotes for strings** with f-string interpolation
- **Import organization**: Standard → Third-party → NiceGUI → Local
- **Comprehensive patterns** for NiceGUI, FastAPI, and SQLModel

### Development Workflow
- **Test-Driven Development** with pytest patterns
- **Async/await best practices** for FastAPI and database operations
- **Type safety** with full type hints and Pydantic validation
- **Error handling patterns** for web applications
- **File organization** recommendations for Python projects

## Integration with Agent OS Commands

### Enhanced Commands
When Python is detected, these commands use Python-specific logic:

- **`create-spec`**: Uses Python plugin override with NiceGUI/FastAPI/SQLModel patterns
- **`plan-product`**: References Python tech stack for project planning
- **`analyze-product`**: Detects Python environment and dependencies
- **`execute-tasks`**: Applies Python coding standards during implementation

### Setup Scripts
The plugin works with all Agent OS setup scripts:

- **`setup-github-copilot.sh`**: VS Code with GitHub Copilot integration
- **`setup-kilocode.sh`**: KiloCode AI assistant integration  
- **`setup-cursor.sh`**: Cursor AI editor integration
- **`setup-claude-code.sh`**: Claude Code integration

## Benefits for Python Developers

### No SQL Required
- **SQLModel ORM**: Type-safe database operations without raw SQL
- **Automatic migrations**: Simple `SQLModel.metadata.create_all()`
- **Pydantic validation**: Built-in data validation and serialization

### Modern Web UI
- **NiceGUI framework**: React-like UI development in Python
- **Component-based**: Reusable UI components with data binding
- **Tailwind CSS**: Modern utility-first styling
- **Responsive design**: Mobile-first approach

### High-Performance APIs
- **FastAPI framework**: Industry-standard async web framework
- **Automatic documentation**: OpenAPI/Swagger generation
- **Type validation**: Request/response validation with Pydantic
- **Async support**: Full async/await pattern support

### Developer Experience
- **Type safety**: Full type hints throughout the stack
- **Modern tooling**: uv package manager, Ruff linting
- **Comprehensive testing**: pytest with async support
- **VS Code integration**: Native GitHub Copilot support

## Usage Examples

### Creating a Python Spec
```bash
# Agent OS automatically detects Python project and uses enhanced create-spec
# Ask: "Use create-spec to create a user dashboard feature"
```

### Project Planning
```bash
# Python tech stack is automatically referenced
# Ask: "Use plan-product to set up a new Python web application"
```

### Code Implementation
```bash
# Python coding standards are automatically applied
# Ask: "Use execute-tasks to implement the user authentication system"
```

## Plugin Architecture

The Python plugin follows Agent OS plugin conventions:

### Detection Logic
```
IF python_project_detected:
  LOAD: @plugins/python/standards/python-tech-stack.md
  LOAD: @plugins/python/standards/python-style.md
  OVERRIDE: @plugins/python/instructions/core/create-spec.md
ELSE:
  USE: Standard Agent OS defaults
```

### Override Mechanism
- **Conditional loading**: Only loads when Python is detected
- **Non-invasive**: Doesn't affect non-Python projects
- **Extensible**: Pattern can be used for other language plugins
- **Backward compatible**: Existing functionality preserved

## Contributing

This plugin is part of the Agent OS Python contribution. See [`CONTRIBUTION_PLAN.md`](CONTRIBUTION_PLAN.md) for details on:

- Contribution strategy and timeline
- Pull request preparation
- Value proposition for the main repository
- Future enhancement plans

## Implementation Details

For technical implementation details, see [`PYTHON_VSCODE_IMPLEMENTATION.md`](PYTHON_VSCODE_IMPLEMENTATION.md) which covers:

- File structure and organization
- Integration points with core Agent OS
- VS Code and AI tool setup procedures
- Development workflow patterns

---

**Learn more about Agent OS**: https://buildermethods.com/agent-os