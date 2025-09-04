# Agent-OS Native Claude Code Transition Plan v5.4
## Embedded Instructions with Robust State Management

---

**Version:** 5.4.0  
**Date:** September 4, 2025  
**Starting Point:** Combined features branch (05308e2)  
**Target:** Native Claude Code framework with embedded instructions and fault-tolerant state  
**Duration:** 3-5 days  
**Risk Level:** Low-Medium (mitigated through atomic operations and recovery)  
**Philosophy:** Reliability through embedded context and robust state management  

---

## 🎯 Executive Summary

Agent-OS is a **development framework** that gets installed INTO other projects. This transition plan updates Agent-OS to work reliably with Claude Code by **embedding instructions directly in commands** to ensure Claude always has full context.

### Critical Understanding
- ✅ **Agent-OS is installed into target projects** via setup script
- ✅ **Claude doesn't reliably follow external references** (key problem)
- ✅ **Solution: Embed instructions in commands** (guaranteed context)
- ✅ **Commands go to .claude/commands/** in target projects
- ✅ **Installation script copies complete commands** with embedded instructions

### Key Decisions
- ✅ **EMBED instructions in commands** (solves reference problem)
- ✅ **Remove @.agent-os references** (no longer needed)
- ✅ **Convert agents to subagents** (proper Claude Code format)
- ✅ **Simple state management** (JSON file)
- ✅ **Update installation script** (simpler - just copy)

---

## 📊 Installation Architecture

### How Agent-OS Works (Updated)

```
┌─────────────────────────────────────┐
│       Agent-OS Repository           │
│         (This Project)              │
│                                     │
│  commands/                          │
│    ├── execute-tasks.md             │
│    │   (with embedded instructions) │
│    └── ...                          │
│                                     │
│  claude-code/agents/                │
│    └── (subagents)                  │
│                                     │
│  setup/project.sh                   │
└────────────┬────────────────────────┘
             │
             │ Installation via
             │ setup/project.sh
             ↓
┌─────────────────────────────────────┐
│        Target Project               │
│                                     │
│  .agent-os/                         │
│    ├── standards/                   │
│    └── state/           (NEW)      │
│                                     │
│  .claude/                           │
│    ├── commands/                    │
│    │   (complete with instructions) │
│    └── agents/          (subagents) │
│                                     │
│  [project files...]                 │
└─────────────────────────────────────┘
```

### Why Embed Instructions?
**Problem:** Claude Code doesn't reliably follow "Refer to instructions in..." references  
**Solution:** Embed all instructions directly in command files  
**Result:** Claude always has complete context in one file  

---

## ⚠️ Critical Command Dependencies

### Dependency Analysis Results
After thorough analysis, we've identified critical dependencies between commands that must be preserved:

#### **Tightly Coupled Commands**
1. **execute-tasks ↔ execute-task**: These share runtime caches (spec_cache, context_cache)
2. **execute-tasks → complete-tasks**: Direct workflow continuation within same session
3. **analyze-product → plan-product**: Context passing for existing codebases

#### **State Dependencies**
Commands expect these directories from previous commands:
- `.agent-os/specs/` (created by create-spec)
- `.agent-os/tasks/` (created by create-tasks)
- `.agent-os/product/` (created by plan-product)
- `.agent-os/codebase/` (created by index-codebase)
- `.agent-os/state/` (NEW - for session management)

#### **Resolution Strategy**
- **DO NOT separate** execute-tasks, execute-task, and complete-tasks (keep as single 730+ line file)
- **Implement filesystem-based state** for cross-command data sharing
- **Preserve directory creation order** in workflow documentation

---

## 🚀 Implementation Plan

### Phase 0: Setup & Understanding ✅

**Status:** COMPLETE

- [x] Created new branch from combined features (05308e2)
- [x] Understood Agent-OS is an installable framework
- [x] Identified that Claude doesn't follow external references reliably
- [x] Restored missing debug command
- [x] Decided to embed instructions for reliability

### Phase 0.5: State Management Setup (NEW - Critical)

Before embedding, implement robust filesystem-based state management with corruption protection:

#### 0.5.1 Create State Management Structure
```bash
# In .agent-os/state/ directory:
workflow.json         # Current workflow state with versioning
session-cache.json    # Spec and context caches with auto-extension
command-state.json    # Cross-command data sharing
recovery/            # Automatic state backups (NEW)
.lock               # File locking for concurrent access (NEW)
```

#### 0.5.2 Enhanced Cache Persistence with Auto-Extension
```json
// .agent-os/state/session-cache.json
{
  "spec_cache": {
    "auth": {
      "path": ".agent-os/specs/auth/auth-spec.md",
      "title": "Authentication System",
      "tasks": ["1.1", "1.2", "1.3"],
      "loaded_at": "2025-09-04T10:00:00Z"
    }
  },
  "context_cache": { /* cached context data */ },
  "metadata": {
    "timestamp": "2025-09-04T10:00:00Z",
    "expires": "2025-09-04T10:05:00Z",
    "workflow_id": "auth-impl-2025-09-04-001",
    "last_accessed": "2025-09-04T10:02:00Z",
    "access_count": 3,
    "auto_extend": true,
    "extension_count": 0,
    "max_extensions": 12,
    "state_version": "1.0.0"
  }
}
```

#### 0.5.3 Atomic State Operations
```javascript
// Embedded in commands for safe state management
function saveState(filepath, data) {
  // Validate data structure
  if (!validateStateSchema(data)) {
    throw new Error('Invalid state data structure');
  }
  
  // Create recovery backup
  const backupPath = createRecoveryBackup(filepath);
  
  // Atomic write using temp file
  const tempFile = `${filepath}.tmp`;
  writeFileSync(tempFile, JSON.stringify(data, null, 2));
  renameSync(tempFile, filepath); // Atomic on most filesystems
  
  // Clean old recovery files (keep last 5)
  cleanOldRecoveryFiles();
  return true;
}

