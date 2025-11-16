---
name: spec-creation
description: Create structured, comprehensive feature specifications through guided requirements gathering and documentation. Use this skill when the user asks to create a spec, plan a feature, gather requirements, or document a new capability.
---

# Specification Creation Skill

This skill guides you through creating comprehensive, well-structured feature specifications using a proven two-phase workflow: **shaping** (requirements gathering) and **writing** (specification documentation).

## When to Use This Skill

Use this skill when the user:

- Asks to "create a spec" or "write a specification"
- Wants to "plan a new feature" or "document requirements"
- Says "let's spec out [feature]" or "help me plan [capability]"
- Needs to "gather requirements" for a feature
- Wants to "shape" an idea into a concrete plan
- Is preparing for feature development and needs documentation

## Core Philosophy

**Spec-driven development** ensures:

1. Clear understanding before coding begins
2. Alignment between user vision and implementation
3. Reuse of existing code and patterns
4. Explicit scope boundaries (what's in, what's out)
5. Visual design alignment when mockups exist
6. Focused, minimal testing approach (not exhaustive)

## Two-Phase Workflow

### Phase 1: Spec Shaping (Requirements Gathering)

**Purpose**: Transform a vague idea into documented, validated requirements.

**Key Steps**:

1. **Initialize structure**: Create dated spec folder (`YYYY-MM-DD-feature-name`)
2. **Understand context**: Read product mission, roadmap, and tech stack
3. **Ask clarifying questions**: Generate 4-8 targeted questions with sensible defaults
4. **Request visuals**: Always ask for mockups/wireframes/screenshots
5. **Identify reusability**: Ask about existing similar features to leverage
6. **Check visuals folder**: Mandatory bash check even if user says "no visuals"
7. **Follow up**: Ask 1-3 focused follow-ups to resolve ambiguities
8. **Document everything**: Save to `planning/requirements.md`

**Critical Practices**:

- Propose assumptions, make it easy for user to confirm or correct
- Always check for visual assets via bash (`ls -la [spec-path]/planning/visuals/`)
- Ask about existing code to reuse (components, patterns, logic)
- Document user's exact answers, not your interpretations
- Keep follow-ups minimal (1-3 questions max)

### Phase 2: Spec Writing (Documentation)

**Purpose**: Transform requirements into a clear, actionable specification with architectural guidance.

**Key Steps**:

1. **Read requirements**: Load and analyze `planning/requirements.md`
2. **Launch parallel code exploration**: Use 2-3 **code-explorer** subagents simultaneously to:
   - Analyze similar features mentioned in requirements
   - Search for reusable UI components
   - Identify backend patterns and services
3. **Launch architecture design**: Use **code-architect** subagent to:
   - Design feature architecture based on requirements and explorer findings
   - Create component design and data flow
   - Provide implementation blueprint
4. **Analyze visuals**: Read each visual file and extract design elements
5. **Write specification**: Create `spec.md` integrating subagent findings
6. **Verify quality**: Self-check for alignment, reusability, and scope clarity

**Specification Template Structure**:

```markdown
# Specification: [Feature Name]

## Goal
[1-2 sentences describing core objective]

## User Stories
- As a [user type], I want to [action] so that [benefit]
[Max 3 user stories]

## Specific Requirements
**[Requirement name]**
- [Up to 8 concise sub-bullets per requirement]
[Max 10 requirements]

## Visual Design
[If mockups exist]
**`planning/visuals/[filename]`**
- [Up to 8 bullets describing UI elements to build]
[One section per visual file]

## Existing Code to Leverage
[Based on code-explorer findings]
**[Component/code found] - `path/to/file`**
- What it does: [From code-explorer analysis]
- How to reuse: [Extend, replicate, import]
- Key methods: [Relevant APIs]
[Max 5 code areas from code-explorer agents]

## Architecture Approach
[Based on code-architect blueprint]
**Component Design:** [Key components and responsibilities]
**Data Flow:** [Entry points → transformations → outputs]
**Integration Points:** [How feature integrates with existing code]

## Out of Scope
- [Up to 10 specific features that MUST NOT be built]
```

**Critical Practices**:

- **Launch subagents in parallel**: Use single message with multiple Task calls
- Wait for code-explorer agents to complete before launching code-architect
- Integrate subagent findings into specification
- DO NOT write actual code in specs
- Keep sections concise and skimmable
- Reference visual files explicitly
- State out-of-scope items clearly
- Follow template exactly (include Architecture Approach section)

## Folder Structure

Every spec creates this structure:

```markdown
agent-os/specs/YYYY-MM-DD-feature-name/
├── planning/
│   ├── requirements.md       # All gathered requirements
│   └── visuals/              # Mockups, wireframes, screenshots
├── implementation/           # Implementation reports (created later)
└── spec.md                   # The final specification document
```

## Key Principles

