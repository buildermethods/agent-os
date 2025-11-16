# Spec Writing Guide

Detailed guidance for transforming gathered requirements into a comprehensive, actionable specification document.

## Overview

Spec writing converts the requirements gathered during shaping into a clear, structured specification that guides implementation. The spec becomes the **source of truth** for developers.

## Step-by-Step Process

### 1. Load Requirements and Context

**Find the spec folder**:

```bash
# Get most recent spec (or user will specify which one)
SPEC_PATH=$(ls -dt agent-os/specs/*/ 2>/dev/null | head -1 | sed 's:/$::')
echo "Working with: $SPEC_PATH"
```

**Read requirements**:

```bash
cat $SPEC_PATH/planning/requirements.md
```

**Check for visuals**:

```bash
ls -la $SPEC_PATH/planning/visuals/ 2>/dev/null | grep -v "^total" | grep -v "^d"
```

**Analyze what you have**:

- User's feature description and goals
- All Q&A from requirements gathering
- Existing similar features mentioned
- Visual mockups or screenshots (if present)
- Scope boundaries and exclusions
- Technical constraints

### 2. Search for Reusable Code

Before writing specifications, thoroughly search the codebase for existing patterns and components.

**Identify search keywords** from requirements:

- Feature names (e.g., "authentication", "dashboard", "form")
- Technical terms (e.g., "validation", "service", "controller")
- UI components mentioned (e.g., "button", "modal", "table")
- Data entities (e.g., "User", "Post", "Comment")

**Search systematically**:

```bash
# Example: For authentication feature
# Search for existing auth patterns
grep -r "authenticate" --include="*.rb" --include="*.js"

# Search for session management
grep -r "session" --include="*.rb"

# Search for similar services
find . -name "*service*" -type f

# Search for UI components
find . -path "*/components/*" -type f
```

**What to look for**:

1. **Similar features**: Features doing something comparable
2. **Reusable UI components**: Buttons, forms, modals, tables, etc.
3. **Service objects**: Business logic you can extend or replicate
4. **Models and controllers**: Data structures and endpoints
5. **Validation patterns**: How validation is currently done
6. **API patterns**: RESTful patterns, GraphQL resolvers, etc.
7. **Naming conventions**: How things are named in this codebase
8. **Architecture patterns**: MVC, service layer, repository pattern, etc.

**Document findings**:

- Component names and file paths
- What they do
- How they could be reused or extended
- Patterns to follow

### 3. Analyze Visual Assets

If visual files exist in `planning/visuals/`:

**For each visual file**:

1. Use Read tool to view it
2. Document systematically:
   - **Layout**: Grid structure, sections, positioning
   - **Components**: Buttons, forms, cards, navigation, etc.
   - **Typography**: Headings, body text, labels
   - **Colors**: Color scheme, backgrounds, accents
   - **Spacing**: Padding, margins, gaps
   - **Interactions**: Hover states, modals, dropdowns shown
   - **User flow**: Navigation paths, form submissions

**Determine fidelity**:

- **Low-fidelity** (wireframe/sketch): Focus on layout and structure, use existing styling
- **High-fidelity** (polished mockup): Follow exact colors, typography, spacing

**Check filename for clues**:

- "lofi", "lo-fi", "wireframe", "sketch", "rough" → low-fidelity
- Otherwise assume high-fidelity if visually polished

### 4. Write the Specification

Create `$SPEC_PATH/spec.md` following this EXACT template:

