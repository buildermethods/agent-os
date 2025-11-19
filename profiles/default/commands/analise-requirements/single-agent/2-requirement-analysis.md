Now that you've initialized the folder for this new feature, proceed with the research phase, or requirement analysis.

Follow these instructions for researching this feature's requirements:

{{workflows/testing/requirement-analysis}}

## Display confirmation and next step

Once you've completed your research and documented it, output the following message:

```
✅ I have documented this feature testing research and requirements in `qa-agent-os/features/[this-feature]/planning`.

Next step: Run the command, `1-create-feature.md`. [AI Please check this part, I dont undrestand the logic here]
```

After all steps complete, inform the user:

```
feature initialized successfully!

✅ feature folder created: `[feature-path]`
✅ Requirements gathered
✅ Visual assets: [Found X files / No files provided]

👉 Run `/generate-testcases` to create the feature.md document.
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that your research questions and insights are ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
