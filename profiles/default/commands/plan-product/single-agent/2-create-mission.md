Now that you've gathered information about this product, use that info to create the mission document in `qa-agent-os/product/mission.md` by following these instructions:

{{workflows/planning/create-product-mission}}

{{UNLESS compiled_single_command}}
## Display confirmation and next step

Once you've created mission.md, output the following message:

```
✅ I have documented the product mission at `qa-agent-os/product/mission.md`.

Review it to ensure it matches your vision and strategic goals for this product.

You're ready to begin the feature workflow. Next, run `/init-feature` to stand up the dated feature directory before diving into tickets.
```
{{ENDUNLESS compiled_single_command}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure the product mission is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
