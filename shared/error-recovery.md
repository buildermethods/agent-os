# Error Recovery Reference

Unified error recovery procedures for all Agent OS commands. Reference this document when errors occur during command execution.

---

## Quick Reference Table

| Error Type | First Action | Escalation |
|------------|--------------|------------|
| State corruption | Load from `recovery/` | Reinitialize state |
| Git checkout fails | Stash changes | Manual resolution |
| Tests fail | Analyze output, fix implementation | Skip with documentation |
| Build errors (own files) | Fix immediately | - |
| Build errors (other files) | DOCUMENT_AND_COMMIT | Create new task |
| Subagent timeout | Retry once | Manual fallback |
| Cache expired | Rebuild from source | Full context reload |
| Partial execution | Check tasks.md, resume | Restart with context |
| Port conflict | Kill process | Use alternate port |

---

## Detailed Recovery Procedures

### 1. State Corruption Recovery

**Symptoms:**
- JSON parse errors in workflow.json or session-cache.json
- Unexpected null values or missing fields
- "Invalid state" errors during load

**Recovery:**
```
1. CHECK: .agent-os/state/recovery/ for backups
   COMMAND: ls -la .agent-os/state/recovery/

2. IF backup exists (sorted by date):
   - Identify most recent valid backup
   - Validate JSON: jq empty [backup-file]
   - Copy to main location: cp [backup] .agent-os/state/workflow.json

3. IF no valid backup:
   - Reinitialize state:
   {
     "state_version": "1.0.0",
     "current_workflow": null,
     "recovery_note": "Reinitialized due to corruption on [DATE]"
   }

4. DOCUMENT: Note in tasks.md what was lost (if anything)
5. RESUME: From task discovery
```

---

### 2. Git Workflow Failures

**Symptoms:**
- Branch checkout fails (uncommitted changes)
- Merge conflicts during branch switch
- Push rejected (force push needed)
- PR creation fails

**Recovery Procedures:**

#### A. Uncommitted Changes
```
1. CHECK: git status for changes
2. DECISION:
   - If changes belong to current task: git stash
   - If changes should be committed: create WIP commit
   - If changes can be discarded: git checkout -- .
3. RETRY: Branch operation
4. RESTORE: git stash pop (if stashed)
```

#### B. Merge Conflicts
```
1. IDENTIFY: Conflicting files (git status)
2. ANALYZE: Nature of conflicts
3. OPTIONS:
   - Accept theirs: git checkout --theirs [file]
   - Accept ours: git checkout --ours [file]
   - Manual merge: Edit conflict markers
4. RESOLVE: git add [resolved-files]
5. CONTINUE: git merge --continue
```

#### C. Push Rejected
```
1. FETCH: git fetch origin
2. CHECK: If behind remote: git pull --rebase
3. RESOLVE: Any rebase conflicts
4. RETRY: git push
5. NEVER: Force push without explicit user permission
```

#### D. PR Creation Fails
```
1. VERIFY: gh auth status (GitHub CLI authenticated)
2. CHECK: Repository permissions
3. ALTERNATIVE: Provide PR URL construction for manual creation
```

---

### 3. Test Failures

**Symptoms:**
- Tests fail after implementation
- Flaky tests (pass sometimes, fail others)
- Test timeouts
- Missing test dependencies

**Recovery Procedures:**

#### A. Implementation-Related Failures
```
1. ANALYZE: Test output for specific failure reason
2. CLASSIFY:
   - Logic error: Fix implementation
   - Missing feature: Verify against spec
   - Wrong assertion: Verify test correctness
3. FIX: Address root cause
4. RE-RUN: Specific failing test first
5. VERIFY: Full test suite after fix
```

#### B. Flaky Tests
```
1. IDENTIFY: Which tests are flaky (run 3x)
2. ISOLATE: Run test alone vs in suite
3. COMMON CAUSES:
   - Race conditions: Add proper waits/locks
   - Shared state: Reset state between tests
   - External dependencies: Mock or stabilize
4. FIX: Or mark as known flaky with skip annotation
```

#### C. Test Timeouts
```
1. CHECK: Is test actually hanging or just slow?
2. INCREASE: Timeout for slow tests if legitimate
3. INVESTIGATE: Infinite loops or deadlocks
4. ADD: Debug logging to identify hang point
```

#### D. Missing Dependencies
```
1. CHECK: Test setup/fixtures are present
2. VERIFY: Test database/services running
3. RUN: npm install / pip install / etc.
4. DOCUMENT: Required test environment setup
```

---

### 4. Build Failures

**Symptoms:**
- Type errors in modified files
- Type errors in unmodified files
- Missing imports
- Configuration errors

**Recovery Procedures:**

#### A. Type Errors in Modified Files
```
1. CLASSIFY: Each error
2. FIX: Immediately before proceeding
3. RE-RUN: Build to verify fix
4. CONTINUE: Only when clean
```

