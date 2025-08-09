---
description: Test Lifecycle Management System for Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Test Lifecycle Management

## Overview

Test and set up the lifecycle management system for specs in your current project.

<pre_flight_check>
  EXECUTE: @~/.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="project_analysis">

### Step 1: Project Structure Analysis

Analyze the current project to understand the existing spec structure and lifecycle management setup.

<analysis_checklist>
  - [ ] Check if .agent-os/specs directory exists
  - [ ] Count existing specs and categorize by status
  - [ ] Check for existing dashboard files
  - [ ] Verify package.json for dashboard scripts
  - [ ] Identify missing lifecycle management components
</analysis_checklist>

<project_structure_analysis>
  <specs_directory>
    - Path: .agent-os/specs/
    - Status: [exists|missing]
    - Spec count: [NUMBER]
  </specs_directory>
  
  <dashboard_files>
    - specs-dashboard.md: [exists|missing]
    - spec-lifecycle-guide.md: [exists|missing]
    - scripts/simple-dashboard-generator.js: [exists|missing]
  </dashboard_files>
  
  <package_json>
    - dashboard script: [exists|missing]
    - dashboard:simple script: [exists|missing]
  </package_json>
</project_structure_analysis>

</step>

<step number="2" name="spec_categorization">

### Step 2: Spec Status Categorization

Analyze existing specs and categorize them by lifecycle status.

<spec_analysis>
  <existing_specs>
    - List all spec directories
    - Determine current status based on naming convention
    - Check for status.md files
    - Calculate progress percentages
  </existing_specs>
  
  <status_categorization>
    - planning: [COUNT] specs
    - active: [COUNT] specs
    - completed: [COUNT] specs
    - archived: [COUNT] specs
  </status_categorization>
  
  <missing_status_files>
    - Identify specs without status.md
    - Plan status.md creation for missing files
  </missing_status_files>
</spec_analysis>

</step>

<step number="3" name="lifecycle_setup">

### Step 3: Lifecycle Management Setup

Create missing lifecycle management files and components.

<setup_actions>
  <if_dashboard_missing>
    - Create .agent-os/specs/specs-dashboard.md
    - Create .agent-os/specs/spec-lifecycle-guide.md
  </if_dashboard_missing>
  
  <if_scripts_missing>
    - Create scripts/ directory if needed
    - Create scripts/simple-dashboard-generator.js
    - Add dashboard script to package.json
  </if_scripts_missing>
  
  <if_status_files_missing>
    - Create status.md for specs without them
    - Update status.md for specs with outdated information
  </if_status_files_missing>
</setup_actions>

<conditional_creation>
  <if_first_time>
    - Create all lifecycle management files
    - Set up dashboard generation
    - Create comprehensive guide
  </if_first_time>
  
  <if_existing_setup>
    - Update missing components only
    - Preserve existing configuration
    - Enhance current setup
  </if_existing_setup>
</conditional_creation>

</step>

<step number="4" name="dashboard_generation">

### Step 4: Generate Current Dashboard

Generate a current dashboard showing the state of all specs in the project.

<dashboard_generation>
  <run_generator>
    - Execute dashboard generation script
    - Create/update specs-dashboard.md
    - Include all existing specs
    - Show progress percentages
  </run_generator>
  
  <dashboard_content>
    - Planning specs with dates
    - Active specs with progress
    - Completed specs with completion dates
    - Archived specs (if any)
    - Summary statistics
  </dashboard_content>
</dashboard_generation>

</step>

<step number="5" name="results_presentation">

### Step 5: Present Test Results

Show the results of the lifecycle management test and provide next steps.

<results_summary>
  <current_status>
    - Total specs: [NUMBER]
    - Planning: [NUMBER]
    - Active: [NUMBER]
    - Completed: [NUMBER]
    - Archived: [NUMBER]
  </current_status>
  
  <setup_completion>
    - Dashboard files: [created|updated]
    - Scripts: [added|existing]
    - Status files: [created|updated]
    - Package.json: [modified|unchanged]
  </setup_completion>
  
  <next_steps>
    - Commands available for use
    - How to move specs between statuses
    - How to update dashboard
    - Best practices for ongoing use
  </next_steps>
</results_summary>

<user_guidance>
  <available_commands>
    ```bash
    # Generate dashboard
    npm run dashboard
    
    # Move spec to active
    mv .agent-os/specs/planning-YYYY-MM-DD-spec-name .agent-os/specs/active-YYYY-MM-DD-spec-name
    
    # Move spec to completed
    mv .agent-os/specs/active-YYYY-MM-DD-spec-name .agent-os/specs/completed-YYYY-MM-DD-spec-name
    
    # Archive completed spec
    mv .agent-os/specs/completed-YYYY-MM-DD-spec-name .agent-os/specs/archived/YYYY-MM-DD-spec-name
    ```
  </available_commands>
  
  <best_practices>
    - Update status.md weekly for active specs
    - Generate dashboard monthly
    - Archive completed specs quarterly
    - Use consistent naming conventions
  </best_practices>
</user_guidance>

</step>

</process_flow>

## Test Results Template

### Project Analysis
- **Project**: [PROJECT_NAME]
- **Specs Directory**: [EXISTS|MISSING]
- **Total Specs**: [NUMBER]

### Current Spec Status
- **Planning**: [NUMBER] specs
- **Active**: [NUMBER] specs  
- **Completed**: [NUMBER] specs
- **Archived**: [NUMBER] specs

### Setup Results
- **Dashboard Created**: [YES|NO]
- **Scripts Added**: [YES|NO]
- **Status Files Updated**: [NUMBER]
- **Package.json Modified**: [YES|NO]

### Available Commands
```bash
npm run dashboard          # Generate dashboard
npm run dashboard:simple   # Generate simple dashboard
```

### Next Steps
1. Review generated dashboard
2. Update spec statuses as needed
3. Use lifecycle management for new specs
4. Regular dashboard updates