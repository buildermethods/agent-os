---
description: Commands for interacting with Testmo API.
---

# Testmo Integration Commands

These commands allow the agent to interact with Testmo.
**Prerequisites**: `TESTMO_BASE_URL` and `TESTMO_API_TOKEN` must be set in the environment.

## Create Run

Create a new test run in Testmo.

```bash
# Usage: create_testmo_run <project_id> <name> <source>
create_testmo_run() {
    local project_id="$1"
    local name="$2"
    local source="$3"

    curl -s -X POST "$TESTMO_BASE_URL/api/v1/projects/$project_id/automation/runs" \
      -H "Authorization: Bearer $TESTMO_API_TOKEN" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      --data "{
        \"name\": \"$name\",
        \"source\": \"$source\"
      }"
}
```

## Upload Results

Upload JUnit XML results to a run.

```bash
# Usage: upload_testmo_results <run_id> <file_path>
upload_testmo_results() {
    local run_id="$1"
    local file_path="$2"

    curl -s -X POST "$TESTMO_BASE_URL/api/v1/automation/runs/$run_id/threads" \
      -H "Authorization: Bearer $TESTMO_API_TOKEN" \
      -H "Accept: application/json" \
      -F "file=@$file_path"
}
```
