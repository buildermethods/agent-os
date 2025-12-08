# Long-Running Agent Harness Improvements

## Overview

Implement persistent progress logging, session startup protocol, and scope constraints based on Anthropic's "Effective Harnesses for Long-Running Agents" research to improve Agent OS's cross-session reliability and memory.

**Reference**: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

---

## Problem Statement

Agent OS currently excels at within-session workflows (TDD, testing gates, git workflow) but has critical gaps in **cross-session persistence**:

1. **Session cache expires** (max 1 hour) - progress context is lost between sessions
2. **No chronological progress log** - new sessions must rediscover context from tasks.md alone
3. **No session startup protocol** - inconsistent environment verification
4. **No scope constraints** - agents may attempt too much in a single session

These issues compound when features span multiple agent sessions, leading to:
- Repeated context discovery work
- Missed handoff information
- Potential for conflicting or redundant changes

---

## Goals

### Primary Goals
1. **Persistent Progress Memory**: Implement permanent progress logging that survives indefinitely across sessions
2. **Session Startup Protocol**: Create explicit environment verification and context loading at session start
3. **Scope Enforcement**: Add guardrails to encourage single-task focus per session

### Secondary Goals
4. **JSON Task Tracking**: Add machine-readable task format alongside markdown
5. **E2E Testing Guidance**: Strengthen browser automation recommendations

---

## User Stories

### US-1: Cross-Session Progress Continuity
**As a** developer using Agent OS across multiple sessions
**I want** the agent to automatically know what was accomplished in previous sessions
**So that** I don't waste time re-explaining context or risk duplicate work

**Acceptance Criteria**:
- [ ] Progress log persists permanently (no expiration)
- [ ] New sessions automatically read recent progress entries
- [ ] Each completed task appends to progress log with timestamp
- [ ] Debug sessions and blockers are logged

### US-2: Reliable Session Startup
**As a** developer starting a new Agent OS session
**I want** the agent to verify environment state before beginning work
**So that** I don't encounter mid-session environment issues

**Acceptance Criteria**:
- [ ] Working directory confirmed at session start
- [ ] Git status and recent commits reviewed
- [ ] Progress log read (last N entries)
- [ ] Dev server health verified
- [ ] Current task selected and confirmed

### US-3: Focused Session Scope
**As a** developer executing tasks
**I want** guidance when attempting multiple parent tasks
**So that** I maintain focused, completable work sessions

**Acceptance Criteria**:
- [ ] Warning when multiple parent tasks selected
- [ ] Recommendation to focus on single task displayed
- [ ] User can override with explicit confirmation
- [ ] Single-task mode is default behavior

### US-4: Machine-Readable Task Status
**As a** developer or tooling author
**I want** task status in JSON format
**So that** I can programmatically query and analyze task progress

**Acceptance Criteria**:
- [ ] tasks.json generated alongside tasks.md
- [ ] JSON includes: id, description, status, attempts, timestamps
- [ ] JSON stays synchronized with markdown version
- [ ] Existing markdown workflow unchanged

---

## Scope

### In Scope
- Progress log implementation (`.agent-os/progress/`)
- Session startup skill (`session-startup.md`)
- Scope constraint logic in `/execute-tasks`
- JSON task format (`tasks.json`)
- Updates to SYSTEM-OVERVIEW.md documentation

### Out of Scope
- Changes to external MCP integrations
- Browser automation tooling (Playwright/Puppeteer integration)
- Multi-agent orchestration patterns
- Performance benchmarking

---

## Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Cross-session context retention | 0% (cache expires) | 100% (permanent log) |
| Session startup verification | Implicit | Explicit 6-step protocol |
| Multi-task warning rate | 0% | 100% when applicable |
| Task data accessibility | Markdown only | Markdown + JSON |

---

## Dependencies

- Existing `/execute-tasks` command structure
- Existing state management patterns in `shared/state-patterns.md`
- Claude Code's native TodoWrite integration
- Git workflow subagent

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Progress log grows too large | Medium | Low | Implement archival for entries older than 30 days |
| JSON/Markdown sync drift | Medium | Medium | Single source of truth pattern - generate one from other |
| Startup protocol adds latency | Low | Low | Keep checks lightweight; parallel where possible |
| Users override scope constraints | High | Low | Log overrides for analysis; respect user autonomy |

---

## Appendix: Anthropic Framework Alignment

This specification directly addresses the following gaps identified in the Anthropic framework comparison:

| Anthropic Principle | Implementation in This Spec |
|---------------------|----------------------------|
| `claude-progress.txt` persistence | Task 1: Progress log |
| Session startup checklist | Task 2: Session startup skill |
| One feature per session | Task 3: Scope constraints |
| JSON feature tracking | Task 4: tasks.json |
| Initializer vs Coding agent | Partially addressed via startup protocol |