```markdown
# Specification: [Feature Name]

## Goal
[1-2 sentences describing the core objective and user value]

## User Stories
- As a [user type], I want to [action] so that [benefit]
- As a [user type], I want to [action] so that [benefit]
[Max 3 user stories total]

## Specific Requirements

**[Requirement name - be specific]**
- [Concise sub-point about this requirement]
- [Technical approach or decision]
- [Design consideration]
- [Data or state management]
- [Integration point if applicable]
- [Up to 8 bullets total per requirement]

**[Another requirement name]**
- [Sub-points following same pattern]

[Continue for up to 10 specific requirements total]

## Visual Design
[ONLY include this section if visual files exist]

**`planning/visuals/[filename.png]`**
- [Specific UI element to build: e.g., "Header with logo left, nav right"]
- [Layout detail: e.g., "3-column grid with 20px gaps"]
- [Component detail: e.g., "Primary button with rounded corners"]
- [Color note: e.g., "Blue accent color for CTAs" (if high-fidelity)]
- [Typography: e.g., "Large heading, 14px body text"]
- [Interaction: e.g., "Modal opens on button click"]
- [Up to 8 bullets per visual file]

**`planning/visuals/[another-file.jpg]`**
- [Details from this file...]

[Repeat for each visual file found]

## Existing Code to Leverage

**[Component/Service/Pattern found - with file path]**
- Located at: `path/to/file.rb`
- What it does: [Brief description]
- How to reuse: [Extend it, replicate pattern, import and use, etc.]
- Relevant methods/exports: [Specific parts to leverage]

**[Another reusable code area]**
- [Same pattern...]

[Up to 5 existing code areas total]

## Out of Scope
- [Specific feature explicitly excluded]
- [Another out-of-scope item]
- [Future enhancement mentioned]
[Up to 10 items clearly stating what MUST NOT be built]
```

**Writing Guidelines**:

**Goal section**:

- 1-2 sentences maximum
- Focus on user value, not implementation
- Answers "Why are we building this?"

**User Stories**:

- Follow "As a [who], I want [what], so that [why]" format
- Max 3 stories
- Focus on different user types or key workflows
- Keep concise

**Specific Requirements**:

- Name each requirement specifically (not "Database" but "User Authentication Schema")
- Each requirement gets up to 8 concise sub-bullets
- Cover: what, how, why, constraints, integrations
- Reference existing code where applicable: "(reuse UserValidator pattern)"
- Max 10 requirements total

**Visual Design**:

- ONLY include if visual files exist
- One sub-section per visual file
- Reference filename explicitly
- Extract specific, actionable design elements
- If low-fidelity: focus on layout/structure, note to use existing styling
- If high-fidelity: include colors, exact spacing, typography details
- Up to 8 bullets per file

**Existing Code to Leverage**:

- Include file paths
- Explain what it does
- State how to reuse it
- Mention specific methods/components
- Shows implementer what to build on vs. build new

**Out of Scope**:

- Be very explicit about what NOT to build
- Prevents scope creep
- Sets clear boundaries
- Taken from requirements discussion
- Up to 10 items

### 5. Quality Self-Check

Before finalizing, verify:

**Requirements Coverage**:

- [ ] All features from requirements.md are addressed
- [ ] No new features added that weren't requested
- [ ] User's constraints and preferences honored
- [ ] Technical considerations from requirements included

**Visual Alignment** (if visuals exist):

- [ ] Every visual file is referenced
- [ ] Design elements extracted and specified
- [ ] Fidelity level understood and documented
- [ ] No visual details missed

**Reusability Check**:

- [ ] Codebase was searched systematically
- [ ] Existing similar features identified
- [ ] Reusable components documented with paths
- [ ] Patterns to follow are noted
- [ ] Not specifying new components when existing ones work

**Scope Clarity**:

- [ ] In-scope features are specific and actionable
- [ ] Out-of-scope matches user's exclusions
- [ ] No over-engineering or unnecessary complexity
- [ ] Keeps it simple and focused

**Template Adherence**:

- [ ] Follows exact template structure
- [ ] No extra sections added
- [ ] All sections are concise and skimmable
- [ ] No actual code written in spec

### 6. Output Completion

Display:

