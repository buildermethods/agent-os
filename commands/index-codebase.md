# Index Codebase Command

## Purpose
Initialize codebase reference documentation for an existing project. This is a one-time setup that creates the initial reference index, which is then maintained incrementally during task execution.

## Usage
Use this command when:
- Installing Agent OS in an existing project with code
- Rebuilding reference documentation after major refactoring
- Setting up codebase indexing for the first time

## Process
1. Creates .agent-os/codebase/ directory structure
2. Scans project for code files
3. Extracts function signatures, exports, and imports
4. Generates initial reference documentation
5. Creates index for quick lookup

## Important Notes
- Run only once when setting up Agent OS
- Subsequent updates happen automatically during execute-task
- May take a few minutes for large codebases
- Respects .gitignore patterns

## Command
@.agent-os/instructions/core/index-codebase.md