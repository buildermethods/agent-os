# Project Structure

This document outlines the directory structure of the QA Agent OS project.

├── **ARCHITECTURE.md**: Details the high-level architecture of the QA Agent OS and its components.
├── **CHANGELOG.md**: Record of all notable changes.
├── **CHANGES_REQUIREMENTS.md**: Guidelines for contributing changes.
├── **config.yml**: Main configuration file for the QA Agent OS.
├── **GEMINI.md**: Project-specific configurations for the Gemini AI model.
├── **IMPLEMENTATION_PLAN.md**: Document outlining the diagnosis of issues and the step-by-step plan for implementing fixes and new features.
├── **LICENSE**: Project license information.
├── **README.md**: Project overview and setup instructions.
├── **VISION.md**: Outlines the core vision, architecture, and end-user workflow for the QA Agent OS.
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
│       ├── **commands/**: Commands executable by the AI agent, adapted for single-agent (compiled) or multi-agent use.
│       │   ├── **analise-requirements/**: Command for the deep requirement-analysis workflow (still available standalone and reused inside `/create-ticket`).
│       │   │   └── **single-agent/**: Single-agent version, compiled into one prompt.
│       │   │       ├── `1-initialize-feature.md`: First phase of requirement analysis.
│       │   │       ├── `2-requirement-analysis.md`: Second phase of requirement analysis.
│       │   │       ├── `3-generate-testcases.md`: Third phase for test case generation.
│       │   │       └── `analise-requirements.md`: Orchestrator for the phases.
│       │   ├── **create-ticket/**: Command that chains requirement analysis + test case generation for a specific ticket.
│       │   │   └── **single-agent/**:
│       │   │       ├── `1-requirements.md`: Runs the requirement-analysis workflow inside an existing feature/ticket folder.
│       │   │       ├── `2-testcases.md`: Generates the test suite from the analyzed requirements.
│       │   │       └── `create-ticket.md`: Orchestrator for the phases.
│       │   ├── **generate-testcases/**: Command for generating test cases based on analyzed requirements.
│       │   │   └── **single-agent/**: Single-agent version.
│       │   │       └── `generate-testcases.md`: Generates test cases.
│       │   ├── **improve-skills/**: Command for enhancing the AI agent's own skills (especially for Claude Code Skills).
│       │   │   └── `improve-skills.md`: The main command file.
│       │   ├── **init-feature/**: New command to initialize the directory structure for a new feature and its first ticket.
│       │   │   └── **single-agent/**: Single-agent version.
│       │   │       └── `init-feature.md`: Initializes feature directories.
│       │   ├── **integrations/**: Commands for integrating with external tools.
│       │   │   ├── `jira-integration.md`: Integrates with Jira.
│       │   │   └── `testmo-integration.md`: Integrates with Testmo.
│       │   └── **plan-product/**: Command to create the QA mission/spec (product vision + team ownership).
│       │       └── **single-agent/**: Single-agent version, compiled into one prompt.
│       │           ├── `1-product-concept.md`: First phase of product planning.
│       │           ├── `2-create-mission.md`: Second phase for creating the mission document.
│       │           └── `plan-product.md`: Orchestrator for the phases.
│       │
│       ├── **standards/**: Defines standards and conventions that the AI agent follows.
│       │   ├── **bugs/**: Standards for bug reporting, analysis, and severity rules.
│       │   │   ├── `bug-analysis.md`
│       │   │   ├── `bug-reporting-standard.md`
│       │   │   ├── `bug-reporting.md`
│       │   │   ├── `bug-template.md`
│       │   │   ├── `evidence-template.md`
│       │   │   └── `severity-rules.md`
│       │   ├── **global/**: Global conventions applicable across all tasks.
│       │   │   ├── `bugs.md`
│       │   │   ├── `conventions.md`
│       │   │   └── `testcases.md`
│       │   ├── **requirement-analysis/**: Guidelines for analyzing business requirements.
│       │   │   ├── `acceptance-criteria-checklist.md`
│       │   │   ├── `brd-analysis.md`
│       │   │   ├── `priority-rules.md`
│       │   │   └── `requirement-analysis-checklist.md`
│       │   ├── **testcases/**: Standards for writing and structuring test cases.
│       │   │   ├── `test-case-standard.md`
│       │   │   ├── `test-case-structure.md`
│       │   │   └── `test-generation.md`
│       │   └── **testing/**: Templates and guidelines for testing activities.
│       │       ├── `api-testing.md`: Standards for API test case design.
│       │       ├── `exploratory-testing.md`
│       │       └── `test-plan-template.md`
│       │
│       └── **workflows/**: Multi-step processes for the AI agent to follow.
│           ├── **bug-tracking/**: Workflow for reporting and tracking bugs.
│           │   └── `bug-reporting.md`
│           ├── **implementation/**: Workflow for creating tasks lists for feature implementation.
│           │   └── `create-tasks-list.md`
│           ├── **planning/**: Workflows for product planning activities.
│           │   ├── `create-product-mission.md`
│           │   └── `gather-product-info.md`
│           └── **testing/**: Workflows for various testing-related activities.
│               ├── `compile-testing-standards.md`
│               ├── `create-ticket.md`: End-to-end flow chaining requirement analysis + test cases.
│               ├── `initialize-feature.md`: Workflow for setting up new feature/ticket directories.
│               ├── `requirement-analysis.md`: Workflow for detailed requirement analysis.
│               └── `testcase-generation.md`: Workflow for generating test cases.
│
└── **scripts/**: Shell scripts for managing the QA Agent OS.
    ├── `base-install.sh`: Basic installation script.
    ├── `common-functions.sh`: Shared functions used by other scripts.
    ├── `create-profile.sh`: Script for creating new profiles.
    ├── `project-install.sh`: Main script for installing QA Agent OS into a project.
    └── `project-update.sh`: Script for updating an existing installation.