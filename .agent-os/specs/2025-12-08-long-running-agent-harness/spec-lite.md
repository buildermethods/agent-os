# Long-Running Agent Harness Improvements - Summary

## One-Line Summary
Implement persistent progress logging and session protocols based on Anthropic's long-running agent research.

## Problem
Agent OS loses context between sessions because cache expires after 1 hour max. New sessions must rediscover progress from scratch.

## Solution
1. **Persistent Progress Log** - Chronological accomplishment log that never expires
2. **Session Startup Protocol** - 6-step environment verification at session start
3. **Scope Constraints** - Encourage single-task focus per session
4. **JSON Task Format** - Machine-readable task tracking alongside markdown

## Key Deliverables
- `.agent-os/progress/progress.md` - Permanent progress log
- `.agent-os/progress/progress.json` - Machine-readable progress
- `session-startup.md` skill - Auto-invoked startup protocol
- `tasks.json` - JSON task tracking format
- Updated `/execute-tasks` with scope constraints

## Success Criteria
- Progress persists across unlimited sessions (currently: max 1 hour)
- Every session starts with explicit 6-step verification
- Multi-task attempts trigger scope warning
- Tasks queryable via JSON format

## Reference
Based on: [Anthropic - Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
