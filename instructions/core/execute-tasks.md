---
description: Rules to initiate execution of a set of tasks using Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Task Execution Rules

## Overview

Execute tasks for a given spec following three distinct phases:
1. Pre-execution setup (Steps 1-3)
2. Task execution loop (Step 4)
3. Post-execution tasks (Step 5)

**IMPORTANT**: All three phases MUST be completed. Do not stop after phase 2.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

## Phase 1: Pre-Execution Setup

<step number="0.5" name="vibe_mode_detection">

### Step 0.5: Vibe Mode Detection (Optional)

**VIBE MODE**: Detect if user wants to work in specless "vibe mode" where they code first and documentation is generated afterward.

<vibe_mode_check>
  IF user indicates desire for specless development OR config enables vibe mode:
    ENABLE: Specless vibe mode execution
    SKIP: Traditional spec-based task selection
    PROCEED: Directly to coding and implementation
  ELSE:
    CONTINUE: With traditional spec-based task assignment
</vibe_mode_check>

<vibe_mode_indicators>
  <explicit_requests>
    - "Let me just code this first"
    - "I want to build without a spec"
    - "Enable vibe mode"
    - "Skip the planning, let's code"
  </explicit_requests>
  
  <implicit_indicators>
    - No spec exists but user wants to start coding
    - User provides code changes without corresponding tasks
    - User requests immediate implementation without specification
  </implicit_indicators>
</vibe_mode_indicators>

<vibe_mode_setup>
  IF vibe_mode enabled:
    CREATE: Temporary vibe mode session tracking
    ENABLE: Code-first development workflow
    PREPARE: For retroactive spec generation via spec-synthesizer
    NOTE: All changes will be analyzed for spec generation in post-execution
</vibe_mode_setup>

</step>

<step number="1" name="task_assignment">

### Step 1: Task Assignment

**CONDITIONAL**: Execute this step only if NOT in vibe mode.

Identify which tasks to execute from the spec (using spec_srd_reference file path and optional specific_tasks array), defaulting to the next uncompleted parent task if not specified.

<task_selection>
  <explicit>user specifies exact task(s)</explicit>
  <implicit>find next uncompleted task in tasks.md</implicit>
  <vibe_mode>skip task assignment - enable free-form development</vibe_mode>
</task_selection>

<instructions>
  ACTION: Identify task(s) to execute
  DEFAULT: Select next uncompleted parent task if not specified
  CONFIRM: Task selection with user
  VIBE_MODE_SKIP: If vibe mode active, skip to Step 4 (execution) with free-form approach
</instructions>

</step>

<step number="2" subagent="context-fetcher" name="context_analysis">

### Step 2: Context Analysis

Use the context-fetcher subagent to gather minimal context for task understanding by always loading spec tasks.md, and conditionally loading @.agent-os/product/mission-lite.md, spec-lite.md, and sub-specs/technical-spec.md if not already in context.

<instructions>
  ACTION: Use context-fetcher subagent to:
    - REQUEST: "Get product pitch from mission-lite.md"
    - REQUEST: "Get spec summary from spec-lite.md"
    - REQUEST: "Get technical approach from technical-spec.md"
  PROCESS: Returned information
</instructions>


<context_gathering>
  <essential_docs>
    - tasks.md for task breakdown
  </essential_docs>
  <conditional_docs>
    - mission-lite.md for product alignment
    - spec-lite.md for feature summary
    - technical-spec.md for implementation details
  </conditional_docs>
</context_gathering>

</step>

<step number="3" subagent="git-workflow" name="git_branch_management">

### Step 3: Git Branch Management

Use the git-workflow subagent to manage git branches to ensure proper isolation by creating or switching to the appropriate branch for the spec.

<instructions>
  ACTION: Use git-workflow subagent
  REQUEST: "Check and manage branch for spec: [SPEC_FOLDER]
            - Create branch if needed
            - Switch to correct branch
            - Handle any uncommitted changes"
  WAIT: For branch setup completion
</instructions>

<branch_naming>
  <source>spec folder name</source>
  <format>exclude date prefix</format>
  <example>
    - folder: 2025-03-15-password-reset
    - branch: password-reset
  </example>
</branch_naming>

</step>

## Phase 2: Task Execution Loop

<step number="4" subagent="workflow-orchestrator" name="intelligent_task_execution">

### Step 4: Intelligent Task Execution with Coordination

**IMPORTANT**: This step uses intelligent coordination to optimize task execution through dependency analysis and parallel execution when possible.

<orchestration_check>
  IF workflow-orchestrator agent is available AND config allows intelligent execution:
    ACTION: Use workflow-orchestrator subagent for coordinated execution
    REQUEST: "Analyze assigned tasks for optimal execution strategy:
             - Analyze task dependencies using dependency-resolver
             - Determine parallel execution opportunities
             - Create coordinated execution plan with monitoring
             - Execute with real-time progress tracking"
    PROCESS: Execute according to intelligent coordination plan
  ELSE:
    FALLBACK: Use standard sequential execution loop
</orchestration_check>

<intelligent_execution_flow>
  STEP 4a: Dependency Analysis (via dependency-resolver)
    ANALYZE: Task dependencies and execution order requirements
    IDENTIFY: Independent tasks that can run in parallel
    RESOLVE: Any conflicts or resource contention issues
    CREATE: Optimal execution sequence with parallelization plan
    
  STEP 4b: Coordinated Execution (via execution-monitor)
    PARALLEL_STREAM_1: Independent tasks that can run concurrently
    PARALLEL_STREAM_2: Additional independent workstreams as available
    SYNCHRONIZATION_POINTS: Coordinate dependent tasks at required intervals
    PROGRESS_MONITORING: Real-time tracking of all execution streams
    
  STEP 4c: Completion Verification
    VERIFY: All assigned tasks completed successfully
    RESOLVE: Any issues that emerged during parallel execution
    CONSOLIDATE: Results from all execution streams
    PREPARE: For post-execution phase
