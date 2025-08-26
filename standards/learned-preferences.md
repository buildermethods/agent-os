# Learned Preferences & Dynamic Standards

## Context

Adaptive standards layer that personalizes Agent OS behavior based on individual user preferences and successful patterns learned over time.

## Overview

This document defines how Agent OS learns from user decisions and adapts its standards and recommendations to match individual coding patterns, architectural choices, and workflow preferences. The system builds on top of base standards while allowing personalization without losing the structured benefits of the Agent OS framework.

---

## Learning-Based Standards Architecture

### Layered Standards System
```yaml
Standards Hierarchy (applied in order):
  1. Base Agent OS Standards (foundation)
  2. Team/Project Standards (shared agreements) 
  3. Learned User Preferences (individual adaptations)
  4. Session Overrides (temporary adjustments)

Conflict Resolution:
  - Higher layers override lower layers
  - User can manually override any learned preference
  - Confidence levels determine application strength
  - Team standards take precedence in collaborative settings
```

### Learning Confidence Levels
```yaml
Confidence Thresholds:
  0.0-0.3: Uncertain (collect more data, no application)
  0.3-0.6: Emerging (suggest occasionally, low confidence)
  0.6-0.8: Confident (apply regularly, allow easy override)
  0.8-1.0: Strong (apply by default, rare override prompts)

Application Strategy:
  - Low confidence: Ask before applying
  - Medium confidence: Apply with notification
  - High confidence: Apply silently with opt-out option
```

---

## Code Style Learning

### Syntax Preferences
```yaml
Indentation Learning:
  pattern: "user_overrides_default_2_spaces_to_4_spaces"
  observations: 23
  consistency: 0.96
  confidence: 0.92
  
  learned_rule:
    default_indentation: "4_spaces"
    override_probability: 0.04
    
  application:
    - Auto-apply in new files
    - Suggest in spec generation
    - Include in project templates

Quote Style Learning:
  pattern: "prefers_single_quotes_for_strings"
  observations: 156
  consistency: 0.91
  confidence: 0.89
  
  learned_rule:
    string_quotes: "single"
    exception_cases: ["html_attributes", "json_data"]
    
  application:
    - Update personal code-style.md
    - Apply in generated code examples
    - Include in linting configurations
```

### Naming Convention Patterns
```yaml
Variable Naming:
  pattern: "consistent_camelCase_for_variables"
  observations: 89
  consistency: 0.94
  confidence: 0.91
  
Function Naming:
  pattern: "descriptive_verb_noun_functions"
  observations: 67
  consistency: 0.87
  confidence: 0.84
  
Component Naming:
  pattern: "PascalCase_with_Component_suffix"
  observations: 34
  consistency: 0.88
  confidence: 0.85
```

---

## Architectural Preference Learning

### Framework and Library Choices
```yaml
React Patterns:
  learned_preferences:
    component_type: "functional_with_hooks" (confidence: 0.94)
    state_management: "context_api_over_redux" (confidence: 0.78)
    styling_approach: "styled_components" (confidence: 0.82)
    testing_library: "react_testing_library" (confidence: 0.91)
    
  decision_history:
    - "chose functional over class components in 28/30 recent implementations"
    - "selected Context API in 15/19 state management decisions"
    - "used styled-components in 18/22 styling decisions"

Database Preferences:
  learned_preferences:
    orm_choice: "prisma_over_sequelize" (confidence: 0.86)
    migration_strategy: "incremental_with_rollback" (confidence: 0.79)
    indexing_approach: "proactive_for_queries" (confidence: 0.92)
    
API Design Patterns:
  learned_preferences:
    style: "RESTful_with_openapi" (confidence: 0.88)
    error_handling: "comprehensive_with_codes" (confidence: 0.94)
    validation: "request_response_validation" (confidence: 0.91)
    authentication: "JWT_with_refresh_tokens" (confidence: 0.89)
```

### Quality Standards Adaptation
```yaml
Testing Preferences:
  learned_standards:
    coverage_target: 85 # (increased from default 80% based on user pattern)
    test_style: "behavior_driven" # (learned from consistent describe/it usage)
    integration_tests: true # (user adds in 90% of features)
    e2e_testing: "critical_paths_only" # (selective approach pattern)
    
Documentation Standards:
  learned_standards:
    api_documentation: "comprehensive" # (user always adds detailed docs)
    code_comments: "business_logic_focused" # (avoids obvious comments)
    readme_sections: ["setup", "architecture", "deployment"] # (consistent additions)
    changelog_detail: "technical_and_user_facing" # (dual audience approach)
```