```markdown
✅ The spec has been created at `[spec-path]/spec.md`

Review it closely to ensure everything aligns with your vision and requirements.

Specification Summary:
- Goal: [1-sentence goal]
- User Stories: [X] stories defined
- Specific Requirements: [Y] requirements detailed
- Visual Design: [Z files analyzed / No visuals provided]
- Existing Code: [N reusable components identified / Starting fresh]
- Out of Scope: [M items explicitly excluded]

Next step: Implement the specification or refine if needed.
```

## Best Practices

### DO

✅ Search codebase thoroughly before specifying new components
✅ Use Read tool on every visual file
✅ Include file paths for existing code to leverage
✅ Keep each section concise and skimmable
✅ Reference requirements.md to ensure alignment
✅ State out-of-scope items explicitly
✅ Follow template structure exactly
✅ Focus on clarity over completeness
✅ Use user's exact terminology from requirements
✅ Note low-fidelity vs. high-fidelity for visuals

### DON'T

❌ Write actual code in the specification
❌ Add features not requested in requirements
❌ Skip codebase search for reusable components
❌ Create overly long or detailed specifications
❌ Add extra template sections
❌ Specify new components when existing ones work
❌ Miss visual files or skip analyzing them
❌ Over-engineer or add unnecessary complexity
❌ Interpret requirements - stick to what user said
❌ Call for comprehensive/exhaustive testing

## Template Section Details

### Goal Section

**Purpose**: Communicate the "why" in 1-2 sentences.

**Good examples**:

- "Enable users to securely authenticate and access personalized dashboards, reducing unauthorized access."
- "Provide admins with bulk data export capabilities to support compliance reporting requirements."

**Bad examples**:

- "Build authentication system with JWT tokens, refresh logic, and session management." (too technical, too detailed)
- "Make users happy." (too vague)

### User Stories Section

**Purpose**: Capture key user workflows and value propositions.

**Good examples**:

- "As a new user, I want to sign up with email and password so that I can access the application."
- "As an admin, I want to export all user data to CSV so that I can analyze trends."
- "As a logged-in user, I want to update my profile picture so that I can personalize my account."

**Bad examples**:

- "As a user, I want the system to work." (too vague)
- "As a developer, I want to implement JWT authentication..." (not user-facing)

### Specific Requirements Section

**Purpose**: Detail what needs to be built, how, and why.

**Naming**: Be specific, not generic.

- ✅ "User Registration Form with Email Validation"
- ❌ "Frontend"

**Sub-bullets**: Up to 8 concise points per requirement.

**Good example**:

```markdown
**User Registration Form with Email Validation**
- Form fields: email, password, password confirmation
- Client-side validation: email format, password strength (min 8 chars)
- Server-side validation using existing EmailValidator service
- Display inline error messages below each field
- Disable submit button while processing
- Redirect to dashboard on successful registration
- Reuse existing FormField component from app/components/shared/
- Follow existing form styling patterns from app/assets/stylesheets/forms.css
```

**Bad example**:

```markdown
**Frontend**
- Build the UI
- Make it look good
- Add validation
- Handle errors
```

### Visual Design Section

**Purpose**: Translate visual mockups into actionable design specifications.

**Good example** (high-fidelity):

```markdown
**`planning/visuals/dashboard-mockup.png`**
- Header: Logo left (140px width), navigation menu right
- 3-column grid layout with 24px gaps
- Card components with white background, 8px border radius, subtle shadow
- Primary CTA button: #3B82F6 blue, white text, 12px padding
- Typography: 24px heading (bold), 14px body text (regular)
- Status badges: green for active, red for inactive
- Mobile breakpoint: stack cards vertically below 768px
- Search bar: full width on mobile, 300px on desktop
```

**Good example** (low-fidelity):

```markdown
**`planning/visuals/lofi-dashboard.png`**
- Header with logo left, navigation right (use existing Header component)
- 3-column grid layout for main content area
- Card-based layout for displaying items (use existing Card component)
- Search and filter bar above grid
- Action button in top right
- Note: This is a wireframe - use existing application styling and components
```

