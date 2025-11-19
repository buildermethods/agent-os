This begins a multi-step process for planning and documenting the mission for the current product.

The FIRST STEP is to confirm the product details by following these instructions:

{{workflows/planning/gather-product-info}}

Then WAIT for me to give you specific instructions on how to use the information you've gathered to create the mission.

{{UNLESS compiled_single_command}}
## Display confirmation and next step

Once you've gathered all of the necessary information, output the following message:

```
I have all the info I need to help you plan this product.

NEXT STEP → Run the command, `2-create-mission.md`
```
{{ENDUNLESS compiled_single_command}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

When planning the product's mission, use the user's standards and preferences for context and baseline assumptions, as documented in these files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
