# Index Codebase

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
Initialize codebase reference documentation for an existing project. This is a one-time setup that creates the initial reference index, which is then maintained incrementally during task execution. Creates comprehensive documentation of function signatures, exports, imports, and schemas.

## Parameters
- `force_rebuild` (optional): Boolean to force complete rebuild of existing references
- `file_limit` (optional): Maximum number of files to index (default: 500 for large projects)
- `include_patterns` (optional): Array of additional file patterns to include

## Dependencies
**Required State Files:**
- `.agent-os/config.yml` (read/write for auto-update configuration)

**Expected Directories:**
- Current working directory (existing codebase to index)
- `.agent-os/` (Agent OS installation)

**Creates Directories:**
- `.agent-os/codebase/` (codebase reference documentation)

**Creates Files:**
- `.agent-os/codebase/index.md` (reference index and statistics)
- `.agent-os/codebase/functions.md` (function and method signatures)
- `.agent-os/codebase/imports.md` (import maps and module exports)
- `.agent-os/codebase/schemas.md` (database and API schemas)

## Task Tracking
**IMPORTANT: Use Claude's TodoWrite tool throughout execution:**
```javascript
// Example todos for this command workflow
const todos = [
  { content: "Check for existing references", status: "pending", activeForm: "Checking for existing references" },
  { content: "Create reference structure", status: "pending", activeForm: "Creating reference structure" },
  { content: "Identify project files", status: "pending", activeForm: "Identifying project files" },
  { content: "Extract code signatures", status: "pending", activeForm: "Extracting code signatures" },
  { content: "Extract database and API schemas", status: "pending", activeForm: "Extracting database and API schemas" },
  { content: "Generate import map", status: "pending", activeForm: "Generating import map" },
  { content: "Update index file", status: "pending", activeForm: "Updating index file" },
  { content: "Configure auto-update", status: "pending", activeForm: "Configuring auto-update" },
  { content: "Generate summary report", status: "pending", activeForm: "Generating summary report" }
];
// Update status to "in_progress" when starting each task
// Mark as "completed" immediately after finishing
```

## For Claude Code
When executing this command:
1. **Initialize TodoWrite** with the workflow steps above for visibility
2. Check for existing references and handle overwrite scenarios
3. Use Task tool to invoke subagents as specified
4. Handle large codebases with batching strategies
5. **Update TodoWrite** status throughout execution
6. Configure automatic updates for future task execution

---

## SECTION: Core Instructions
<!-- BEGIN EMBEDDED CONTENT -->

# Index Codebase Rules

## Overview

Create initial codebase reference documentation by scanning the project and extracting function signatures, imports, exports, and schemas. This is a one-time initialization - subsequent updates happen automatically during task execution.

## Process Flow

### Step 1: Check for Existing References

Verify if codebase references already exist to prevent accidental overwrite.

**Verification:**
```
CHECK: .agent-os/codebase/ directory
IF exists:
  PROMPT: "Codebase references already exist. Overwrite? (y/n)"
  IF no:
    EXIT: Preserve existing references
ELSE:
  CONTINUE: Create new references
```

### Step 2: Create Reference Structure

Create the codebase reference directory and files.

**Directory Structure:**
```
CREATE: .agent-os/codebase/
CREATE: .agent-os/codebase/index.md
CREATE: .agent-os/codebase/functions.md
CREATE: .agent-os/codebase/imports.md
CREATE: .agent-os/codebase/schemas.md
```

**Initial Content:**
```markdown
# Codebase Reference Index

Generated: [DATE]
Last Updated: [DATE]

## Reference Files
- functions.md: Function and method signatures
- imports.md: Import maps and module exports
- schemas.md: Database and API schemas

## Indexed Directories
[Will be populated during scan]
```

### Step 3: Identify Project Files

Scan the project to identify code files to index.

**File Discovery:**

**Supported Extensions:**
- JavaScript: .js, .jsx, .mjs
- TypeScript: .ts, .tsx
- Python: .py
- Ruby: .rb
- Go: .go
- Rust: .rs
- Java: .java
- C#: .cs

**Exclusions:**
- node_modules/
- vendor/
- dist/
- build/
- .git/
- coverage/
- tmp/
- Respect .gitignore patterns

**Scanning Strategy:**
- USE: Glob patterns to find files
- LIMIT: First 500 files for large projects
- PRIORITIZE: src/, app/, lib/ directories

### Step 4: Extract Code Signatures

Use the codebase-indexer subagent to extract function signatures, exports, and imports from identified files.

**Extraction Batching:**
- BATCH_SIZE: 10 files at a time
- PROCESS: Extract signatures from each batch
- UPDATE: Reference files after each batch

**Instructions:**
```
ACTION: Use codebase-indexer subagent
REQUEST: "Index the following files:
          [BATCH_OF_FILES]
          Extract:
          - Function/method signatures with line numbers
          - Class definitions
          - Module exports
          - Import statements and aliases"
WAIT: For indexer to process batch
REPEAT: For all file batches
```

### Step 5: Extract Database and API Schemas

Identify and extract database schemas and API definitions.