### Existing Code to Leverage Section

**Purpose**: Point implementer to reusable code, preventing duplication.

**Good example**:

```markdown
**UserValidator Service**
- Located at: `app/services/user_validator.rb`
- What it does: Validates email format, password strength, username uniqueness
- How to reuse: Import and call `UserValidator.validate(user_params)` before saving
- Relevant methods: `valid_email?`, `strong_password?`, `unique_username?`
- Note: Extend with phone number validation if needed

**FormField Component**
- Located at: `app/components/shared/form_field.jsx`
- What it does: Reusable form input with label, error display, and validation
- How to reuse: Import and use `<FormField>` for all form inputs
- Props: label, type, name, value, onChange, error, required
- Supports: text, email, password, number, textarea types
```

**Bad example**:

```markdown
**Some validation stuff**
- There's validation somewhere in the app
- Use it if you find it
```

### Out of Scope Section

**Purpose**: Explicitly state what will NOT be built to prevent scope creep.

**Good example**:

```markdown
## Out of Scope
- Two-factor authentication (2FA) - planned for future release
- OAuth login with Google/Facebook - separate initiative
- Password reset via email - existing feature suffices for now
- User profile customization beyond avatar - v2 feature
- Admin user management interface - separate spec being created
- Automated security notifications - compliance requirement not yet finalized
- Login analytics and reporting - not part of MVP
- Remember me / persistent sessions - security review needed first
```

**Bad example**:

```markdown
## Out of Scope
- Other stuff
- Things we're not doing
- Future features
```

## Common Scenarios

### Scenario 1: High-fidelity mockup with specific design

**Visual file**: `dashboard-final.png` (polished, shows exact colors/fonts)

**Spec approach**:

```markdown
## Visual Design

**`planning/visuals/dashboard-final.png`**
- Color scheme: Primary #3B82F6, secondary #10B981, background #F9FAFB
- Typography: Inter font family, 28px heading (600 weight), 14px body (400 weight)
- Card design: White background, 12px border radius, box-shadow: 0 1px 3px rgba(0,0,0,0.1)
- Button: Primary blue, white text, 10px padding, 6px border radius, hover: darken 10%
- Grid: 3 columns on desktop, 2 on tablet (1024px), 1 on mobile (768px)
- Spacing: 32px between major sections, 16px between cards
- Icons: Lucide icon set, 20px size, gray color (#6B7280)
```

### Scenario 2: Low-fidelity wireframe

**Visual file**: `lofi-sketch.png` (rough, no colors, simple boxes)

**Spec approach**:

```markdown
## Visual Design

**`planning/visuals/lofi-sketch.png`**
- Note: This is a low-fidelity wireframe - use existing application styling
- Layout: Header at top, sidebar left (200px), main content area right
- Header: Logo left, user menu right (use existing Header component)
- Sidebar: Navigation menu with icons (use existing NavMenu component)
- Main area: Page title, action button, data table below
- Table: 5 columns (Name, Email, Status, Created, Actions) - use existing DataTable
- Action button: Top right of main area (use existing Button component with primary variant)
- Focus on layout structure, not visual styling details
```

### Scenario 3: Multiple visual files

**Files**: `mobile-view.png`, `desktop-view.png`, `modal-detail.png`

**Spec approach**:

```markdown
## Visual Design

**`planning/visuals/desktop-view.png`**
- Full dashboard layout with sidebar navigation left (240px fixed)
- 4-column grid for metric cards
- Data table below cards with sortable columns
- Search and filter controls above table

**`planning/visuals/mobile-view.png`**
- Hamburger menu for navigation (slides in from left)
- Single column layout, cards stack vertically
- Simplified table with 3 columns (Name, Status, Actions)
- Fixed bottom navigation bar with key actions

**`planning/visuals/modal-detail.png`**
- Modal overlay: centered, max-width 600px, white background
- Header: title left, close button right (X icon)
- Body: form fields with labels above inputs
- Footer: Cancel (secondary) and Save (primary) buttons right-aligned
```

