# QA Agent OS

## Project Overview

This project, "QA Agent OS," is a system for generating contextual prompts and workflows for AI coding assistants. It acts as an operating system for AI agents, providing them with the necessary standards, conventions, and workflows to perform Quality Assurance tasks effectively. The system is built around a templating engine that compiles Markdown files into detailed prompts and commands for an AI agent, particularly "Claude Code."

The core technologies are Shell scripts (`bash`) for the tooling, YAML for configuration, and Markdown for the content of the prompts and workflows.

## Building and Running

The project is installed and configured on a per-project basis.

### Installation

To install the QA Agent OS into a project, run the following command from the project's root directory:

```bash
/Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/scripts/project-install.sh
```

### Configuration

The installation is driven by a configuration file located at `config.yml`. This file determines:

*   Whether to install commands for "Claude Code" or other generic AI tools.
*   Whether to use a multi-agent setup with sub-agents.
*   How to provide "standards" to the AI agent (either as "skills" or injected file references).
*   The default "profile" to use for installation.

The default profile is `default`, located in the `profiles/` directory.

### Updating

To update an existing installation with new settings or a new version of the QA Agent OS, run:

```bash
/Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/scripts/project-update.sh
```

## Development Conventions

The project's conventions and standards are designed to be customized for each project where it's installed. The base conventions are defined in the `profiles/default/standards/` directory.

*   **Global Conventions:** General conventions are located in `profiles/default/standards/global/conventions.md`.
*   **Customization:** To add or override conventions, you can create a new profile and either modify the existing files or add new ones. The system uses a profile inheritance model, so a new profile can extend the `default` profile.
*   **Workflows:** The project uses a concept of "workflows" which are multi-step processes for the AI agent to follow. These are defined in the `profiles/default/workflows/` directory.

The entire system is designed to be highly modular and customizable to fit the specific needs of a project's QA process.
