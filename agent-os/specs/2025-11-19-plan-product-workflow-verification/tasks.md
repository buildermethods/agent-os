# Task Breakdown: Plan-Product Workflow Verification and Enhancement

## Overview
Total Task Groups: 5
Estimated Tasks: 22

This task breakdown focuses on fixing the plan-product command to create ONLY mission.md (not roadmap.md or tech-stack.md), ensuring proper phase transitions, error handling, and compliance with the 3-layer context architecture.

## Task List

### Task Group 1: Investigation and Analysis
**Dependencies:** None

- [x] 1.0 Complete investigation of current plan-product implementation
  - [x] 1.1 Read and analyze current plan-product command structure
    - Review `/profiles/default/commands/plan-product/single-agent/plan-product.md` (orchestrator)
    - Review `/profiles/default/commands/plan-product/single-agent/1-product-concept.md` (Phase 1)
    - Review `/profiles/default/commands/plan-product/single-agent/2-create-mission.md` (Phase 2)
    - Document current phase tag usage and compilation approach
  - [x] 1.2 Analyze workflow files for roadmap/tech-stack references
    - Review `/profiles/default/workflows/planning/gather-product-info.md`
    - Review `/profiles/default/workflows/planning/create-product-mission.md`
    - Identify all references to roadmap.md and tech-stack.md
    - Document specific line numbers where changes needed
  - [x] 1.3 Review product-planner subagent definition
    - Read `/profiles/default/agents/product-planner.md`
    - Check final validation bash script (Step 5)
    - Document incorrect references to roadmap.md and tech-stack.md
  - [x] 1.4 Study analise-requirements command as reference pattern
    - Review `/profiles/default/commands/analise-requirements/single-agent/analise-requirements.md`
    - Review `/profiles/default/commands/analise-requirements/single-agent/1-initialize-feature.md`
    - Review `/profiles/default/commands/analise-requirements/single-agent/2-requirement-analysis.md`
    - Document successful patterns: phase tags, conditional messaging, validation
  - [x] 1.5 Review compilation and processing logic
    - Read `process_phase_tags()` function in `/scripts/common-functions.sh` (lines 740-884)
    - Read `process_conditionals()` function in `/scripts/common-functions.sh` (lines 491-623)
    - Understand how `compiled_single_command` tag works for conditional messaging
    - Confirm no changes needed to compilation logic itself

**Acceptance Criteria:**
- Complete understanding of current plan-product structure documented
- All roadmap.md and tech-stack.md references identified with specific file paths and line numbers
- Working reference pattern from analise-requirements command documented
- Compilation logic confirmed as working correctly (no changes needed)

### Task Group 2: Cleanup - Remove Roadmap and Tech-Stack References
**Dependencies:** Task Group 1

- [x] 2.0 Remove all roadmap.md and tech-stack.md references
  - [x] 2.1 Update plan-product.md orchestrator
    - File: `/profiles/default/commands/plan-product/single-agent/plan-product.md`
    - Remove mention of "roadmap" from line 1 description
    - Update to: "You are helping to plan and document the mission for the current product."
    - Verify phase tags remain intact: `{{PHASE 1: @qa-agent-os/commands/plan-product/1-product-concept.md}}` and `{{PHASE 2: @qa-agent-os/commands/plan-product/2-create-mission.md}}`
  - [x] 2.2 Update 1-product-concept.md phase file
    - File: `/profiles/default/commands/plan-product/single-agent/1-product-concept.md`
    - Remove "and roadmap" from line 1
    - Remove "and tech stack" from line 24 standards section
    - Update to mention only mission document creation
  - [x] 2.3 Clean up gather-product-info.md workflow
    - File: `/profiles/default/workflows/planning/gather-product-info.md`
    - Review for any roadmap or tech-stack mentions (currently appears clean)
    - Verify it only collects: Product Idea, Key Features, Target Users
  - [x] 2.4 Update create-product-mission.md workflow
    - File: `/profiles/default/workflows/planning/create-product-mission.md`
    - Confirm it only creates mission.md structure
    - Verify no roadmap or tech-stack sections in template
    - Ensure Important Constraints focus on user benefits and conciseness
  - [x] 2.5 Fix product-planner.md subagent definition
    - File: `/profiles/default/agents/product-planner.md`
    - Line 3: Remove "and roadmap" from description
    - Line 9: Remove "and development roadmap" from role description
    - Line 35: Update validation loop to check ONLY mission.md
    - Remove any roadmap.md or tech-stack.md from the validation file list
    - Line 43: Update completion message to remove roadmap reference
    - Line 49: Remove "and roadmap" from standards compliance section

