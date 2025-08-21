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

## Specification Mapping Standards

### Enhanced functions.md Format with Spec References

Include specification mapping in function signatures:

```markdown
## src/auth/authentication.js
login(email: string, password: string): Promise<AuthResult> ::line:15 ::spec:auth-spec.md:2.1 ✓
logout(): void ::line:42 ::spec:auth-spec.md:2.3 ⚠️ (missing error handling)
getCurrentUser(): Promise<User> ::line:67 ::no-spec ❓
resetPassword(email: string): Promise<boolean> ::line:89 ::spec:auth-spec.md:2.5 ❌ (wrong return type)
::exports: login, logout, getCurrentUser, resetPassword
::compliance: 2/4 functions fully spec-compliant
::spec-coverage: auth-spec.md sections 2.1-2.5
```

### Specification Compliance Indicators

- **✓** Function fully matches specification requirements
- **⚠️** Function exists but has compliance issues (with specific reason)  
- **❓** Function has no specification coverage
- **❌** Function violates specification requirements (with specific issue)

### Enhanced schemas.md Format with Spec Mapping

Cross-reference schemas with specifications:

```markdown
## Database Schemas ::spec:database-schema.md

### users ::spec:database-schema.md:3.1 ✓
- id: integer (primary key)
- email: string (unique, max 255) ::spec:3.1.2
- password_hash: string (bcrypt) ::spec:3.1.3
- created_at: timestamp ::spec:3.1.4
- updated_at: timestamp ::spec:3.1.4

### posts ::spec:database-schema.md:3.2 ⚠️ (missing indexes)
- id: integer (primary key)
- user_id: integer (foreign key) ::spec:3.2.2
- title: string (max 200) ::spec:3.2.3
- content: text ::spec:3.2.4
- published_at: timestamp ::spec:3.2.5

## API Endpoints ::spec:api-spec.md

### Authentication ::spec:api-spec.md:2.0 ✓
POST /api/auth/login ::spec:2.1 - User authentication
POST /api/auth/logout ::spec:2.2 - Session termination
GET /api/auth/current ::spec:2.3 - Current user info

### Users ::spec:api-spec.md:3.0 ⚠️ (missing PATCH endpoint)
GET /api/users/:id ::spec:3.1 - Get user profile
PUT /api/users/:id ::spec:3.2 - Update user profile
DELETE /api/users/:id ::spec:3.3 - Delete user account
```

### Specification-Aware Conditional Loading

Use specification context to guide reference loading:

```markdown
<conditional-block spec-condition="auth-functionality">
IF current spec involves authentication features:
  GREP: functions.md for "## */auth/*" AND "::spec:auth-spec"
  LOAD: Only auth-related functions with spec compliance status
  PRIORITIZE: Functions with compliance issues (⚠️ or ❌) for review
ELSE:
  SKIP: Auth-specific references not needed
</conditional-block>

<conditional-block spec-condition="api-implementation">  
IF current spec involves API development:
  GREP: schemas.md for "## API Endpoints" AND specific spec section
  LOAD: Only relevant API endpoint references
  CHECK: Compliance status for implementation planning
ELSE:
  SKIP: API references not needed
</conditional-block>
```

### Cross-Reference Validation

Maintain bidirectional mapping between specs and code:

```markdown
## Specification Coverage Report

### auth-spec.md Coverage
- Section 2.1 (User Login): ✓ Implemented in src/auth/authentication.js:15
- Section 2.2 (User Logout): ✓ Implemented in src/auth/authentication.js:42  
- Section 2.3 (Current User): ⚠️ Implemented in src/auth/authentication.js:67 (missing validation)
- Section 2.4 (Password Reset): ❌ Not implemented
- Section 2.5 (Account Verification): ❓ Implemented but not in spec

### Orphaned Implementations
- src/auth/social-login.js:25 (socialLogin) - No specification coverage
- src/auth/two-factor.js:33 (generateTOTP) - No specification coverage
```

## Maintenance

- Initial index: Run @commands/index-codebase.md
- Auto-update: Happens during execute-task workflow  
- Manual rebuild: Re-run index-codebase command
- Cleanup: Remove outdated file sections when files deleted
- Spec validation: Check compliance indicators during indexing
- Coverage reports: Generate spec-to-code mapping reports