function loadState(filepath, defaultState = {}) {
  try {
    const data = JSON.parse(readFileSync(filepath));
    validateStateSchema(data);
    return data;
  } catch (e) {
    // Attempt recovery from backups
    const recovered = attemptRecoveryFromBackup(filepath);
    if (recovered) return recovered;
    
    console.warn(`State corrupted: ${filepath}, using defaults`);
    return defaultState;
  }
}
```

#### 0.5.4 Cache Auto-Extension Logic
```javascript
// Prevent cache expiration during active workflows
function checkAndExtendCache(cacheData) {
  const now = new Date();
  const expires = new Date(cacheData.metadata.expires);
  
  // Auto-extend if recently accessed and not exceeded max extensions
  if (expires - now < 60000 && // Less than 1 minute remaining
      cacheData.metadata.extension_count < cacheData.metadata.max_extensions) {
    
    // Extend by 5 minutes
    cacheData.metadata.expires = new Date(now.getTime() + 5 * 60000).toISOString();
    cacheData.metadata.extension_count++;
    return true;
  }
  
  return expires > now; // Return validity status
}
```

#### 0.5.5 File Locking Mechanism
```bash
# Simple lock implementation for concurrent access protection
acquire_lock() {
  local lockfile=".agent-os/state/.lock"
  local timeout=30
  
  # Wait for lock with timeout
  while [ -f "$lockfile" ] && [ $elapsed -lt $timeout ]; do
    sleep 1
  done
  
  echo "$$:$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$lockfile"
}

release_lock() {
  rm -f ".agent-os/state/.lock"
}
```

**Checklist:**
- [ ] Design state file schemas with versioning
- [ ] Implement atomic read/write operations
- [ ] Add corruption recovery with backup system
- [ ] Implement cache auto-extension logic
- [ ] Add file locking for concurrent access
- [ ] Create state validation schemas
- [ ] Test cross-command state sharing
- [ ] Test recovery from corrupted states

### Phase 1: Embed Instructions in Commands (Day 1)

Merge each command with its corresponding instruction(s):

#### 1.1 Command Embedding Map (UPDATED)

| Command | Instructions to Embed | Result Size | Notes |
|---------|----------------------|-------------|-------|
| execute-tasks.md | execute-tasks.md (234) + execute-task.md (489) + complete-tasks.md (316) | ~1050 lines | Keep coupled workflow together |
| create-spec.md | create-spec.md (430) | ~440 lines | Standalone |
| create-tasks.md | create-tasks.md (129) | ~140 lines | Standalone |
| plan-product.md | plan-product.md (347) | ~355 lines | Standalone |
| analyze-product.md | analyze-product.md (226) | ~235 lines | References plan-product |
| index-codebase.md | index-codebase.md (290) | ~300 lines | Standalone |
| debug.md | debug.md (427) | ~435 lines | Standalone |

#### 1.2 Enhanced Embedding Format (UPDATED)

```markdown
# [Command Name]

