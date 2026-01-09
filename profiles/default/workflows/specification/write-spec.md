# Spec Writing

## Core Responsibilities

1. **Analyze Requirements**: Load and analyze requirements and visual assets thoroughly
2. **Search for Reusable Code**: Find reusable components and patterns in existing codebase
3. **Impact Analysis**: Find ALL code affected by this change (critical for refactoring)
4. **Create Specification**: Write comprehensive specification document

## Workflow

### Step 1: Analyze Requirements and Context

Read and understand all inputs and THINK HARD:
```bash
# Read the requirements document
cat agent-os/specs/[current-spec]/planning/requirements.md

# Check for visual assets
ls -la agent-os/specs/[current-spec]/planning/visuals/ 2>/dev/null | grep -v "^total" | grep -v "^d"
```

Parse and analyze:
- User's feature description and goals
- Requirements gathered by spec-shaper
- Visual mockups or screenshots (if present)
- Any constraints or out-of-scope items mentioned

### Step 2: Search for Reusable Code

Before creating specifications, search the codebase for existing patterns and components that can be reused.

Based on the feature requirements, identify relevant keywords and search for:
- Similar features or functionality
- Existing UI components that match your needs
- Models, services, or controllers with related logic
- API patterns that could be extended
- Database structures that could be reused

Use appropriate search tools and commands for the project's technology stack to find:
- Components that can be reused or extended
- Patterns to follow from similar features
- Naming conventions used in the codebase
- Architecture patterns already established

Document your findings for use in the specification.

### Step 2.5: Impact Analysis - Find All Affected Code

**CRITICAL:** Before creating the specification, perform comprehensive impact analysis to find ALL code that will be affected by this change. This is especially important for refactoring tasks that modify shared constants, types, or patterns.

**When to perform impact analysis:**
- Modifying shared constants or type definitions
- Renaming or changing values used across multiple files
- Refactoring code that may have duplicates in different packages
- Changing APIs, database schemas, or configuration formats

**How to perform impact analysis:**

Use appropriate search tools for the project's technology stack (grep, ripgrep, IDE search, etc.).

1. **Search for constant/type usages:**
   ```bash
   # Find all files using the constants/types being modified
   # Adjust file extensions for your project's language(s)
   grep -r "CONSTANT_NAME" .
   ```

2. **Check for duplicate definitions:**
   ```bash
   # Detect if the same constant is defined in multiple places (this is a RED FLAG)
   grep -rn "CONSTANT_NAME" . | grep -E "(export|define|const|var|let|=)"
   ```
   If duplicates are found, they MUST be consolidated in the spec.

3. **Find hardcoded values:**
   ```bash
   # Search for hardcoded values that should use the constant
   grep -rn "'literal_value'" .
   ```

4. **Identify all packages/modules affected:**
   ```bash
   # List unique directories with matches
   grep -r "CONSTANT_NAME" . | cut -d':' -f1 | xargs -I{} dirname {} | sort -u
   ```

5. **Find related mappings and transformations:**
   ```bash
   # Search for mapping structures that may reference the constants being changed
   grep -rn "mapping\|Mapping\|MAP\|Map" .

   # Search for transformation/conversion functions
   grep -rn "transform\|Transform\|convert\|Convert\|to[A-Z]" .
   ```

   **Why this matters:** When changing constants or types, related data structures often need updates too:
   - Lookup tables that map one value to another
   - Configuration objects that use values from the constant
   - Transformation functions that convert between formats

   Review grep results for structures that reference or depend on the values being changed.

**Document your findings:**
- Total files affected (count)
- Duplicate definitions found (these MUST be listed for consolidation)
- Hardcoded values found (these MUST be listed for refactoring)
- Related mappings/transformations found (these MUST be reviewed for updates)
- All packages/modules requiring updates

**Include in specification:** Add a "Files Requiring Modification" section OR expand "Existing Code to Leverage" to include all affected files, not just reusable ones.

### Step 3: Create Core Specification

Write the main specification to `agent-os/specs/[current-spec]/spec.md`.

DO NOT write actual code in the spec.md document. Just describe the requirements clearly and concisely.

Keep it short and include only essential information for each section.

Follow this structure exactly when creating the content of `spec.md`:

```markdown
# Specification: [Feature Name]

## Goal
[1-2 sentences describing the core objective]

## User Stories
- As a [user type], I want to [action] so that [benefit]
- [repeat for up to 2 max additional user stories]

## Specific Requirements

**Specific requirement name**
- [Up to 8 CONCISE sub-bullet points to clarify specific sub-requirements, design or architectual decisions that go into this requirement, or the technical approach to take when implementing this requirement]

[repeat for up to a max of 10 specific requirements]

## Visual Design
[If mockups provided]

**`planning/visuals/[filename]`**
- [up to 8 CONCISE bullets describing specific UI elements found in this visual to address when building]

[repeat for each file in the `planning/visuals` folder]

## Existing Code to Leverage

**Code, component, or existing logic found**
- [up to 5 bullets that describe what this existing code does and how it should be re-used or replicated when building this spec]

[repeat for up to 5 existing code areas]

## Out of Scope
- [up to 10 concise descriptions of specific features that are out of scope and MUST NOT be built in this spec]
```

## Important Constraints

1. **Always search for reusable code** before specifying new components
2. **Always perform impact analysis** for refactoring tasks - find ALL affected files, not just similar ones
3. **Check for duplicate definitions** - if the same constant/type exists in multiple packages, flag it for consolidation
4. **Check for related mappings** - search for lookup tables, transformations, and config objects that depend on the values being changed
5. **Reference visual assets** when available
6. **Do NOT write actual code** in the spec
7. **Keep each section short**, with clear, direct, skimmable specifications
8. **Do NOT deviate from the template above** and do not add additional sections
