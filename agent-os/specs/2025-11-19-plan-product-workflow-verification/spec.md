# Specification: Plan-Product Workflow Verification and Enhancement

## Goal
Verify and fix the plan-product command workflow to ensure it creates only mission.md in qa-agent-os/product/ (not roadmap.md or tech-stack.md), with proper phase transitions, error handling, and user guidance throughout the product planning process.

## User Stories
- As a QA engineer using QA Agent OS, I want the plan-product command to create only the mission.md file so that my product documentation follows the system's 3-layer context architecture
- As a team lead setting up QA Agent OS, I want the plan-product workflow to provide clear guidance and validation so that I can confidently document my product vision

## Specific Requirements

**Remove roadmap.md and tech-stack.md Creation**
- Plan-product command must ONLY create mission.md in qa-agent-os/product/
- Remove all references to roadmap.md and tech-stack.md from product-planner subagent definition
- Remove creation instructions for roadmap.md and tech-stack.md from create-product-mission.md workflow
- Update validation logic to only check for mission.md existence
- Clean up any template structures or instructions related to roadmap or tech-stack files

**Phase 1: Gather Product Concepts**
- Execute 1-product-concept.md phase which calls gather-product-info.md workflow
- Check if qa-agent-os/product/ directory exists and list existing files before gathering
- Prompt user for required information: Product Idea (core concept), Key Features (minimum 3), Target Users (minimum 1 segment)
- Validate all required information is provided before proceeding
- Display clear next-step message directing user to run Phase 2 when in separate command mode
- Reference global standards for context and baseline assumptions

**Phase 2: Create Mission Document**
- Execute 2-create-mission.md phase which calls create-product-mission.md workflow
- Create qa-agent-os/product/ directory if it doesn't exist
- Generate mission.md following the defined structure: Pitch, Users (Primary Customers, User Personas), The Problem, Differentiators, Key Features
- Focus on user benefits in feature descriptions, not technical implementation details
- Keep content concise and skimmable for quick comprehension
- Validate mission.md was created successfully after generation
- Display completion message with file path and next steps for feature testing

**Single-Agent Command Structure**
- Main orchestrator file plan-product.md uses phase tags to reference sub-commands
- Phase tags format: @qa-agent-os/commands/plan-product/1-product-concept.md and @qa-agent-os/commands/plan-product/2-create-mission.md
- Phase tags get replaced with actual file paths during installation compilation by process_phase_tags() function
- Support both compiled single-command mode and separate phase command execution
- Include conditional messaging using compiled_single_command tag to show/hide next-step instructions

**Subagent Integration**
- Product-planner subagent definition in profiles/default/agents/product-planner.md orchestrates the workflow
- Subagent has access to Write, Read, Bash, WebFetch tools
- Subagent follows two-step workflow: Step 1 calls gather-product-info, Step 2 calls create-product-mission
- Final validation bash script in subagent checks only for mission.md (not roadmap or tech-stack)
- Subagent references workflows using template tags that get compiled during installation

**Error Handling and Validation**
- Check directory existence before file operations and create if missing
- Validate required information completeness before proceeding between phases
- Provide clear error messages if required information is missing with specific prompts for what's needed
- Validate mission.md file creation success with bash check after generation
- Handle existing product directory gracefully by prompting user whether to review or start fresh

**Standards Compliance Integration**
- Reference global standards files using conditional standards_as_claude_code_skills tag
- Inject standards as file references when standards_as_claude_code_skills is false
- Apply standards during mission creation to align with user's coding style and preferences
- Ensure mission content doesn't conflict with tech stack or conventions documented in standards

## Visual Design
No visual assets provided for this specification.

## Existing Code to Leverage

**analise-requirements Command Structure**
- Uses same phase tag pattern with numbered phase files (1-initialize-feature.md, 2-requirement-analysis.md, 3-generate-testcases.md)
- Main orchestrator file references phases using @qa-agent-os/commands/analise-requirements/ paths
- Demonstrates successful multi-phase command compilation pattern to replicate for plan-product
- Shows proper sequencing instructions: "execute IN SEQUENCE, following their numbered file names"
- Includes clear phase transition messaging and validation between steps

**common-functions.sh Processing Logic**
- process_phase_tags() function replaces @qa-agent-os/ references with actual file paths during compilation
- Modular command construction approach allows clean source files with compiled outputs
- Supports conditional tag processing for standards_as_claude_code_skills and compiled_single_command flags
- YAML parsing utilities handle config.yml reading for profile and compilation settings

**gather-product-info.md Workflow Pattern**
- Bash validation to check if product folder exists before prompting
- Clear listing of required vs optional information with minimum requirements
- Structured prompt template when required information is missing
- Pattern should be maintained but ensure it doesn't reference roadmap or tech-stack

**create-product-mission.md Template Structure**
- Markdown template with clear sections and placeholder syntax ([PRODUCT_NAME], [TARGET_USERS], etc.)
- Focus on user benefits, concise content principles documented in constraints
- Comment at top indicates mission should specify product under test as comprehensive vision
- Structure is correct but must not include roadmap or tech-stack sections

**Existing mission.md Output**
- Currently contains roadmap.md and tech-stack.md in qa-agent-os/product/ which violates architecture
- These files were incorrectly created and should be removed from future workflow executions
- Mission.md structure itself is correctly formatted following the template
- File serves as reference for proper mission content but incorrect that other files were created alongside it

## Out of Scope
- Creating or managing roadmap.md in qa-agent-os/product/ - this file should NOT be created by the workflow
- Creating or managing tech-stack.md in qa-agent-os/product/ - this file should NOT be created by the workflow
- Multi-agent mode implementation for plan-product command - only single-agent mode is being verified
- Modifying the overall 3-layer context architecture or directory structure
- Changes to project-install.sh or common-functions.sh compilation logic beyond understanding current behavior
- Integration with external tools like Jira or project management systems
- Automated testing framework setup - manual end-to-end testing is sufficient for this verification
- Migration logic to clean up existing roadmap.md and tech-stack.md files from projects already using the system
- Modifications to other commands or workflows beyond plan-product
- Updates to global standards files or testing standards
