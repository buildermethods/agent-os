# QA Agent OS Implementation Plan

## 1. Objective

To fully align the `qa-agent-os` project with the architecture and workflow defined in `VISION.md`. This involves correcting the installation scripts, creating the necessary directory structures, ensuring the default profile contains all the required commands and logic for a QA engineer's workflow, and refining existing commands/workflows for clarity and correctness.

## 2. Diagnosis of Gaps (Summary)

Our initial analysis revealed several key gaps between the project's vision and its current implementation:

1.  **Missing Core Directories:** The `project-install.sh` script failed to create the essential `qa-agent-os/product/` and `qa-agent-os/features/` directories, which are central to the Product and Specs layers of the vision.
2.  **Confusing/Redundant Command Installation:** The `project-install.sh` included an `agent_os_commands` option that installed commands to a generic folder, conflicting with the `.claude/commands/` structure and streamlining efforts.
3.  **Path Mismatches in Compilation:** The `common-functions.sh` script contained hardcoded `@agent-os/` paths in its `process_phase_tags` and `process_standards` functions, leading to broken references with the intended `@qa-agent-os/` paths.
4.  **Incomplete/Broken Command Suite:**
    *   The `/analise-requirements` command was critically broken, referencing a non-existent phase file and containing faulty logical flow.
    *   The `/generate-testcases` command was confused about its output location and file naming.
    *   A critical command, `/init-feature`, was missing entirely from the default profile.
5.  **Content Gaps in Standards:** An API testing standard was noted as missing, which is important for comprehensive test case generation.
6.  **Workflows Need Refinement:** Existing workflow files contained typos, unclear instructions, or references that needed to be updated to match the new directory structure and command logic.

## 3. Step-by-Step Implementation & Progress

This section details the actions taken to resolve the identified gaps.

### Step 1: Modify Installation Scripts (`scripts/project-install.sh` & `scripts/common-functions.sh`)

**Status: COMPLETED**

-   **Action 1.1 (project-install.sh):** Modified the `create_agent_os_folder` function to explicitly create `qa-agent-os/product/` and `qa-agent-os/features/` subdirectories.
-   **Action 1.2 & 1.3 (project-install.sh):** Removed the redundant `install_agent_os_commands` function and all associated references (flags, `load_configuration`, `perform_installation` calls) to streamline the installation to Claude-centric commands.
-   **Action 1.4 (common-functions.sh):** Corrected the hardcoded path `s/.*@agent-os\/commands\///` to `s/.*@qa-agent-os\/commands\///` in `process_phase_tags`.
-   **Action 1.5 (common-functions.sh):** Corrected the hardcoded `@agent-os/` to `@qa-agent-os/` in the `process_standards` function for output paths.

### Step 2: Create and Align Default Profile Commands (`profiles/default/commands/`)

**Status: COMPLETED**

-   **Action 2.1:** Created the directory structure for the new `/init-feature` command: `profiles/default/commands/init-feature/single-agent/`.
-   **Action 2.2:** Created the main command file `profiles/default/commands/init-feature/single-agent/init-feature.md`, defining its role in initializing the feature and ticket directories.
-   **Action 2.3:** Created the missing `3-generate-testcases.md` phase file for `/analise-requirements`: `profiles/default/commands/analise-requirements/single-agent/3-generate-testcases.md`.
-   **Action 2.4:** Fixed the master `analise-requirements.md` file to correctly reference the new phase 3 and removed user comments.
-   **Action 2.5:** Fixed the broken logic in `profiles/default/commands/analise-requirements/single-agent/2-requirement-analysis.md`, updating its "next step" instructions.
-   **Action 2.6:** Corrected the path bug in `profiles/default/commands/analise-requirements/single-agent/1-initialize-feature.md`'s confirmation message (singular 'feature' to plural 'features').
-   **Action 2.7:** Fixed the `profiles/default/commands/generate-testcases/single-agent/generate-testcases.md` command by updating its confirmation message to correctly point to `qa-agent-os/features/[feature-name]/[ticket-id]/artifacts/testcases.md` and removing WIP comments.

### Step 3: Align Default Profile Standards (`profiles/default/standards/`)

**Status: COMPLETED**

-   **Action 3.1:** Created the missing API testing standard file: `profiles/default/standards/testing/api-testing.md`.

### Step 4: Review and Refine Workflows (`profiles/default/workflows/`)

**Status: COMPLETED**

-   **Action 4.1:** Rewrote `profiles/default/workflows/testing/initialize-feature.md` to be more robust, prompting for feature name and first ticket ID, and creating the full nested directory structure (`documentation/`, `[TICKET_ID]/planning/`, `[TICKET_ID]/artifacts/`).
-   **Action 4.2:** Refined `profiles/default/workflows/testing/requirement-analysis.md` for clarity, consistency, removal of user comments, and correct placeholder usage, ensuring it targets a specific ticket.
-   **Action 4.3:** Rewrote `profiles/default/workflows/testing/testcase-generation.md` to correctly ingest requirements from a ticket's `planning` folder and save test cases to the corresponding `artifacts` folder, using correct paths.

## 4. Next Steps

-   **Final Review:** Conduct a comprehensive final review of all implemented changes against the `VISION.md` to ensure full alignment and consistency.
-   **Testing:** Recommend running the `project-install.sh` script in a test project and verifying the created structure and compiled command outputs.
