# Codebase Reference Standards

## Context

Guidelines for maintaining codebase reference documentation that prevents AI hallucination while optimizing for context efficiency.

## Reference File Structure

```
.agent-os/codebase/
├── index.md       # Quick lookup index with statistics
├── functions.md   # Function and method signatures
├── imports.md     # Import maps and module exports
└── schemas.md     # Database and API schemas
```

## Format Standards

### functions.md Format

Use grep-optimized single-line format:

```markdown
## path/to/module.ext
functionName(params): ReturnType ::line:15
methodName(params): ReturnType ::line:42
ClassName ::line:67
::exports: functionName, ClassName
```

Key principles:
- One line per function/class
- Include line numbers with `::line:` prefix
- List exports at end with `::exports:` prefix
- Group by file path with `##` headers

### imports.md Format

Document import aliases and module exports:

```markdown
## Import Aliases
@/utils -> src/utils
@/components -> src/components
~/models -> app/models

## Module Exports
src/utils/auth.js: { getCurrentUser, validateToken, hashPassword }
src/components/Button.jsx: default Button
app/models/user.rb: class User
```

### schemas.md Format

Document database schemas and API endpoints:

```markdown
## Database Tables

### users
- id: integer (primary key)
- email: string (unique)
- password_hash: string
- created_at: timestamp

## API Endpoints

### Authentication
POST /api/auth/login - User login
POST /api/auth/logout - User logout
GET /api/auth/current - Get current user
```

## Conditional Loading

Use conditional blocks to load only relevant references:

```markdown
<conditional-block task-condition="auth-module">
IF task involves authentication:
  GREP: functions.md for "## auth/"
  LOAD: Only auth module signatures
ELSE:
  SKIP: Auth references not needed
</conditional-block>
```

## Incremental Updates

During task execution:
1. Identify modified files
2. Extract signatures from changed files only
3. Replace file sections in reference docs
4. Preserve unchanged file references

## Grep Patterns for Common Languages

### JavaScript/TypeScript
```bash
# Functions
grep -E "(function |const \w+ = |let \w+ = )" file.js

# Classes
grep -E "class \w+" file.js

# Exports
grep -E "(export |module\.exports)" file.js
```

### Python
```bash
# Functions and methods
grep -E "def \w+\(" file.py

# Classes
grep -E "class \w+[:\(]" file.py

# Imports
grep -E "(import |from .+ import)" file.py
```

### Ruby
```bash
# Methods
grep -E "def \w+" file.rb

# Classes and modules
grep -E "(class |module )\w+" file.rb
```

## Best Practices

1. **Keep It Minimal**: Store only signatures, not implementations
2. **Line Numbers**: Include for easy navigation
3. **Single Line**: One signature per line for grep efficiency
4. **Alphabetical**: Maintain order within file sections
5. **Incremental**: Update only changed files
6. **Context-Aware**: Load only what's needed for current task

## Usage in Instructions

Reference in execute-task.md:
```markdown
<step name="load_references">
  IF .agent-os/codebase/ exists:
    GREP: Relevant module sections
    CACHE: For task duration
  ELSE:
    NOTE: No references available
</step>
```

## Maintenance

- Initial index: Run @commands/index-codebase.md
- Auto-update: Happens during execute-task workflow
- Manual rebuild: Re-run index-codebase command
- Cleanup: Remove outdated file sections when files deleted