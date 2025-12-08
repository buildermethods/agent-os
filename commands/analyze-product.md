# Analyze Product

## Quick Navigation
- [Description](#description)
- [Parameters](#parameters)
- [Dependencies](#dependencies)
- [Task Tracking](#task-tracking)
- [Core Instructions](#core-instructions)
- [State Management](#state-management)
- [Error Handling](#error-handling)
- [Subagent Integration](#subagent-integration)

## Description
Analyze your product's codebase and install Agent OS. This command performs deep codebase analysis, discovers existing specifications, and installs Agent OS with documentation that reflects actual implementation progress.

## Parameters
- `analysis_depth` (optional): "shallow" for basic analysis or "deep" for comprehensive review
- `preserve_existing` (optional): Boolean to preserve existing Agent OS files

## Dependencies
**Required State Files:**
- None (this command analyzes existing state)

**Expected Directories:**
- Current working directory (existing codebase)
- Potential existing `.agent-os/` structure

**Creates Directories:**
- `.agent-os/product/` (product documentation)

**Creates Files:**
- `.agent-os/product/mission.md` (comprehensive product mission)
- `.agent-os/product/mission-lite.md` (condensed mission for AI context)
- `.agent-os/product/tech-stack.md` (detected technical architecture)
- `.agent-os/product/roadmap.md` (development phases with completed work)

## Task Tracking
**IMPORTANT: Use Claude's TodoWrite tool throughout execution:**
```javascript
// Example todos for this command workflow
const todos = [
  { content: "Analyze existing codebase structure", status: "pending", activeForm: "Analyzing existing codebase structure" },
  { content: "Discover existing specifications", status: "pending", activeForm: "Discovering existing specifications" },
  { content: "Get current date for timestamps", status: "pending", activeForm: "Getting current date for timestamps" },
  { content: "Gather product context from user", status: "pending", activeForm: "Gathering product context from user" },
  { content: "Execute plan-product with analysis", status: "pending", activeForm: "Executing plan-product with analysis" },
  { content: "Customize generated documentation", status: "pending", activeForm: "Customizing generated documentation" },
  { content: "Verify installation completeness", status: "pending", activeForm: "Verifying installation completeness" },
  { content: "Generate installation summary", status: "pending", activeForm: "Generating installation summary" }
];
// Update status to "in_progress" when starting each task
// Mark as "completed" immediately after finishing
```

## For Claude Code
When executing this command:
1. **Initialize TodoWrite** with the workflow steps above for visibility
2. Perform comprehensive codebase analysis before user interaction
3. Use Task tool to invoke subagents as specified
4. Integrate analysis results with plan-product workflow
5. **Update TodoWrite** status throughout execution
6. Provide detailed installation summary with next steps

---

## SECTION: Core Instructions
<!-- BEGIN EMBEDDED CONTENT -->

# Analyze Current Product & Install Agent OS

## Overview

Install Agent OS into an existing codebase, analyze current product state and progress. Builds on plan-product.md

## Process Flow

### Step 1: Analyze Existing Codebase

Perform a deep codebase analysis of the current codebase to understand current state before documentation purposes.

**Analysis Areas:**

**Project Structure:**
- Directory organization
- File naming patterns
- Module structure
- Build configuration

**Technology Stack:**
- Frameworks in use
- Dependencies (package.json, Gemfile, requirements.txt, etc.)
- Database systems
- Infrastructure configuration

**Implementation Progress:**
- Completed features
- Work in progress
- Authentication/authorization state
- API endpoints
- Database schema

**Specification Discovery:**
- Existing specification files in .agent-os/specs/, specs/, docs/, requirements/
- Technical documentation and API specs
- Design documents and architectural decisions
- Specification coverage vs actual implementation

**Code Patterns:**
- Coding style in use
- Naming conventions
- File organization patterns
- Testing approach

**Instructions:**
- ACTION: Thoroughly analyze the existing codebase and specifications
- SEARCH: For existing specifications in .agent-os/specs/, specs/, docs/, requirements/ directories
- DOCUMENT: Current technologies, features, patterns, and available specifications
- IDENTIFY: Architectural decisions already made and specification coverage
- NOTE: Development progress, completed work, and spec-to-implementation alignment
- CATALOG: Any gaps between specifications and current implementation

### Step 2: Get Current Date

Use the current date from the environment context for analysis timestamps.

**Instructions:**
```
ACTION: Get today's date from environment context
NOTE: Claude Code provides "Today's date: YYYY-MM-DD" in every session
STORE: Date for use in analysis documentation
```

### Step 3: Gather Product Context

Use the Explore agent (native) to supplement codebase analysis with business context and future plans.

**Context Questions:**
```
Based on my analysis of your codebase, I can see you're building [OBSERVED_PRODUCT_TYPE].

To properly set up Agent OS, I need to understand:

1. **Product Vision**: What problem does this solve? Who are the target users?

2. **Current State**: Are there features I should know about that aren't obvious from the code?

3. **Roadmap**: What features are planned next? Any major refactoring planned?

4. **Team Preferences**: Any coding standards or practices the team follows that I should capture?
```

**Instructions:**
- ACTION: Ask user for product context
- COMBINE: Merge user input with codebase analysis
- PREPARE: Information for plan-product.md execution

### Step 4: Execute Plan-Product with Context

Execute our standard flow for installing Agent OS in existing products

**Execution Parameters:**
- **Main Idea**: [DERIVED_FROM_ANALYSIS_AND_USER_INPUT]
- **Key Features**: [IDENTIFIED_IMPLEMENTED_AND_PLANNED_FEATURES]
- **Target Users**: [FROM_USER_CONTEXT]
- **Tech Stack**: [DETECTED_FROM_CODEBASE]

**Execution Prompt:**
```
@.agent-os/instructions/core/plan-product.md

I'm installing Agent OS into an existing product. Here's what I've gathered:

**Main Idea**: [SUMMARY_FROM_ANALYSIS_AND_CONTEXT]

**Key Features**:
- Already Implemented: [LIST_FROM_ANALYSIS]
- Planned: [LIST_FROM_USER]

**Target Users**: [FROM_USER_RESPONSE]

**Tech Stack**: [DETECTED_STACK_WITH_VERSIONS]
```

**Instructions:**
- ACTION: Execute plan-product.md with gathered information
- PROVIDE: All context as structured input
- ALLOW: plan-product.md to create .agent-os/product/ structure

### Step 5: Customize Generated Documentation

Refine the generated documentation to ensure accuracy for the existing product by updating roadmap, tech stack, and decisions based on actual implementation.

**Customization Tasks:**

**Roadmap Adjustment:**
- Mark completed features as done
- Move implemented items to "Phase 0: Already Completed"
- Adjust future phases based on actual progress

**Tech Stack Verification:**
- Verify detected versions are correct
- Add any missing infrastructure details
- Document actual deployment setup

**Roadmap Template:**
```markdown
## Phase 0: Already Completed

_Analysis Date: [CURRENT_DATE from environment]_

The following features have been implemented:

- [x] [FEATURE_1] - [DESCRIPTION_FROM_CODE]
- [x] [FEATURE_2] - [DESCRIPTION_FROM_CODE]
- [x] [FEATURE_3] - [DESCRIPTION_FROM_CODE]

## Phase 1: Current Development

- [ ] [IN_PROGRESS_FEATURE] - [DESCRIPTION]

[CONTINUE_WITH_STANDARD_PHASES]
```

### Step 6: Final Verification and Summary

Verify installation completeness and provide clear next steps for the user to start using Agent OS with their existing codebase.

**Verification Checklist:**
- [ ] .agent-os/product/ directory created
- [ ] All product documentation reflects actual codebase
- [ ] Roadmap shows completed and planned features accurately
- [ ] Tech stack matches installed dependencies

**Summary Template:**
```markdown
## ✅ Agent OS Successfully Installed

I've analyzed your [PRODUCT_TYPE] codebase and set up Agent OS with documentation that reflects your actual implementation.

### What I Found

- **Tech Stack**: [SUMMARY_OF_DETECTED_STACK]
- **Completed Features**: [COUNT] features already implemented
- **Code Style**: [DETECTED_PATTERNS]
- **Current Phase**: [IDENTIFIED_DEVELOPMENT_STAGE]

### What Was Created

- ✓ Product documentation in `.agent-os/product/`
- ✓ Roadmap with completed work in Phase 0
- ✓ Tech stack reflecting actual dependencies

### Next Steps

1. Review the generated documentation in `.agent-os/product/`
2. Make any necessary adjustments to reflect your vision
3. See the Agent OS README for usage instructions: https://github.com/buildermethods/agent-os
4. Start using Agent OS for your next feature:
   ```
   @.agent-os/instructions/core/create-spec.md
   ```

Your codebase is now Agent OS-enabled! 🚀
```

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

Use patterns from @shared/state-patterns.md for file operations.

**Analyze-product specific:** Scan codebase structure, detect tech stack, backup existing .agent-os before changes.

---

## SECTION: Error Handling

See @shared/error-recovery.md for general recovery procedures.

### Analyze-product Specific Error Handling

| Error | Recovery |
|-------|----------|
| Codebase analysis failure | Continue with partial results, prompt for tech stack |
| Spec discovery failure | Continue without, recommend spec creation |
| User context failure | Infer from code structure, allow customization |
| Documentation conflict | Backup existing, allow selective merge |
| No existing codebase | Expected for new projects, proceed with defaults |

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- Use native Explore agent for gathering user requirements and supplementing codebase analysis
- Execute plan-product.md workflow with analyzed context and user input