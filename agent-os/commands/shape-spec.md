---
description: Shape and plan a new feature specification through guided requirements gathering
argument_hint: Optional feature description
---

# Spec Shaping Workflow

You are helping the user shape and plan the scope for a new feature. This MULTI-PHASE process documents key decisions regarding scope, design, and architecture approach.

## Phase 1: Initialize Spec Structure

### Step 1: Get Feature Description

IF you were given a description of the feature, use that to initiate a new spec.

OTHERWISE:

1. Check `agent-os/product/roadmap.md` to find the next feature
2. Ask the user:

   ```bash
   Which feature would you like to initiate a new spec for?

   - The roadmap shows [feature description] is next. Go with that?
   - Or provide a description of a feature you'd like to initiate a spec for.
   ```

3. **WAIT for user response before proceeding**

### Step 2: Create Spec Folder Structure

```bash
# Get today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)

# Determine kebab-case spec name from user's description
SPEC_NAME="[kebab-case-name]"

# Create dated folder name
DATED_SPEC_NAME="${TODAY}-${SPEC_NAME}"

# Store this path for output
SPEC_PATH="agent-os/specs/$DATED_SPEC_NAME"

# Create folder structure
mkdir -p $SPEC_PATH/planning
mkdir -p $SPEC_PATH/planning/visuals
mkdir -p $SPEC_PATH/implementation

echo "Created spec folder: $SPEC_PATH"
```

### Step 3: Confirm Initialization

Output:

```markdown
✅ Spec folder initialized: `[spec-path]`

Structure created:
- planning/ - For requirements and specifications
- planning/visuals/ - For mockups and screenshots
- implementation/ - For implementation documentation

Ready for requirements research phase.
```

## Phase 2: Research Requirements

### Step 1: Analyze Product Context

Before generating questions, understand the broader product context by reading:

1. **Product Mission** (`agent-os/product/mission.md`):
   - Overall mission and purpose
   - Target users and primary use cases
   - Core problems the product solves
   - Expected user benefits

2. **Product Roadmap** (`agent-os/product/roadmap.md`):
   - Features already completed
   - Current product state
   - Where this feature fits in the broader roadmap
   - Related features that might inform this work

3. **Tech Stack** (`agent-os/product/tech-stack.md`):
   - Technologies and frameworks in use
   - Technical constraints and capabilities
   - Available libraries and tools

This context helps you:

- Ask more relevant and contextual questions
- Identify existing features that might be reused
- Ensure feature aligns with product goals
- Understand user needs and expectations

### Step 2: Generate Clarifying Questions

Generate 4-8 targeted, NUMBERED questions that explore requirements while suggesting reasonable defaults.

**Question generation guidelines:**

- Start each question with a number
- Propose sensible assumptions based on best practices
- Frame as "I'm assuming X, is that correct?"
- Make it easy for users to confirm or provide alternatives
- Include specific suggestions they can say yes/no to
- Always end with a question about exclusions

**Required format:**

```markdown
Based on your idea for [spec name], I have some clarifying questions:

1. I assume [specific assumption]. Is that correct, or [alternative]?
2. I'm thinking [specific approach]. Should we [alternative]?
3. [Continue with numbered questions...]
[Last numbered question about exclusions]

**Existing Code Reuse:**
Are there existing features in your codebase with similar patterns we should reference? For example:
- Similar interface elements or UI components to re-use
- Comparable page layouts or navigation patterns
- Related backend logic or service objects
- Existing models or controllers with similar functionality

Please provide file/folder paths or names of these features if they exist.

**Visual Assets Request:**
Do you have any design mockups, wireframes, or screenshots that could help guide the development?

If yes, please place them in: `[spec-path]/planning/visuals/`

Use descriptive file names like:
- homepage-mockup.png
- dashboard-wireframe.jpg
- lofi-form-layout.png
- mobile-view.png
- existing-ui-screenshot.png

Please answer the questions above and let me know if you've added any visual files or can point to similar existing features.
```

**STOP and wait for user response.**

### Step 3: Process Answers and Check for Visuals

After receiving user answers:

1. Store the user's answers for later documentation

2. **MANDATORY: Check for visual assets** (even if user says "no visuals"):

   ```bash
   # THIS IS MANDATORY - users often add files without mentioning them
   ls -la [spec-path]/planning/visuals/ 2>/dev/null | grep -E '\.(png|jpg|jpeg|gif|svg|pdf)$' || echo "No visual files found"
   ```

3. IF visual files are found:
   - Use Read tool to analyze EACH visual file
   - Note key design elements, patterns, and user flows
   - Document observations for each file
   - Check filenames for low-fidelity indicators (lofi, wireframe, sketch, etc.)

4. IF user provided paths to similar features:
   - Note these paths/names for spec-writer to reference
   - DO NOT explore them yourself (to save time)
   - Document their names for future reference

