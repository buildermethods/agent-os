---
description: Wheels Framework Intelligent Context Dispatcher
version: 1.0
encoding: UTF-8
---

# Wheels Framework Context Dispatcher

This document serves as an intelligent dispatcher for loading appropriate Wheels framework context based on the task at hand. It uses conditional blocks to provide targeted information, reducing token usage while maintaining comprehensive assistance.

## Context Loading Strategy

The dispatcher analyzes user requests and loads only relevant documentation sections, following this priority:

1. **Immediate Task Context** - Load only what's needed for the current task
2. **Related Context** - Include closely related patterns if helpful
3. **Reference Context** - Add reference documentation when needed
4. **Complete Context** - Load everything only for comprehensive reviews

## Conditional Loading Blocks

### IF: User is working with Routes or URLs
```
LOAD:
- patterns/routing-patterns.md (FULL)
- framework-architecture.md (SECTIONS: "Framework Request Lifecycle", "Component Dependency Map")
- reference/configuration-guide.md (SECTION: "Routes Configuration")
```

### IF: User is creating/editing Models
```
LOAD:
- patterns/code-patterns.md (SECTIONS: "Model Patterns", "Repository Pattern", "Service Layer")
- patterns/migration-patterns.md (RELATED to model changes)
- framework-architecture.md (SECTION: "Model Methods")
- patterns/testing-patterns.md (SECTION: "Model Testing")
```

### IF: User is working with Controllers
```
LOAD:
- patterns/code-patterns.md (SECTIONS: "Controller Patterns", "Service Layer")
- patterns/routing-patterns.md (SECTION: "RESTful Controllers")
- framework-architecture.md (SECTION: "Controller Methods")
- patterns/api-patterns.md (IF: API controller)
```

### IF: User is working with Views
```
LOAD:
- patterns/view-patterns.md (FULL)
- framework-architecture.md (SECTION: "View rendering")
- patterns/code-patterns.md (SECTION: "View Helpers")
```

### IF: User is implementing Authentication
```
LOAD:
- patterns/authentication-patterns.md (FULL)
- patterns/code-patterns.md (SECTIONS: "Security Patterns", "Session Management")
- reference/configuration-guide.md (SECTION: "Security Settings")
```

### IF: User is building an API
```
LOAD:
- patterns/api-patterns.md (FULL)
- patterns/authentication-patterns.md (SECTIONS: "JWT Authentication", "API Key Authentication")
- patterns/routing-patterns.md (SECTION: "API Versioning")
- reference/configuration-guide.md (SECTION: "API Configuration")
```

### IF: User is writing Tests
```
LOAD:
- patterns/testing-patterns.md (FULL)
- reference/cli-reference.md (SECTION: "Testing Commands")
- framework-architecture.md (SECTION: "Testing Infrastructure")
```

### IF: User is running Migrations
```
LOAD:
- patterns/migration-patterns.md (FULL)
- reference/cli-reference.md (SECTION: "Migration Commands")
- reference/troubleshooting-guide.md (SECTION: "Migration Issues")
```

### IF: User is using CLI Commands
```
LOAD:
- reference/cli-reference.md (RELEVANT SECTIONS)
- reference/troubleshooting-guide.md (IF: command errors)
```

### IF: User is configuring the Application
```
LOAD:
- reference/configuration-guide.md (FULL)
- framework-architecture.md (SECTION: "Environment Variables")
```

### IF: User encounters Errors
```
LOAD:
- reference/error-catalog.md (SEARCH for error type)
- reference/troubleshooting-guide.md (RELEVANT SECTION)
- patterns/code-patterns.md (SECTION: "Error Handling")
```

### IF: User is optimizing Performance
```
LOAD:
- patterns/code-patterns.md (SECTIONS: "Caching Patterns", "Query Optimization")
- framework-architecture.md (SECTION: "Performance Considerations")
- reference/cli-reference.md (SECTION: "Performance Commands")
```

### IF: User is deploying to Production
```
LOAD:
- reference/cli-reference.md (SECTIONS: "Deployment Commands", "Environment Management")
- reference/configuration-guide.md (SECTION: "Production Configuration")
- framework-architecture.md (SECTION: "Deployment Features")
```

## Smart Context Rules

### Rule 1: Minimal Loading
Start with the smallest context that answers the question. Expand only if needed.

### Rule 2: Pattern Recognition
Detect patterns in user requests:
- CRUD operations → Load scaffold patterns
- Database work → Load migration patterns
- Frontend work → Load view patterns
- Security concerns → Load authentication patterns

### Rule 3: Progressive Enhancement
Begin with basic patterns, add advanced patterns only when complexity increases:
```
Basic Task → Core Pattern → Advanced Pattern → Architecture Context
```

