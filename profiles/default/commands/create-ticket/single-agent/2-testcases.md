Now that the ticket requirements are saved, generate the executable test suite and store it with the ticket artifacts.

Follow these instructions (the same workflow executed by `/generate-testcases`):

{{workflows/testing/testcase-generation}}

## Display confirmation and wrap-up

Once you've created `artifacts/testcases.md`, output:

```
✅ Test cases generated at `qa-agent-os/features/[feature]/[ticket]/artifacts/testcases.md`.

Ticket package ready! You can now:
- Run `/create-ticket` again for the next ticket in this feature, or
- Move on to execution/reporting with these assets.
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

Ensure the tests follow the global and test case standards:

{{standards/global/*}}
{{standards/testcases/*}}
{{ENDUNLESS standards_as_claude_code_skills}}


