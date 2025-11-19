Now that you've initialized the folder for this new feature, proceed with the research phase, or requirement analysis.

Follow these instructions for researching this feature's requirements:

{{workflows/testing/requirement-analysis}}

{{UNLESS compiled_single_command}}
## Display confirmation and next step

Once you've completed your research and documented it, output the following message:

```
✅ I have documented this feature testing research and requirements in `qa-agent-os/features/[this-feature]/planning`.

NEXT STEP 👉 Run the command, `3-generate-testcases`.
```
{{ENDUNLESS compiled_single_command}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that your research questions and insights are ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
