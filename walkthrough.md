# QA Agent OS - Walkthrough

This document outlines the features and components of the newly implemented **QA Agent OS**.

## 1. Specialized Agents
We have created 5 specialized agents to handle different aspects of the QA process:

| Agent | Role | Input | Output |
| :--- | :--- | :--- | :--- |
| **[Requirement Analyst](file:///Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/profiles/default/agents/requirement-analyst.md)** | Analyzes BRDs/PRDs for risks and ambiguities. | PRD Text | Risk Report, QA Breakdown |
| **[Test Case Generator](file:///Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/profiles/default/agents/test-case-generator.md)** | Creates comprehensive test cases. | QA Breakdown | Test Case Suite (Markdown) |
| **[Bug Writer](file:///Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/profiles/default/agents/bug-writer.md)** | Drafts professional bug reports. | Logs, Steps | Jira Ticket Description |
| **[Evidence Summarizer](file:///Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/profiles/default/agents/evidence-summarizer.md)** | Analyzes logs/screens for root cause. | Log Files | Root Cause Analysis |
| **[Integration Actions](file:///Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/profiles/default/agents/integration-actions.md)** | Handles API calls to Jira/Testmo. | API Payload | Success/Failure |

## 2. QA Standards
We have consolidated and defined strict standards to ensure quality and consistency:

- **[Test Case Standard](file:///Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/profiles/default/standards/testcases/test-case-standard.md)**: Defines the structure for Functional, API, and Regression tests.
- **[Bug Reporting Standard](file:///Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/profiles/default/standards/bugs/bug-reporting-standard.md)**: Defines severity levels, priority, and evidence requirements.
- **[BRD Analysis Standard](file:///Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/profiles/default/standards/requirement-analysis/brd-analysis.md)**: Guidelines for identifying risks in requirements.

## 3. Workflows
The **[QA Master Workflow](file:///Users/edmundo.figueroaherbas@medirect.com.mt/projects/personal/qa-agent-os/profiles/default/workflows/qa-workflow.md)** orchestrates the entire process:
1.  **Requirement Analysis**: User provides a feature description -> Agent identifies risks.
2.  **Test Generation**: Agent generates test cases based on the analysis.
3.  **Bug Reporting**: Agent analyzes logs and drafts a Jira ticket.

## 4. Integrations
- **Jira**: Commands to create issues and add comments.
- **Testmo**: Commands to create runs and upload results.
- **Gemini CLI**: Added full support for generating Gemini CLI commands via `gemini_commands: true` in `config.yml`.

## 5. Verification
To use this system:
1.  Ensure `config.yml` has your desired settings (Claude/Gemini).
2.  Run `scripts/project-install.sh` to install the agents and commands.
3.  Set your environment variables (`JIRA_API_TOKEN`, etc.).
4.  Run the `qa-workflow` command (e.g., `qa-agent-os qa-workflow` or via your AI assistant).