#### B. Type Errors in Unmodified Files
```
1. CHECK: If error existed before changes
2. DETERMINE: If current task should fix it
3. OPTIONS:
   - Fix now if quick (<5 min)
   - Document and defer if future task addresses it
   - Create new task if out of scope
4. USE: DOCUMENT_AND_COMMIT decision if deferring
```

#### C. Missing Imports
```
1. SEARCH: Codebase for correct import path
2. CHECK: imports.md in codebase references
3. VERIFY: Module actually exports the item
4. FIX: Import statement
```

#### D. Configuration Errors
```
1. IDENTIFY: Which config file is problematic
2. COMPARE: With working version (git diff)
3. VALIDATE: Against schema if available
4. TEST: Config in isolation
```

---

### 5. Subagent/Skill Invocation Failures

**Symptoms:**
- Task tool returns error
- Skill doesn't produce expected output
- Timeout waiting for subagent
- Subagent returns partial results

**Recovery Procedures:**

#### A. Task Tool Errors
```
1. RETRY: Once with same parameters
2. SIMPLIFY: Break request into smaller parts
3. FALLBACK: Execute manually if critical path
```

#### B. Skill Output Issues
```
1. VERIFY: Skill description matches use case
2. CHECK: allowed-tools are sufficient
3. INVOKE: Explicitly if auto-invoke failed
4. DOCUMENT: For skill improvement
```

#### C. Timeouts
```
1. BREAK: Large request into chunks
2. ADD: Progress indicators if possible
3. RETRY: With smaller scope
```

#### D. Partial Results
```
1. IDENTIFY: What's missing
2. SUPPLEMENT: With manual approach
3. COMBINE: Results for complete picture
```

---

### 6. Cache Expiration Recovery

**Symptoms:**
- "Cache expired" warnings
- Stale spec references
- Session restart mid-task

**Recovery:**
```
1. IF within same session:
   - Rebuild cache from source files
   - Use native Explore agent to rediscover specs
   - Continue from current step

2. IF new session:
   - Check tasks.md for completion status
   - Identify last completed task
   - Resume from next incomplete task
   - Rebuild context via Context Analysis steps
```

---

### 7. Partial Task Failure (Resume Protocol)

**Situation:** Task execution interrupted mid-way (crash, timeout, user stop)

**Resume Procedure:**
```
1. CHECK: tasks.md for last completed checkpoint
   - Look for [x] completed tasks
   - Identify first [ ] incomplete task

2. CHECK: git status for uncommitted changes
   - If clean: Resume from incomplete task
   - If changes: Evaluate if changes are complete for any task

3. CHECK: Test status
   COMMAND: npm test (or equivalent)
   - If passing: Implementation may be complete
   - If failing: Determine scope of failure

4. RECONSTRUCT: Context
   - Re-run Spec Discovery and Context Analysis
   - Skip completed tasks
   - Resume from first incomplete

5. DOCUMENT: Resume point in session notes
```

---

### 8. Development Server Conflicts

**Symptoms:**
- "Port already in use" errors
- Multiple server instances
- Zombie processes

**Recovery:**
```
1. IDENTIFY: Process using port
   COMMAND: lsof -i :[PORT]

2. VERIFY: Is it our dev server or something else?

3. IF our server:
   - Kill gracefully: kill [PID]
   - Or force: kill -9 [PID]

4. IF unknown process:
   - ASK: User before killing
   - ALTERNATIVE: Use different port

5. VERIFY: Port is free before starting new server
```

---

### 9. File Creation/Write Failures

**Symptoms:**
- Permission denied errors
- Disk space issues
- Path not found errors

**Recovery:**
```
1. CHECK: Parent directory exists
   COMMAND: ls -la [parent-path]

2. IF permission issue:
   - Check file/directory permissions
   - Verify write access to target location

3. IF disk space:
   - Check available space: df -h
   - Clean up temporary files if needed

4. IF path not found:
   - Create parent directories: mkdir -p [path]
   - Verify path spelling
```

---

### 10. Context Gathering Failures

**Symptoms:**
- Required files not found
- Explore agent returns empty results
- Missing product documentation

**Recovery:**
```
1. VERIFY: Expected files exist at documented paths

2. IF file missing:
   - Check if command prerequisites were run
   - Suggest running prerequisite command first

3. IF empty results:
   - Broaden search parameters
   - Check file patterns/globs

4. ALLOW: Proceeding with reduced context
   - Document context limitations
   - Prompt for missing critical information
```

---

## Command-Specific Error Notes

Commands should add only their unique error scenarios below this reference:

### execute-tasks
- Cache auto-extension failure: Reset extension_count, rebuild cache

### debug
- Context detection ambiguity: Fall back to "general" scope, ask user

### create-spec
- Naming conflicts: Append disambiguation suffix (-v2, -alt)

### create-tasks
- Spec not found: Verify spec path, run create-spec first

### plan-product / analyze-product
- No existing codebase: Expected for new projects, proceed with defaults

### index-codebase
- Large codebase timeout: Process in batches by directory
