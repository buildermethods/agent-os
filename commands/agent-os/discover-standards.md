# Discover Standards

Extract tribal knowledge from your codebase into concise, documented standards.

## Important Guidelines

- **Always use AskUserQuestion tool** when asking the user anything
- **Write concise standards** — Use minimal words. Standards must be scannable by AI agents without bloating context windows.
- **Offer suggestions** — Present options the user can confirm, choose between, or correct. Don't make them think harder than necessary.

## Process

### Step 1: Determine Focus Area

Check if the user specified an area when running this command. If they did, skip to Step 2.

If no area was specified:

1. Analyze the codebase structure (folders, file types, patterns)
2. Identify 3-5 major areas. Examples:
   - **Frontend areas:** UI components, styling/CSS, state management, forms, routing
   - **Backend areas:** API routes, database/models, authentication, background jobs
   - **Cross-cutting:** Error handling, validation, testing, naming conventions, file structure
   - **Algorithms:** Filters, controllers, solvers, estimators, ML models, training loops, numerical methods, signal processing (use algorithm template — see "Discovering Algorithms" section below)
3. Use AskUserQuestion to present the areas:

```
I've identified these areas in your codebase:

1. **API Routes** (src/api/) — Request handling, response formats
2. **Database** (src/models/, src/db/) — Models, queries, migrations
3. **React Components** (src/components/) — UI patterns, props, state
4. **Authentication** (src/auth/) — Login, sessions, permissions
5. **Algorithms** (src/filters/, src/control/) — Filters, controllers, solvers

Which area should we focus on for discovering standards? (Pick one, or suggest a different area)
```

Wait for user response before proceeding.

### Step 2: Analyze & Present Findings

Once an area is determined:

1. Read key files in that area (5-10 representative files)
2. Look for patterns that are:
   - **Unusual or unconventional** — Not standard framework/library patterns
   - **Opinionated** — Specific choices that could have gone differently
   - **Tribal** — Things a new developer wouldn't know without being told
   - **Consistent** — Patterns repeated across multiple files

3. Use AskUserQuestion to present findings and let user select:

```
I analyzed [area] and found these potential standards worth documenting:

1. **API Response Envelope** — All responses use { success, data, error } structure
2. **Error Codes** — Custom error codes like AUTH_001, DB_002 with specific meanings
3. **Pagination Pattern** — Cursor-based pagination with consistent param names

Which would you like to document?

Options:
- "Yes, all of them"
- "Just 1 and 3"
- "Add: [your suggestion]"
- "Skip this area"
```

Wait for user selection before proceeding.

### Step 3: Ask Why, Then Draft Each Standard

**IMPORTANT:** For each selected standard, you MUST complete this full loop before moving to the next standard:

1. **Ask 1-2 clarifying questions** about the "why" behind the pattern. Use your AskUserQuestion tool for this.
2. **Wait for user response**
3. **Draft the standard** incorporating their answer
4. **Confirm with user** before creating the file
5. **Create the file** if approved

Example questions to ask (adapt based on the specific standard):

- "What problem does this pattern solve? Why not use the default/common approach?"
- "Are there exceptions where this pattern shouldn't be used?"
- "What's the most common mistake a developer or agent makes with this?"

**Do NOT batch all questions upfront.** Process one standard at a time through the full loop.

### Step 4: Create the Standard File

