# QA Standard – Bug Analysis

This standard guides the agent in analyzing a reported bug to determine its validity, scope, and root cause before attempting a fix.

## Analysis Steps

1.  **Reproduce the Issue**
    *   Can you reproduce it with the provided steps?
    *   If not, what variations did you try?

2.  **Isolate the Cause**
    *   Which component is likely responsible?
    *   Is it a frontend, backend, or data issue?
    *   Are there relevant logs or error messages?

3.  **Determine Scope**
    *   Does this affect all users or specific segments?
    *   Is it a regression? (Did it work before?)

4.  **Severity Assessment**
    *   **Critical**: Blocker, data loss, security vulnerability.
    *   **High**: Major functionality broken, no workaround.
    *   **Medium**: Functionality broken but workaround exists.
    *   **Low**: Cosmetic or minor annoyance.

## Output Format

When analyzing a bug, produce a summary in this format:

```markdown
### Bug Analysis: [Bug Title]

**Reproduction Status**: [Reproduced / Not Reproduced]
**Root Cause Hypothesis**: [Brief explanation]
**Affected Components**: [List of files/modules]
**Severity**: [Critical/High/Medium/Low]
**Proposed Fix Strategy**: [High-level approach]
```
