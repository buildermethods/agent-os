---
name: codebase-names
description: "Validate function, variable, and component names against the codebase index before writing code. Auto-invoke this skill when referencing existing functions, importing components, or modifying files with existing code."
allowed-tools: Read, Grep, Glob
---

# Codebase Names Validation Skill

Automatically validate exact names from the codebase index to prevent naming errors when writing code that integrates with existing functions, components, or variables.

## When to Use This Skill

Claude should automatically invoke this skill:
- **Before calling existing functions** in new code
- **Before importing existing components/utilities**
- **Before modifying existing files** with function references
- **When referencing existing variables/classes/types**
- **When using database table or API endpoint names**

## Codebase Reference Files

Look for these files in `.agent-os/codebase/`:
- `functions.md` - Function signatures with parameters and return types
- `imports.md` - Component and utility import paths
- `schemas.md` - Database tables and API endpoints

## Workflow

### 1. Identify Target Modules
From the current task, determine which modules/areas need name validation.

### 2. Search Codebase References
```bash
# For function names
grep "functionName" .agent-os/codebase/functions.md

# For component imports
grep "ComponentName" .agent-os/codebase/imports.md

# For schemas
grep "table_name" .agent-os/codebase/schemas.md
```

### 3. Provide Exact Names Reference

## Output Format

```markdown
📚 Existing Names Reference

Functions (from [file-path]):
- exactFunctionName(param1, param2): ReturnType ::line:42
- anotherFunction(param): ReturnType ::line:87

Components/Imports:
- import { ExactComponentName } from '@/exact/path'
- import { useExactHook } from '@/hooks/exact-name'

Variables (in [file-path]):
- exactVariableName: Type
- anotherVariable: Type

Schemas:
- table_name (columns: id, name, created_at)
- api/exact/endpoint

⚠️  USE THESE EXACT NAMES - DO NOT GUESS OR APPROXIMATE
```

## Smart Module Detection

Based on task context, automatically search for:

**Auth-related tasks:**
- Grep "## src/auth/" or "## lib/auth/" in functions.md
- Find auth utilities, validation functions, token handlers

**Component tasks:**
- Grep component names in imports.md
- Find related hooks and utilities

**API/Backend tasks:**
- Grep API-related functions in functions.md
- Extract schemas from schemas.md

**Database tasks:**
- Grep table names in schemas.md
- Find model functions in functions.md

## Missing Names Protocol

If requested names are not found:
```
❌ Not Found in Codebase Index

Could not locate: [function/component/variable name]

Options:
1. Name may not exist - needs to be created
2. Codebase index may be outdated - run /index-codebase
3. Name may be in different module - specify alternate location

DO NOT proceed with guessed names. Clarify with user.
```

## Key Principles

1. **Exact Names Only**: Never guess or approximate - use exact names from index
2. **Proactive Validation**: Provide names before code is written, not after
3. **Copy-Paste Ready**: Format names for easy use in code
4. **Clear Warnings**: Alert when names are missing or potentially outdated