</intelligent_execution_flow>

<fallback_execution_flow>
  ### Standard Sequential Execution (If Orchestration Unavailable)
  
  LOAD @.agent-os/instructions/core/execute-task.md ONCE

  FOR each parent_task assigned in Step 1:
    EXECUTE instructions from execute-task.md with:
      - parent_task_number
      - all associated subtasks
    WAIT for task completion
    UPDATE tasks.md status
  END FOR

  **IMPORTANT**: After loop completes, CONTINUE to Phase 3 (Step 5). Do not stop here.
</fallback_execution_flow>

<coordination_benefits>
  <parallel_execution>
    - Independent tasks execute concurrently for faster completion
    - Resource optimization prevents conflicts and bottlenecks
    - Real-time monitoring provides visibility into progress
    - Intelligent dependency resolution prevents execution errors
  </parallel_execution>
  
  <smart_coordination>
    - Dependency analysis prevents execution order issues
    - Conflict resolution handles resource contention
    - Progress tracking enables proactive issue management
    - Optimization reduces overall execution time
  </smart_coordination>
</coordination_benefits>

<execution_strategies>
  <simple_linear>
    conditions: [few_tasks, clear_dependencies, single_focus]
    approach: Sequential execution in dependency order
    coordination: Minimal - standard execute-task.md process
  </simple_linear>
  
  <parallel_optimized>
    conditions: [independent_tasks, adequate_resources, time_pressure]
    approach: Maximum parallelization with sync points
    coordination: Full orchestration with real-time monitoring
  </parallel_optimized>
  
  <hybrid_approach>
    conditions: [mixed_dependencies, moderate_complexity]
    approach: Phases with internal parallelization
    coordination: Balanced orchestration with dependency respect
  </hybrid_approach>
</execution_strategies>

<loop_logic>
  <continue_conditions>
    - More unfinished parent tasks exist in any execution stream
    - User has not requested stop
    - No blocking issues prevent continuation
  </continue_conditions>
  <exit_conditions>
    - All assigned tasks marked complete across all streams
    - User requests early termination
    - Critical blocking issue prevents safe continuation
  </exit_conditions>
</loop_logic>

<progress_monitoring>
  <real_time_updates>
    - Track progress across parallel execution streams
    - Monitor resource utilization and conflicts
    - Provide status updates on coordination effectiveness
    - Alert on blocking issues requiring attention
  </real_time_updates>
  
  <coordination_feedback>
    - Report parallelization efficiency and time savings
    - Document successful coordination patterns
    - Identify optimization opportunities for future executions
    - Provide learning data for workflow orchestrator improvement
  </coordination_feedback>
</progress_monitoring>

<instructions>
  ACTION: Use workflow-orchestrator for intelligent task coordination when available
  ANALYZE: Dependencies and parallelization opportunities before execution
  COORDINATE: Multiple execution streams with proper synchronization
  MONITOR: Progress across all streams with real-time feedback
  OPTIMIZE: Resource usage and timeline through intelligent coordination
  FALLBACK: Sequential execution if intelligent coordination unavailable
  VERIFY: All tasks complete before proceeding to Phase 3
  **IMPORTANT**: When all coordinated execution completes, proceed to Step 5
</instructions>

</step>

## Phase 3: Post-Execution Tasks

<step number="5" name="post_execution_tasks">

### Step 5: Run the task completion steps

**CRITICAL**: This step MUST be executed after all tasks are implemented. Do not end the process without completing this phase.

After all tasks in tasks.md have been implemented, use @.agent-os/instructions/core/post-execution-tasks.md to run our series of steps we always run when finishing and delivering a new feature.

<vibe_mode_integration>
  IF vibe mode was used during execution:
    STEP 5a: Retroactive Documentation Generation (via spec-synthesizer)
      ACTION: Use spec-synthesizer subagent to generate documentation from implemented code
      REQUEST: "Analyze implemented code and generate retroactive specification:
               - Infer requirements from code implementation
               - Generate comprehensive spec.md from code analysis
               - Create tasks.md reflecting actual implementation approach
               - Generate technical-spec.md with architectural decisions"
      PROCESS: Generated specifications and integrate with post-execution workflow
      
    STEP 5b: Enhanced Post-Execution with Vibe Mode Context
      LOAD: @.agent-os/instructions/core/post-execution-tasks.md once
      ACTION: Execute post-execution-tasks.md with vibe mode context
      INCLUDE: Generated specifications in all post-execution activities
      
  ELSE:
    LOAD: @.agent-os/instructions/core/post-execution-tasks.md once
    ACTION: Execute standard post-execution-tasks.md process_flow
</vibe_mode_integration>

<instructions>
  **VIBE MODE PROCESS**:
    - Generate specs from implemented code using spec-synthesizer
    - Run standard post-execution process with generated documentation
    - Include code-to-spec traceability in recap
    - Validate generated specs against implemented functionality
    
  **STANDARD PROCESS**:
    - Running full test suite
    - Git workflow (commit, push, PR)
    - Verifying task completion
    - Updating roadmap (if applicable)
    - Creating recap document
    - Generating completion summary
    - Playing notification sound
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>
