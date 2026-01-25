# Pause

Save your position before ending a session. Simple, fast, minimal questions.

## Usage

```
/pause
/pause "note about where I left off"
```

## Process

### Step 1: Load Current State

1. Read `agent-os/STATE.md` (create if missing using template below)
2. Get active spec path from STATE.md
3. If no active spec in STATE.md:
   - Look at `agent-os/specs/` for folders
   - If folders exist: use most recent by timestamp (folder name is YYYY-MM-DD-HHMM-slug)
   - Update STATE.md with this active spec
   - If no folders: inform user "No specs found. Run /shape-spec first."

### Step 2: Derive Progress

Read `agent-os/specs/{spec}/plan.md` and count tasks:
- Tasks use checkbox format: `- [ ] Task name` (incomplete) or `- [x] Task name` (done)
- Count total checkboxes
- Count checked boxes
- Current task = first unchecked
- If no checkboxes found, count `## Task` headings and assume 0 done

No questions. Auto-derive from plan.md.

### Step 3: Get Optional Note

If user provided a note as argument, use it.

Otherwise, use AskUserQuestion:

```
Brief note for next session? (optional, press enter to skip)
```

Keep it short. One line max.

### Step 4: Update STATE.md

Update `agent-os/STATE.md`:
- Status: `paused`
- Last activity: current timestamp
- Current task: first incomplete task
- Next step: inferred from progress
- Note: user's note (if provided)

### Step 5: Confirm

Output:

```
Saved to STATE.md

Active: {spec path}
Progress: {done}/{total} tasks
Next: {suggested action}

See you next session.
```

Done. No commit, no ceremony.

## STATE.md Template

If `agent-os/STATE.md` doesn't exist, create it:

```markdown
# Agent OS State

## Active Spec
Path: None
Status: idle

## Progress
Tasks: 0/0 done
Current: None

## Session
Last activity: None
Note: None

## Next Step
Run /shape-spec to create a spec

## Decisions (latest 5)
- None

## Blockers
- None
```

## Tips

- Run /pause before context gets too full
- Keep notes brief - just enough to jog memory
- STATE.md is the only file updated