### 1. Context Before Questions

Always read product mission, roadmap, and tech stack before asking questions. This makes questions more relevant and informed.

### 2. Visuals Are Critical

- Always ask for visual assets
- Always check visuals folder via bash (users often forget to mention files)
- Analyze every visual file with Read tool
- Reference visuals explicitly in spec
- Check filenames for fidelity indicators (lofi, wireframe, etc.)

### 3. Reusability First (via Subagents)

- Launch **code-explorer** subagents in parallel to find reusable code
- Analyze similar features, components, and patterns
- Launch **code-architect** to design architecture leveraging existing code
- Document subagent findings in specification
- Avoid specifying new components when existing ones work
- Follow established patterns identified by subagents

### 4. Scope Clarity

- Define explicit in-scope features
- State out-of-scope items clearly
- Avoid over-engineering
- Keep it simple and focused
- No unnecessary complexity

### 5. Limited Testing Approach

- Specs should call for focused, minimal tests
- Implementation task groups: 2-8 tests each
- Testing engineer adds max 10 additional tests
- Total: ~16-34 tests per feature (not hundreds)
- Run only new tests, not entire suite

## Quality Verification

After creating a spec, verify:

**Requirements Accuracy**:

- [ ] All user answers captured exactly
- [ ] No missing or misrepresented answers
- [ ] Reusability opportunities documented
- [ ] Visual insights recorded

**Visual Alignment** (if visuals exist):

- [ ] All visual files analyzed with Read tool
- [ ] Design elements specified in spec
- [ ] Visual references in appropriate sections
- [ ] Fidelity level understood and documented

**Reusability Check**:

- [ ] Existing similar features identified
- [ ] Codebase searched for reusable components
- [ ] No unnecessary new components specified
- [ ] Existing patterns followed

**Scope Validation**:

- [ ] Only requested features included
- [ ] Out-of-scope items match user exclusions
- [ ] No over-engineering or extra complexity
- [ ] Specification is clear and skimmable

## Common Mistakes to Avoid

❌ **Don't**:

- Skip the visual check (always run `ls -la visuals/`)
- Write actual code in the spec
- Add features not requested by user
- Create new components when existing ones work
- Skip codebase search for reusable code
- Make specifications too long or detailed
- Add extra template sections
- Call for comprehensive/exhaustive testing
- Interpret user answers (use their exact words)

✅ **Do**:

- Always check visuals folder via bash
- Ask about existing similar features
- Search codebase before specifying new components
- Keep specifications concise and skimmable
- Follow template structure exactly
- Document user's exact answers
- Specify focused, limited testing (2-8 tests per task group)
- Verify alignment before finalizing

## Integration with Development Workflow

This skill prepares the foundation for:

1. **Task creation**: Breaking spec into implementation tasks
2. **Implementation**: Building the feature according to spec
3. **Verification**: Validating implementation matches spec
4. **Testing**: Writing focused tests per spec guidance

The spec becomes the **source of truth** that guides all subsequent development work.

## Example Usage Flow

```bash
User: "I want to create a spec for user authentication"

[Skill activates]

Phase 1 - Shaping:
→ Create spec folder: agent-os/specs/2025-11-16-user-authentication/
→ Read product mission, roadmap, tech stack
→ Generate 6 clarifying questions about auth approach
→ Ask about existing similar features
→ Request visual assets
→ Receive user answers
→ Run: ls -la agent-os/specs/2025-11-16-user-authentication/planning/visuals/
→ Find login-mockup.png (user forgot to mention it!)
→ Read and analyze login-mockup.png
→ Ask 2 follow-up questions about visual elements
→ Document everything to planning/requirements.md

Phase 2 - Writing:
→ Read planning/requirements.md
→ **Launch 3 code-explorer agents in parallel** (single message):
  • Explorer 1: Analyze existing auth features (sessions, login)
  • Explorer 2: Search for reusable form components
  • Explorer 3: Find validation and service patterns
→ Wait for all explorers to complete
→ **Launch code-architect agent**:
  • Input: Requirements + explorer findings + visual mockup
  • Output: Architecture blueprint with component design, data flow
→ Read login-mockup.png and analyze design elements
→ Create spec.md integrating all findings:
  • Goal, User Stories, Requirements sections
  • Visual Design section referencing login-mockup.png
  • Existing Code section with SessionService, AuthForm (from explorers)
  • Architecture Approach section (from architect blueprint)
  • Out of Scope: 2FA, OAuth, password reset
→ Verify alignment with requirements and subagent findings
→ Output completion message

Result: Comprehensive, architecture-informed spec ready for implementation
```

## Additional Resources

For detailed workflow instructions, see:

- [shaping-guide.md](shaping-guide.md) - Step-by-step shaping workflow details
- [writing-guide.md](writing-guide.md) - Specification writing best practices and examples
