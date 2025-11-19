# Requirements Analising Process

You are helping me define and plan the scope of a feature testing.  The following process is aimed at documenting what we have to test a feature, can be BRD, tickets.

This process will follow 3 main phases, each with their own workflow steps:

Process overview (details to follow)

PHASE 1. Initilize feature testing
PHASE 2. Research requirements for this feature testing
PHASE 3. Inform the user that the feature testing has initialized

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process:

### PHASE 1: Initialize Feature

Use the **requirement-analyst** subagent to initialize a new feature testing.

IF the user has provided a description, provide that to the feature-initializer.

The feature-initializer will provide the path to the dated feature folder (YYYY-MM-DD-feature-name) they've created.

### PHASE 2: Research Requirements

After feature-initializer completes, immediately use the **requirement-analyst** subagent:

Provide the feature-shaper with:
- The feature folder path from feature-initializer

The feature-shaper will give you several separate responses that you MUST show to the user. These include:
1. Numbered clarifying questions along with a request for visual assets (show these to user, wait for user's response)
2. Follow-up questions if needed (based on user's answers and provided visuals)

**IMPORTANT**:
- Display these questions to the user and wait for their response
- The feature-shaper may ask you to relay follow-up questions that you must present to user

### PHASE 3: Inform the user

After all steps complete, inform the user:

```
feature shaping is complete!

✅ feature folder created: `[feature-path]`
✅ Requirements gathered
✅ Visual assets: [Found X files / No files provided]

NEXT STEP 👉 Run `/write-feature` to generate the detailed feature tewsting document.
```
