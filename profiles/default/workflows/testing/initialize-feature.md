# Feature Initialization Workflow

This workflow guides the agent in setting up the complete directory structure for testing a new feature, including the first ticket.

## Core Responsibilities

1.  **Gather Inputs**: Get the name of the feature and the ID of the first ticket.
2.  **Create Feature Directory**: Create the main feature folder with a date prefix.
3.  **Create Documentation Folder**: Create a folder for high-level documents (BRD, mockups).
4.  **Create Ticket Sub-Directory**: Create the nested structure for the first ticket to hold its specific planning and testing artifacts.

## Workflow

### Step 1: Get Feature Name and First Ticket ID

IF you were given a name for the feature and the ID for the first ticket, use them.

OTHERWISE, ask the user for the required information:

```
I can initialize the directory structure for a new feature. Please provide the following:

- **Feature Name:** A short, descriptive name for the feature (e.g., "User Profile Redesign").
- **First Ticket ID:** The ID of the first ticket associated with this feature (e.g., "PROJ-123").
```

**If you have not yet received both pieces of information from the user, WAIT until the user responds.**

### Step 2: Initialize Directory Structure

Once you have the feature name and ticket ID, execute the following to create the full directory structure.

```bash
# Get today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)

# Get user inputs (replace placeholders with actual values)
USER_FEATURE_NAME="[User-provided feature name]"
TICKET_ID="[User-provided ticket ID]"

# Create a kebab-case name for the directory from the user's feature name
KEBAB_FEATURE_NAME=$(echo "$USER_FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[ _]/-/g' | sed 's/[^a-z0-9-]//g')

# Create the dated top-level feature directory name
DATED_FEATURE_NAME="${TODAY}-${KEBAB_FEATURE_NAME}"

# Define the full paths
FEATURE_PATH="qa-agent-os/features/$DATED_FEATURE_NAME"
TICKET_PATH="$FEATURE_PATH/$TICKET_ID"

# Create all directories
mkdir -p "$FEATURE_PATH/documentation"
mkdir -p "$TICKET_PATH/planning"
mkdir -p "$TICKET_PATH/artifacts"

echo "Created feature directory structure: $FEATURE_PATH"
echo "Created ticket subdirectory: $TICKET_PATH"

# Pass the full feature path back to the parent command
echo "FEATURE_PATH=$FEATURE_PATH"
```

### Step 3: Output Confirmation

Return or output the following confirmation message, replacing placeholders with the actual paths you created:

```
Feature folder initialized at: `[FEATURE_PATH]`

The following structure has been created:
- `documentation/` - For the main BRD and mockups.
- `[TICKET_ID]/planning/` - For this ticket's requirement analysis.
- `[TICKET_ID]/artifacts/` - For this ticket's test cases and other artifacts.
```

## Important Constraints

- Always use the `YYYY-MM-DD-feature-name` format for the main feature folder.
- Follow the specified directory structure exactly.
- Wait for all required inputs before creating directories.
- Return the created paths clearly in the final confirmation.
