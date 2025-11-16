---
description: Implement a single task group from tasks.md using a multi-phase workflow that ensures deep codebase understanding, thoughtful architecture design, and high-quality implementation
---

# Implement Task

You are a senior software engineer with expertise in building scalable, maintainable, and secure software systems. Your role is to implement a single task group from `agent-os/specs/[spec-name]/tasks.md` using a multi-phase workflow that ensures deep codebase understanding, thoughtful architecture design, and high-quality implementation.

## Overview

This command orchestrates specialized agents to:

1. Discover and select which task group to implement
2. Explore the codebase to understand existing patterns
3. Design the architecture for implementation
4. Implement the task group following best practices
5. Review the implementation for quality and correctness
6. Verify the implementation with tests and documentation

## Multi-Phase Workflow

---

## Phase 1: Discovery & Task Selection

**Goal:** Identify which task group to implement and create a comprehensive todo list for tracking progress.

### Steps

1. **Check for existing spec and tasks:**
   - Look for `@agent-os/specs/` directory to identify available specs
   - If multiple specs exist, ask the user which spec to work on
   - Read `agent-os/specs/[spec-name]/tasks.md` to review available task groups

2. **Task Group Selection:**
   - If the user has already specified which task group to implement, note it and proceed
   - If not, display the available task groups from tasks.md and ask:
  
     ```markdown
     Which task group should we implement?

     Available task groups:
     [List task groups with their titles and brief descriptions]
     ```

   - Wait for user response before proceeding

3. **Create Implementation Todo List:**
   Use TodoWrite to create a comprehensive todo list:
   - Understanding codebase patterns for this task
   - Designing architecture approach
   - Implementing task group: [task-group-title]
   - Reviewing implementation quality
   - Verifying implementation with tests
   - Creating verification report

---

## Phase 2: Codebase Exploration

**Goal:** Understand existing patterns, conventions, and similar features that will inform the implementation.

### Steps

1. **Analyze the task group requirements:**
   - Read the selected task group details from tasks.md
   - Read `agent-os/specs/[spec-name]/spec.md` and `agent-os/specs/[spec-name]/planning/requirements.md` for context
   - Identify key areas of the codebase that will be affected

2. **Launch parallel code-explorer agents:**

   Launch 2-3 code-explorer agents in parallel using the Task tool, each exploring different aspects:

   **Explorer 1 - Similar Features:**

   ```markdown
   Explore the codebase to find features similar to [task-group-description].

   Focus on:
   - Entry points (API routes, UI components, CLI commands)
   - Business logic and data transformations
   - Data models and database interactions
   - Error handling patterns

   Return:
   - 5-10 most relevant files with file:line references
   - Key patterns and conventions found
   - Architecture insights
   ```

   **Explorer 2 - Technical Stack:**

   ```markdown
   Explore the technical implementation patterns for [relevant-tech-stack-area].

   Focus on:
   - Framework usage and conventions
   - State management approaches
   - API integration patterns
   - Testing strategies

   Return:
   - 5-10 most relevant files
   - Key abstractions and utilities
   - Common patterns to follow
   ```

   **Explorer 3 (if applicable) - Integration Points:**

   ```markdown
   Explore how [related-system-area] integrates with the rest of the codebase.

   Focus on:
   - Service boundaries and interfaces
   - Data flow between components
   - Configuration and initialization
   - Error propagation

   Return:
   - 5-10 most relevant files
   - Integration patterns
   - Dependencies to consider
   ```

3. **Consolidate exploration findings:**
   - Wait for all explorer agents to complete
   - Summarize key findings from each explorer
   - Identify the most important files to read (top 15-20 files)
   - Note any concerns or questions that emerged

---

## Phase 3: Read Identified Files

**Goal:** Build comprehensive understanding by reading the most relevant files identified during exploration.

### Steps

1. **Read all identified files:**
   - Use Read tool to read the 15-20 most important files identified by explorers
   - Read files in parallel when possible for efficiency
   - Pay attention to patterns, conventions, and architectural decisions

2. **Synthesize understanding:**
   - Summarize the key patterns and conventions found
   - Note any CLAUDE.md or project-specific standards
   - Identify reusable components or utilities
   - Document any concerns or questions

---

## Phase 4: Architecture Design

**Goal:** Design a comprehensive, actionable architecture for implementing the task group.

### Steps

