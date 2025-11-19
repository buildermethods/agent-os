# QA Agent OS Implementation Plan

## 1. Objective

To fully align the `qa-agent-os` project with the architecture and workflow defined in `VISION.md`. This involves correcting the installation scripts, creating the necessary directory structures, and ensuring the default profile contains all the required commands and logic for a QA engineer's workflow.

## 2. Diagnosis of Gaps (Summary)

Our analysis revealed four key gaps between the project's vision and its current implementation:

1.  **Incomplete Command Suite:** The `profiles/default/commands` directory is missing commands that are critical to the workflow described in `VISION.md`, such as `/init-feature` and `/generate-testcases`.

## 3. Step-by-Step Implementation

This plan will be executed sequentially to resolve the identified gaps.

### Step 1: Align `profiles/default/` Content

The source profile must be updated to include the commands and structure that the new installation script will expect.

-   **Action 1.1:** Create a new command directory for `/init-feature` at `profiles/default/commands/init-feature/`.
-   **Action 1.2:** Create the main command file `profiles/default/commands/init-feature/init-feature.md`. This file will contain the prompt and logic for creating a new feature directory (e.g., `YYYY-MM-DD-FeatureName`) inside `qa-agent-os/features/`.
-   **Action 1.3:** Create a new command directory for `/generate-testcases` at `profiles/default/commands/generate-testcases/`.
-   **Action 1.4:** Create the main command file for generating test cases. This will be an update to the existing `profiles/default/commands/generate-testcases/single-agent/generate-testcases.md`.
-   **Action 1.5:** Update the existing `/analise-requirements` command (`profiles/default/commands/analise-requirements/single-agent/analise-requirements.md`) to be aware of the new `qa-agent-os/features/` structure.

### Step 2: Review and Refine Workflows & Agents

Ensure the high-level workflow and agent definitions are consistent with the new command structure.

-   **Action 2.1:** Review files in `profiles/default/workflows/` (e.g., `testing/requirement-analysis.md`) to ensure they reference the new and updated commands correctly.
-   **Action 2.2:** Review files in `profiles/default/agents/` (e.g., `requirement-analyst.md`) to ensure their purpose and prompts align with the tasks they will perform within the new structure.

By completing these steps, the `qa-agent-os` will be fully functional and capable of deploying the end-to-end QA workflow described in the `VISION.md` document.
