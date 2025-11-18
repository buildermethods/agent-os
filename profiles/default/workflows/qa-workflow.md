---
description: Standard workflow for executing QA tasks
---

# QA Workflow

This workflow guides you through the standard QA process, from analysis to reporting.

## 1. Analyze Requirements / Bug Report
*   **If Feature Testing**:
    *   Read the requirements/story.
    *   Identify key acceptance criteria.
    *   Check `test-plan-template.md` for strategy.
*   **If Bug Fix Verification**:
    *   Read the bug report.
    *   Use `bug-analysis.md` to analyze the issue.
    *   Attempt to reproduce the bug.

## 2. Plan Testing
*   **Create Test Cases**:
    *   Use `test-case-structure.md`.
    *   Ensure coverage of positive, negative, and edge cases.
*   **Prepare Data**:
    *   Identify or generate necessary test data.

## 3. Execute Tests
*   **Run Test Cases**:
    *   Execute each step carefully.
    *   Compare actual results with expected results.
*   **Log Results**:
    *   Pass/Fail status for each test case.
    *   Capture evidence (screenshots/logs) for failures.

## 4. Report Findings
*   **If Bugs Found**:
    *   Create a bug report using `bug-template.md`.
    *   Link to the relevant test case.
*   **Final Report**:
    *   Summarize testing activities.
    *   Provide a go/no-go recommendation.