**Acceptance Criteria:**
- Zero references to roadmap.md in all plan-product files
- Zero references to tech-stack.md in all plan-product files
- All descriptions and instructions mention only mission.md creation
- Product-planner subagent validates only mission.md file

### Task Group 3: Phase 1 - Gather Product Concepts Implementation
**Dependencies:** Task Group 2

- [x] 3.0 Implement Phase 1: Gather Product Concepts
  - [x] 3.1 Enhance 1-product-concept.md with proper structure
    - Add clear opening instruction: "This begins a multi-step process for planning and documenting the mission for the current product."
    - Include workflow reference: `{{workflows/planning/gather-product-info}}`
    - Add waiting instruction: "Then WAIT for me to give you specific instructions on how to use the information you've gathered to create the mission."
  - [x] 3.2 Add conditional next-step messaging for separate command mode
    - Use pattern: `{{UNLESS compiled_single_command}}`
    - Add section: "## Display confirmation and next step"
    - Message template: "I have all the info I need to help you plan this product.\n\nNEXT STEP → Run the command, `2-create-mission.md`"
    - Close with: `{{ENDUNLESS compiled_single_command}}`
  - [x] 3.3 Add standards compliance section
    - Use pattern: `{{UNLESS standards_as_claude_code_skills}}`
    - Add section: "## User Standards & Preferences Compliance"
    - Include reference: `{{standards/global/*}}`
    - Context: "When planning the product's mission, use the user's standards and preferences for context and baseline assumptions"
    - Close with: `{{ENDUNLESS standards_as_claude_code_skills}}`
  - [x] 3.4 Verify gather-product-info.md workflow functionality
    - Confirm bash check for existing qa-agent-os/product/ directory
    - Verify required information prompts: Product Idea, Key Features (min 3), Target Users (min 1)
    - Ensure validation for completeness before proceeding
    - Check graceful handling of existing product directory

**Acceptance Criteria:**
- Phase 1 file follows analise-requirements pattern structure
- Conditional messaging works for both single-command and separate-phase modes
- Standards references inject correctly when standards_as_claude_code_skills is false
- Workflow executes without errors and validates required information

### Task Group 4: Phase 2 - Create Mission Document Implementation
**Dependencies:** Task Group 3

- [x] 4.0 Implement Phase 2: Create Mission Document
  - [x] 4.1 Enhance 2-create-mission.md with proper structure
    - Add opening: "Now that you've gathered information about this product, use that info to create the mission document in `qa-agent-os/product/mission.md` by following these instructions:"
    - Include workflow reference: `{{workflows/planning/create-product-mission}}`
  - [x] 4.2 Add conditional completion messaging for separate command mode
    - Use pattern: `{{UNLESS compiled_single_command}}`
    - Add section: "## Display confirmation and next step"
    - Message template: "✅ I have documented the product mission at `qa-agent-os/product/mission.md`.\n\nReview it to ensure it matches your vision and strategic goals for this product.\n\nYou're ready to start planning the testing of a feature! You can do so by running `analise-requirements`."
    - Close with: `{{ENDUNLESS compiled_single_command}}`
  - [x] 4.3 Add standards compliance section
    - Use pattern: `{{UNLESS standards_as_claude_code_skills}}`
    - Add section: "## User Standards & Preferences Compliance"
    - Include reference: `{{standards/global/*}}`
    - Context: "IMPORTANT: Ensure the product mission is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards"
    - Close with: `{{ENDUNLESS standards_as_claude_code_skills}}`
  - [x] 4.4 Verify create-product-mission.md workflow template
    - Confirm mission.md structure includes only: Pitch, Users, The Problem, Differentiators, Key Features
    - Verify constraints emphasize user benefits and conciseness
    - Check directory creation logic: create qa-agent-os/product/ if doesn't exist
    - Ensure no roadmap or tech-stack sections in template

**Acceptance Criteria:**
- Phase 2 file follows analise-requirements pattern structure
- Conditional messaging correctly references next step (analise-requirements, not shape-spec or write-spec)
- Standards references inject correctly when standards_as_claude_code_skills is false
- Workflow creates only mission.md with correct structure

