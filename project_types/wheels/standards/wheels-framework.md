---
description: Wheels Framework Development Standards and Documentation
version: 1.0
encoding: UTF-8
---

# Wheels Framework Development Standards

This dispatcher provides conditional loading of Wheels framework documentation based on task requirements.

## Context

Comprehensive documentation for developing applications with the Wheels.dev framework, including architecture, patterns, examples, and reference materials.

<conditional-block context-check="wheels-architecture">
IF framework-architecture.md already in context:
  SKIP: Framework architecture already loaded
  NOTE: "Using Wheels architecture documentation already in context"
ELSE IF task involves Wheels framework development:
  <context_fetcher_strategy>
    IF current agent is Claude Code AND context-fetcher agent exists:
      USE: @agent:context-fetcher
      REQUEST: "Get Wheels framework architecture from wheels-framework/framework-architecture.md"
      PROCESS: Returned architecture documentation
    ELSE:
      READ: @~/.agent-os/standards/wheels-framework/framework-architecture.md
  </context_fetcher_strategy>
ELSE:
  SKIP: Wheels architecture not needed for current task
</conditional-block>

<conditional-block task-condition="wheels-cli" context-check="cli-reference">
IF current task involves Wheels CLI commands OR CommandBox operations:
  IF cli-reference.md already in context:
    SKIP: CLI reference already loaded
    NOTE: "Using Wheels CLI reference already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Wheels CLI command reference from wheels-framework/reference/cli-reference.md"
        PROCESS: Returned CLI documentation
      ELSE:
        READ: @~/.agent-os/standards/wheels-framework/reference/cli-reference.md
    </context_fetcher_strategy>
ELSE:
  SKIP: CLI reference not relevant to current task
</conditional-block>

<conditional-block task-condition="wheels-patterns" context-check="code-patterns">
IF current task involves implementing Wheels controllers, models, or views:
  IF code-patterns.md already in context:
    SKIP: Code patterns already loaded
    NOTE: "Using Wheels code patterns already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Wheels code patterns from wheels-framework/patterns/code-patterns.md"
        PROCESS: Returned pattern documentation
      ELSE:
        READ: @~/.agent-os/standards/wheels-framework/patterns/code-patterns.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Code patterns not relevant to current task
</conditional-block>

<conditional-block task-condition="wheels-migrations" context-check="migration-patterns">
IF current task involves database migrations OR schema changes:
  IF migration-patterns.md already in context:
    SKIP: Migration patterns already loaded
    NOTE: "Using Wheels migration patterns already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Wheels migration patterns from wheels-framework/patterns/migration-patterns.md"
        PROCESS: Returned migration documentation
      ELSE:
        READ: @~/.agent-os/standards/wheels-framework/patterns/migration-patterns.md
    </context_fetcher_strategy>
    
    ### Critical Migration Rules:
    - ALWAYS use CLI to generate migrations: `wheels g migration MigrationName`
    - NEVER manually create migration files
    - Run migrations with: `wheels dbmigrate latest`
    - Rollback with: `wheels dbmigrate down`
ELSE:
  SKIP: Migration patterns not relevant to current task
</conditional-block>

<conditional-block task-condition="wheels-testing" context-check="testing-patterns">
IF current task involves writing tests OR TestBox OR test configuration:
  IF testing-patterns.md already in context:
    SKIP: Testing patterns already loaded
    NOTE: "Using Wheels testing patterns already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Wheels testing patterns from wheels-framework/patterns/testing-patterns.md"
        PROCESS: Returned testing documentation
      ELSE:
        READ: @~/.agent-os/standards/wheels-framework/patterns/testing-patterns.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Testing patterns not relevant to current task
</conditional-block>

<conditional-block task-condition="wheels-errors" context-check="error-catalog">
IF current task involves debugging OR error resolution:
  IF error-catalog.md already in context:
    SKIP: Error catalog already loaded
    NOTE: "Using Wheels error catalog already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Wheels error catalog from wheels-framework/reference/error-catalog.md"
        PROCESS: Returned error documentation
      ELSE:
        READ: @~/.agent-os/standards/wheels-framework/reference/error-catalog.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Error catalog not relevant to current task
</conditional-block>

<conditional-block task-condition="wheels-troubleshooting" context-check="troubleshooting-guide">
IF current task involves troubleshooting OR performance issues:
  IF troubleshooting-guide.md already in context:
    SKIP: Troubleshooting guide already loaded
    NOTE: "Using Wheels troubleshooting guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Wheels troubleshooting guide from wheels-framework/reference/troubleshooting-guide.md"
        PROCESS: Returned troubleshooting documentation
      ELSE:
        READ: @~/.agent-os/standards/wheels-framework/reference/troubleshooting-guide.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Troubleshooting guide not relevant to current task
</conditional-block>

<conditional-block task-condition="wheels-examples" context-check="application-examples">
IF current task requires complete application examples OR reference implementations:
  IF application-examples.md already in context:
    SKIP: Application examples already loaded
    NOTE: "Using Wheels application examples already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Wheels application examples from wheels-framework/examples/application-examples.md"
        PROCESS: Returned example documentation
      ELSE:
        READ: @~/.agent-os/standards/wheels-framework/examples/application-examples.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Application examples not relevant to current task
</conditional-block>

## Quick Reference

### Documentation Structure
- **Architecture**: Framework internals, request lifecycle, component relationships
- **Patterns**: Reusable code patterns for controllers, models, views
- **Migrations**: Database migration best practices and patterns  
- **Testing**: TestBox testing patterns and best practices
- **CLI Reference**: Complete command reference for Wheels CLI
- **Error Catalog**: Common errors with diagnosis and solutions
- **Troubleshooting**: Problem-solving guide for development issues
- **Examples**: Complete working application examples

### Key Wheels Principles
- Convention over configuration
- RESTful by default
- Database-driven development
- Use `config()` for initialization, NOT `init()`
- Framework methods prefixed with `$` are internal, they should not be used in app code
- Always use CLI for generating code and migrations

### Common Commands
- Generate model: `wheels g model ModelName`
- Generate controller: `wheels g controller ControllerName`
- Generate scaffold: `wheels g scaffold ResourceName`
- Run migrations: `wheels dbmigrate latest`
- Run tests: `wheels test run` or `box testbox run`

## Related Standards
- CFML style guide: @~/.agent-os/standards/code-style/cfml-style.md
- CFC style guide: @~/.agent-os/standards/code-style/cfc-style.md
- Wheels style guide: @~/.agent-os/standards/code-style/wheels-style.md