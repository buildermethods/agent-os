# Spec Implementation Process

Now that we have a spec and tasks list ready for implementation, we will proceed with implementation of this spec by following this multi-phase process:

PHASE 1: Determine which task group(s) from tasks.md should be implemented
PHASE 2: Delegate implementation to implementer subagents (one per task group)
PHASE 3: After ALL task groups have been implemented, delegate to implementation-verifier to produce the final verification report.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Determine which task group(s) to implement

First, check if the user has already provided instructions about which task group(s) to implement.

**If the user HAS provided instructions:** Proceed to PHASE 2 to delegate implementation of those specified task group(s) to **implementer** subagents (one per task group).

**If the user has NOT provided instructions:**

Read `agent-os/specs/[this-spec]/tasks.md` to review the available task groups, then output the following message to the user and WAIT for their response:

```
Should we proceed with implementation of all task groups in tasks.md?

If not, then please specify which task(s) to implement.
```

### PHASE 2: Delegate implementation to implementer subagents

**CRITICAL: Spawn a SEPARATE implementer subagent for EACH task group.** Each subagent gets its own context window, enabling focused and effective implementation.

**Execution strategy based on task group dependencies:**

1. **Analyze dependencies** - Check for "Dependencies:" annotations in tasks.md for each task group
2. **Independent task groups** (no dependencies, or all dependencies already completed): Launch their implementer subagents **IN PARALLEL** by issuing multiple Task tool calls in a single message
3. **Dependent task groups**: Wait for the required dependency to complete before launching

**For EACH task group, spawn a dedicated implementer subagent providing:**

- **ONE specific task group** from `agent-os/specs/[this-spec]/tasks.md` (including the parent task, all sub-tasks, and any sub-bullet points)
- The path to this spec's documentation: `agent-os/specs/[this-spec]/spec.md`
- The path to this spec's requirements: `agent-os/specs/[this-spec]/planning/requirements.md`
- The path to this spec's visuals (if any): `agent-os/specs/[this-spec]/planning/visuals`

Instruct each subagent to:
1. Analyze the provided spec.md, requirements.md, and visuals (if any)
2. Analyze patterns in the codebase according to its built-in workflow
3. Implement the assigned task group according to requirements and standards
4. Update `agent-os/specs/[this-spec]/tasks.md` to mark completed tasks with `- [x]`

**Example: Parallel execution**
If Task Group 1 and Task Group 2 have no dependencies on each other, launch both implementer subagents in a single message:
- Task tool call #1: implementer for Task Group 1
- Task tool call #2: implementer for Task Group 2

**Example: Sequential execution**
If Task Group 3 depends on Task Group 1:
1. Wait for Task Group 1 implementer to complete
2. Then launch Task Group 3 implementer

### PHASE 3: Produce the final verification report

IF ALL task groups in tasks.md are marked complete with `- [x]`, then proceed with this step.  Otherwise, return to PHASE 1.

Assuming all tasks are marked complete, then delegate to the **implementation-verifier** subagent to do its implementation verification and produce its final verification report.

Provide to the subagent the following:
- The path to this spec: `agent-os/specs/[this-spec]`
Instruct the subagent to do the following:
  1. Run all of its final verifications according to its built-in workflow
  2. Produce the final verification report in `agent-os/specs/[this-spec]/verifications/final-verification.md`.
