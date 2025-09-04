# Create Spec

## Quick Navigation
- [Description](#description)
- [Parameters](#parameters)
- [Dependencies](#dependencies)
- [Task Tracking](#task-tracking)
- [Core Instructions](#core-instructions)
- [State Management](#state-management)
- [Error Handling](#error-handling)
- [Subagent Integration](#subagent-integration)

## Description
Create a detailed spec for a new feature with technical specifications and task breakdown. This command guides through the complete specification creation process from initial idea to review-ready documentation.

## Parameters
- `feature_concept` (optional): Initial feature idea or description (can be provided interactively)
- `scope_mode` (optional): "roadmap_next" for next roadmap item or "custom" for user-defined feature

## Dependencies
**Required State Files:**
- `.agent-os/product/mission-lite.md` (read for context alignment)
- `.agent-os/product/tech-stack.md` (read for technical constraints)
- `.agent-os/product/roadmap.md` (read for roadmap integration)

**Expected Directories:**
- `.agent-os/product/` (product documentation)
- `.agent-os/standards/` (coding standards)

**Creates Directories:**
- `.agent-os/specs/YYYY-MM-DD-spec-name/` (new spec folder)
- `.agent-os/specs/YYYY-MM-DD-spec-name/sub-specs/` (technical specifications)

## Task Tracking
**IMPORTANT: Use Claude's TodoWrite tool throughout execution:**
```javascript
// Example todos for this command workflow
const todos = [
  { content: "Check pre-flight requirements", status: "pending", activeForm: "Checking pre-flight requirements" },
  { content: "Initiate spec creation process", status: "pending", activeForm: "Initiating spec creation process" },
  { content: "Gather product context", status: "pending", activeForm: "Gathering product context" },
  { content: "Clarify requirements and scope", status: "pending", activeForm: "Clarifying requirements and scope" },
  { content: "Determine current date for naming", status: "pending", activeForm: "Determining current date for naming" },
  { content: "Create spec folder structure", status: "pending", activeForm: "Creating spec folder structure" },
  { content: "Generate main specification document", status: "pending", activeForm: "Generating main specification document" },
  { content: "Create lite specification summary", status: "pending", activeForm: "Creating lite specification summary" },
  { content: "Build technical specification", status: "pending", activeForm: "Building technical specification" },
  { content: "Generate database schema if needed", status: "pending", activeForm: "Generating database schema if needed" },
  { content: "Create API specification if needed", status: "pending", activeForm: "Creating API specification if needed" },
  { content: "Request user review and approval", status: "pending", activeForm: "Requesting user review and approval" }
];
// Update status to "in_progress" when starting each task
// Mark as "completed" immediately after finishing
```

## For Claude Code
When executing this command:
1. **Initialize TodoWrite** with the workflow steps above for visibility
2. Follow the embedded instructions below completely
3. Use Task tool to invoke subagents as specified
4. Handle conditional logic for database and API specs
5. **Update TodoWrite** status throughout execution
6. Ensure user approval before proceeding to create-tasks

---

## SECTION: Core Instructions
<!-- BEGIN EMBEDDED CONTENT -->

# Spec Creation Rules

## Overview

Generate detailed feature specifications aligned with product roadmap and mission.

## Process Flow

### Step 1: Spec Initiation

Use the context-fetcher subagent to identify spec initiation method by either finding the next uncompleted roadmap item when user asks "what's next?" or accepting a specific spec idea from the user.

**Option A Flow:**
- **Trigger phrases**: "what's next?"
- **Actions**:
  1. CHECK @.agent-os/product/roadmap.md
  2. FIND next uncompleted item
  3. SUGGEST item to user
  4. WAIT for approval

**Option B Flow:**
- **Trigger**: user describes specific spec idea
- **Accept**: any format, length, or detail level
- **Proceed**: to context gathering

### Step 2: Context Gathering (Conditional)

Use the context-fetcher subagent to read @.agent-os/product/mission-lite.md and @.agent-os/product/tech-stack.md only if not already in context to ensure minimal context for spec alignment.

**Conditional Logic:**
```
IF both mission-lite.md AND tech-stack.md already read in current context:
  SKIP this entire step
  PROCEED to step 3
ELSE:
  READ only files not already in context:
    - mission-lite.md (if not in context)
    - tech-stack.md (if not in context)
  CONTINUE with context analysis
```

**Context Analysis:**
- **mission_lite**: core product purpose and value
- **tech_stack**: technical requirements

### Step 3: Requirements Clarification

Use the context-fetcher subagent to clarify scope boundaries and technical considerations by asking numbered questions as needed to ensure clear requirements before proceeding.

**Clarification Areas:**
- **Scope**:
  - in_scope: what is included
  - out_of_scope: what is excluded (optional)
- **Technical**:
  - functionality specifics
  - UI/UX requirements
  - integration points

**Decision Tree:**
```
IF clarification_needed:
  ASK numbered_questions
  WAIT for_user_response
ELSE:
  PROCEED to_date_determination
```

### Step 4: Date Determination

Use the date-checker subagent to determine the current date in YYYY-MM-DD format for folder naming. The subagent will output today's date which will be used in subsequent steps.

**Subagent Output:**
The date-checker subagent will provide the current date in YYYY-MM-DD format at the end of its response. Store this date for use in folder naming in step 5.

### Step 5: Spec Folder Creation

Use the file-creator subagent to create directory: .agent-os/specs/YYYY-MM-DD-spec-name/ using the date from step 4.

Use kebab-case for spec name. Maximum 5 words in name.

**Folder Naming:**
- **Format**: YYYY-MM-DD-spec-name
- **Date**: use stored date from step 4
- **Name Constraints**:
  - max_words: 5
  - style: kebab-case
  - descriptive: true

**Example Names:**
- 2025-03-15-password-reset-flow
- 2025-03-16-user-profile-dashboard
- 2025-03-17-api-rate-limiting

### Step 6: Create spec.md

Use the file-creator subagent to create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec.md using this template:

**File Template Header:**
```markdown
# Spec Requirements Document

> Spec: [SPEC_NAME]
> Created: [CURRENT_DATE]
```

**Required Sections:**
- Overview
- User Stories
- Spec Scope
- Out of Scope
- Expected Deliverable

**Section Templates:**

**Overview:**
```markdown
## Overview

[1-2_SENTENCE_GOAL_AND_OBJECTIVE]
```
- Length: 1-2 sentences
- Content: goal and objective
- Example: Implement a secure password reset functionality that allows users to regain account access through email verification. This feature will reduce support ticket volume and improve user experience by providing self-service account recovery.

**User Stories:**
```markdown
## User Stories

### [STORY_TITLE]

As a [USER_TYPE], I want to [ACTION], so that [BENEFIT].

[DETAILED_WORKFLOW_DESCRIPTION]
```
- Count: 1-3 stories
- Include: workflow and problem solved
- Format: title + story + details

**Spec Scope:**
```markdown
## Spec Scope

1. **[FEATURE_NAME]** - [ONE_SENTENCE_DESCRIPTION]
2. **[FEATURE_NAME]** - [ONE_SENTENCE_DESCRIPTION]
```
- Count: 1-5 features
- Format: numbered list
- Description: one sentence each

**Out of Scope:**
```markdown
## Out of Scope

- [EXCLUDED_FUNCTIONALITY_1]
- [EXCLUDED_FUNCTIONALITY_2]
```
- Purpose: explicitly exclude functionalities

**Expected Deliverable:**
```markdown
## Expected Deliverable

1. [TESTABLE_OUTCOME_1]
2. [TESTABLE_OUTCOME_2]
```
- Count: 1-3 expectations
- Focus: browser-testable outcomes

### Step 7: Create spec-lite.md

Use the file-creator subagent to create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md for the purpose of establishing a condensed spec for efficient AI context usage.

**File Template:**
```markdown
# Spec Summary (Lite)
```

**Content Structure:**
- **Spec Summary**:
  - Source: Step 6 spec.md overview section
  - Length: 1-3 sentences
  - Content: core goal and objective of the feature

**Content Template:**
[1-3_SENTENCES_SUMMARIZING_SPEC_GOAL_AND_OBJECTIVE]

**Example:**
Implement secure password reset via email verification to reduce support tickets and enable self-service account recovery. Users can request a reset link, receive a time-limited token via email, and set a new password following security best practices.

### Step 8: Create Technical Specification

Use the file-creator subagent to create the file: sub-specs/technical-spec.md using this template:

**File Template:**
```markdown
# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
```

**Spec Sections:**
- **Technical Requirements**:
  - functionality details
  - UI/UX specifications
  - integration requirements
  - performance criteria
- **External Dependencies (Conditional)**:
  - only include if new dependencies needed
  - new libraries/packages
  - justification for each
  - version requirements

**Example Template:**
```markdown
## Technical Requirements

- [SPECIFIC_TECHNICAL_REQUIREMENT]
- [SPECIFIC_TECHNICAL_REQUIREMENT]

## External Dependencies (Conditional)

[ONLY_IF_NEW_DEPENDENCIES_NEEDED]
- **[LIBRARY_NAME]** - [PURPOSE]
- **Justification:** [REASON_FOR_INCLUSION]
```

**Conditional Logic:**
```
IF spec_requires_new_external_dependencies:
  INCLUDE "External Dependencies" section
ELSE:
  OMIT section entirely
```

### Step 9: Create Database Schema (Conditional)

Use the file-creator subagent to create the file: sub-specs/database-schema.md ONLY IF database changes needed for this task.

**Decision Tree:**
```
IF spec_requires_database_changes:
  CREATE sub-specs/database-schema.md
ELSE:
  SKIP this_step
```

**File Template:**
```markdown
# Database Schema

This is the database schema implementation for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
```

**Schema Sections:**
- **Changes**:
  - new tables
  - new columns
  - modifications
  - migrations
- **Specifications**:
  - exact SQL or migration syntax
  - indexes and constraints
  - foreign key relationships
- **Rationale**:
  - reason for each change
  - performance considerations
  - data integrity rules

### Step 10: Create API Specification (Conditional)

Use the file-creator subagent to create file: sub-specs/api-spec.md ONLY IF API changes needed.

**Decision Tree:**
```
IF spec_requires_api_changes:
  CREATE sub-specs/api-spec.md
ELSE:
  SKIP this_step
```

**File Template:**
```markdown
# API Specification

This is the API specification for the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
```

**API Sections:**
- **Routes**:
  - HTTP method
  - endpoint path
  - parameters
  - response format
- **Controllers**:
  - action names
  - business logic
  - error handling
- **Purpose**:
  - endpoint rationale
  - integration with features

**Endpoint Template:**
```markdown
## Endpoints

### [HTTP_METHOD] [ENDPOINT_PATH]

**Purpose:** [DESCRIPTION]
**Parameters:** [LIST]
**Response:** [FORMAT]
**Errors:** [POSSIBLE_ERRORS]
```

### Step 11: User Review

Request user review of spec.md and all sub-specs files, waiting for approval or revision requests.

**Review Request:**
```
I've created the spec documentation:

- Spec Requirements: @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
- Spec Summary: @.agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md
- Technical Spec: @.agent-os/specs/YYYY-MM-DD-spec-name/sub-specs/technical-spec.md
[LIST_OTHER_CREATED_SPECS]

Please review and let me know if any changes are needed.

When you're ready, run the /create-tasks command to have me build the tasks checklist from this spec.
```

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

### State Operations
All spec creation uses basic file operations with conditional overwrites:

```javascript
// Check for existing specs
const specExists = checkSpecExists(specPath);
if (specExists) {
  // Prompt user for overwrite confirmation
  const confirmed = promptOverwrite();
  if (!confirmed) return;
}

// Create spec directory structure
const specFolder = `.agent-os/specs/${dateString}-${kebabCaseName}`;
createDirectory(specFolder);
createDirectory(`${specFolder}/sub-specs`);

// Track creation progress
const creationState = {
  spec_folder: specFolder,
  created_files: [],
  conditional_files: {
    database_schema: needsDbSchema,
    api_spec: needsApiSpec
  }
};
```

### File Creation Tracking
- Track all created files for cleanup on failure
- Store file creation sequence for rollback
- Maintain checksums for content validation
- Log creation timestamps for audit trail

---

## SECTION: Error Handling

### Error Recovery Procedures

1. **File Creation Failures**:
   - Roll back any partially created files
   - Clean up empty directories
   - Preserve user input for retry
   - Report specific failure cause

2. **Template Generation Errors**:
   - Fall back to minimal template structure
   - Allow manual content entry
   - Preserve completed sections
   - Continue with remaining sections

3. **Context Gathering Failures**:
   - Use cached context from previous sessions
   - Allow proceeding with reduced context
   - Prompt for missing critical information
   - Document context limitations

4. **Date/Naming Conflicts**:
   - Generate alternative folder names
   - Append disambiguation suffix
   - Prompt user for preferred naming
   - Validate name availability

5. **User Review Timeout**:
   - Save work in progress
   - Allow resumption from any step
   - Preserve all generated content
   - Provide clear resumption instructions

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- `context-fetcher` for reading product documentation and gathering requirements
- `date-checker` for determining current date in proper format
- `file-creator` for creating specification files and directory structure