# Development Best Practices

## Context

Global development guidelines for Agent OS projects.

<conditional-block context-check="core-principles">
IF this Core Principles section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Core Principles already in context"
ELSE:
  READ: The following principles

## Core Principles

### Keep It Simple
- Implement code in the fewest lines possible
- Avoid over-engineering solutions
- Choose straightforward approaches over clever ones

### Optimize for Readability
- Prioritize code clarity over micro-optimizations
- Write self-documenting code with clear variable names
- Add comments for "why" not "what"

### DRY (Don't Repeat Yourself)
- Extract repeated business logic to private methods
- Extract repeated UI markup to reusable components
- Create utility functions for common operations

### File Structure
- Keep files focused on a single responsibility
- Group related functionality together
- Use consistent naming conventions
</conditional-block>

<conditional-block context-check="dependencies" task-condition="choosing-external-library">
IF current task involves choosing an external library:
  IF Dependencies section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Dependencies guidelines already in context"
  ELSE:
    READ: The following guidelines
ELSE:
  SKIP: Dependencies section not relevant to current task

## Dependencies

### Choose Libraries Wisely
When adding third-party dependencies:
- Select the most popular and actively maintained option
- Check the library's GitHub repository for:
  - Recent commits (within last 6 months)
  - Active issue resolution
  - Number of stars/downloads
  - Clear documentation
</conditional-block>

<conditional-block context-check="spec-awareness" task-condition="implementing-from-spec">
IF current task involves implementing from specifications:
  IF Specification Awareness section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Specification Awareness guidelines already in context"
  ELSE:
    READ: The following spec-driven practices

## Specification Awareness Practices

### Spec-First Development
- Always identify and load relevant specifications before coding
- Map each implementation decision to specific specification requirements
- Reference spec sections in code comments (e.g., `// Implements: auth-spec.md:2.1`)
- Validate implementation against specification constraints during development

### Specification Compliance
- Include specification references in error messages and validation
- Test edge cases and requirements explicitly defined in specifications
- Document any deviations from specifications with justification
- Use spec-defined data structures, interfaces, and contracts exactly as specified

### Requirement Traceability  
- Maintain clear mapping between code and specification requirements
- Update specifications when requirements change during implementation
- Ensure all specified functionality is implemented and tested
- Review spec compliance before marking tasks complete
</conditional-block>

<conditional-block context-check="codebase-references" task-condition="using-existing-code">
IF current task involves using existing codebase functions or patterns:
  IF Codebase Reference section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Codebase Reference guidelines already in context"  
  ELSE:
    READ: The following reference-aware practices

## Codebase Reference Practices

### Anti-Hallucination Development
- Always check functions.md for existing function signatures before creating new ones
- Verify import paths in imports.md before importing modules
- Use exact function names and signatures from codebase references  
- Confirm API contracts match existing patterns in schemas.md

### Reference-Driven Implementation
- Load relevant codebase sections using context-fetcher before implementation
- Follow established patterns and conventions from existing codebase
- Reuse existing utilities instead of duplicating functionality
- Maintain consistency with existing error handling and validation patterns

### Codebase Integration
- Update codebase references (functions.md, imports.md) when adding new code
- Verify integration points work with existing system architecture
- Test interactions with existing functions and modules
- Document new functions using established reference documentation patterns
</conditional-block>