### Rule 4: Cross-Reference Intelligence
When loading one context, check for required dependencies:
- Models often need Migrations
- Controllers often need Routes
- APIs need Authentication
- Tests need Models/Controllers

### Rule 5: Version Awareness
Detect Wheels version mentions and prioritize:
- "Wheels 3.0" → Load new features and changes
- "Legacy" or "2.x" → Include migration guides
- "BoxLang" → Load BoxLang-specific information

## Context Loading Examples

### Example 1: "How do I create a user login system?"
```
PRIMARY LOAD:
- patterns/authentication-patterns.md (SECTIONS: "Session-based Authentication", "User Model")
- patterns/migration-patterns.md (SECTION: "User Tables")

SECONDARY LOAD (if needed):
- patterns/view-patterns.md (SECTION: "Form Helpers")
- patterns/routing-patterns.md (SECTION: "Authentication Routes")
```

### Example 2: "Generate a scaffold for products"
```
PRIMARY LOAD:
- reference/cli-reference.md (SECTION: "wheels g scaffold")
- patterns/code-patterns.md (SECTION: "Scaffold Patterns")

SECONDARY LOAD (if customization needed):
- patterns/migration-patterns.md
- patterns/view-patterns.md
```

### Example 3: "My migration is failing"
```
PRIMARY LOAD:
- reference/troubleshooting-guide.md (SECTION: "Migration Issues")
- reference/error-catalog.md (SEARCH: migration errors)

SECONDARY LOAD (if needed):
- patterns/migration-patterns.md (SECTION: "Troubleshooting")
- reference/cli-reference.md (SECTION: "Migration debugging")
```

## Optimization Strategies

### Token Reduction Techniques

1. **Section Extraction**: Load only specific sections instead of full documents
2. **Keyword Matching**: Use grep/search to find relevant portions
3. **Hierarchical Loading**: Start with summaries, expand to details
4. **Caching Context**: Remember loaded context within conversation

### Response Optimization

1. **Direct Answers**: Provide code examples immediately
2. **Progressive Disclosure**: Show simple solution first, complex if needed
3. **Reference Links**: Point to sections rather than loading everything
4. **Pattern Matching**: Recognize similar requests and reuse context

## Integration with AI Assistants

### For Claude/ChatGPT/Copilot

When an AI assistant accesses this dispatcher:

1. **Parse the user's request** to identify task type
2. **Match against conditional blocks** to determine context needs
3. **Load only specified sections** using the loading instructions
4. **Provide targeted assistance** with minimal token usage
5. **Expand context progressively** if initial response insufficient

### Context Priority Matrix

| Task Type | Primary Context | Secondary Context | Reference Context |
|-----------|----------------|-------------------|-------------------|
| Routes | routing-patterns | framework-architecture | configuration-guide |
| Models | code-patterns, migrations | testing-patterns | cli-reference |
| Controllers | code-patterns, routes | api-patterns | framework-architecture |
| Views | view-patterns | code-patterns | - |
| Authentication | authentication-patterns | code-patterns | configuration-guide |
| API Development | api-patterns | authentication-patterns | routing-patterns |
| Testing | testing-patterns | code-patterns | cli-reference |
| Migrations | migration-patterns | cli-reference | troubleshooting-guide |
| Deployment | cli-reference | configuration-guide | framework-architecture |
| Debugging | error-catalog | troubleshooting-guide | code-patterns |

## Dynamic Context Assembly

### Step 1: Intent Classification
```
User Input → Intent Classifier → Task Category
```

### Step 2: Context Selection
```
Task Category → Conditional Block → Document List
```

### Step 3: Section Extraction
```
Document List → Section Filter → Relevant Content
```

### Step 4: Response Generation
```
Relevant Content → AI Processing → Targeted Response
```

## Continuous Improvement

This dispatcher should be updated when:

1. **New patterns emerge** from common user requests
2. **Documentation structure changes** in the framework
3. **Performance metrics** show inefficient loading patterns
4. **User feedback** indicates missing or excessive context

## Usage Instructions for AI Systems

1. **Always consult this dispatcher first** when handling Wheels framework requests
2. **Load context progressively** - start minimal, expand as needed
3. **Track loaded context** to avoid redundant loading
4. **Measure token usage** and optimize loading patterns
5. **Update loading rules** based on effectiveness

## Metadata for AI Training

```json
{
  "framework": "CFWheels",
  "version": "3.0",
  "dispatcher_version": "1.0",
  "optimization_goal": "minimal_token_usage",
  "context_strategy": "progressive_loading",
  "update_frequency": "quarterly",
  "effectiveness_metric": "tokens_per_resolution"
}
```

This dispatcher ensures efficient, targeted assistance for Wheels framework development while minimizing token usage and maximizing relevance.