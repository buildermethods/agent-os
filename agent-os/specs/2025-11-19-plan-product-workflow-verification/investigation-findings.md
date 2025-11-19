# Investigation Findings: Plan-Product Workflow Verification

**Date:** 2025-11-19
**Scope:** Complete analysis of current plan-product implementation and related systems
**Status:** Investigation Complete

---

## Executive Summary

The investigation reveals that the plan-product workflow currently references the creation of multiple product documentation files (mission.md, roadmap.md, tech-stack.md) when it should only create mission.md. The workflow follows a correct two-phase pattern similar to analise-requirements command, but contains incorrect file references and scope. The compilation logic (process_phase_tags() and process_conditionals()) is functioning correctly and requires no changes. All issues are in the command and workflow content files.

---

## 1. Current Plan-Product Structure Analysis

### 1.1 Plan-Product Command Files

**File:** `/profiles/default/commands/plan-product/single-agent/plan-product.md`
- **Type:** Orchestrator file (main entry point)
- **Current Content:** Lines 1-2 describe the workflow as "plan and document the mission, roadmap and tech stack"
- **Current Phase Tags:**
  - Line 10: `{{PHASE 1: @qa-agent-os/commands/plan-product/1-product-concept.md}}`
  - Line 12: `{{PHASE 2: @qa-agent-os/commands/plan-product/2-create-mission.md}}`
- **Issue:** Mentions "roadmap and tech stack" in description when only mission.md should be created
- **Pattern Analysis:** Uses correct phase tag syntax: `{{PHASE X: @qa-agent-os/commands/[command]/[file].md}}`

**File:** `/profiles/default/commands/plan-product/single-agent/1-product-concept.md`
- **Type:** Phase 1 instruction file
- **Current Content:**
  - Line 1: "This begins a multi-step process for planning and documenting the mission and roadmap for the current product."
  - Line 5: Workflow reference: `{{workflows/planning/gather-product-info}}`
  - Lines 9-19: Conditional messaging using `{{UNLESS compiled_single_command}}`
  - Lines 21-27: Conditional standards injection using `{{UNLESS standards_as_claude_code_skills}}`
- **Issues:**
  - Line 1: Mentions "and roadmap" when only mission should be documented
  - Line 24: Standards section mentions "When planning the product's tech stack, mission statement and roadmap" - includes incorrect references
- **Correct Elements:**
  - Workflow reference syntax is correct
  - Conditional messaging pattern is correct
  - Standards injection pattern is correct

**File:** `/profiles/default/commands/plan-product/single-agent/2-create-mission.md`
- **Type:** Phase 2 instruction file
- **Current Content:**
  - Line 1: "Now that you've gathered information about this product, use that info to create the mission document..."
  - Line 3: Workflow reference: `{{workflows/planning/create-product-mission}}`
  - Lines 5-17: Conditional messaging using `{{UNLESS compiled_single_command}}`
  - Lines 19-25: Conditional standards injection using `{{UNLESS standards_as_claude_code_skills}}`
- **Issues:**
  - Line 15: References "shape-spec.md" or "write-spec.md" as next step instead of "analise-requirements"
  - Standards reference is correct
- **Status:** Mostly correct, only needs the "next step" reference updated

---

## 2. Workflow Files Analysis

### 2.1 Gather Product Info Workflow

**File:** `/profiles/default/workflows/planning/gather-product-info.md`
- **Status:** CLEAN - No roadmap or tech-stack references found
- **Content Summary:**
  - Lines 4-9: Bash check for existing product directory
  - Lines 12-23: Collects required information (Product Idea, Key Features, Target Users)
  - No references to roadmap.md or tech-stack.md
- **Assessment:** This workflow is correctly scoped and requires NO changes

### 2.2 Create Product Mission Workflow

**File:** `/profiles/default/workflows/planning/create-product-mission.md`
- **Status:** MOSTLY CLEAN with one comment that needs review
- **Content Summary:**
  - Lines 1-2: Introduces mission.md creation
  - Lines 3-3: Comment (lines 3-4) discussing mission structure and context - not actionable code
  - Lines 6-49: Mission structure template with correct sections:
    - Pitch
    - Users
    - The Problem
    - Differentiators
    - Key Features
  - Lines 51-54: Constraints focusing on user benefits and conciseness
  - No references to roadmap.md or tech-stack.md in actual template
