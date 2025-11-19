# Project Structure

This document outlines the directory structure of the QA Agent OS project.

├── **CHANGELOG.md**: Record of all notable changes.
├── **CHANGES_REQUIREMENTS.md**: Guidelines for contributing changes.
├── **config.yml**: Main configuration file for the QA Agent OS.
├── **GEMINI.md**: Project-specific configurations for the Gemini AI model.
├── **LICENSE**: Project license information.
├── **README.md**: Project overview and setup instructions.
│
├── **profiles/**: Contains different configurations for the AI agent.
│   └── **default/**: The default profile with standard configurations.
│       ├── **claude-code-skill-template.md**: Template for defining new skills for the "Claude Code" model.
│       │
│       ├── **agents/**: Defines the roles of sub-agents for multi-agent setups.
│       │   ├── `bug-writer.md`: Agent for documenting bugs.
│       │   ├── `evidence-summarizer.md`: Agent for summarizing bug or test evidence.
│       │   ├── `feature-initializer.md`: Agent for setting up new features.
│       │   ├── `integration-actions.md`: Agent for handling tool integrations (Jira, Testmo).
│       │   ├── `product-planner.md`: Agent for creating product plans.
│       │   ├── `requirement-analyst.md`: Agent for analyzing requirements.
│       │   └── `testcase-writer.md`: Agent for generating test cases.
│       │
│       ├── **commands/**: Commands executable by the AI agent.
│       │   ├── `analise-requirements/`: Commands for analyzing requirements.
│       │   ├── `generate-testcases/`: Commands for generating test cases.
│       │   ├── `improve-skills/`: Commands for enhancing the agent's skills.
│       │   ├── `integrations/`: Commands for tool integrations.
│       │   └── `plan-product/`: Commands for product planning.
│       │
│       ├── **standards/**: Defines standards and conventions for the AI agent.
│       │   ├── `bugs/`: Standards for bug reporting.
│       │   ├── `global/`: Global conventions for all tasks.
│       │   ├── `requirement-analysis/`: Guidelines for requirement analysis.
│       │   ├── `testcases/`: Standards for test case writing.
│       │   └── `testing/`: Templates for testing.
│       │
│       └── **workflows/**: Multi-step processes for the AI agent.
│           ├── `bug-tracking/`: Workflow for bug reporting.
│           ├── `implementation/`: Workflow for creating implementation tasks.
│           ├── `planning/`: Workflows for product planning.
│           └── `testing/`: Workflows for testing-related tasks.
│
└── **scripts/**: Shell scripts for managing the QA Agent OS.
    ├── `base-install.sh`: Basic installation script.
    ├── `common-functions.sh`: Shared functions for scripts.
    ├── `create-profile.sh`: Script for creating new profiles.
    ├── `project-install.sh`: Main installation script.
    └── `project-update.sh`: Script for updating existing installations.