**Schema Locations:**

**Database:**
- db/schema.rb (Rails)
- migrations/*.sql
- models/*.py (Django/SQLAlchemy)
- prisma/schema.prisma
- schema.sql

**API:**
- swagger.json/yaml
- openapi.json/yaml
- routes/*.js
- controllers/*.rb
- api/routes.py

**Extraction:**
```
IF schema files found:
  EXTRACT: Table definitions
  EXTRACT: Column types
  EXTRACT: API endpoints
  WRITE: To schemas.md
ELSE:
  NOTE: "No schema files detected"
```

### Step 6: Generate Import Map

Create a map of import aliases and module exports for quick reference.

**Import Mapping:**

**Detect Aliases:**
- webpack.config.js aliases
- tsconfig.json paths
- package.json imports
- babel.config.js aliases

**Module Exports:**
- SCAN: Each indexed file
- IDENTIFY: Default and named exports
- MAP: File path to exports list

**Output Format:**
```markdown
## Import Aliases
@/utils -> src/utils
~/components -> src/components

## Module Exports
src/utils/auth.js: { getCurrentUser, validateToken }
src/components/Button.jsx: default Button
```

### Step 7: Update Index File

Update the index.md file with scan statistics and directory list.

**Index Update:**
- UPDATE: Generated date
- LIST: All indexed directories
- COUNT: Total files indexed
- COUNT: Functions/methods found
- COUNT: Classes found
- NOTE: Any skipped directories

**Statistics:**
```markdown
## Scan Statistics
- Files Indexed: [COUNT]
- Functions: [COUNT]
- Classes: [COUNT]
- Exports: [COUNT]
- Last Updated: [DATE]
```

### Step 8: Configure Auto-Update

Ensure config.yml is set up for incremental updates during task execution.

**Config Check:**
```
READ: .agent-os/config.yml
IF codebase_indexing section missing:
  ADD:
    codebase_indexing:
      enabled: true
      incremental: true
ELSE:
  ENSURE: enabled: true
  ENSURE: incremental: true
```

**Instructions:**
- ACTION: Update config.yml if needed
- VERIFY: Auto-update is enabled
- NOTE: Future updates will be automatic

### Step 9: Generate Summary Report

Provide a summary of the indexing operation.

**Report Template:**
```markdown
# Codebase Indexing Complete

## Summary
- Files indexed: [COUNT]
- Functions documented: [COUNT]
- Classes documented: [COUNT]
- Exports mapped: [COUNT]

## Reference Files Created
- .agent-os/codebase/index.md
- .agent-os/codebase/functions.md
- .agent-os/codebase/imports.md
- .agent-os/codebase/schemas.md

## Next Steps
- References will update automatically during task execution
- Use @.agent-os/codebase/ for function lookups
- Run this command again only for full rebuild
```

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

### State Operations
All codebase indexing uses batched processing with progress tracking:

```javascript
// Initialize indexing state
const indexingState = {
  total_files: 0,
  processed_files: 0,
  indexed_functions: 0,
  indexed_classes: 0,
  indexed_exports: 0,
  current_batch: [],
  completed_batches: [],
  errors: []
};

// File discovery and batching
const discoveredFiles = scanProjectFiles(includePatterns, fileLimit);
const fileBatches = batchFiles(discoveredFiles, BATCH_SIZE);

// Progress tracking during batching
for (const batch of fileBatches) {
  const batchResults = await processBatch(batch);
  indexingState.processed_files += batch.length;
  indexingState.completed_batches.push(batchResults);
  updateProgressDisplay(indexingState);
}
```

### Reference File Management
- Use atomic writes for all reference files
- Track changes for incremental updates
- Maintain file locks during indexing operations
- Backup existing references before overwrite

### Configuration Integration
- Read and update .agent-os/config.yml safely
- Enable automatic incremental updates
- Configure file watching for future updates
- Set appropriate scan limits and patterns

---

## SECTION: Error Handling

### Error Recovery Procedures

1. **Existing Reference Conflicts**:
   - Prompt user for overwrite confirmation
   - Backup existing references with timestamp
   - Allow selective file replacement
   - Preserve user customizations where possible

2. **File Discovery Failures**:
   - Continue with discovered files
   - Report inaccessible directories
   - Skip corrupted or binary files
   - Log discovery errors for review

3. **Code Extraction Failures**:
   - Continue processing remaining files
   - Log extraction errors per file
   - Provide partial results with warnings
   - Allow manual addition of missed signatures

4. **Batching Timeout Issues**:
   - Reduce batch size automatically
   - Skip problematic files temporarily
   - Allow resumption from last successful batch
   - Provide manual override options

5. **Schema Discovery Failures**:
   - Continue without schema documentation
   - Note missing schema files in report
   - Allow manual schema file specification
   - Provide post-indexing schema addition

6. **Configuration Update Failures**:
   - Continue without auto-update configuration
   - Warn about manual update requirements
   - Provide manual configuration instructions
   - Allow retry of configuration update

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- `codebase-indexer` for extracting function signatures, classes, imports, and exports from code files in batches