For each standard (after completing Step 3's Q&A):

1. Determine the appropriate folder (create if needed):
   - `api/`, `database/`, `javascript/`, `css/`, `backend/`, `testing/`, `global/`
   - `algorithms/` — For algorithmic/mathematical code (see "Discovering Algorithms" section)

2. Check if a related standard file already exists — append to it if so

3. Draft the content and use AskUserQuestion to confirm:

```
Here's the draft for api/response-format.md:

---
# API Response Format

All API responses use this envelope:

\`\`\`json
{ "success": true, "data": { ... } }
{ "success": false, "error": { "code": "...", "message": "..." } }
\`\`\`

- Never return raw data without the envelope
- Error responses must include both code and message
- Success responses omit the error field entirely
---

Create this file? (yes / edit: [your changes] / skip)
```

4. Create or update the file in `agent-os/standards/[folder]/`
5. **Then repeat Steps 3-4 for the next selected standard**

### Step 5: Update the Index

After all standards are created:

1. Scan `agent-os/standards/` for all `.md` files
2. For each new file without an index entry, use AskUserQuestion:

```
New standard needs an index entry:
  File: api/response-format.md

Suggested description: "API response envelope structure and error format"

Accept this description? (yes / or type a better one)
```

3. Update `agent-os/standards/index.yml`:

```yaml
api:
  response-format:
    description: API response envelope structure and error format
```

Alphabetize by folder, then by filename.

### Step 6: Offer to Continue

Use AskUserQuestion:

```
Standards created for [area]:
- api/response-format.md
- api/error-codes.md

Would you like to discover standards in another area, or are we done?
```

---

## Discovering Algorithms

When the user selects "Algorithms" as the focus area, use a different flow. Algorithm documentation requires more structure to prevent convention bugs in mathematical/computational code.

### Algorithm Step 1: Identify Algorithms

Scan for algorithmic patterns:
- Filters, estimators, state estimation
- Controllers, planners, optimizers, solvers
- ML models, training loops, loss functions
- Numerical methods, simulations
- Signal processing, transforms
- Kinematics, dynamics

Present findings:

```
I found these potential algorithms in your codebase:

1. **EKF** (src/filters/ekf.cpp, src/filters/ekf.h) — State estimation filter
2. **QP Solver** (src/control/qp_solver.py) — Quadratic programming optimization
3. **CNN Classifier** (src/models/classifier.py, src/models/layers.py) — Image classification

Which would you like to document?
```

### Algorithm Step 2: For Each Algorithm, Ask High-Level Questions

Follow the algorithm template structure. Ask about:

1. **Purpose**: "What does this algorithm do? What problem does it solve?"

2. **I/O**: "What are the inputs and outputs? What are their types, shapes, units?"

3. **Files (owns:)**: "Which files implement this algorithm? (I found: src/filters/ekf.cpp, src/filters/ekf.h — are there others?)"

4. **Conventions**: "Are there domain-specific conventions that affect correctness?"
   - This is open-ended — don't assume. Could be:
     - Coordinate frames (robotics)
     - Quaternion conventions (robotics, graphics)
     - Tensor layouts (ML)
     - Units (scientific)
     - Sign conventions (control systems)
   - If user says none, that's fine

5. **Method**: "What are the key steps of this algorithm?"

### Algorithm Step 3: Create Algorithm File

Use the algorithm template (embedded in `/algorithm-drift` command):

```markdown
---
owns:
  - src/filters/ekf.cpp
  - src/filters/ekf.h
---

# Extended Kalman Filter

## Purpose
[From user's answer]

## I/O
**Inputs:**
- [From user's answer with types/units]

**Outputs:**
- [From user's answer with types/units]

## Conventions
[From user's answer, or "None identified" if not applicable]

## Diagram
[Generate based on method description]

## Method
[From user's answer, structured as steps]

## Implementation
- `ekf.cpp` — Main filter implementation
- `ekf.h` — State and covariance types

## Notes
[Any edge cases, invariants, or validation notes from discussion]
```

Create in `agent-os/standards/algorithms/{name}.md`

### Algorithm Step 4: Continue

Repeat for each selected algorithm, then update index as usual.

---

## Output Location

All standards: `agent-os/standards/[folder]/[standard].md`
Index file: `agent-os/standards/index.yml`

## Writing Concise Standards

Standards will be injected into AI context windows. Every word costs tokens. Follow these rules:

- **Lead with the rule** — State what to do first, explain why second (if needed)
- **Use code examples** — Show, don't tell
- **Skip the obvious** — Don't document what the code already makes clear
- **One standard per concept** — Don't combine unrelated patterns
- **Bullet points over paragraphs** — Scannable beats readable

**Good:**
```markdown
# Error Responses

Use error codes: `AUTH_001`, `DB_001`, `VAL_001`

\`\`\`json
{ "success": false, "error": { "code": "AUTH_001", "message": "..." } }
\`\`\`

- Always include both code and message
- Log full error server-side, return safe message to client
```

**Bad:**
```markdown
# Error Handling Guidelines

When an error occurs in our application, we have established a consistent pattern for how errors should be formatted and returned to the client. This helps maintain consistency across our API and makes it easier for frontend developers to handle errors appropriately...
[continues for 3 more paragraphs]
```

## Example: Full Loop for One Standard

Here's how to process a single standard through the complete workflow:

**1. Present findings (Step 2):**
```
I found these patterns in your API code:
1. **Response Envelope** — All responses use { success, data, error }
2. **Error Codes** — Custom codes like AUTH_001

Which would you like to document?
```

User: "Both"

**2. Ask why for first standard (Step 3):**
```
For the Response Envelope pattern:
- What problem does this solve? Why not return raw data?
- Are there any endpoints that don't use this pattern?
```

User: "We use it so the frontend always knows where to find the data. All endpoints use it, no exceptions."

**3. Draft first standard (Step 3 continued):**
```
Here's the draft for api/response-envelope.md:

---
# Response Envelope

All API responses use this structure:
\`\`\`json
{ "success": true, "data": { ... } }
{ "success": false, "error": { ... } }
\`\`\`

- Frontend always checks `success` first, then reads `data` or `error`
- No exceptions — every endpoint uses this format
---

Create this file?
```

User: "Yes"

**4. Create file, then move to next standard:**

[Create the file]

**5. Ask why for second standard (back to Step 3):**
```
For the Error Codes pattern:
- What's the naming convention for codes?
- Where should new error codes be documented?
```

User: "Format is AREA_NUMBER like AUTH_001. We keep a list in the wiki."

**6. Draft second standard, confirm, create file...**

[Continue until all selected standards are done]

**Key point:** Complete the full ask → draft → confirm → create cycle for each standard before starting the next one.
