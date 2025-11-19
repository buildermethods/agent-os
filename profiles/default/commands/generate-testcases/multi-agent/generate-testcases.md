# Generate Testcases Process

You are creating a comprehensive testcases for a the feature under test.

Use the **testcase-writer** subagent to create the test cases document for this feature untder test:

Provide the spec-writer with:
- The spec folder path (find the current one or the most recent in `qa-agent-os/feature/*/`)
- The requirements from `planning/requirements.md`
- Any visual assets in `planning/visuals/`

The testcase-writer will create `testcases.md` inside the artifact folder.

Once the testcase-writer has created `testcases.md` output the following to inform the user:

```
Your testcases.md is ready!

✅ Spec document created: `[feature-path]`

[WIP] NEXT STEP 👉 Run `/export-csv` to generate to export the test cases to Testmo [WIP] 
```