- **Assessment:** This workflow is correctly scoped. The inline comment (lines 3-4) is just discussion and doesn't affect functionality. NO changes required.

---

## 3. Product-Planner Subagent Analysis

**File:** `/profiles/default/agents/product-planner.md`
- **Current Content:**
  - Line 2: Description: "Use proactively to create product documentation including mission, and roadmap"
  - Line 3: Role description: "Your role is to create comprehensive product documentation including mission, and development roadmap."
  - Lines 23-27: Workflow references (correct)
  - Lines 35-41: Final validation bash script - **CRITICAL ISSUE**
    - Line 35: Validation loop checks for file "mission.md"
    - Line 43: Completion message references "agent-os/product/" (should be "qa-agent-os/product/")
  - Lines 49-52: Standards compliance section - mentions "mission and roadmap"

**Issues Found:**
1. **Line 2:** Remove "and roadmap" from description
2. **Line 3:** Remove "and development roadmap" from role
3. **Lines 35-41:** Validation script is actually CORRECT - it only checks mission.md (despite the description mentioning roadmap)
4. **Line 43:** Path reference "agent-os/product/" should be "qa-agent-os/product/"
5. **Line 49:** Remove "and roadmap" from standards compliance statement

**Assessment:** The validation bash script (Step 5) is technically correct as it only validates mission.md, but descriptions are misleading. The path reference in line 43 needs fixing.

---

## 4. Reference Pattern Analysis: Analise-Requirements Command

**File:** `/profiles/default/commands/analise-requirements/single-agent/analise-requirements.md`
- **Pattern:** Multi-phase orchestrator
- **Phase Tags Format:** `{{PHASE X: @qa-agent-os/commands/analise-requirements/[X]-[name].md}}`
- **Structure:** Correctly sequences three phases with clear phase labels

**File:** `/profiles/default/commands/analise-requirements/single-agent/1-initialize-feature.md`
- **Correct Pattern Elements:**
  1. Opening instruction: "The FIRST STEP is to initialize the feature testing..."
  2. Workflow reference: `{{workflows/testing/initialize-feature}}`
  3. Conditional messaging: `{{UNLESS compiled_single_command}}`
  4. Confirmation message within conditional block
  5. Conditional message closing: `{{ENDUNLESS compiled_single_command}}`
- **Standards Injection:** Uses `{{standards/global/*}}` pattern within `{{UNLESS standards_as_claude_code_skills}}` blocks

**File:** `/profiles/default/commands/analise-requirements/single-agent/2-requirement-analysis.md`
- **Correct Pattern Elements:**
  1. Opening instruction: "Now that you've initialized..."
  2. Workflow reference: `{{workflows/testing/requirement-analysis}}`
  3. Conditional messaging: `{{UNLESS compiled_single_command}}`
  4. Confirmation message with next step guidance
  5. Standards compliance section with `{{UNLESS standards_as_claude_code_skills}}`
- **Next Step Reference:** Correctly references `3-generate-testcases` as next phase

**Key Takeaway:** The plan-product Phase 2 file currently references "shape-spec.md" or "write-spec.md" as next steps, but it should reference "analise-requirements" as the next command for the user to run after product mission is created.

---

## 5. Compilation and Processing Logic

### 5.1 Process Phase Tags Function

**File:** `/scripts/common-functions.sh` (lines 740-884)

**Function Purpose:** Embeds content of referenced files with H1 headers when mode="embed"

**Key Mechanics:**
- Line 747-750: If no mode specified, returns content unchanged (no processing)
- Line 754: Finds all PHASE tags using regex: `{{PHASE [^}]*}}`
- Lines 761-881: For each phase tag found:
  - Extracts phase label (e.g., "PHASE 1")
  - Extracts file reference path (e.g., "plan-product/1-product-concept.md")
  - Converts filename to title (e.g., "1-product-concept" → "Product Concept")
  - Constructs full path with `/single-agent/` directory insertion
  - Reads file content and processes it through:
    - `process_conditionals()` with `compiled_single_command=true` (line 791)
    - `process_workflows()` (line 792)
    - Standards replacement processing (lines 794-838)
  - Creates replacement with H1 header: `# PHASE X: [Title]`
  - Replaces phase tag with embedded content