---

## Workflow Preference Personalization

### Spec Creation Patterns
```yaml
Detail Level Preferences:
  learned_pattern: "comprehensive_upfront_specs"
  confidence: 0.87
  evidence:
    - User expands 78% of minimal generated specs
    - Adds technical details in 91% of spec reviews
    - Includes edge cases in 85% of acceptance criteria
    
  adaptation:
    - Smart spec generator defaults to detailed mode
    - Include technical implementation sections by default
    - Add comprehensive error handling scenarios
    - Generate detailed task breakdowns

Section Focus Areas:
  most_important_sections:
    1. "technical_requirements" (modified in 94% of specs)
    2. "user_stories" (detailed in 89% of specs)  
    3. "acceptance_criteria" (expanded in 91% of specs)
    4. "api_specifications" (added to 78% of relevant specs)
    
  least_important_sections:
    1. "out_of_scope" (skipped in 67% of specs)
    2. "future_considerations" (minimal detail in 72% of specs)
```

### Implementation Workflow Patterns
```yaml
Development Approach:
  learned_pattern: "test_first_with_incremental_implementation"
  confidence: 0.82
  
  workflow_sequence:
    1. Write comprehensive tests (95% of implementations)
    2. Implement core functionality (100%)
    3. Add error handling (91% of implementations)
    4. Performance optimization (78% when needed)
    5. Documentation update (88% of implementations)
    
Task Management Style:
  learned_pattern: "detailed_subtasks_with_acceptance_criteria"
  confidence: 0.86
  
  preferences:
    - Break large tasks into 2-4 hour chunks
    - Include specific acceptance criteria for each subtask
    - Add dependencies and blockers explicitly
    - Track technical debt items separately
```

---

## Team Collaboration Adaptations

### Shared vs Personal Preferences
```yaml
Team Consensus Areas:
  - code_style: "team_eslint_config" (override personal preferences)
  - git_workflow: "feature_branches_with_reviews" (team standard)
  - testing_approach: "jest_framework" (team decision)
  - deployment_process: "ci_cd_with_staging" (shared infrastructure)

Personal Preference Areas:
  - spec_detail_level: "comprehensive" (personal style)
  - documentation_approach: "technical_focused" (individual strength)
  - refactoring_frequency: "proactive" (personal standard)
  - error_handling_depth: "comprehensive" (personal quality bar)

Conflict Resolution Examples:
```
🤝 Team vs Personal Preference Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Analysis:
- Your preference: 4-space indentation (confidence: 92%)
- Team standard: 2-space indentation (eslint config)

💡 Recommendation:
Apply team standard for shared code, maintain personal preference for:
- Personal projects and prototypes
- Documentation and spec files
- Local development environment settings

→ Update your profile to respect team standards in collaborative contexts? (y/n)
```

### Learning from Team Patterns
```yaml
Successful Team Patterns:
  pattern: "pair_programming_for_complex_features"
  team_adoption: 0.75
  success_rate: 0.91
  user_participation: 0.68
  
  learned_insight:
    "Complex features (>5 tasks) have 34% higher success rate with pair programming"
    
  personal_adaptation:
    - Suggest pairing for features with >5 implementation tasks
    - Prefer pairing for unfamiliar technology implementations
    - Request pairing for architecture-level decisions
```

---

## Dynamic Standards Application

### Real-Time Personalization
```yaml
Spec Generation Customization:
  - Apply learned architectural preferences automatically
  - Adjust detail level based on user's historical modifications
  - Include user's typical quality standards
  - Suggest technologies from user's successful pattern library

Code Creation Guidance:
  - Apply personal code style preferences
  - Suggest architectural patterns user has success with
  - Include error handling approaches user consistently uses
  - Recommend testing strategies aligned with user's quality bar

Workflow Optimization:
  - Suggest task breakdown matching user's preferred granularity
  - Recommend implementation sequence based on user's successful patterns
  - Apply user's preferred documentation and review approaches
