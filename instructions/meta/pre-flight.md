---
description: Common Pre-Flight Steps for Agent OS Instructions
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Pre-Flight Rules

- IMPORTANT: For any step that specifies a subagent in the subagent="" XML attribute you MUST use the specified subagent to perform the instructions for that step.

- Process XML blocks sequentially

- Read and execute every numbered step in the process_flow EXACTLY as the instructions specify.

- If you need clarification on any details of your current task, stop and ask the user specific numbered questions and then continue once you have all of the information you need.

- Use exact templates as provided

<intelligent_workflow_analysis>
  <step number="0" subagent="workflow-orchestrator" name="intelligent_workflow_routing">
  
### Step 0: Intelligent Workflow Analysis (Optional)

Use the workflow-orchestrator subagent to analyze the user request and determine optimal workflow routing and coordination strategy.

<workflow_intelligence_check>
  IF workflow-orchestrator agent is available AND config allows intelligent orchestration:
    ACTION: Use workflow-orchestrator subagent
    REQUEST: "Analyze user request for workflow complexity and routing recommendations:
             - Assess intent complexity and scope
             - Determine optimal agent sequence
             - Identify parallelization opportunities
             - Provide workflow coordination strategy"
    PROCESS: Present workflow plan and routing recommendations
    RESPECT: User preferences for orchestration level
  ELSE:
    SKIP: Continue with standard pre-flight
</workflow_intelligence_check>

<workflow_analysis_areas>
  <intent_classification>
    1. Request complexity assessment (simple, moderate, complex, architectural)
    2. Intent type detection (new_feature, improvement, bug_fix, integration)
    3. Multi-agent coordination requirements analysis
    4. Parallel execution opportunity identification
  </intent_classification>
  
  <routing_intelligence>
    - Smart agent sequence determination
    - Dependency resolution for multi-step workflows
    - Resource optimization and conflict prevention  
    - Timeline estimation with parallelization benefits
  </routing_intelligence>
  
  <coordination_strategy>
    - Sequential coordination for dependent tasks
    - Parallel coordination for independent workstreams
    - Hybrid coordination for complex multi-phase workflows
    - Error recovery and rollback planning
  </coordination_strategy>
</workflow_analysis_areas>

<orchestration_guidance>
  <display_format>
    🎯 Workflow Analysis: [Complexity assessment and approach]
    📋 Recommended Plan: [Agent sequence and coordination strategy]
    ⚡ Optimization: [Parallelization and efficiency opportunities]
    → [Timeline estimates and expected benefits]
    → [User confirmation for complex workflows]
  </display_format>
  
  <orchestration_levels>
    - guided: Show workflow plans with explanations and user confirmation
    - intelligent: Provide recommendations with automatic routing for accepted patterns
    - transparent: Execute optimal workflows with real-time progress updates
    - off: Skip orchestration analysis entirely
  </orchestration_levels>
</orchestration_guidance>

<context_intelligence_fallback>
  <step number="0.1" subagent="context-intelligence" name="context_optimization_analysis">
  
  ### Step 0.1: Context Intelligence Fallback (If Workflow Orchestrator Unavailable)
  
  Use the context-intelligence subagent to analyze usage patterns and provide optimization recommendations for this session.

  <intelligence_check>
    IF context-intelligence agent is available AND workflow-orchestrator not used:
      ACTION: Use context-intelligence subagent
      REQUEST: "Analyze current project context and provide session optimization recommendations"
      PROCESS: Present any relevant suggestions to user
      RESPECT: User preferences for suggestion frequency
  </intelligence_check>

  <pattern_detection>
    <analysis_areas>
      1. Project size and complexity assessment
      2. Previous session pattern recognition  
      3. Context usage optimization opportunities
      4. Workflow-specific recommendations
    </analysis_areas>
    
    <recommendation_types>
      - Context compression for large files
      - Deduplication for repetitive access patterns
      - Warmup suggestions for complex projects
      - Workflow optimizations based on task type
    </recommendation_types>
  </pattern_detection>

  <user_guidance>
    <display_format>
      📊 Context Analysis: [Brief assessment]
      💡 Recommendation: [Specific suggestion with benefits]
      → [Clear explanation of value]
      → [User choice prompt when applicable]
    </display_format>
    
    <intelligence_levels>
      - guided: Show recommendations with explanations
      - auto: Apply safe optimizations with notification
      - off: Skip analysis entirely
    </intelligence_levels>
  </user_guidance>
  
  </step>
</context_intelligence_fallback>

  </step>
</intelligent_workflow_analysis>
