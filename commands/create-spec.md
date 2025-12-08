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
  { content: "Create content mapping if needed", status: "pending", activeForm: "Creating content mapping if needed" },
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

Use the Explore agent (native) to identify spec initiation method by either finding the next uncompleted roadmap item when user asks "what's next?" or accepting a specific spec idea from the user.

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

Use the Explore agent (native) to read @.agent-os/product/mission-lite.md and @.agent-os/product/tech-stack.md only if not already in context to ensure minimal context for spec alignment.

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

### Step 3: Requirements Clarification (brainstorming skill)

Use the brainstorming skill to explore approaches and refine requirements through Socratic questioning.

**Core Principle:** UNDERSTAND BEFORE DESIGNING

**Brainstorming Workflow:**
```
ACTION: brainstorming skill invoked for complex features
APPROACH:
  1. Ask ONE question at a time (avoid overwhelming)
  2. Provide multiple-choice options when possible
  3. Present 2-3 approaches with trade-offs
  4. Validate understanding incrementally
```

**Questions to Explore:**
- What problem does this feature solve?
- Who are the primary users?
- What are the success criteria?
- Are there hard constraints (performance, compatibility)?
- What's explicitly out of scope?

**Approach Exploration (for complex features):**
```
IF multiple_valid_approaches:
  GENERATE: 2-3 distinct approaches
  PRESENT: Trade-offs for each (pros, cons, complexity)
  RECOMMEND: One approach with reasoning
  VALIDATE: User agreement before proceeding
```

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
  ASK numbered_questions (one at a time)
  WAIT for_user_response
ELSE:
  PROCEED to_date_determination
```

### Step 4: Date Determination

Use the current date from the environment context in YYYY-MM-DD format for folder naming.

**Date Source:**
Claude Code provides "Today's date: YYYY-MM-DD" in every session context. Use this date for folder naming in step 5.

### Step 5: Spec Folder Creation

Create the directory: .agent-os/specs/YYYY-MM-DD-spec-name/ using the date from step 4.

**Directory Creation:**
```bash
mkdir -p .agent-os/specs/YYYY-MM-DD-spec-name/sub-specs
```

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

Create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec.md using the Write tool with this template:

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

Create the file: .agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md using the Write tool. Purpose: condensed spec for efficient AI context usage.

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

Create the file: sub-specs/technical-spec.md using the Write tool with this template:

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

Create the file: sub-specs/database-schema.md using the Write tool ONLY IF database changes needed for this task.

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

Create the file: sub-specs/api-spec.md using the Write tool ONLY IF API changes needed.

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

### Step 10.5: Create Content Mapping (Conditional)

Create the file: sub-specs/content-mapping.md using the Write tool ONLY IF external content is referenced.

**Decision Tree:**
```
IF spec_references_external_content:
  CREATE sub-specs/content-mapping.md
ELSE:
  SKIP this_step
```

**Content Detection:**
Check if the spec requires external content such as:
- **Static Content**: Images, videos, audio, documents, PDFs
- **Data Files**: JSON, CSV, XML, YAML, datasets
- **Templates**: Email templates, document templates, content structures
- **External Resources**: Fonts, third-party assets, CMS content

**Decision Logic:**
```
CHECK spec.md and technical-spec.md for mentions of:
  - "image", "photo", "graphic", "icon", "logo"
  - "data file", "JSON", "CSV", "dataset"
  - "document", "PDF", "template"
  - "video", "audio", "media"
  - "content", "copy", "assets"

IF any_content_mentioned OR user_provides_content_files:
  ASK: "This feature references external content. Please provide:
        1. List of content files or directories with paths
        2. Purpose of each content item
        3. Current location of content (if it exists)

        Or reply 'none' if no external content is needed."

  WAIT: For user response

  IF user_provides_content_details:
    ACTION: Create file using Write tool
    CREATE: sub-specs/content-mapping.md
    NOTE: Add reference to content-mapping.md in spec.md
  ELSE:
    SKIP: Content mapping creation
ELSE:
  SKIP: This entire step
```

**File Template:**
```markdown
# Content Mapping

This document maps all external content referenced by the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md

## Overview

[Brief description of what content is needed and why]

## Content Categories

### [CATEGORY_NAME]

#### Purpose
[What this content is used for in the feature]

#### Content Items

