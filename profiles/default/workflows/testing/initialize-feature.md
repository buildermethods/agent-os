# Feature testing Initialization Specs

## Core Responsibilities

1. **Get the description of the feature:** Receive it from the user 
2. **Initialize Feature Testing Structure**: Create the feature testing folder with date prefix
3. **Save Raw Idea**: Document the user's exact description without modification
4. **Create Create Implementation & Verification Folders**: Setup folder structure for tracking implementation of this feature testing.
5. **Prepare for Requirements**: Set up structure for next phase

## Workflow

### Step 1: Get the description of the feature

IF you were given a description of the feature, then use that to initiate a new feature to testing specs.

OTHERWISE ask the use what is going to be the new feature to test:

```
What feature to test would you like to start testing?

- provide a description of the feature you'd like to start testing.
```

**If you have not yet received a description from the user, WAIT until user responds.**

### Step 2: Initialize Spec Structure

Determine a kebab-case spec name from the user's description, then create the spec folder:

```bash
# Get today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)

# Determine kebab-case spec name from user's description
FEAUTRE_NAME="[kebab-case-name]"

# Create dated folder name
DATED_FEAUTRE_NAME="${TODAY}-${FEAUTRE_NAME}"

# Store this path for output
FEATURE_PATH="qa-agent-os/features/$DATED_FEAUTRE_NAME"

# Create folder structure following architecture
mkdir -p $FEATURE_PATH/planning
mkdir -p $FEATURE_PATH/planning/visuals

echo "Created feature testing spec folder: $FEATURE_PATH"
```

### Step 3: Create artifacts testing Folder

Create 2 folders:
- `$FEATURE_PATH/artifacts/`

Leave this folder empty, for now. Later, this folder will be populated with testing artifacts, documention from agents.

### Step 4: Output Confirmation

Return or output the following:

```
Feature testing folder initialized: `[feature-path]`

Structure created:
- planning/ - For requirements and specifications
- planning/visuals/ - For mockups and screenshots
- artifacts/ - For artifacts testing documentation

Ready for requirements research phase.
```

## Important Constraints

- Always use dated folder names (YYYY-MM-DD-spec-name)
- Pass the exact featyre path back to the orchestrator
- Follow folder structure exactly
- Implementation folder should be empty, for now
