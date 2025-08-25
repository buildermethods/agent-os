# Code Style Guide

## Context

Global code style rules for Agent OS projects.

<conditional-block context-check="general-formatting">
IF this General Formatting section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using General Formatting rules already in context"
ELSE:
  READ: The following formatting rules

## General Formatting

### Indentation
- Use 2 spaces for indentation (never tabs)
- Maintain consistent indentation throughout files
- Align nested structures for readability

### Naming Conventions
- **Methods and Variables**: Use snake_case (e.g., `user_profile`, `calculate_total`)
- **Classes and Modules**: Use PascalCase (e.g., `UserProfile`, `PaymentProcessor`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)

### String Formatting
- Use single quotes for strings: `'Hello World'`
- Use double quotes only when interpolation is needed
- Use template literals for multi-line strings or complex interpolation

### Code Comments
- Add brief comments above non-obvious business logic
- Document complex algorithms or calculations
- Explain the "why" behind implementation choices
- Never remove existing comments unless removing the associated code
- Update comments when modifying code to maintain accuracy
- Keep comments concise and relevant
</conditional-block>

<conditional-block task-condition="html-css-tailwind" context-check="html-css-style">
IF current task involves writing or updating HTML, CSS, or TailwindCSS:
  IF html-style.md AND css-style.md already in context:
    SKIP: Re-reading these files
    NOTE: "Using HTML/CSS style guides already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get HTML formatting rules from code-style/html-style.md"
        REQUEST: "Get CSS and TailwindCSS rules from code-style/css-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ the following style guides (only if not already in context):
        - @~/.agent-os/standards/code-style/html-style.md (if not in context)
        - @~/.agent-os/standards/code-style/css-style.md (if not in context)
    </context_fetcher_strategy>
ELSE:
  SKIP: HTML/CSS style guides not relevant to current task
</conditional-block>

<conditional-block task-condition="javascript" context-check="javascript-style">
IF current task involves writing or updating JavaScript:
  IF javascript-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using JavaScript style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get JavaScript style rules from code-style/javascript-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ: @~/.agent-os/standards/code-style/javascript-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: JavaScript style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="cfml" context-check="cfml-style">
IF current task involves writing or updating CFML (ColdFusion Markup Language):
  IF cfml-style.md AND cfc-style.md already in context:
    SKIP: Re-reading these files
    NOTE: "Using CFML/CFC style guides already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get CFML tag-based markup rules from code-style/cfml-style.md"
        REQUEST: "Get CFC script-based rules from code-style/cfc-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ the following style guides (only if not already in context):
        - @~/.agent-os/standards/code-style/cfml-style.md (for tag-based CFML views)
        - @~/.agent-os/standards/code-style/cfc-style.md (for script-based CFCs)
    </context_fetcher_strategy>
    
    ### CFML Key Principles:
    - Use tag-based syntax for views and partials (.cfm files)
    - Use script-based syntax for components (.cfc files)
    - Always encode output with encodeForHTML() in views
    - Use explicit scoping (variables., arguments., this.)
    - Follow camelCase for variables and methods
    - Use PascalCase for component names
ELSE:
  SKIP: CFML style guides not relevant to current task
</conditional-block>

<conditional-block task-condition="wheels-framework" context-check="wheels-style">
IF current task involves Wheels Framework development:
  IF wheels-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using Wheels Framework style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Wheels Framework conventions from code-style/wheels-style.md"
        PROCESS: Returned style rules including:
          - MVC patterns and conventions
          - Critical security practices (e() for output)
          - URL/form helpers (linkTo, urlFor, startFormTag)
          - Flash message patterns
          - Migration patterns
          - CLI commands
      ELSE:
        READ: @~/.agent-os/standards/code-style/wheels-style.md
    </context_fetcher_strategy>
    
    ### Wheels Framework Critical Rules:
    - ALWAYS escape HTML output with e() unless using formatters
    - Use linkTo() for complete links, urlFor() for href attributes
    - Pass flash messages as redirect parameters, not separate calls
    - Always call super.config() in controllers and models
    - Use config() method for initialization, NOT init()
    - Never use whereParams in findAll(), use where parameter
    - Configuration files are in /config (not /app/config) in Wheels 3.0
    - Add labelDataRequired="true" for required form fields
    - Use guard statements pattern (early returns) in controllers
    
    ### Comprehensive Wheels Documentation:
    For detailed Wheels framework documentation, patterns, and examples:
    READ: @~/.agent-os/standards/wheels-framework.md
    This dispatcher provides conditional loading of:
    - Framework architecture and internals
    - Code patterns for controllers, models, views
    - Database migration patterns
    - Testing patterns with TestBox
    - CLI command reference
    - Error catalog and troubleshooting
    - Complete application examples
ELSE:
  SKIP: Wheels Framework style guide not relevant to current task
</conditional-block>
