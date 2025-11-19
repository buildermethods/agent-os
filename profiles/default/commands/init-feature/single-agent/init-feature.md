You are initializing a new feature for testing. Your task is to create a dedicated directory for this feature inside the `qa-agent-os/features/` folder.

Follow these instructions:

{{workflows/testing/initialize-feature}}

## Display confirmation and next step

Once you have created the feature directory, output the following message, replacing `[feature-directory-name]` with the name of the directory you created:

```
✅ I have initialized the feature folder at `qa-agent-os/features/[feature-directory-name]`.

This folder contains:
- `documentation/` for the BRD and mockups.
- A subdirectory for the first ticket associated with this feature.

NEXT STEP 👉 Run the `/analise-requirements` command for the first ticket to begin the requirement analysis process. For example:
`/analise-requirements --feature [feature-directory-name] --ticket TWRR-123`
```
