# Create Ticket Workflow

Use this workflow whenever a new ticket is assigned under an existing feature. It ensures the agent leverages the product mission, captures clarified requirements, and produces an executable test suite. The steps mirror running `/analise-requirements` followed by `/generate-testcases`.

## Step 0: Confirm Context
1. Load `qa-agent-os/product/mission.md` and note the **Team Ownership** table so you know which squad owns the surface.
2. Identify the feature folder created via `/init-feature` (e.g., `qa-agent-os/features/2025-11-19-twrr/`).
3. Capture the ticket identifier and ensure the ticket subfolder exists (`qa-agent-os/features/<feature>/<ticket-id>/`).

## Step 1: Requirement Analysis (`/analise-requirements`)

Run the requirement analysis workflow to capture clarified requirements, BRD links, visual assets, and risks.

{{workflows/testing/requirement-analysis}}

Deliverable: `[ticket]/planning/requirements.md`

## Step 2: Test Case Generation (`/generate-testcases`)

Using the freshly saved requirements, produce the test suite for this ticket.

{{workflows/testing/testcase-generation}}

Deliverable: `[ticket]/artifacts/testcases.md`

## Step 3: Confirm Handover
- Announce where requirements + test cases live.
- Note any open questions or dependencies back to the owning team (per the mission's team map).
- If more tickets remain under the same feature, repeat this workflow.