**How It Works with Compiled Commands:**
- When command is compiled (single-command mode), `process_phase_tags()` is called with `mode="embed"`
- This embeds all phase files into one document, removing phase tags
- Sets `compiled_single_command=true` when processing embedded content
- This causes `{{UNLESS compiled_single_command}}` blocks to be excluded (conditional messaging removed)

**Assessment:** Function is working correctly. No changes needed.

### 5.2 Process Conditionals Function

**File:** `/scripts/common-functions.sh` (lines 491-623)

**Function Purpose:** Process conditional compilation tags to include/exclude sections based on flags

**Supported Tags:**
- `{{IF flag_name}}` ... `{{ENDIF flag_name}}` - Include block if flag is true
- `{{UNLESS flag_name}}` ... `{{ENDUNLESS flag_name}}` - Include block if flag is false

**Supported Flags:**
- `use_claude_code_subagents` - Check if subagents are enabled
- `standards_as_claude_code_skills` - Check if standards are injected as Claude Code skills
- `compiled_single_command` - Check if command is being compiled (phase tags embedded)

**Logic Flow:**
- Line 504-615: Line-by-line processing of content
- Lines 506-537: Handle `{{IF}}` tags - push current state to stack, update based on condition
- Lines 541-573: Handle `{{UNLESS}}` tags - opposite logic of IF
- Lines 576-605: Handle closing tags (`{{ENDIF}}` and `{{ENDUNLESS}}`) - pop state from stack
- Lines 608-614: Include line in output only if current `should_include` is true
- Lines 618-620: Validation check for unclosed conditionals

**Example Usage in Plan-Product:**
- `{{UNLESS compiled_single_command}}` - Content only appears in separate-phase mode (not compiled)
- `{{UNLESS standards_as_claude_code_skills}}` - Standards injected only when not using Claude Code skills

**Assessment:** Function is working correctly and handles nested conditions properly. No changes needed.

---

## 6. Summary of Issues Found

### Critical Issues (Must Fix)
1. **plan-product.md orchestrator (Line 1-2):** Remove "roadmap and tech stack" from description
2. **1-product-concept.md (Line 1):** Remove "and roadmap" from opening
3. **1-product-concept.md (Line 24):** Remove references to tech-stack and roadmap from standards section
4. **2-create-mission.md (Line 15):** Change next-step references from "shape-spec.md" or "write-spec.md" to "analise-requirements"
5. **product-planner.md (Line 2):** Remove "and roadmap" from description
6. **product-planner.md (Line 3):** Remove "and development roadmap" from role description
7. **product-planner.md (Line 43):** Fix path from "agent-os/product/" to "qa-agent-os/product/"
8. **product-planner.md (Line 49):** Remove "and roadmap" from standards statement

### Non-Issues (No Changes Needed)
- `gather-product-info.md` workflow - correctly scoped
- `create-product-mission.md` workflow - correctly scoped
- `process_phase_tags()` function - working correctly
- `process_conditionals()` function - working correctly
- Phase tag syntax - correct throughout
- Conditional messaging patterns - correct throughout
- Product-planner validation bash script (Step 5) - technically correct, only descriptions misleading

---

## 7. Compilation Flow Confirmation

### Current Compilation Process (No Changes Needed)

1. **Installation Stage:**
   - `project-install.sh` reads config.yml
   - `compile_commands()` is called for each command

2. **Compilation for Single-Command Mode:**
   - `process_conditionals()` called with `compiled_single_command=true`
   - This removes all `{{UNLESS compiled_single_command}}` blocks (NEXT STEP messages)
   - `process_phase_tags()` called with `mode="embed"`
   - This embeds all PHASE file contents into orchestrator
   - Result: Single document with both phases, no phase transitions

3. **Separate-Phase Mode (No Compilation):**
   - Files used as-is from source
   - `{{UNLESS compiled_single_command}}` blocks included (NEXT STEP messages shown)
   - Phase tags remain in place but typically ignored in editor mode

