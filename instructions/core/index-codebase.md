---
description: Initialize codebase reference documentation for Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Index Codebase Rules

## Overview

Create initial codebase reference documentation by scanning the project and extracting function signatures, imports, exports, and schemas. This is a one-time initialization - subsequent updates happen automatically during task execution.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="check_existing">

### Step 1: Check for Existing References

Verify if codebase references already exist to prevent accidental overwrite.

<verification>
  CHECK: .agent-os/codebase/ directory
  IF exists:
    PROMPT: "Codebase references already exist. Overwrite? (y/n)"
    IF no:
      EXIT: Preserve existing references
  ELSE:
    CONTINUE: Create new references
</verification>

</step>

<step number="2" name="create_structure">

### Step 2: Create Reference Structure

Create the codebase reference directory and files.

<directory_structure>
  CREATE: .agent-os/codebase/
  CREATE: .agent-os/codebase/index.md
  CREATE: .agent-os/codebase/functions.md
  CREATE: .agent-os/codebase/imports.md
  CREATE: .agent-os/codebase/schemas.md
</directory_structure>

<initial_content>
  <index_md>
    # Codebase Reference Index
    
    Generated: [DATE]
    Last Updated: [DATE]
    
    ## Reference Files
    - functions.md: Function and method signatures
    - imports.md: Import maps and module exports
    - schemas.md: Database and API schemas
    
    ## Indexed Directories
    [Will be populated during scan]
  </index_md>
</initial_content>

</step>

<step number="3" name="identify_files">

### Step 3: Identify Project Files

Scan the project to identify code files to index.

<file_discovery>
  <supported_extensions>
    JavaScript: .js, .jsx, .mjs
    TypeScript: .ts, .tsx
    Python: .py
    Ruby: .rb
    Go: .go
    Rust: .rs
    Java: .java
    C#: .cs
  </supported_extensions>
  
  <exclusions>
    - node_modules/
    - vendor/
    - dist/
    - build/
    - .git/
    - coverage/
    - tmp/
    - Respect .gitignore patterns
  </exclusions>
</file_discovery>

<scanning_strategy>
  USE: Glob patterns to find files
  LIMIT: First 500 files for large projects
  PRIORITIZE: src/, app/, lib/ directories
</scanning_strategy>

</step>

<step number="4" subagent="codebase-indexer" name="extract_signatures">

### Step 4: Extract Code Signatures

Use the codebase-indexer subagent to extract function signatures, exports, and imports from identified files.

<extraction_batching>
  BATCH_SIZE: 10 files at a time
  PROCESS: Extract signatures from each batch
  UPDATE: Reference files after each batch
</extraction_batching>

<instructions>
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
</instructions>

</step>

<step number="5" name="extract_schemas">

### Step 5: Extract Database and API Schemas

Identify and extract database schemas and API definitions.

<schema_locations>
  <database>
    - db/schema.rb (Rails)
    - migrations/*.sql
    - models/*.py (Django/SQLAlchemy)
    - prisma/schema.prisma
    - schema.sql
  </database>
  
  <api>
    - swagger.json/yaml
    - openapi.json/yaml
    - routes/*.js
    - controllers/*.rb
    - api/routes.py
  </api>
</schema_locations>

<extraction>
  IF schema files found:
    EXTRACT: Table definitions
    EXTRACT: Column types
    EXTRACT: API endpoints
    WRITE: To schemas.md
  ELSE:
    NOTE: "No schema files detected"
</extraction>

</step>

<step number="6" name="generate_import_map">

### Step 6: Generate Import Map

Create a map of import aliases and module exports for quick reference.

<import_mapping>
  <detect_aliases>
    - webpack.config.js aliases
    - tsconfig.json paths
    - package.json imports
    - babel.config.js aliases
  </detect_aliases>
  
  <module_exports>
    SCAN: Each indexed file
    IDENTIFY: Default and named exports
    MAP: File path to exports list
  </module_exports>
</import_mapping>

<output_format>
  ## Import Aliases
  @/utils -> src/utils
  ~/components -> src/components
  
  ## Module Exports
  src/utils/auth.js: { getCurrentUser, validateToken }
  src/components/Button.jsx: default Button
</output_format>

</step>

<step number="7" name="update_index">

### Step 7: Update Index File

Update the index.md file with scan statistics and directory list.

<index_update>
  UPDATE: Generated date
  LIST: All indexed directories
  COUNT: Total files indexed
  COUNT: Functions/methods found
  COUNT: Classes found
  NOTE: Any skipped directories
</index_update>

<statistics>
  ## Scan Statistics
  - Files Indexed: [COUNT]
  - Functions: [COUNT]
  - Classes: [COUNT]
  - Exports: [COUNT]
  - Last Updated: [DATE]
</statistics>

</step>

<step number="8" name="enable_auto_update">

### Step 8: Configure Auto-Update

Ensure config.yml is set up for incremental updates during task execution.

<config_check>
  READ: .agent-os/config.yml
  IF codebase_indexing section missing:
    ADD:
      codebase_indexing:
        enabled: true
        incremental: true
  ELSE:
    ENSURE: enabled: true
    ENSURE: incremental: true
</config_check>

<instructions>
  ACTION: Update config.yml if needed
  VERIFY: Auto-update is enabled
  NOTE: Future updates will be automatic
</instructions>

</step>

<step number="9" name="final_report">

### Step 9: Generate Summary Report

Provide a summary of the indexing operation.

<report_template>
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
</report_template>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>