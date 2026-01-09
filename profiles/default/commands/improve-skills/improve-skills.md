I want you to help me improve the files that make up my Claude Code Skills by rewriting their descriptions so that they can be more readily discovered and used by Claude Code when it works on coding tasks.

All of the Skills in our project are located in `.claude/skills/`. Each Skill has its own folder and inside each Skill folder is a file called `SKILL.md`.

LOOP through each `SKILL.md` file and FOR EACH use the following process to revise its content and improve it:

## Claude Code Skill Improvement Process

### Step 1: Confirm which skills to improve

First, ask the user to confirm whether they want ALL of their Claude Code skills to be improved, only select Skills.  Assume the answer will be "all" but ask the user to confirm by displaying the following message, then WAIT for the user's response before proceeding to Step 2:

```
Before I proceed with improving your Claude Code Skills, can you confirm that you want me to revise and improve ALL Skills in your .claude/skills/ folder?

If not, then please specify which Skills I should include or exclude.
```

---

## Skills Writing Reference

Before improving skills, understand these key concepts:

### Critical: Three-Phase Loading Model

```
Phase 1: YAML frontmatter cached for ALL skills
    ↓
Phase 2: SKILL.md loaded when model decides to use skill
    ↓
Phase 3: Related files loaded based on links + context
```

**Implications:**
- `description` must contain trigger patterns (Phase 1 decision)
- SKILL.md must be SHORT - loaded before full context known
- Related files can be LONGER - loaded only when needed
- Links must have context descriptions (when to load each file)

### Supported YAML Frontmatter Fields

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | auto | Identifier (lowercase, hyphens, max 64 chars) |
| `description` | **yes** | **Critical for triggering.** Max 1024 chars |
| `when_to_use` | no | Additional trigger guidance |
| `allowed-tools` | no | Restrict available tools |

### Unsupported Fields - REMOVE If Present

These fields are **ignored** by Claude Code:
- `tags` - not supported
- `version` - not supported
- `dependencies` - not supported

### Description Patterns

```yaml
# Standard triggers - list scenarios:
description: "Use when writing database queries, creating migrations, working with Prisma models"

# Mandatory loading (always load):
description: "MANDATORY: Project coding standards. Use for all code in this project"

# Combined with when_to_use:
description: "Database patterns and best practices"
when_to_use: "When working with PostgreSQL, Prisma, or SQL queries"

# File type triggers:
description: "Tailwind CSS patterns. Use when writing .tsx, .vue, .css files with utility classes"

# Comprehensive (recommended for max discoverability):
description: "Write accessible React components. Use when creating .tsx files, implementing ARIA attributes, keyboard navigation, or fixing accessibility issues"
```

### Compactness Principle

**Skills consume context window. Every character matters.**

- Short, clear descriptions with triggers
- Minimal SKILL.md content - only essentials
- **Illustrative examples**: 3-5 lines max (showing concept)
- **Reference patterns**: Can be longer if they provide copy-paste value
- Link to supporting files for details

### File Structure Options

**Minimal:**
```
skill-name/
└── SKILL.md
```

**With Supporting Files:**
```
skill-name/
├── SKILL.md          # Overview + links (SHORT)
├── REFERENCE.md      # Detailed info
└── EXAMPLES.md       # Code examples
```

**Multi-topic (preferred for context efficiency):**
```
skill-name/
├── SKILL.md              # Core rules + short illustrative examples
├── EXAMPLES-QUERIES.md   # Examples for database queries
├── EXAMPLES-MIGRATIONS.md # Examples for migrations
└── EXAMPLES-MODELS.md    # Examples for models
```

### Quick Template

```markdown
---
name: my-skill
description: "Use when [specific trigger situations]"
---

# My Skill

## When to use this skill

- When writing or editing [file types]
- When implementing [features]
- When debugging [issues]

## Purpose
[One sentence]

## Instructions
1. Step one
2. Step two

## Example
\`\`\`code
// 3-5 lines max
\`\`\`
```

---

### Step 2: Analyze what this Skill does

Analyze and read the skill file to understand what it is, what it should be used for, and when it should be used. The specific best practices are described and linked within it. Look to these places to read and understand each skill:

