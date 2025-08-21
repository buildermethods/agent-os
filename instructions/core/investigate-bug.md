---
description: Investigate Bug Rules for Agent OS
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Investigate Bug Rules

## Overview

Investigate and document bugs without immediately fixing them, providing detailed analysis for future resolution.

<pre_flight_check>
  EXECUTE: @.agent-os/instructions/meta/pre-flight.md
</pre_flight_check>

<process_flow>

<step number="1" name="bug_report_gathering">

### Step 1: Bug Report Gathering

Collect all available information about the reported bug.

<information_collection>
  <from_user>
    - Bug description
    - Reproduction steps
    - Expected behavior
    - Actual behavior
    - Frequency of occurrence
    - Environment details
  </from_user>
  
  <from_system>
    - Error messages
    - Stack traces
    - Log files
    - Screenshots/recordings
    - System state
  </from_system>
</information_collection>

<initial_assessment>
  <severity>
    - Critical: System unusable
    - High: Major feature broken
    - Medium: Feature partially working
    - Low: Minor inconvenience
  </severity>
  
  <scope>
    - Number of users affected
    - Features impacted
    - Workarounds available
  </scope>
</initial_assessment>

<instructions>
  ACTION: Gather all bug information
  ASSESS: Severity and scope
  DOCUMENT: Initial findings
  PREPARE: Investigation plan
</instructions>

</step>

<step number="2" subagent="debug-helper" name="environmental_analysis">

### Step 2: Environmental Analysis

Use the debug-helper subagent to analyze the environment and context where the bug occurs.

<environment_check>
  <system>
    - OS and version
    - Runtime version
    - Dependencies versions
    - Configuration settings
  </system>
  
  <application>
    - Version/commit
    - Build configuration
    - Feature flags
    - Database state
  </application>
  
  <timing>
    - When first observed
    - Recent deployments
    - Related changes
    - Pattern of occurrence
  </timing>
</environment_check>

<instructions>
  ACTION: Use debug-helper subagent
  REQUEST: "Analyze environment for bug: [BUG_DESCRIPTION]
            Check: system config, app version, recent changes
            Identify: environmental factors and patterns"
  DOCUMENT: Environmental findings
  NOTE: Any unique conditions
</instructions>

</step>

<step number="3" name="reproduction_investigation">

### Step 3: Reproduction Investigation

Attempt to reproduce the bug and document findings without fixing.

<reproduction_attempts>
  <systematic_approach>
    1. Follow exact reported steps
    2. Try variations of steps
    3. Test in different environments
    4. Identify minimum reproduction
  </systematic_approach>
  
  <documentation>
    - Successful reproduction steps
    - Failed reproduction attempts
    - Environmental differences
    - Intermittent patterns
  </documentation>
  
  <data_collection>
    - Network requests/responses
    - State before/after
    - Memory usage
    - Performance metrics
  </data_collection>
</reproduction_attempts>

<reproduction_status>
  <reproducible>
    - Document exact steps
    - Note consistency
    - Capture all outputs
  </reproducible>
  
  <intermittent>
    - Document success rate
    - Identify patterns
    - Note correlations
  </intermittent>
  
  <not_reproducible>
    - Document attempts made
    - List environmental differences
    - Suggest further investigation
  </not_reproducible>
</reproduction_status>

<instructions>
  ACTION: Attempt bug reproduction
  DOCUMENT: All attempts and results
  IDENTIFY: Patterns and correlations
  AVOID: Making any fixes at this stage
</instructions>

</step>

<step number="4" subagent="debug-helper" name="code_analysis">

### Step 4: Code Analysis

Use the debug-helper subagent to analyze potentially affected code without modifying it.

<static_analysis>
  <identify>
    - Suspect functions/methods
    - Related components
    - Data flow paths
    - State dependencies
  </identify>
  
  <examine>
    - Logic conditions
    - Error handling
    - Edge cases
    - Assumptions made
  </examine>
  
  <history>
    - Recent changes to area
    - Previous bugs in component
    - Code quality issues
    - Technical debt
  </history>
</static_analysis>

<dynamic_analysis>
  <tracing>
    - Execution path
    - Variable values
    - State changes
    - Timing issues
  </tracing>
  
  <monitoring>
    - Resource usage
    - Performance metrics
    - Error patterns
    - Log analysis
  </monitoring>
</dynamic_analysis>

<instructions>
  ACTION: Use debug-helper subagent
  REQUEST: "Analyze code for bug: [BUG_DESCRIPTION]
            Examine: [SUSPECT_COMPONENTS]
            Review: logic, state, error handling
            Check: recent changes and history"
  DOCUMENT: Code analysis findings
  AVOID: Making any code changes
</instructions>

</step>

<step number="5" name="hypothesis_formation">

### Step 5: Hypothesis Formation

Develop hypotheses about the bug's root cause based on investigation.

