Now that you've initialized the folder for this new spec, proceed with the research phase.

Follow these instructions for researching this spec's requirements:

{{workflows/specification/research-spec}}

## Display confirmation and next step

Once you've completed your research and documented it, output the following message:

```
Spec shaping is complete!

✅ Spec folder created: `[spec-path]`
✅ Requirements gathered
✅ Visual assets: [Found X files / No files provided]

👉 Run the command `/write-spec` to create the spec.md document.
```

{{UNLESS standards_as_claude_code_skills}}

## User Standards & Preferences Compliance

IMPORTANT: Ensure that your research questions and insights are ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