**[ITEM_NAME]**
- **Path**: `[EXACT_FILE_PATH]`
- **Type**: [FILE_TYPE]
- **Description**: [WHAT_IT_CONTAINS]
- **Usage**: [HOW_TO_USE_IN_IMPLEMENTATION]
- **Dimensions/Size**: [IF_APPLICABLE]
- **Reference Name**: `[EXACT_NAME_TO_USE_IN_CODE]`

[REPEAT_FOR_EACH_CONTENT_ITEM]

## Implementation Guidelines

### File Path References
[Instructions on how to reference these files in code]

Example:
```typescript
// Import pattern
import [referenceName] from '[path]'
```

### Content Processing
[Any transformations, optimizations, or processing needed]

### Validation Rules
[How to verify content is correctly integrated]

## Content Checklist

- [ ] All content files exist at specified paths
- [ ] File formats match specifications
- [ ] Content is optimized for production
- [ ] References use exact names from this mapping
```

**Content Organization:**
Organize content into logical categories such as:
- **Images**: Hero images, product photos, icons, logos
- **Data**: JSON datasets, CSV files, configuration files
- **Documents**: PDFs, markdown files, text content
- **Media**: Videos, audio files
- **Templates**: Email templates, content structures

**Key Requirements:**
1. **Exact Paths**: Provide precise file paths relative to project root
2. **Reference Names**: Define exact variable/constant names to use in code
3. **Implementation Guidelines**: Include import patterns and usage examples
4. **Validation**: Create checklist for verifying correct integration

**Example Content Items:**

For images:
```markdown
**Hero Background Image**
- **Path**: `public/images/hero/main-background.jpg`
- **Type**: JPEG image
- **Description**: Full-width hero background showing product in use
- **Usage**: Background image for hero section
- **Dimensions**: 1920x1080px (16:9 aspect ratio)
- **Reference Name**: `heroBackground`
```

For data files:
```markdown
**Product Data**
- **Path**: `data/products.json`
- **Type**: JSON dataset
- **Description**: Array of product objects with id, name, price, description
- **Usage**: Load and display in product listing page
- **Schema**: `{ id: number, name: string, price: number, description: string }[]`
- **Reference Name**: `productsData`
```

For documents:
```markdown
**Marketing Copy**
- **Path**: `content/marketing/landing-page-copy.md`
- **Type**: Markdown document
- **Description**: Marketing text organized by section (hero, features, testimonials)
- **Usage**: Import and display in respective page sections
- **Reference Name**: `landingPageCopy`
```

### Step 11: User Review

Request user review of spec.md and all sub-specs files, waiting for approval or revision requests.

**Review Request:**
```
I've created the spec documentation:

- Spec Requirements: @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md
- Spec Summary: @.agent-os/specs/YYYY-MM-DD-spec-name/spec-lite.md
- Technical Spec: @.agent-os/specs/YYYY-MM-DD-spec-name/sub-specs/technical-spec.md
[IF_DATABASE_SCHEMA_CREATED]
- Database Schema: @.agent-os/specs/YYYY-MM-DD-spec-name/sub-specs/database-schema.md
[IF_API_SPEC_CREATED]
- API Specification: @.agent-os/specs/YYYY-MM-DD-spec-name/sub-specs/api-spec.md
[IF_CONTENT_MAPPING_CREATED]
- Content Mapping: @.agent-os/specs/YYYY-MM-DD-spec-name/sub-specs/content-mapping.md

Please review and let me know if any changes are needed.

When you're ready, run the /create-tasks command to have me build the tasks checklist from this spec.
```

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

Use patterns from @shared/state-patterns.md for file operations.

**Create-spec specific state:**
```json
{
  "spec_creation": {
    "spec_folder": "YYYY-MM-DD-name",
    "created_files": [],
    "conditional_files": { "database_schema": false, "api_spec": false }
  }
}
```

**Overwrite handling:** Check for existing specs, prompt user for confirmation before overwriting.

---

## SECTION: Error Handling

See @shared/error-recovery.md for general recovery procedures.

### Create-spec Specific Error Handling

| Error | Recovery |
|-------|----------|
| File creation failure | Roll back partial files, clean empty directories |
| Template generation error | Fall back to minimal template, allow manual entry |
| Context gathering failure | Proceed with reduced context, document limitations |
| Date/naming conflict | Append suffix (-v2, -alt), prompt user for preference |
| User review timeout | Save progress, provide resumption instructions |

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- Use native Explore agent for reading product documentation and gathering requirements