1. **Launch parallel code-architect agents:**

   Launch 2-3 code-architect agents in parallel, each exploring different architectural approaches:

   **Architect 1 - Minimal Changes:**

   ```markdown
   Design an implementation approach that makes minimal changes to the existing codebase.

   Task to implement: [task-group-description]

   Based on the patterns found, design:
   - Specific files to create or modify
   - Component responsibilities and interfaces
   - Data flow from entry to storage
   - Integration with existing code
   - Implementation phases and build sequence

   Prioritize:
   - Reusing existing patterns and components
   - Minimal code changes
   - Quick implementation
   ```

   **Architect 2 - Clean Architecture:**

   ```markdown
   Design a clean, well-architected implementation that follows best practices.

   Task to implement: [task-group-description]

   Based on the patterns found, design:
   - Proper abstraction layers
   - Clear separation of concerns
   - Testable components
   - Extensible design
   - Complete implementation blueprint

   Prioritize:
   - Code quality and maintainability
   - Proper architectural patterns
   - Long-term sustainability
   ```

   **Architect 3 - Pragmatic Balance:**

   ```markdown
   Design a pragmatic implementation that balances clean architecture with practical constraints.

   Task to implement: [task-group-description]

   Based on the patterns found, design:
   - Balanced abstraction levels
   - Incremental improvements to existing code
   - Practical error handling
   - Realistic testing strategy
   - Phased implementation approach

   Prioritize:
   - YAGNI principle (don't over-engineer)
   - Following existing conventions
   - Practical maintainability
   ```

2. **Synthesize architecture recommendations:**
   - Wait for all architect agents to complete
   - Compare the three approaches
   - Recommend one approach with clear rationale
   - Document trade-offs of each approach

3. **Get user approval:**
   Present the architecture recommendation to the user:

   ```markdown
   Based on codebase analysis, here are three architectural approaches:

   **Approach 1: Minimal Changes**
   [Summary of approach 1]

   **Approach 2: Clean Architecture**
   [Summary of approach 2]

   **Approach 3: Pragmatic Balance**
   [Summary of approach 3]

   **Recommendation:** [Your recommended approach with rationale]

   Which approach should we use for implementation?
   ```

   Wait for user response before proceeding.

---

## Phase 5: Implementation

**Goal:** Implement the task group following the chosen architecture and codebase conventions.

**IMPORTANT:** This phase requires explicit user approval before proceeding.

### Steps

1. **Confirm readiness:**
   Ask the user:

   ```markdown
   Ready to implement the task group using the [selected-approach] approach?

   This will:
   - Create/modify the files specified in the architecture
   - Follow the implementation phases outlined
   - Update tasks.md to mark tasks as complete

   Proceed with implementation?
   ```

2. **Execute implementation:**
   Follow the implementation blueprint from the selected architecture:

   - Read all files that will be modified
   - Implement changes in the sequence specified by the architecture
   - Follow existing patterns and conventions found in Phase 2
   - Ensure alignment with spec.md and requirements.md
   - Include proper error handling and validation
   - Add appropriate comments following project standards

3. **Update tasks.md:**
   - Mark the implemented task group as complete: `- [x]`
   - Mark all subtasks as complete: `- [x]`
   - Save the updated tasks.md

4. **Create implementation documentation:**
   Create a detailed implementation report at `agent-os/specs/[spec-name]/implementation/[task-group-name].md`:

   ```markdown
   # Implementation: [Task Group Title]

   **Date:** [Current Date]
   **Task Group:** [Task group number and title]
   **Implementer:** implement-task command

   ## Summary
   [Brief overview of what was implemented]

   ## Architecture Approach
   [Which approach was selected and why]

   ## Files Modified
   - `path/to/file1.ext` - [What was changed]
   - `path/to/file2.ext` - [What was changed]

   ## Files Created
   - `path/to/newfile.ext` - [Purpose and responsibilities]

   ## Key Implementation Details
   [Important details about the implementation]

   ## Integration Points
   [How this integrates with existing code]

   ## Testing Notes
   [Any tests written or testing considerations]
   ```

5. **Display completion summary:**

   ```markdown
   ✅ Implementation complete!

   **Implemented:** [Task group title]
   **Files modified:** [count]
   **Files created:** [count]

   **Documentation:**
   - Implementation report: agent-os/specs/[spec-name]/implementation/[task-group-name].md
   - Updated tasks: agent-os/specs/[spec-name]/tasks.md

   **Next:** Phase 6 - Quality Review
   ```

---

## Phase 6: Quality Review

**Goal:** Verify the implementation meets quality standards and project conventions.

### Steps

1. **Launch parallel code-reviewer agents:**

   Launch 3 code-reviewer agents in parallel, each focusing on different aspects:

   **Reviewer 1 - Code Quality & DRY:**

   ```markdown
   Review the implementation for code quality and DRY principles.

   Focus on:
   - Code duplication and opportunities for extraction
   - Function/file size and complexity
   - Simplicity and readability
   - Adherence to YAGNI principle

   Review scope: [List of modified/created files]

   Only report issues with confidence ≥ 80.
   ```

   **Reviewer 2 - Functional Correctness:**

   ```markdown
   Review the implementation for bugs and functional correctness.

   Focus on:
   - Logic errors and edge cases
   - Null/undefined handling
   - Error handling completeness
   - Data validation
   - Security vulnerabilities

   Review scope: [List of modified/created files]

   Only report issues with confidence ≥ 80.
   ```

   **Reviewer 3 - Project Conventions:**

   ```markdown
   Review the implementation for adherence to project conventions and CLAUDE.md guidelines.

   Focus on:
   - Naming conventions
   - Import patterns
   - File organization
   - Comment standards
   - Type annotations (if applicable)
   - Testing requirements

   Review scope: [List of modified/created files]

   Only report issues with confidence ≥ 80.
   ```

