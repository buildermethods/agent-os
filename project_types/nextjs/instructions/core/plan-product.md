---
description: Product Planning Rules for Agent OS
globs:
alwaysApply: false
version: 4.0
encoding: UTF-8
---

# Product Planning Rules

## Overview

Generate product docs for new projects: mission, tech-stack and roadmap files for AI agent consumption.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" subagent="context-fetcher" name="gather_user_input">

### Step 1: Gather User Input

Use the context-fetcher subagent to collect all required inputs from the user including main idea, key features (minimum 3), target users (minimum 1), and tech stack preferences with blocking validation before proceeding.

<data_sources>
  <primary>user_direct_input</primary>
  <fallback_sequence>
    1. @.agent-os/standards/tech-stack.md
    2. @.claude/CLAUDE.md
    3. Cursor User Rules
  </fallback_sequence>
</data_sources>

<error_template>
  Please provide the following missing information:
  1. Main idea for the product
  2. List of key features (minimum 3)
  3. Target users and use cases (minimum 1)
  4. Tech stack preferences
  5. Has the new application been initialized yet and we're inside the project folder? (yes/no)
</error_template>

</step>

<step number="2" subagent="file-creator" name="create_documentation_structure">

### Step 2: Create Documentation Structure

Use the file-creator subagent to create the following file_structure with validation for write permissions and protection against overwriting existing files:

<file_structure>
  .agent-os/
  └── product/
      ├── mission.md          # Product vision and purpose
      ├── mission-lite.md     # Condensed mission for AI context
      ├── tech-stack.md       # Technical architecture
      └── roadmap.md          # Development phases
</file_structure>

</step>

<step number="3" subagent="file-creator" name="create_mission_md">

### Step 3: Create mission.md

Use the file-creator subagent to create the file: .agent-os/product/mission.md and use the following template:

<file_template>
  <header>
    # Product Mission
  </header>
  <required_sections>
    - Pitch
    - Users
    - The Problem
    - Differentiators
    - Key Features
  </required_sections>
</file_template>

<section name="pitch">
  <template>
    ## Pitch

    [PRODUCT_NAME] is a [PRODUCT_TYPE] that helps [TARGET_USERS] [SOLVE_PROBLEM] by providing [KEY_VALUE_PROPOSITION].
  </template>
  <constraints>
    - length: 1-2 sentences
    - style: elevator pitch
  </constraints>
</section>

<section name="users">
  <template>
    ## Users

    ### Primary Customers

    - [CUSTOMER_SEGMENT_1]: [DESCRIPTION]
    - [CUSTOMER_SEGMENT_2]: [DESCRIPTION]

    ### User Personas

    **[USER_TYPE]** ([AGE_RANGE])
    - **Role:** [JOB_TITLE]
    - **Context:** [BUSINESS_CONTEXT]
    - **Pain Points:** [PAIN_POINT_1], [PAIN_POINT_2]
    - **Goals:** [GOAL_1], [GOAL_2]
  </template>
  <schema>
    - name: string
    - age_range: "XX-XX years old"
    - role: string
    - context: string
    - pain_points: array[string]
    - goals: array[string]
  </schema>
</section>

<section name="problem">
  <template>
    ## The Problem

    ### [PROBLEM_TITLE]

    [PROBLEM_DESCRIPTION]. [QUANTIFIABLE_IMPACT].

    **Our Solution:** [SOLUTION_DESCRIPTION]
  </template>
  <constraints>
    - problems: 2-4
    - description: 1-3 sentences
    - impact: include metrics
    - solution: 1 sentence
  </constraints>
</section>

<section name="differentiators">
  <template>
    ## Differentiators

    ### [DIFFERENTIATOR_TITLE]

    Unlike [COMPETITOR_OR_ALTERNATIVE], we provide [SPECIFIC_ADVANTAGE]. This results in [MEASURABLE_BENEFIT].
  </template>
  <constraints>
    - count: 2-3
    - focus: competitive advantages
    - evidence: required
  </constraints>
</section>

<section name="features">
  <template>
    ## Key Features

    ### Core Features

    - **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]

    ### Collaboration Features

    - **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]
  </template>
  <constraints>
    - total: 8-10 features
    - grouping: by category
    - description: user-benefit focused
  </constraints>
