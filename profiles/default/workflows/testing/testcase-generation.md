# Test Case Generation Workflow

This workflow guides the agent in generating a comprehensive suite of test cases for a specific ticket, based on its analyzed requirements.

## Core Responsibilities

1.  **Analyze Requirements**: Read and fully understand the `requirements.md` file for the ticket under test.
2.  **Generate Test Cases**: Based on the requirements, create a full suite of test cases, including positive, negative, and boundary conditions.
3.  **Save Test Cases**: Document the generated test cases in a structured Markdown file and save it to the correct directory.

**Note:** The placeholder `[ticket-path]` in this workflow refers to the full path to the ticket being analyzed, for example: `qa-agent-os/features/2025-11-19-feature-name/TICKET-123`.

---

## Workflow

### Step 1: Ingest Requirements

Read the detailed requirements from the ticket's `planning` directory.

```bash
# Set the path to the requirements file
REQUIREMENTS_FILE="[ticket-path]/planning/requirements.md"

# Read the file to use as context for the next step
cat $REQUIREMENTS_FILE
```

### Step 2: Generate Test Cases

Using the content of the `requirements.md` file as your context, generate a comprehensive set of test cases.

-   Adhere to the standards defined in `@qa-agent-os/standards/testcases/test-case-structure.md`.
-   Adhere to the standards defined in `@qa-agent-os/standards/testing/api-testing.md` for any API-related tests.
-   Include a mix of functional, UI, and edge case tests as appropriate.
-   Each test case must have a clear Title, Steps, and Expected Result.

### Step 3: Save the Test Cases

Save the generated test cases to a new file named `testcases.md` inside the ticket's `artifacts` directory.

```bash
# The path where the test cases will be saved
OUTPUT_FILE="[ticket-path]/artifacts/testcases.md"

# Write the generated content to the file
# (The agent will use its 'Write' tool to perform this action)
```
