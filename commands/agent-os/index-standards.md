# Index Standards

Rebuild and maintain the standards index file (`index.yml`).

## Purpose

The index enables `/inject-standards` to suggest relevant standards without reading all files. It maps each standard to a brief description for quick matching.

## Process

### Step 1: Scan for Standards Files

1. List all `.md` files in `agent-os/standards/` and its subfolders
2. Build a list of all standards organized by folder:
   ```
   root/coding-style.md        # Files in standards/ root use "root" as the folder name
   root/naming.md
   api/response-format.md
   api/error-handling.md
   database/migrations.md
   ```

**Note:** `root` is a reserved keyword — it refers to `.md` files directly in `agent-os/standards/` (not in a subfolder). Do not create an actual folder named "root".

### Step 2: Load Existing Index

Read `agent-os/standards/index.yml` if it exists. Note which entries already have descriptions.

### Step 3: Identify Changes

Compare the file scan with the existing index:

- **New files** — Standards files without index entries
- **Deleted files** — Index entries for files that no longer exist
- **Existing files** — Already indexed, keep as-is

### Step 4: Handle New Files

For each new standard file that needs an index entry:

1. Read the file to understand its content
2. Use AskUserQuestion to propose a description:

```
New standard needs indexing:
  File: api/response-format.md

Suggested description: "API response envelope structure and error format"

Accept? (yes / or type a better description)
```

Keep descriptions to **one short sentence** — they're for matching, not documentation.

### Step 5: Handle Deleted Files

If there are index entries for files that no longer exist:

1. List them for the user
2. Remove them from the index automatically (no confirmation needed)

Report: "Removed 2 stale index entries: api/old-pattern.md, testing/deprecated.md"

### Step 6: Write Updated Index

Generate `agent-os/standards/index.yml` with this structure:

```yaml
folder-name:
  file-name:
    description: Brief description here
```

**Rules:**
- Alphabetize folders
- Alphabetize files within each folder
- File names without `.md` extension
- One-line descriptions only

**Example:**
```yaml
root:
  coding-style:
    description: General coding style, formatting, linting rules
  naming:
    description: File naming, variable naming, class naming conventions

api:
  error-handling:
    description: Error codes, exception handling, error response format
  response-format:
    description: API response envelope structure, status codes, pagination

database:
  migrations:
    description: Migration file structure, naming conventions, rollback patterns
```

**Note:** `root` appears first and contains standards files that live directly in `agent-os/standards/` (not in subfolders).

### Step 7: Report Results

Summarize what changed:

```
Index updated:
  ✓ 2 new entries added
  ✓ 1 stale entry removed
  ✓ 8 entries unchanged

Total: 9 standards indexed
```

## When to Run

- After manually creating or deleting standards files
- If `/inject-standards` suggestions seem out of sync
- To clean up a messy or outdated index

**Note:** `/discover-standards` runs this automatically as its final step, so you usually don't need to call it separately after discovering standards.

## Output

Updates `agent-os/standards/index.yml`