- The Skill's name and file name.
- The Skill.md contains a link that points to `agent_os/standards/...` — Follow that link and read its contents.

### Step 3: Normalize the Skill name and rewrite the description

#### 3.1: Convert the skill name to kebab-case

Transform the `name` field in the frontmatter to kebab-case format:
- Convert all letters to lowercase
- Replace all whitespace characters (spaces, tabs) with a single hyphen
- Collapse multiple consecutive spaces/hyphens into a single hyphen
- Trim leading/trailing hyphens if present

Example transformations:
- `"API Standards"` → `"api-standards"`
- `"Vue  Component   Guidelines"` → `"vue-component-guidelines"`
- `"TypeScript Best Practices"` → `"typescript-best-practices"`

#### 3.2: Rewrite the description

The most important element of a skill.md file that impacts its discoverability and trigger-ability by Claude Code is the content we write in the `description` in the skill.md frontmatter.

**Algorithm for maximum discoverability:**

1. **First sentence:** Clearly state what the skill does
   ```
   "Write Tailwind CSS code and structure front-end UIs using utility classes."
   ```

2. **Following sentences:** List specific trigger scenarios using these patterns:
   - **File types:** "When writing or editing .tsx, .vue, .css files"
   - **Situations:** "When creating forms, layouts, or responsive designs"
   - **Tools/technologies:** "When using PostCSS, CSS-in-JS, or styled-components"
   - **Actions:** "When debugging, optimizing, or refactoring [specific area]"

**Key principle:** Focus ONLY on when to USE the skill.
Never include when NOT to use - this reduces discoverability.

**Longer descriptions are better:** More trigger scenarios = higher discoverability.
Use the full 1024 chars if needed.

**Good vs Bad Examples:**
```yaml
# Bad - too vague, won't trigger:
description: "Helps with database"

# Good - specific triggers:
description: "Use when connecting to PostgreSQL/MySQL, writing queries, or debugging database issues"

# Better - multiple trigger scenarios:
description: "API documentation generator. Use when documenting REST endpoints, creating OpenAPI specs, writing JSDoc comments, or generating SDK documentation"
```

#### 3.3: Remove unsupported fields

Check YAML frontmatter and REMOVE these fields if present:
- `tags`
- `version`
- `dependencies`

These fields are ignored by Claude Code and should be removed.

### Step 4: Insert a section for 'When to use this skill'

At the top of the content of skill.md, below the frontmatter, insert an H2 heading, "When to use this skill" followed by a list of use case examples.

The use case examples can repeat the same one(s) listed in the description and/or expand on them.

**Tip:** This section has no character limit (unlike description's 1024 chars), so you can expand on triggers mentioned in the description and add more specific scenarios.

Example:
```markdown
## When to use this skill

- [Descriptive example A]
- [Descriptive example B]
- [Descriptive example C]
...
```

### Step 5: Advise the user on improving their skills further

After revising ALL Skill.md files located in the project's `.claude/skills/` folder, display the following message to the user:

```
All Claude Code Skills have been analyzed and revised!

## Quality Checklist

Verify each skill meets these criteria:

- [ ] `description` contains specific trigger patterns
- [ ] Has "When to use this skill" section at top of content
- [ ] No `tags`/`version`/`dependencies` fields (unsupported)
- [ ] SKILL.md is SHORT (loaded early, before full context)
- [ ] Illustrative examples are short (3-5 lines)
- [ ] Links have context descriptions (when to load each file)
- [ ] One skill = one capability (focused scope)

## Additional Recommendations

- **Compactness:** Skills consume context window. Every character matters.
- **Triggering:** Description determines when skill loads - make it as specific as possible.
- **Progressive disclosure:** SKILL.md loads first, supporting files only when needed.
- **Multi-topic skills:** Split examples into separate files by topic for context efficiency.
- **Content completeness:** Include all relevant instructions, details and directives within the content of the Skill.
- You can link to other files (like your Agent OS standards files) using markdown links.
- Consolidate similar skills where it makes sense for Claude to find and use them together.
```
