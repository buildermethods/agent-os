# Test Case Generation

## Core Responsibilities

1. **AI help me to fill**
6. **Save Requirements**: Document the requirments you've gathered to a single file named: `[feature-path]/bugs/<date>_bug_title.md`


## Workflow

<!-- **Agent**: `Bug Writer`
**Input**: Logs / Screenshots
**Output**: Jira Ticket -->

1.  If a failure is detected or user reports a bug:
2.  Ask for logs/evidence.
3.  Pass to `Evidence Summarizer` for root cause analysis.
4.  Pass summary to `Bug Writer` to draft the report.
5.  Use `Integration Actions` to post to Jira (if confirmed).
