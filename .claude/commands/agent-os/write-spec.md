# Spec Writing Process

You are creating a comprehensive specification for a new feature.

Use the **spec-writer** subagent to create the specification document for this spec:

Provide the spec-writer with:
- The spec folder path (find the current one or the most recent in `agent-os/specs/*/`)
- The requirements from `planning/requirements.md`
- Any visual assets in `planning/visuals/`

The spec-writer will create `spec.md` inside the spec folder.

Once the spec-writer has created `spec.md` output the following to inform the user:

```
Your spec.md is ready!

✅ Spec document created: `[spec-path]`

NEXT STEP 👉 Run `/create-tasks` to generate your tasks list for this spec.
```
