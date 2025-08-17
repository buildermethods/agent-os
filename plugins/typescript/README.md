# Agent OS TypeScript Plugin

This directory contains TypeScript-specific extensions and overrides for Agent OS, providing comprehensive support for TypeScript development with modern frameworks and conditional stack selection.

## Overview

The TypeScript plugin automatically activates when a TypeScript project is detected, providing:

- **TypeScript-specific tech stack defaults** with conditional MERN/MEAN support
- **Comprehensive TypeScript coding standards** with framework-specific patterns
- **Enhanced instruction overrides** for TypeScript development workflows
- **Seamless integration** with existing Agent OS commands

## Plugin Structure

```
plugins/typescript/
├── README.md                           # This file
├── standards/
│   └── typescript-tech-stack.md        # TypeScript technology defaults
└── instructions/
    └── core/
        └── create-spec.md              # TypeScript-enhanced spec creation
```

## Automatic Detection

The TypeScript plugin activates automatically when any of these conditions are met:

### File-based Detection
- `tsconfig.json` exists in project root
- `package.json` exists with TypeScript dependencies
- `index.ts` or `app.ts` exists in project root

### Manual Override
- "typescript" specified in `.agent-os/product/tech-stack.md`
- "MERN" or "MEAN" mentioned in project requirements

## Technology Stack

The TypeScript plugin intelligently selects the appropriate stack based on project requirements:

### Default TypeScript Stack
When TypeScript is detected without MERN/MEAN specification:

- **Frontend**: React + TypeScript
- **UI Framework**: Quasar (Vue-compatible components in React)
- **Backend**: Hono.js
- **Database**: PostgreSQL + Drizzle ORM
- **Auth**: Better Auth
- **Deployment**: Dokploy

### MERN Stack
When "MERN" is specified in project requirements:

- **Database**: MongoDB
- **Backend Framework**: Express.js
- **Frontend Library**: React
- **Runtime**: Node.js

### MEAN Stack
When "MEAN" is specified in project requirements:

- **Database**: MongoDB
- **Backend Framework**: Express.js
- **Frontend Framework**: Angular
- **Runtime**: Node.js

## Enhanced Features

### TypeScript-Specific Spec Creation
- **React component specifications** with TypeScript interfaces
- **Hono.js endpoint definitions** with type-safe routing
- **Drizzle ORM schema definitions** with TypeScript types
- **TypeScript implementation notes** section in specs
- **Framework-specific task breakdown** based on selected stack

### Coding Standards
- **2-space indentation** (follows global standard)
- **100-character line length** (TypeScript community standard)
- **Single quotes for strings** with template literals
- **Import organization**: Node → Third-party → Local → Types
- **Comprehensive patterns** for React, Hono.js, and Drizzle ORM

### Development Workflow
- **Type-Driven Development** with TypeScript strict mode
- **Component-based architecture** for React applications
- **API-first design** with Hono.js and OpenAPI
- **Type-safe database operations** with Drizzle ORM
- **Comprehensive testing** with Vitest and Playwright

## Integration with Agent OS Commands

### Enhanced Commands
When TypeScript is detected, these commands use TypeScript-specific logic:

- **`create-spec`**: Uses TypeScript plugin override with stack-specific patterns
- **`plan-product`**: References TypeScript tech stack for project planning
- **`analyze-product`**: Detects TypeScript environment and dependencies
- **`execute-tasks`**: Applies TypeScript coding standards during implementation

### Setup Scripts
The plugin works with all Agent OS setup scripts:

- **`setup-github-copilot.sh`**: VS Code with GitHub Copilot integration
- **`setup-kilocode.sh`**: KiloCode AI assistant integration  
- **`setup-cursor.sh`**: Cursor AI editor integration
- **`setup-claude-code.sh`**: Claude Code integration

## Benefits for TypeScript Developers

### Type Safety Throughout
- **End-to-end type safety**: From database to UI components
- **Compile-time error detection**: Catch bugs before runtime
- **IntelliSense support**: Full IDE autocomplete and refactoring
- **Type inference**: Minimal type annotations needed

### Modern Web Development
- **React ecosystem**: Mature component libraries and tooling
- **Quasar components**: Enterprise-ready UI components
- **Hono.js performance**: Lightweight and fast backend framework
- **PostgreSQL reliability**: Industry-standard relational database

### AI-Optimized Stack
- **Claude Code compatibility**: Proven success with React + TypeScript
- **Clear code structure**: AI tools understand the codebase better
- **Type annotations**: Reduce AI hallucinations and errors
- **Modern patterns**: Latest best practices for AI assistance

### Flexible Deployment
- **Dokploy platform**: Self-hosted PaaS with Docker support
- **GitHub Actions**: Automated CI/CD pipelines
- **Environment management**: Easy staging and production setup
- **Monitoring included**: Built-in application monitoring

## Usage Examples

### Creating a TypeScript Spec
```bash
# Agent OS automatically detects TypeScript project and uses enhanced create-spec
# Ask: "Use create-spec to create a user authentication feature"
```

### Project Planning
```bash
# TypeScript tech stack is automatically referenced
# Ask: "Use plan-product to set up a new TypeScript web application"
```

### Code Implementation
```bash
# TypeScript coding standards are automatically applied
# Ask: "Use execute-tasks to implement the dashboard components"
```

## Plugin Architecture

The TypeScript plugin follows Agent OS plugin conventions:

### Detection Logic
```
IF typescript_project_detected OR mern_mean_mentioned:
  LOAD: @plugins/typescript/standards/typescript-tech-stack.md
  OVERRIDE: @plugins/typescript/instructions/core/create-spec.md
  SELECT_STACK: Based on project requirements
ELSE:
  USE: Standard Agent OS defaults
```

### Stack Selection
- **Automatic detection**: Analyzes project requirements
- **Conditional loading**: Selects appropriate stack (Default/MERN/MEAN)
- **Non-invasive**: Doesn't affect non-TypeScript projects
- **Extensible**: Easy to add new stack variants

## Why the Default Stack?

The default TypeScript stack is specifically chosen for AI-assisted development:

1. **Claude Code Compatibility**: React + TypeScript has the most proven success stories with Claude Code, handling complex codebases and large-scale refactoring
2. **Cross-Platform Needs**: Since Agent OS needs to work with multiple AI tools and environments, Quasar's approach of "single codebase for web, mobile, desktop, and embedded" aligns perfectly
3. **Healthcare Integration**: Your background in healthcare apps benefits from React's mature ecosystem and TypeScript's safety
4. **AI Agent Orchestration**: React's component model works excellently for building complex AI workflow interfaces
5. **Modern Performance**: Hono.js provides Express-like simplicity with better performance for API development

---

**Learn more about Agent OS**: https://buildermethods.com/agent-os