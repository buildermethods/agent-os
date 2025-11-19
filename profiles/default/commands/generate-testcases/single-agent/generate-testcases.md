Now that we've have planned, anilised , and got the requireents    for a the feature under test, we will now proceed with generating the test cases document, following these instructions:

{{workflows/testing/testcase-generation}}

## Display confirmation and next step

Display the following message to the user:

```
The testcases has been created at `qa-agent-os/features/[this-feature]/[ticket-id]/artifacts/testcases.md`.

Review it closely to ensure everything aligns with your vision and requirements.
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that the featureification document's content is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