### Scenario 4: Reusable components found

**Search results**: Found `UserForm`, `EmailInput`, `PasswordInput` components

**Spec approach**:

```markdown
## Existing Code to Leverage

**UserForm Component**
- Located at: `app/components/forms/user_form.jsx`
- What it does: Handles user creation/editing with built-in validation
- How to reuse: Extend for registration flow, add email confirmation field
- Props: user, onSubmit, submitLabel, mode (create|edit)
- Already includes: Email validation, password strength meter, error display

**EmailInput Component**
- Located at: `app/components/inputs/email_input.jsx`
- What it does: Email input with format validation and autocomplete
- How to reuse: Use directly for email field in registration form
- Props: value, onChange, error, required
- Features: Real-time format validation, suggestions for common domains

**PasswordInput Component**
- Located at: `app/components/inputs/password_input.jsx`
- What it does: Password input with strength indicator and show/hide toggle
- How to reuse: Use for both password and password confirmation fields
- Props: value, onChange, error, showStrength, required
- Features: Strength meter, visibility toggle, copy/paste handling

## Specific Requirements

**User Registration Form Integration**
- Compose UserForm with EmailInput and PasswordInput components
- Add password confirmation field using second PasswordInput instance
- Extend UserForm validation to include password match check
- Reuse existing form error handling and display logic
- Follow existing form submission patterns (async with loading state)
- Redirect using existing navigation context
```

## Quality Verification Checklist

Before finalizing spec.md:

**Content Accuracy**:

- [ ] All user answers from requirements.md reflected
- [ ] No new features added beyond requirements
- [ ] Technical constraints from requirements honored
- [ ] Scope boundaries match user's exclusions

**Visual Alignment**:

- [ ] Every visual file in planning/visuals/ is referenced
- [ ] Each visual analyzed with Read tool
- [ ] Design elements extracted and specified
- [ ] Fidelity level noted (wireframe vs final design)
- [ ] No visual details overlooked

**Reusability**:

- [ ] Codebase searched for similar features
- [ ] Existing components identified and documented
- [ ] File paths provided for reusable code
- [ ] Patterns to follow are noted
- [ ] Not creating new components unnecessarily

**Template Compliance**:

- [ ] Goal: 1-2 sentences, user value focused
- [ ] User Stories: Max 3, proper format
- [ ] Specific Requirements: Max 10, each with max 8 bullets
- [ ] Visual Design: Only if visuals exist, covers all files
- [ ] Existing Code: Max 5 areas, includes paths and usage
- [ ] Out of Scope: Explicit exclusions from requirements
- [ ] No extra sections added
- [ ] No actual code written

**Clarity**:

- [ ] Each section is concise and skimmable
- [ ] Requirements are specific, not vague
- [ ] Technical approach is clear
- [ ] Implementer knows exactly what to build
- [ ] Specifications are actionable

**Simplicity**:

- [ ] No over-engineering
- [ ] Kept focused and minimal
- [ ] Reuses existing code where possible
- [ ] Follows YAGNI (You Aren't Gonna Need It)
- [ ] No unnecessary complexity

## Final Notes

**The spec is a guide, not a prison**:

- Implementers can ask questions during development
- Minor details can be decided during implementation
- The spec provides direction, not every tiny decision

**Focus on what matters**:

- Core functionality and user value
- Visual design (if mockups provided)
- Reusability and existing code
- Scope boundaries (what's in, what's out)
- Technical approach and architecture

**Keep it skimmable**:

- Developers will read this quickly
- Use bullets, not paragraphs
- Be concise and direct
- Make it easy to scan

**Trust the template**:

- The structure is proven and works
- Don't add sections
- Don't skip sections (if content exists)
- Follow it exactly
