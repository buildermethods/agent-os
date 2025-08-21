# Test Plan for Codebase Indexing Feature

## Test Scenarios

### 1. Initial Index Creation
```bash
# Run index-codebase command on a sample project
@commands/index-codebase.md
```
Expected:
- Creates .agent-os/codebase/ directory
- Generates functions.md, imports.md, schemas.md, index.md
- Extracts function signatures from code files
- Maps import aliases and exports

### 2. Context-Fetcher Integration
Test requests to context-fetcher agent:
- "Find function signatures for auth module"
- "Get import path for Button component"
- "Check if getCurrentUser function exists"

Expected:
- Returns only matching lines from reference files
- Uses grep for efficient extraction
- Indicates if already in context

### 3. Execute-Task Integration
During task execution:
- Step 3.5: Loads relevant codebase references
- Step 6.5: Updates references for changed files

Expected:
- Conditional loading based on task needs
- Incremental updates only for modified files
- Preserves unchanged references

### 4. Incremental Updates
After modifying a file:
```javascript
// Add new function to src/utils/helpers.js
export function formatUserName(user) {
  return `${user.firstName} ${user.lastName}`;
}
```

Expected:
- codebase-indexer detects the change
- Updates only src/utils/helpers.js section in functions.md
- Adds new export to imports.md
- Other sections remain unchanged

### 5. Grep Efficiency Test
```bash
# Time grep vs full file read
time grep "getCurrentUser" .agent-os/codebase/functions.md
time cat .agent-os/codebase/functions.md
```

Expected:
- Grep completes in < 10ms for typical file
- Significantly faster than reading entire file

### 6. Configuration Test
Check config.yml settings:
```yaml
codebase_indexing:
  enabled: true
  incremental: true
```

Expected:
- Indexing runs when enabled: true
- Skips when enabled: false
- Incremental updates when incremental: true

## Success Criteria

✅ Prevents function name hallucination
✅ Maintains correct import paths
✅ Minimal context usage (< 500 tokens per lookup)
✅ Automatic updates during workflow
✅ Fast grep-based retrieval (< 50ms)
✅ Handles multiple programming languages

## Sample Test Project Structure

```
test-project/
├── src/
│   ├── auth/
│   │   ├── utils.js
│   │   └── middleware.js
│   ├── components/
│   │   ├── Button.jsx
│   │   └── Card.tsx
│   └── utils/
│       ├── api.js
│       └── validation.js
├── package.json
└── .agent-os/
    └── codebase/
        ├── index.md
        ├── functions.md
        ├── imports.md
        └── schemas.md
```

## Verification Commands

```bash
# Check if references exist
ls -la .agent-os/codebase/

# Verify function extraction
grep -c "::line:" .agent-os/codebase/functions.md

# Check import mappings
grep "@/" .agent-os/codebase/imports.md

# Test selective loading
grep "## src/auth/" .agent-os/codebase/functions.md
```