# Resume

Restore context at the start of a new session. Shows where you left off and suggests next action.

## Usage

```
/resume
```

## Process

### Step 1: Load State

Read `agent-os/STATE.md`.

If it doesn't exist:
```
No STATE.md found. Run /shape-spec to start a new spec.
```

If status is `idle` or no active spec:
```
No active work. Run /shape-spec to create a spec.
```

If status is `done`:
```
Previous spec completed: {spec path}
Run /shape-spec to start a new spec.
```

### Step 2: Load Spec Context

Read from active spec folder:
- `agent-os/specs/{spec}/shape.md` (scope)
- `agent-os/specs/{spec}/plan.md` (tasks + progress)

### Step 3: Display Status

Output:

```
Welcome back.

Active: {spec path}
Status: {planning | executing | verifying | paused}
Progress: {done}/{total} tasks
Paused: {last activity timestamp}
Note: "{user's note}" (if any)

Current task: {task name}
Scope: {summary from shape.md}

Suggested: {next action}
```

### Step 4: Offer Choice

Use AskUserQuestion:

```
What would you like to do?

1. Continue implementation
2. Show full plan
3. Run /verify-execution
4. Show scope
```

Then proceed based on choice:
- Continue: remind user of current task, let them work
- Show plan: read and display plan.md
- Verify: tell user to run /verify-execution
- Scope: read and display scope from shape.md

### Step 5: Update State

Update `agent-os/STATE.md`:
- Status: `executing` (or keep as `verifying` if that was the state)
- Last activity: current timestamp

## Tips

- /resume is for new sessions after /pause
- If you just want to check status mid-session, read STATE.md directly
- The suggested action is based on progress - trust it or override