</section>

</step>

<step number="4" subagent="file-creator" name="create_tech_stack_md">

### Step 4: Create tech-stack.md

Use the file-creator subagent to create the file: .agent-os/product/tech-stack.md and use the following template:

<file_template>
  <header>
    # Technical Stack
  </header>
</file_template>

<required_items>
  - application_framework: string + version
  - database_system: string
  - javascript_framework: string
  - import_strategy: ["importmaps", "node"]
  - css_framework: string + version
  - ui_component_library: string
  - fonts_provider: string
  - icon_library: string
  - application_hosting: string
  - database_hosting: string
  - asset_hosting: string
  - deployment_solution: string
  - code_repository_url: string
</required_items>

<data_resolution>
  IF has_context_fetcher:
    FOR missing tech stack items:
      USE: @agent:context-fetcher
      REQUEST: "Find [ITEM_NAME] from tech-stack.md"
      PROCESS: Use found defaults
  ELSE:
    PROCEED: To manual resolution below

  <manual_resolution>
    <for_each item="required_items">
      <if_not_in>user_input</if_not_in>
      <then_check>
        1. @.agent-os/standards/tech-stack.md
        2. @.claude/CLAUDE.md
        3. Cursor User Rules
      </then_check>
      <else>add_to_missing_list</else>
    </for_each>
  </manual_resolution>
</data_resolution>

<missing_items_template>
  Please provide the following technical stack details:
  [NUMBERED_LIST_OF_MISSING_ITEMS]

  You can respond with the technology choice or "n/a" for each item.
</missing_items_template>


</step>

<step number="5" subagent="file-creator" name="create_mission_lite_md">

### Step 5: Create mission-lite.md

Use the file-creator subagent to create the file: .agent-os/product/mission-lite.md for the purpose of establishing a condensed mission for efficient AI context usage.

Use the following template:

<file_template>
  <header>
    # Product Mission (Lite)
  </header>
</file_template>

<content_structure>
  <elevator_pitch>
    - source: Step 3 mission.md pitch section
    - format: single sentence
  </elevator_pitch>
  <value_summary>
    - length: 1-3 sentences
    - includes: value proposition, target users, key differentiator
    - excludes: secondary users, secondary differentiators
  </value_summary>
</content_structure>

<content_template>
  [ELEVATOR_PITCH_FROM_MISSION_MD]

  [1-3_SENTENCES_SUMMARIZING_VALUE_TARGET_USERS_AND_PRIMARY_DIFFERENTIATOR]
</content_template>

<example>
  TaskFlow is a project management tool that helps remote teams coordinate work efficiently by providing real-time collaboration and automated workflow tracking.

  TaskFlow serves distributed software teams who need seamless task coordination across time zones. Unlike traditional project management tools, TaskFlow automatically syncs with development workflows and provides intelligent task prioritization based on team capacity and dependencies.
</example>

</step>

<step number="6" subagent="file-creator" name="create_roadmap_md">

### Step 6: Create roadmap.md

Use the file-creator subagent to create the following file: .agent-os/product/roadmap.md using the following template:

<file_template>
  <header>
    # Product Roadmap
  </header>
</file_template>

<phase_structure>
  <phase_count>1-3</phase_count>
  <features_per_phase>3-7</features_per_phase>
  <phase_template>
    ## Phase [NUMBER]: [NAME]

    **Goal:** [PHASE_GOAL]
    **Success Criteria:** [MEASURABLE_CRITERIA]

    ### Features

    - [ ] [FEATURE] - [DESCRIPTION] `[EFFORT]`

    ### Dependencies

    - [DEPENDENCY]
  </phase_template>
</phase_structure>

<phase_guidelines>
  - Phase 1: Core MVP functionality
  - Phase 2: Key differentiators
  - Phase 3: Scale and polish
  - Phase 4: Advanced features
  - Phase 5: Enterprise features
</phase_guidelines>

<effort_scale>
  - XS: 1 day
  - S: 2-3 days
  - M: 1 week
  - L: 2 weeks
  - XL: 3+ weeks
</effort_scale>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