4. **Standards Injection:**
   - `{{UNLESS standards_as_claude_code_skills}}` blocks included when standards should be injected
   - Standards references replaced with actual standard file content or links

---

## 8. Workflow Pattern Comparison

### Analise-Requirements (Working Pattern)
```
orchestrator.md
  ├─ Phase 1 file references in PHASE tags
  │  ├─ Workflow reference: {{workflows/testing/initialize-feature}}
  │  ├─ Conditional next-step message ({{UNLESS compiled_single_command}})
  │  └─ Standards injection block ({{UNLESS standards_as_claude_code_skills}})
  │
  ├─ Phase 2 file references in PHASE tags
  │  ├─ Workflow reference: {{workflows/testing/requirement-analysis}}
  │  ├─ Conditional next-step message
  │  └─ Standards injection block
  │
  └─ Phase 3 file references in PHASE tags
     ├─ Workflow reference
     └─ (Optional conditional messaging)
```

### Plan-Product (Current - Needs Alignment)
```
orchestrator.md
  ├─ Phase 1 file - MOSTLY CORRECT
  │  ├─ Workflow reference: {{workflows/planning/gather-product-info}} ✓
  │  ├─ Conditional next-step message ✓
  │  └─ Standards injection block (needs content update)
  │
  └─ Phase 2 file - NEEDS UPDATE
     ├─ Workflow reference: {{workflows/planning/create-product-mission}} ✓
     ├─ Conditional next-step message (needs next-step update)
     └─ Standards injection block ✓
```

---

## 9. Detailed Change Requirements

### Phase 1 (1-product-concept.md) Changes
**Required Updates:**
- Remove "and roadmap" from line 1
- Update line 24 standards context from "When planning the product's tech stack, mission statement and roadmap..." to "When planning the product's mission..."

### Phase 2 (2-create-mission.md) Changes
**Required Updates:**
- Update line 15 from "shape-spec.md" or "write-spec.md" to "analise-requirements"

### Orchestrator (plan-product.md) Changes
**Required Updates:**
- Remove "roadmap and tech stack" from line 1-2 description

### Subagent (product-planner.md) Changes
**Required Updates:**
- Line 2: Remove "and roadmap"
- Line 3: Remove "and development roadmap"
- Line 43: Fix "agent-os/product/" to "qa-agent-os/product/"
- Line 49: Remove "and roadmap"

---

## 10. Compilation Logic Confirmation

The following functions require NO changes:
- `process_phase_tags()` - Correctly embeds PHASE-tagged files
- `process_conditionals()` - Correctly processes conditional blocks
- `process_workflows()` - Correctly processes workflow references
- `process_standards()` - Correctly injects standards references

The compilation logic is well-designed and handles all the patterns used in plan-product and analise-requirements correctly.

---

## 11. Next Steps (From Investigation Perspective)

The investigation confirms that:
1. ✓ Current pattern (phase tags, conditionals, standards injection) is correct
2. ✓ Compilation logic is working correctly
3. ✗ Content references (roadmap, tech-stack) need cleanup
4. ✗ Next-step guidance needs to be updated to reference analise-requirements
5. ✓ Workflows (gather-product-info, create-product-mission) are correctly scoped

**Task Group 2 can proceed immediately** - all issues are content-level only, no architectural or compilation changes needed.

---

## Appendix: File Reference Summary

### Files to Modify (In Priority Order)
1. `/profiles/default/commands/plan-product/single-agent/1-product-concept.md` - 2 changes
2. `/profiles/default/commands/plan-product/single-agent/2-create-mission.md` - 1 change
3. `/profiles/default/commands/plan-product/single-agent/plan-product.md` - 1 change
4. `/profiles/default/agents/product-planner.md` - 4 changes
5. `/profiles/default/workflows/planning/gather-product-info.md` - 0 changes (clean)
6. `/profiles/default/workflows/planning/create-product-mission.md` - 0 changes (clean)

### Files to Review (No Changes)
1. `/scripts/common-functions.sh` - process_phase_tags() and process_conditionals() - verified working
2. `/profiles/default/commands/analise-requirements/` - reference pattern - verified correct

**Total Content Changes Required:** 8 changes across 4 files