<hypothesis_development>
  <primary_hypothesis>
    - Most likely cause
    - Supporting evidence
    - How to verify
    - Confidence level
  </primary_hypothesis>
  
  <alternative_hypotheses>
    - Other possible causes
    - Evidence for/against
    - Priority order
    - Testing approach
  </alternative_hypotheses>
  
  <contributing_factors>
    - Environmental conditions
    - Timing/race conditions
    - Data dependencies
    - User interactions
  </contributing_factors>
</hypothesis_development>

<verification_plan>
  <tests_needed>
    - Specific scenarios to test
    - Data requirements
    - Tools needed
    - Expected outcomes
  </tests_needed>
  
  <investigation_depth>
    - Further analysis required
    - Expert consultation needed
    - Additional logging needed
    - Performance profiling required
  </investigation_depth>
</verification_plan>

<instructions>
  ACTION: Form bug hypotheses
  RANK: By likelihood and evidence
  PLAN: Verification approach
  DOCUMENT: All hypotheses and reasoning
</instructions>

</step>

<step number="6" subagent="file-creator" name="investigation_report">

### Step 6: Create Investigation Report

Use the file-creator subagent to create a comprehensive investigation report.

<report_structure>
  <header>
    # Bug Investigation Report
    
    **Date:** [TIMESTAMP]
    **Investigator:** AI Agent
    **Bug ID:** [BUG_IDENTIFIER]
    **Severity:** [SEVERITY_LEVEL]
  </header>
  
  <summary>
    ## Executive Summary
    - Brief bug description
    - Impact assessment
    - Reproduction status
    - Recommended next steps
  </summary>
  
  <details>
    ## Detailed Findings
    
    ### Bug Description
    [Full description and symptoms]
    
    ### Reproduction Steps
    [Exact steps if reproducible]
    
    ### Environmental Factors
    [Relevant environment details]
    
    ### Code Analysis
    [Affected components and analysis]
    
    ### Root Cause Hypotheses
    1. [Primary hypothesis]
    2. [Alternative hypotheses]
    
    ### Supporting Evidence
    [Data, logs, traces supporting hypotheses]
  </details>
  
  <recommendations>
    ## Recommendations
    
    ### Immediate Actions
    - Workarounds available
    - Risk mitigation steps
    - Monitoring requirements
    
    ### Fix Approach
    - Suggested solution strategy
    - Estimated effort
    - Testing requirements
    - Potential risks
    
    ### Prevention
    - How to prevent similar issues
    - Testing improvements needed
    - Code quality enhancements
  </recommendations>
</report_structure>

<instructions>
  ACTION: Use file-creator subagent
  REQUEST: "Create investigation report at .agent-os/debugging/investigations/[TIMESTAMP]-[BUG_NAME].md
            Include all findings, hypotheses, and recommendations"
  ENSURE: Report is comprehensive and actionable
  PROVIDE: Clear next steps for fixing
</instructions>

</step>

<step number="7" name="stakeholder_communication">

### Step 7: Stakeholder Communication

Prepare and deliver investigation findings to relevant stakeholders.

<communication_prep>
  <audience_specific>
    <for_developers>
      - Technical details
      - Code locations
      - Fix suggestions
      - Testing approach
    </for_developers>
    
    <for_users>
      - Impact summary
      - Workarounds
      - Timeline expectations
      - Status updates
    </for_users>
    
    <for_management>
      - Business impact
      - Resource needs
      - Risk assessment
      - Priority recommendation
    </for_management>
  </audience_specific>
</communication_prep>

<deliverables>
  <investigation_summary>
    - Key findings
    - Reproduction status
    - Root cause hypothesis
    - Next steps
  </investigation_summary>
  
  <technical_details>
    - Full investigation report
    - Code analysis results
    - Test scenarios
    - Fix recommendations
  </technical_details>
</deliverables>

<instructions>
  ACTION: Prepare stakeholder communication
  SUMMARIZE: Key findings appropriately
  PROVIDE: Investigation report location
  RECOMMEND: Priority and next steps
</instructions>

</step>

</process_flow>

<post_flight_check>
  EXECUTE: @.agent-os/instructions/meta/post-flight.md
</post_flight_check>

<investigation_best_practices>

## Investigation Best Practices

### Thorough Documentation
- Document everything, even failed attempts
- Include timestamps and versions
- Capture exact error messages
- Save relevant logs and traces

### Systematic Approach
- Start broad, then narrow focus
- Test one variable at a time
- Verify assumptions explicitly
- Consider multiple hypotheses

### Avoid Premature Conclusions
- Gather sufficient evidence
- Test alternative explanations
- Consider coincidental correlations
- Validate findings independently

### Communication
- Regular status updates
- Clear, jargon-free summaries
- Actionable recommendations
- Realistic timelines

</investigation_best_practices>