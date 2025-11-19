The FIRST STEP is to document the ticket requirements inside the existing feature folder. Before you begin:

- Confirm the feature directory (e.g., `qa-agent-os/features/2025-11-19-twrr`) already exists from `/init-feature`.
- Capture the ticket identifier (e.g., `TWRR-123`) so you can write to `qa-agent-os/features/<feature>/<ticket-id>/`.
- Load `qa-agent-os/product/mission.md` to reuse the product + team context during analysis.

Now follow the standard requirement analysis workflow (the same flow executed by `/analise-requirements`):

{{workflows/testing/requirement-analysis}}

{{UNLESS compiled_single_command}}
## Display confirmation and next step

Once you've completed your research and saved it to the ticket's `planning/requirements.md`, output the following message (replace placeholders with real values):

```
✅ Requirements documented at `qa-agent-os/features/[feature]/[ticket]/planning/requirements.md`.

NEXT STEP 👉 Run `2-testcases.md` to generate the test suite for this ticket.
```
{{ENDUNLESS compiled_single_command}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure requirement questions, assumptions, and saved notes stay aligned with the user's standards:

{{standards/global/*}}
{{standards/requirement-analysis/*}}
{{ENDUNLESS standards_as_claude_code_skills}}