### Step 4: Optional Code Exploration (if similar features mentioned)

If user mentioned specific similar features or paths in their answers, optionally launch a **code-explorer** subagent to quickly understand that feature:

```markdown
Launch code-explorer to analyze similar feature:

**Target**: [Path/feature mentioned by user, e.g., "app/features/posts"]
**Goal**: Quick understanding of:
- Key components and patterns used
- File structure and organization
- Reusable elements

**Purpose**: Inform follow-up questions with concrete understanding of existing implementation.
```

**This is optional** - only if user provided specific feature paths/names and it would help formulate better follow-up questions.

### Step 5: Generate Follow-up Questions (if needed)

Determine if follow-ups are needed based on:

**Visual-triggered follow-ups:**

- If visuals found but not mentioned: "I found [filename(s)] in the visuals folder. Let me analyze these for the specification."
- If filenames indicate low-fidelity: "I notice you've provided [filename(s)] which appear to be wireframes. Should we treat these as layout guides rather than exact design specifications, using our application's existing styling instead?"
- If visuals show features not discussed in answers
- If discrepancies exist between answers and visuals

**Reusability follow-ups:**

- If user didn't provide similar features but spec seems common: "This seems like it might share patterns with existing features. Could you point me to any similar forms/pages/logic in your app?"
- If provided paths seem incomplete: "You mentioned [feature]. Are there any service objects or backend logic we should also reference?"

**Answer-triggered follow-ups:**

- Vague requirements need clarification
- Missing technical details
- Unclear scope boundaries

**If follow-ups needed:**

```markdown
Based on your answers [and the visual files I found], I have a few follow-up questions:

1. [Specific follow-up question]
2. [Another follow-up if needed]

Please provide these additional details.
```

**STOP and wait for responses.**

### Step 6: Save Complete Requirements

After all questions are answered, save ALL gathered information to: `[spec-path]/planning/requirements.md`

Use this exact structure:

```markdown
# Spec Requirements: [Spec Name]

## Initial Description
[User's original spec description]

## Requirements Discussion

### First Round Questions

**Q1:** [First question asked]
**Answer:** [User's answer]

**Q2:** [Second question asked]
**Answer:** [User's answer]

[Continue for all questions]

### Existing Code to Reference
[Based on user's response about similar features]

**Similar Features Identified:**
- Feature: [Name] - Path: `[path provided by user]`
- Components to potentially reuse: [user's description]
- Backend logic to reference: [user's description]

[If user provided no similar features]
No similar existing features identified for reference.

### Follow-up Questions
[If any were asked]

**Follow-up 1:** [Question]
**Answer:** [User's answer]

## Visual Assets

### Files Provided:
[Based on actual bash check, not user statement]
- `filename.png`: [Description of what it shows from your analysis]
- `filename2.jpg`: [Key elements observed from your analysis]

### Visual Insights:
- [Design patterns identified]
- [User flow implications]
- [UI components shown]
- [Fidelity level: high-fidelity mockup / low-fidelity wireframe]

[If bash check found no files]
No visual assets provided.

## Requirements Summary

### Functional Requirements
- [Core functionality based on answers]
- [User actions enabled]
- [Data to be managed]

### Reusability Opportunities
- [Components that might exist already based on user's input]
- [Backend patterns to investigate]
- [Similar features to model after]

### Scope Boundaries
**In Scope:**
- [What will be built]

**Out of Scope:**
- [What won't be built]
- [Future enhancements mentioned]

### Technical Considerations
- [Integration points mentioned]
- [Existing system constraints]
- [Technology preferences stated]
- [Similar code patterns to follow]
```

### Step 7: Output Completion

Return:

```markdown
✅ Spec initialized successfully!

Spec folder created: `[spec-path]`
✅ Requirements gathered
✅ Visual assets: [Found X files / No files provided]

Requirements research complete!
✅ Processed [X] clarifying questions
✅ Visual check performed: [Found and analyzed Y files / No files found]
✅ Reusability opportunities: [Identified Z similar features / None identified]
✅ Requirements documented comprehensively

Requirements saved to: `[spec-path]/planning/requirements.md`

👉 Run `/write-spec` to create the spec.md document.
```

## Important Constraints

- **MANDATORY**: Always run bash command to check visuals folder after receiving user answers
- DO NOT write technical specifications. Just record findings to `[spec-path]/planning/requirements.md`
- Visual check is based on actual file(s) found via bash, NOT user statements
- Check filenames for low-fidelity indicators and clarify design intent if found
- Ask about existing similar features to promote code reuse
- Keep follow-ups minimal (1-3 questions max)
- Save user's exact answers, not interpretations
- Document all visual findings including fidelity level
- Document paths to similar features for spec-writer to reference
- OUTPUT questions and STOP to wait for user responses
