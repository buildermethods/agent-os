Now that the requirements for the ticket have been analyzed, the final step is to generate the test cases.

Follow these instructions to generate the test cases based on the analyzed requirements:

{{workflows/testing/testcase-generation}}

## Display confirmation and next step

Once you have generated the test cases and saved them to `artifacts/testcases.md`, output the following message:

```
✅ I have generated the test cases and saved them at `qa-agent-os/features/[feature-name]/[ticket-id]/artifacts/testcases.md`.

The analysis for this ticket is complete. You can now:
- Run `/analise-requirements` for the next ticket in this feature.
- Or, if all tickets are analyzed, proceed with reviewing the generated tests.
```