## Quick Navigation
- [Description](#description)
- [Parameters](#parameters)
- [Dependencies](#dependencies)
- [Task Tracking](#task-tracking)
- [Core Instructions](#core-instructions)
- [State Management](#state-management)
- [Error Handling](#error-handling)

## Description
[Brief description of what this command does]

## Parameters
- `param1` (required): Description
- `param2` (optional): Description with default

## Dependencies
**Required State Files:**
- `.agent-os/state/workflow.json` (read/write)
- `.agent-os/state/session-cache.json` (for execute-tasks only)

**Expected Directories:**
- List directories this command expects to exist
- List directories this command will create

## Task Tracking
**IMPORTANT: Use Claude's TodoWrite tool throughout execution:**
```javascript
// Example todos for this command
const todos = [
  { content: "Load state and validate cache", status: "pending", activeForm: "Loading state and validating cache" },
  { content: "Execute main workflow", status: "pending", activeForm: "Executing main workflow" },
  { content: "Save state and cleanup", status: "pending", activeForm: "Saving state and cleanup" }
];
// Update status to "in_progress" when starting each task
// Mark as "completed" immediately after finishing
```

## For Claude Code
When executing this command:
1. **Initialize TodoWrite** with command steps for visibility
2. Check and load any required state from `.agent-os/state/`
3. Use atomic operations for all state reads/writes
4. Follow the embedded instructions below completely
5. Use Task tool to invoke subagents as specified
6. Save state updates back to `.agent-os/state/`
7. Handle cache persistence with auto-extension for execute-tasks
8. **Update TodoWrite** status throughout execution

---

## SECTION: Core Instructions
<!-- BEGIN EMBEDDED CONTENT -->
[Full content from instructions/core/[name].md]
[All steps, rules, and workflows]
[No external references]
<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management
<!-- Enhanced with atomic operations and recovery -->
### State Operations
- Use atomic `saveState()` function for all writes
- Use `loadState()` with defaults for all reads
- Implement cache auto-extension for active workflows
- Acquire/release locks for critical sections

For execute-tasks command specifically:
- Load/save spec_cache to `.agent-os/state/session-cache.json`
- Auto-extend cache if workflow is active
- Pass cache internally between execute-task iterations
- Create recovery backups before major state changes

---

## SECTION: Error Handling
### Error Recovery Procedures
1. **State Corruption**: Attempt recovery from `.agent-os/state/recovery/`
2. **Lock Timeout**: Force acquire after 30 seconds with warning
3. **Cache Expiration**: Reload from source if auto-extension fails
4. **Partial Failure**: Save progress to recovery point, allow resume

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke:
- `task-executor` for task execution
- `spec-creator` for specification creation
- `codebase-indexer` for code analysis
- etc.
```

#### 1.3 Handle Meta Instructions

Meta instructions (pre-flight, post-flight) should also be embedded where needed:
- Embed relevant sections directly in commands
- Remove external references to meta instructions

**Checklist:**
- [ ] Embed execute-tasks + execute-task + complete-tasks as single file
- [ ] Add state management logic to execute-tasks for cache persistence
- [ ] Embed create-spec instructions
- [ ] Embed create-tasks instructions
- [ ] Embed plan-product instructions
- [ ] Embed analyze-product instructions
- [ ] Embed index-codebase instructions
- [ ] Embed debug instructions
- [ ] Handle meta instruction content
- [ ] Remove all @.agent-os references
- [ ] Add dependency documentation to each command

### Phase 2: Convert Agents to Subagents (Day 2)

Convert existing agents to Claude Code subagent format:

#### 2.1 Update Agent Format
```yaml
---
name: codebase-indexer
description: Indexes and analyzes project codebases
tools: Read, Glob, Grep, Write
---

# Codebase Indexer

[Original agent content adapted for subagent use]
```

#### 2.2 Agent Conversion Checklist

- [ ] codebase-indexer.md → Claude Code subagent format
- [ ] context-fetcher.md → Claude Code subagent format
- [ ] date-checker.md → Claude Code subagent format
- [ ] file-creator.md → Claude Code subagent format
- [ ] git-workflow.md → Claude Code subagent format
- [ ] project-manager.md → Claude Code subagent format
- [ ] spec-cache-manager.md → Claude Code subagent format
- [ ] test-runner.md → Claude Code subagent format

### Phase 3: Update Installation Script (Day 3)

Simplify `setup/project.sh` since commands now contain everything:

#### 3.1 Simplified Installation
```bash
# Copy complete commands (with embedded instructions)
cp commands/*.md .claude/commands/

# Copy subagents
cp claude-code/agents/*.md .claude/agents/

# Create state directory with recovery subdirectory
mkdir -p .agent-os/state/recovery
echo '{"state_version": "1.0.0", "current_workflow": null}' > .agent-os/state/workflow.json

# Copy standards
cp -r standards/ .agent-os/standards/

# Optional: Install minimal hooks for state validation
if [ "$1" == "--with-hooks" ]; then
    mkdir -p .claude/hooks
    
    # Pre-write hook for JSON validation
    cat > .claude/hooks/pre-write.sh << 'EOF'
#!/bin/bash
# Validates JSON state files before writing
if [[ "$1" == *".agent-os/state/"*.json ]]; then
    jq empty "$1" 2>/dev/null || {
        echo "ERROR: Invalid JSON in state file"
        exit 1
    }
fi
EOF
    
    # Post-command hook for cache cleanup
    cat > .claude/hooks/post-command.sh << 'EOF'
#!/bin/bash
# Clean expired caches after command execution
find .agent-os/state -name "session-cache.json" -mmin +60 \
    -exec rm {} \; 2>/dev/null
EOF
    
    chmod +x .claude/hooks/*.sh
fi

# Add cache and state directories to .gitignore (if not already present)
if [ -f .gitignore ]; then
    # Check if Agent-OS section already exists
    if ! grep -q "# Agent-OS cache and state files" .gitignore; then
        echo "" >> .gitignore
        echo "# Agent-OS cache and state files" >> .gitignore
        echo ".agent-os/state/session-cache.json" >> .gitignore
        echo ".agent-os/state/command-state.json" >> .gitignore
        echo ".agent-os/state/recovery/" >> .gitignore
        echo ".agent-os/state/.lock" >> .gitignore
        echo ".agent-os/cache/" >> .gitignore
        echo ".agent-os/debugging/" >> .gitignore
        echo ".agent-os/**/*.cache" >> .gitignore
        echo ".agent-os/**/*.tmp" >> .gitignore
    fi
else
    # Create new .gitignore with Agent-OS entries
    cat > .gitignore << 'EOF'
# Agent-OS cache and state files
.agent-os/state/session-cache.json
.agent-os/state/command-state.json
.agent-os/state/recovery/
.agent-os/state/.lock
.agent-os/cache/
.agent-os/debugging/
.agent-os/**/*.cache
.agent-os/**/*.tmp
EOF
fi
```

#### 3.2 Remove Instruction Installation
- No need to copy instructions separately
- Commands contain everything
- Simpler installation process

**Checklist:**
- [ ] Update setup/project.sh for embedded commands
- [ ] Remove instruction copying logic
- [ ] Add state directory creation with recovery subdirectory
- [ ] Add optional hooks installation (--with-hooks flag)
- [ ] Implement JSON validation hook
- [ ] Implement cache cleanup hook
- [ ] Add gitignore entries for cache/state/recovery files
- [ ] Handle existing .gitignore gracefully (check before appending)
- [ ] Test installation process with and without hooks
- [ ] Update installation documentation

### Phase 4: Test in Real Project (Day 4)

#### 4.1 Create Test Project
```bash
mkdir -p /tmp/test-project
cd /tmp/test-project

# Run installation
/path/to/agent-os/setup/project.sh --claude-code
```

#### 4.2 Verify Installation
```
test-project/
├── .agent-os/
│   ├── standards/
│   └── state/
│       └── workflow.json
├── .claude/
│   ├── commands/        # Complete with embedded instructions
│   └── agents/          # Subagents
├── .gitignore           # Updated with Agent-OS cache exclusions
```

#### 4.3 Test Execution
In Claude Code:
1. Open test project
2. Ask: "Execute the create-spec command for a todo app"
3. Verify Claude has all instructions without external references
4. Confirm complete workflow execution

**Checklist:**
- [ ] Commands contain full instructions
- [ ] No external reference errors
- [ ] Subagents invocable via Task tool
- [ ] State management works
- [ ] Complete workflows execute

### Phase 5: Cleanup & Documentation (Day 5)

#### 5.1 Repository Structure
After embedding, we can simplify:
```
agent-os/
├── commands/                # Commands with embedded instructions
│   ├── execute-tasks.md    # ~1050 lines (includes execute-task + complete-tasks)
│   ├── create-spec.md      # ~440 lines
│   ├── create-tasks.md     # ~140 lines
│   ├── plan-product.md     # ~355 lines
│   ├── analyze-product.md  # ~235 lines
│   ├── index-codebase.md   # ~300 lines
│   └── debug.md            # ~435 lines
│
├── claude-code/
│   └── agents/             # Subagents (to be installed)
│
├── instructions/           # Keep for reference/documentation
│   ├── core/              # Original modular instructions
│   ├── meta/              # Meta instructions (embedded where needed)
│   └── utils/             # Utilities
│
├── standards/              # Development standards
├── setup/                  # Installation scripts
│   └── project.sh         # Simplified installer
│
└── README.md              # Updated documentation
```

#### 5.2 Documentation Updates
- Explain embedded instruction approach
- Document that commands are self-contained
- Update installation guide
- Create migration guide for existing users

**Checklist:**
- [ ] Clean repository structure
- [ ] Update README
- [ ] Create migration guide
- [ ] Document embedded approach
- [ ] Prepare release notes

---

## 🔄 What Changed from v5.3

### Previous Plan (v5.3)
- Basic filesystem state management
- Simple cache expiration (5 minutes)
- No corruption recovery
- No TodoWrite integration
- No hooks consideration

### Current Plan (v5.4)
- **Robust state management with atomic operations**
- **Cache auto-extension for active workflows**
- **Automatic corruption recovery with backups**
- **TodoWrite integration throughout commands**
- **Optional minimal hooks for validation**
- **File locking for concurrent access protection**
- **Enhanced error recovery procedures**

---

## ✅ Success Criteria

### Must Have
- [x] All 7 commands contain embedded instructions
- [ ] No external instruction references
- [ ] All 8 agents converted to subagent format
- [ ] Installation creates working structure
- [ ] Claude executes complete workflows reliably

### Nice to Have  
- [ ] Automated embedding script for updates
- [ ] Size optimization for embedded commands
- [ ] Enhanced error messages
- [ ] Performance improvements

### Won't Have
- ❌ External instruction references (unreliable)
- ❌ JavaScript dependencies
- ❌ Complex state management
- ❌ Separate instruction files in target projects

---

## 📅 Timeline (UPDATED)

| Day | Phase | Outcome |
|-----|-------|---------|
| **Day 0** | Setup & Understanding | ✅ Complete |
| **Day 0.5** | State Management Setup | Filesystem-based caching |
| **Day 1** | Embed Instructions | Commands self-contained with proper coupling |
| **Day 2** | Convert Agents | Subagents ready |
| **Day 3** | Update Installation | Simplified script with state setup |
| **Day 4** | Test Everything | Verified reliability & dependencies |
| **Day 5** | Documentation | Ready for release |

---

## 🚦 Implementation Checklist

### Day 0: Complete ✅
- [x] Understood the reference problem
- [x] Decided on embedding approach
- [x] Created clean branch
- [x] Restored debug command
- [x] Analyzed command dependencies and coupling

### Day 0.5: State Management (NEW)
- [ ] Create `.agent-os/state/` directory structure
- [ ] Implement session-cache.json schema
- [ ] Add cache serialization helpers
- [ ] Test state persistence between commands

### Day 1: Embed Instructions (CRITICAL UPDATES)
- [ ] Merge execute-tasks + execute-task + complete-tasks into single file
- [ ] Add TodoWrite integration examples to each command
- [ ] Add filesystem cache persistence logic to merged execute-tasks
- [ ] Implement atomic state operations in commands
- [ ] Merge create-spec with instructions
- [ ] Merge create-tasks with instructions
- [ ] Merge plan-product with instructions
- [ ] Merge analyze-product with instructions
- [ ] Merge index-codebase with instructions
- [ ] Merge debug with instructions
- [ ] Remove @.agent-os references
- [ ] Add Claude Code guidance with TodoWrite usage
- [ ] Document dependencies in each command header
- [ ] Add error recovery procedures to each command

### Day 2: Convert Agents
- [ ] Update all 8 agents to subagent format
- [ ] Add proper YAML frontmatter
- [ ] Test subagent invocation

### Day 3: Update Installation
- [ ] Simplify setup/project.sh
- [ ] Remove instruction copying
- [ ] Add state directory creation
- [ ] Implement .gitignore update logic
- [ ] Test installation and .gitignore handling
- [ ] Verify no sensitive cache data tracked

### Day 4: Test
- [ ] Create test project
- [ ] Run installation
- [ ] Test all commands
- [ ] Verify no reference errors
- [ ] Confirm complete execution

### Day 5: Release
- [ ] Clean repository
- [ ] Update documentation
- [ ] Create migration guide
- [ ] Prepare release

---

## 🎓 Key Insights

### The Reference Problem
Claude Code doesn't reliably follow "refer to instructions in..." references. This caused incomplete execution and missed steps.

### The Embedding Solution
By embedding instructions directly in commands:
- Claude always has complete context
- No reliance on following references
- Guaranteed complete execution
- Slightly larger files but much more reliable

### Trade-offs
- **Pros:** Reliability, completeness, simplicity
- **Cons:** Larger command files, some duplication
- **Verdict:** Reliability is worth the file size increase

---

## 💡 Final Notes

This plan addresses two core reliability issues:
1. Claude Code doesn't consistently follow external references
2. Commands with runtime dependencies (like execute-tasks) need special handling

The enhanced embedded approach means:
- Command files grow from ~7 lines to 140-1050 lines
- execute-tasks becomes a single ~1050 line file (includes execute-task and complete-tasks)
- State persistence via filesystem ensures cross-command data sharing
- Installation includes state directory setup
- Users get consistent, reliable behavior with preserved optimizations

### Critical Implementation Notes
- **DO NOT separate execute-tasks, execute-task, and complete-tasks** - they share runtime state
- **DO implement filesystem caching** before embedding to test the mechanism
- **DO document dependencies** at the top of each command file
- **CONSIDER a build process** for future maintainability (generate embedded files from sources)

This is a pragmatic solution that prioritizes reliability while preserving the sophisticated caching and workflow optimizations that make AgentOS efficient.

---

**Document Status:** Enhanced with robust state management and TodoWrite integration  
**Confidence Level:** Very High (comprehensive error handling and recovery mechanisms)  
**Risk Level:** Low-Medium (significantly reduced through atomic operations and recovery)  
**Next Step:** Execute Day 0.5 - Implement robust state management, then Day 1 - Embed with TodoWrite

---

*This revision (v5.4) incorporates critical enhancements:*
- *Atomic state operations prevent corruption*
- *Cache auto-extension prevents workflow interruption*
- *TodoWrite integration ensures progress visibility*
- *Recovery mechanisms provide fault tolerance*
- *Optional hooks add validation without complexity*

*The execute-tasks workflow remains unified to preserve cache sharing while gaining robust state management.*