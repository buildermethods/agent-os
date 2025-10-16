Now that we have a spec and tasks list ready for implementation, we must generate an ordered series of prompt texts, which will be used to direct the implementation of this spec's tasks.

Follow these steps to generate this spec's ordered series of prompts texts, each in its own .md file located in `agent-os/specs/[this-spec]/implementation/prompts/`.

LOOP through EACH task group in `agent-os/specs/[this-spec]/tasks.md` and for each, use the following workflow to generate a markdown file with prompt text for each task group:

## Task Group Prompt Generation Workflow

### Step 1. Create the prompt markdown file

Create the prompt markdown file using this naming convention:
`agent-os/specs/[this-spec]/implementation/prompts/[task-group-number]-[task-group-title].md`.

For example, if the 3rd task group in tasks.md is named "Comment System" then create `3-comment-system.md`.

### Step 2. Populate the prompt file

Populate the prompt markdown file using the following Prompt file content template.

#### Bracket content replacements

In the content template below, replace "[spec-title]" and "[this-spec]" with the current spec's title, and "[task-group-number]" with the current task group's number.

Replace "[implementer-standards]" using the following logic:
1. Get the ID of the `Assigned Implementer` for this task group specified in `tasks.md`
2. Find the implementer by that ID in `agent-os/roles/implementers.yml`
3. Check the list of `standards` for that implementer as specified in `agent-os/roles/implementers.yml`
4. Compile the list of file references to those standards and display the list in place of "[implementer-standards]", one file reference per line. Use this logic for determining the list of files to include in this list:
  a. If the value for `standards` is simply `all`, then include every single file, folder, sub-folder and files within sub-folders in your list of files.
  b. If the item under standards ends with "*" then it means that all files within this folder or sub-folder should be included.  For example, `frontend/*` means include all files and sub-folders and their files located inside of `agent-os/standards/frontend/`.
  c. If a file ends in `.md` then it means this is one specific file you must include in your list of files.  For example `backend/api.md` means you must include in the file located at `agent-os/standards/backend/api.md`.
  d. De-duplicate files in your list of file references.

The compiled list of standards should like this, where each file reference is on its own line and begins with `@`.  The exact list of files will vary:

```
@agent-os/standards/global/coding-style.md
@agent-os/standards/global/conventions.md
@agent-os/standards/global/tech-stack.md
@agent-os/standards/backend/api/authentication.md
@agent-os/standards/backend/api/endpoints.md
@agent-os/standards/backend/api/responses.md
@agent-os/standards/frontend/css.md
@agent-os/standards/frontend/responsive.md
```

#### Prompt file content template:

```markdown
We're continuing our implementation of [spec-title] by implementing task group number [task-group-number]:

## Implement this task and its sub-tasks:

[paste entire task group including parent task, all of its' sub-tasks, and sub-bullet points]

## Understand the context

Read @agent-os/specs/[this-spec]/spec.md to understand the context for this spec and where the current task fits into it.

## Perform the implementation

{{workflows/implementation/implement-task}}

## Update tasks.md task status

{{workflows/implementation/update-tasks-list}}

## Document your implementation

{{workflows/implementation/document-implementation}}

## User Standards & Preferences Compliance

IMPORTANT: Ensure that your implementation work is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

[implementer-standards]

```

### Step 3: Output the list of created prompt files

Output to user the following:

"Ready to begin implementation of [spec-title]!

Use the following list of prompts to direct the implementation of each task group:

[list prompt files in order]

**Pause-for-Review Workflow:**
Input these prompts one-by-one. After each task group is completed, the agent will:
1. Summarize the implementation and list files changed
2. Provide a suggested commit message
3. Ask for your approval to create the commit
4. Create the commit after you approve
5. You then proceed to the next task group prompt when ready

This iterative approach prevents massive uncommittable changesets and allows for incremental testing and feedback. You maintain control over when to proceed to the next task group.

**See** @agent-os/standards/global/agent-workflow.md for detailed guidance on commit strategies.

Progress will be tracked in `agent-os/specs/[this-spec]/tasks.md`"