```

### Adaptive Learning Feedback
```yaml
Learning Effectiveness Tracking:
  - Monitor acceptance rate of personalized suggestions
  - Track implementation success rate with learned preferences
  - Measure time savings from applied personalizations
  - Collect user satisfaction feedback on adaptations

Continuous Improvement:
  - Refine confidence thresholds based on prediction accuracy
  - Update learning algorithms based on user behavior changes
  - Expand pattern recognition for new preference categories
  - Improve team vs individual preference balance
```

---

## Standards Evolution Examples

### Personal Standards File Generation
```yaml
# Example: Auto-generated personal code-style.md additions

## Personal Code Style Preferences (Learned)
*Auto-generated from 6 months of coding patterns*

### Confirmed Preferences (High Confidence)
- **Indentation**: 4 spaces (96% consistency, overrides default)
- **String Quotes**: Single quotes (91% consistency)  
- **Function Style**: Arrow functions for callbacks (94% consistency)
- **Import Organization**: Named imports preferred (87% consistency)

### Emerging Patterns (Medium Confidence)  
- **Error Handling**: Comprehensive try-catch blocks (78% of implementations)
- **TypeScript Usage**: Interfaces over types (71% preference)
- **Component Structure**: Custom hooks for business logic (73% of components)

### Quality Standards
- **Test Coverage**: Personal target 85% (increased from 80% default)
- **Documentation**: Focus on business logic and edge cases
- **Code Review**: Emphasize architecture and performance implications
```

### Project-Specific Adaptations
```yaml
# Example: E-commerce project learned adaptations

## E-commerce Domain Patterns (Project-Specific Learning)
*Based on successful implementations in similar projects*

### Architectural Decisions
- **State Management**: Redux for product catalog, Context for user state
- **Payment Processing**: Stripe integration with webhook validation
- **Inventory Tracking**: Real-time updates with optimistic UI
- **User Authentication**: Social login + email with 2FA for admin

### Quality Additions
- **Security Testing**: Include payment security tests in all financial features
- **Performance**: Add caching for product queries (learned from past bottlenecks)
- **Analytics**: Include conversion tracking in all user-facing features
- **Monitoring**: Add business metric tracking for commerce operations
```

---

## Privacy and Control Mechanisms

### User Control Over Learning
```yaml
Granular Learning Controls:
  - Enable/disable learning for specific categories
  - Set confidence thresholds for automatic application
  - Review and modify learned preferences manually
  - Export personal standards for backup/sharing

Data Transparency:
  - Show exactly what patterns have been learned
  - Explain confidence levels and evidence for each preference
  - Provide history of when and why standards were adapted
  - Allow inspection of decision-making data
```

### Learning Data Management
```yaml
Local Storage Structure:
  .agent-os/learning/
  ├── user-preferences.json          # Core preference profiles
  ├── decision-history/              # Chronological decision tracking
  │   ├── 2024-01-spec-decisions.json
  │   ├── 2024-01-code-decisions.json
  │   └── 2024-01-workflow-decisions.json
  ├── pattern-library/               # Personal successful patterns
  │   ├── react-component-patterns.json
  │   ├── api-design-patterns.json
  │   └── testing-strategy-patterns.json
  └── team-insights/                 # Collaborative learning data
      ├── shared-standards.json
      └── team-success-patterns.json

Data Retention:
  - Automatic cleanup of decision data older than 1 year
  - Compress historical data while preserving learned patterns
  - User-controlled data export and deletion
  - Privacy-first approach with no external data transmission
```

---

## Integration with Agent Ecosystem

### Standards Application Points
```yaml
Smart Spec Generator Integration:
  - Apply learned architectural preferences to generated specs
  - Use personal quality standards for acceptance criteria
  - Include user's preferred tech stack in implementation suggestions
  - Customize spec detail level based on user's modification patterns

Context Intelligence Integration:
  - Use learned preferences to improve context optimization
  - Apply personal coding patterns to context prioritization
  - Customize optimization suggestions based on user's acceptance patterns

Project Manager Integration:
  - Include learned workflow preferences in task breakdown
  - Apply personal quality standards to completion criteria
  - Use successful pattern library for implementation suggestions
  - Customize recap generation based on user's focus areas
```

This dynamic standards system ensures that Agent OS becomes increasingly personalized while maintaining its structured approach and team collaboration benefits. The learning system respects user privacy, provides full transparency and control, and continuously improves the development experience through adaptive intelligence.