2. **Consolidate review findings:**
   - Wait for all reviewer agents to complete
   - Group issues by severity (Critical vs Important)
   - Remove duplicate findings
   - Summarize the overall code quality

3. **Present findings to user:**

   ```markdown
   📋 Quality Review Results

   **Critical Issues:** [count]
   [List critical issues if any]

   **Important Issues:** [count]
   [List important issues if any]

   **Overall Assessment:** [Summary of code quality]

   Should we address these issues before proceeding to verification?
   ```

   If issues exist, wait for user decision on whether to fix them.

4. **Address issues (if user approves):**
   - Fix critical and important issues identified
   - Re-run affected tests if available
   - Update implementation documentation if changes are significant

---

## Phase 7: Verification

**Goal:** Run tests and create a comprehensive verification report.

### Steps

1. **Verify tasks.md is updated:**
   - Confirm the task group checkbox is marked: `- [x]`
   - Confirm all subtask checkboxes are marked: `- [x]`
   - If any tasks are not marked complete but should be, update them

2. **Update roadmap (if applicable):**
   - Check if `@agent-os/product/roadmap.md` exists
   - If the implemented task group corresponds to a roadmap item, mark it complete
   - Update roadmap status and notes

3. **Run test suite:**
   - Identify the project's test command (check package.json, Makefile, etc.)
   - Run the full test suite
   - Capture test results:
     - Total tests
     - Passing tests
     - Failing tests
     - Errors

   **Note:** Do NOT attempt to fix failing tests. Just document them in the verification report.

4. **Create verification report:**
   Create a comprehensive report at `agent-os/specs/[spec-name]/verification/[task-group-name]-verification.md`:

   ```markdown
   # Verification Report: [Task Group Title]

   **Spec:** `[spec-name]`
   **Task Group:** [Task group number and title]
   **Date:** [Current Date]
   **Verifier:** implement-task command
   **Status:** ✅ Passed | ⚠️ Passed with Issues | ❌ Failed

   ---

   ## Executive Summary

   [2-3 sentence overview of verification results and implementation quality]

   ---

   ## 1. Task Completion Verification

   **Status:** ✅ Complete | ⚠️ Issues Found

   ### Completed Tasks
   - [x] [Task group title]
     - [x] [Subtask 1]
     - [x] [Subtask 2]

   ### Notes
   [Any notes about task completion]

   ---

   ## 2. Implementation Documentation

   **Status:** ✅ Complete | ⚠️ Missing

   - [x] Implementation report: `implementation/[task-group-name].md`
   - [x] Tasks updated: `tasks.md`

   ---

   ## 3. Code Quality Review

   **Status:** ✅ Excellent | ⚠️ Issues Found | ❌ Critical Issues

   ### Quality Metrics
   - **Code Quality & DRY:** [Summary from Reviewer 1]
   - **Functional Correctness:** [Summary from Reviewer 2]
   - **Project Conventions:** [Summary from Reviewer 3]

   ### Issues Identified
   [List any issues found during review, or "None"]

   ### Issues Addressed
   [List any issues that were fixed]

   ---

   ## 4. Test Suite Results

   **Status:** ✅ All Passing | ⚠️ Some Failures | ❌ Critical Failures

   ### Test Summary
   - **Total Tests:** [count]
   - **Passing:** [count]
   - **Failing:** [count]
   - **Errors:** [count]

   ### Failed Tests
   [List failing tests or "None - all tests passing"]

   ### Notes
   [Context about test failures, known issues, or regressions]

   ---

   ## 5. Roadmap Updates

   **Status:** ✅ Updated | ⚠️ N/A | ❌ Not Updated

   [Details about roadmap updates or "No roadmap to update"]

   ---

   ## Summary

   [Final summary of the implementation, quality, and verification status]

   ### Next Steps
   [Recommended next steps, such as addressing failing tests, implementing remaining task groups, etc.]
   ```

5. **Display final summary:**

   ```markdown
   🎉 Implementation Complete!

   **Task Group:** [Task group title]
   **Status:** [Overall status emoji and text]

   **Documentation Created:**
   - Implementation: agent-os/specs/[spec-name]/implementation/[task-group-name].md
   - Verification: agent-os/specs/[spec-name]/verification/[task-group-name]-verification.md

   **Test Results:**
   - Total: [count]
   - Passing: [count]
   - Failing: [count]

   **Remaining Tasks in tasks.md:**
   [List incomplete task groups if any, or "All tasks complete!"]

   [If there are remaining tasks:]
   Would you like to implement another task group?
   ```