### Task Group 5: Testing, Validation, and Documentation
**Dependencies:** Task Groups 1-4

- [x] 5.0 Complete end-to-end testing and validation
  - [x] 5.1 Test compilation process
    - Run project-install.sh or project-update.sh on a test project
    - Verify plan-product.md compiles correctly in `.claude/commands/qa-agent-os/`
    - Check phase tags are replaced with embedded content when compiled_single_command=true
    - Confirm conditional blocks process correctly based on config flags
  - [x] 5.2 Test single-command mode (compiled)
    - Execute compiled plan-product command in Claude Code
    - Verify Phase 1 executes and gathers product information
    - Confirm no "NEXT STEP" message appears between phases (compiled_single_command=true)
    - Verify Phase 2 executes automatically after Phase 1
    - Check that only mission.md is created in qa-agent-os/product/
  - [x] 5.3 Test separate-phase command mode
    - Execute 1-product-concept.md separately
    - Verify "NEXT STEP → Run the command, `2-create-mission.md`" message appears
    - Execute 2-create-mission.md separately
    - Confirm mission.md created with correct content
    - Verify completion message references analise-requirements as next step
  - [x] 5.4 Test subagent mode (if applicable)
    - Trigger product-planner subagent
    - Verify workflow follows two-step process
    - Check final validation script only validates mission.md existence
    - Confirm no roadmap.md or tech-stack.md are created or referenced
  - [x] 5.5 Validate error handling and edge cases
    - Test with existing qa-agent-os/product/ directory
    - Verify graceful prompt: "Review existing files or start fresh?"
    - Test with missing required information (should prompt user)
    - Confirm bash validation checks mission.md creation success
    - Test standards injection with standards_as_claude_code_skills=false
  - [x] 5.6 Update feature documentation
    - Document test results in `/qa-agent-os/features/2025-11-19-plan-product-workflow-verification/testing-results.md`
    - Include screenshots or output samples of successful execution
    - Document any edge cases or known limitations
    - Note differences between single-command and separate-phase modes

**Acceptance Criteria:**
- Plan-product command compiles without errors
- Single-command mode executes both phases sequentially without manual intervention
- Separate-phase mode shows proper "NEXT STEP" guidance between phases
- Only mission.md is created; no roadmap.md or tech-stack.md files
- Error handling works correctly for missing info and existing directories
- All test results documented with evidence

## Execution Order

Recommended implementation sequence:
1. **Investigation and Analysis** (Task Group 1) - Understand current state and identify all issues
2. **Cleanup** (Task Group 2) - Remove all incorrect roadmap/tech-stack references
3. **Phase 1 Implementation** (Task Group 3) - Fix gather product concepts workflow
4. **Phase 2 Implementation** (Task Group 4) - Fix create mission document workflow
5. **Testing and Validation** (Task Group 5) - Verify end-to-end functionality and document results

## Key Files Reference

### Files to Modify:
- `/profiles/default/commands/plan-product/single-agent/plan-product.md` - Main orchestrator
- `/profiles/default/commands/plan-product/single-agent/1-product-concept.md` - Phase 1
- `/profiles/default/commands/plan-product/single-agent/2-create-mission.md` - Phase 2
- `/profiles/default/agents/product-planner.md` - Subagent definition
- `/profiles/default/workflows/planning/gather-product-info.md` - Phase 1 workflow
- `/profiles/default/workflows/planning/create-product-mission.md` - Phase 2 workflow

### Files to Reference (Do Not Modify):
- `/profiles/default/commands/analise-requirements/single-agent/*.md` - Working pattern reference
- `/scripts/common-functions.sh` - Compilation logic (no changes needed)
- `/qa-agent-os/features/2025-11-19-plan-product-workflow-verification/spec.md` - Requirements

## Important Notes

- **Focus on mission.md ONLY**: The entire workflow must create only mission.md in qa-agent-os/product/
- **Follow analise-requirements pattern**: Use the same structure for phase tags, conditional messaging, and standards injection
- **Test both modes**: Verify both compiled single-command mode and separate-phase execution mode
- **No compilation changes needed**: The process_phase_tags() and process_conditionals() functions work correctly; only command files need updates
- **Standards injection**: Use `{{UNLESS standards_as_claude_code_skills}}` blocks to conditionally inject standards references
- **Conditional messaging**: Use `{{UNLESS compiled_single_command}}` blocks for "NEXT STEP" messages that should only appear in separate-phase mode
