---
description: Decision tree for choosing the appropriate debugging workflow
globs:
alwaysApply: false
version: 2.0
encoding: UTF-8
---

# Debugging Decision Tree

## Overview

Quick reference guide for choosing the appropriate debugging workflow.

## Simplified Debugging Commands

Agent OS now uses only **3 debugging commands**:

### 1. `@commands/debug.md` - Smart Debugging
- **Auto-detects context** (task, spec, or general)
- Use for any debugging where you need to fix the issue
- Handles all scopes intelligently

### 2. `@commands/investigate.md` - Analysis Only
- Use when you need to understand an issue without fixing
- Creates investigation reports for later resolution
- Good for complex issues needing deeper analysis

### 3. `@commands/fix-regression.md` - Regression Fixes
- Use when something that previously worked is now broken
- Leverages git history to find breaking changes
- Quick path to restoration

## Decision Flow

```
Need to debug something?
├─ Was it working before? (Regression)
│   └─ YES → Use @commands/fix-regression.md
│   
├─ Do you need to fix it now?
│   ├─ YES → Use @commands/debug.md (auto-detects context)
│   └─ NO → Use @commands/investigate.md
│
└─ Just use @commands/debug.md when in doubt!
```

## How Context Auto-Detection Works

The `debug.md` command automatically determines:

1. **Checks for active spec**: Is there a tasks.md with incomplete tasks?
2. **Determines scope**:
   - Single task affected → Task scope
   - Multiple tasks/integration → Spec scope  
   - No active spec → General scope
3. **Applies appropriate workflow**: Uses the right approach for the detected context

## Integration with Execution Workflows

During `execute-task.md` or `execute-tasks.md`:
- Issues encountered → `debug.md` (auto-detects context)
- Need investigation only → `investigate.md`
- Previous functionality broken → `fix-regression.md`

## Output Locations

Debug reports are automatically organized by scope:
- **Task debugging**: `.agent-os/debugging/tasks/`
- **Spec debugging**: `.agent-os/debugging/specs/`
- **General debugging**: `.agent-os/debugging/`
- **Investigations**: `.agent-os/debugging/investigations/`
- **Regressions**: `.agent-os/debugging/regressions/`

## Best Practices

1. **Trust auto-detection**: The debug command is smart enough to figure out context
2. **Use investigate for complex issues**: When you need time to think
3. **Use fix-regression for speed**: When you know it worked before
4. **Document everything**: All commands create appropriate reports