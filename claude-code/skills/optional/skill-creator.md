---
name: skill-creator
description: "Guide for creating custom Agent OS skills. Use this skill when users want to create new skills that extend Claude's capabilities with specialized workflows, domain knowledge, or tool integrations."
allowed-tools: Read, Write, Grep, Glob
---

# Skill Creator

Create effective skills that extend Claude's capabilities. This skill guides the creation of well-structured, context-efficient skills.

**Core Principle:** SKILLS TEACH CLAUDE PROCEDURAL KNOWLEDGE IT DOESN'T HAVE

## When to Use This Skill

Claude should invoke this skill:
- **When user wants to create a new skill**
- **When automating a repetitive workflow**
- **When domain-specific knowledge is needed repeatedly**
- **When updating or improving existing skills**

## Skill Anatomy

### Required Structure

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (required)
│   │   ├── name: (required)
│   │   ├── description: (required)
│   │   └── allowed-tools: (required for Agent OS)
│   └── Markdown instructions (required)
└── Optional resources/
    ├── scripts/      - Executable code
    ├── references/   - Documentation to load as needed
    └── assets/       - Files used in output
```

### YAML Frontmatter

```yaml
---
name: my-skill-name
description: "[When to invoke]. [What it does]. Auto-invoke trigger description."
allowed-tools: Tool1, Tool2, Tool3
---
```

**Description is critical** - It's what Claude reads to decide when to invoke the skill.

**Good descriptions:**
- "Verify build passes before commits. Auto-invoke before any git commit."
- "Root cause analysis before fixes. Auto-invoke when debugging issues."

**Bad descriptions:**
- "A useful skill" (too vague)
- "Does stuff with code" (no trigger info)

### Markdown Body Sections

```markdown
# Skill Title

[1-2 sentence overview]

**Core Principle:** [THE KEY RULE IN CAPS]

## When to Use This Skill

Claude should automatically invoke this skill:
- **Trigger 1** description
- **Trigger 2** description

## Workflow

### Step 1: [Name]
[Instructions with code examples]

### Step 2: [Name]
[Instructions with code examples]

## Output Format

```markdown
[Template for skill output]
```

## Key Principles

1. **Principle 1**: Explanation
2. **Principle 2**: Explanation
```

## Skill Creation Workflow

### Phase 1: Understand the Need

**1.1 Ask Clarifying Questions**
```
- What problem does this skill solve?
- What triggers should invoke it?
- What tools does it need?
- What's the expected output?
```

**1.2 Find Examples**
```
- How is this workflow done manually?
- What are common mistakes to prevent?
- What decisions need to be made?
```

### Phase 2: Design the Skill

**2.1 Define Triggers (Description Field)**
```
Good triggers:
- Specific events: "before git commit"
- Specific tasks: "when debugging issues"
- Specific contexts: "when creating new features"
```

**2.2 Choose Allowed Tools**
```
PRINCIPLE: Minimum necessary tools only

Common tools:
- Read, Grep, Glob - for reading code
- Bash - for running commands
- Write - for creating files
- mcp__ide__getDiagnostics - for IDE integration
- AskUserQuestion - for user interaction
```

**2.3 Structure the Workflow**
```
Break into clear steps:
1. Gather information
2. Analyze/process
3. Make decisions
4. Take action
5. Verify result
```

### Phase 3: Write the Skill

**3.1 Keep It Concise**
```
RULE: Context window is precious

- Challenge each paragraph: "Does Claude need this?"
- Prefer examples over explanations
- Remove obvious information
- Target < 200 lines for SKILL.md body
```

**3.2 Make Outputs Actionable**
```
Skill output should:
- Provide clear next steps
- Include copy-paste ready code/commands
- Give explicit recommendations
```

### Phase 4: Test and Iterate

**4.1 Test the Skill**
```
- Does it trigger at the right times?
- Does the workflow make sense?
- Is the output useful?
```

**4.2 Iterate Based on Usage**
```
After real usage:
- What was confusing?
- What was missing?
- What was unnecessary?
```

## Output Format

```markdown
## New Skill: [skill-name]

### Skill File

**Path:** `claude-code/skills/[skill-name].md`

```yaml
---
name: [skill-name]
description: "[Trigger description]. [Purpose]. Auto-invoke when [condition]."
allowed-tools: [Tool1], [Tool2]
---

# [Skill Title]

[Overview paragraph]

**Core Principle:** [KEY RULE]

## When to Use This Skill

Claude should automatically invoke this skill:
- **[Trigger 1]** description
- **[Trigger 2]** description

## Workflow

### 1. [Step Name]
[Instructions]

### 2. [Step Name]
[Instructions]

## Output Format

[Template]

## Key Principles

1. **[Principle]**: [Explanation]
```

### Installation

Add to `setup/project.sh`:
```bash
for skill in ... [skill-name]; do
```

Update `SYSTEM-OVERVIEW.md` skills table.
```

## Key Principles

1. **Description = Trigger**: The description field determines when skill is used
2. **Minimum Tools**: Only request tools the skill actually needs
3. **Concise > Comprehensive**: Don't waste context on obvious info
4. **Actionable Output**: Skills should produce usable results
5. **Iterate**: Skills improve through real usage

## Anti-Patterns to Avoid

- **Vague descriptions**: "A helpful skill" → Specify triggers
- **Too many tools**: Request only what's needed
- **Wall of text**: Keep body under 200 lines
- **No output format**: Always define expected output
- **Missing principles**: Include key rules to follow
