# Codebase Reference Index

Generated: 2025-01-21
Last Updated: 2025-01-21

## Overview

This directory contains lightweight reference documentation for the codebase, designed to prevent AI hallucination while maintaining context efficiency.

## Reference Files

| File | Description | Entries |
|------|-------------|---------|
| [functions.md](./functions.md) | Function and method signatures | 38 functions |
| [imports.md](./imports.md) | Import maps and module exports | 45 modules |
| [schemas.md](./schemas.md) | Database and API schemas | 6 tables, 28 endpoints |

## Indexed Directories

```
src/
├── auth/          ✓ Indexed (2 files)
├── components/    ✓ Indexed (6 files)
├── hooks/         ✓ Indexed (5 files)
├── models/        ✓ Indexed (4 files)
├── store/         ✓ Indexed (4 files)
├── utils/         ✓ Indexed (4 files)
└── types/         ✓ Indexed (3 files)
```

## Statistics

- **Total Files Indexed**: 28
- **Functions Documented**: 38
- **Classes Documented**: 5
- **Module Exports**: 45
- **Database Tables**: 6
- **API Endpoints**: 28

## Usage Guide

### Finding Functions
```bash
# Find all functions in auth module
grep "## src/auth/" functions.md

# Find specific function
grep "getCurrentUser" functions.md

# Find functions with specific return type
grep ": Promise<" functions.md
```

### Finding Imports
```bash
# Find import alias
grep "@/utils" imports.md

# Find module exports
grep "src/utils/api.js:" imports.md

# Find React hooks imports
grep "^react:" imports.md
```

### Finding Schemas
```bash
# Find table structure
grep -A 10 "### users" schemas.md

# Find API endpoints
grep "POST.*auth" schemas.md

# Find environment variables
grep "JWT" schemas.md
```

## Maintenance

### Automatic Updates
- References update automatically during task execution
- Only changed files are re-indexed
- Happens via execute-task.md workflow

### Manual Operations
- **Full Rebuild**: Run `@commands/index-codebase.md`
- **Check Status**: Review this index.md file
- **Clean Orphans**: Remove sections for deleted files

## Configuration

Controlled via `.agent-os/config.yml`:
```yaml
codebase_indexing:
  enabled: true
  incremental: true
```

## Best Practices

1. **Don't Edit Manually**: Let the indexer maintain these files
2. **Use Grep**: Always grep for specific sections, don't read entire files
3. **Keep Current**: Run index-codebase after major refactoring
4. **Check Line Numbers**: Use `::line:` references to navigate to source

## Notes

- Line numbers may drift between updates - use as approximate guides
- Signatures show interface only, not implementation
- Private/internal functions may be excluded based on naming conventions
- Test files are generally excluded from indexing