# TypeScript Tech Stack

## Context

Global tech stack defaults for Agent OS TypeScript projects, that will influence project-specific `.agent-os/product/tech-stack.md`.

## Stack Selection Logic

The TypeScript plugin automatically selects the appropriate stack based on project requirements:

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

## Core Technologies (Default Stack)

### Frontend & UI
- **Language**: TypeScript 5.0+
- **Frontend Framework**: React 18+
- **UI Components**: Quasar Framework (Vue-compatible components)
- **State Management**: Zustand or React Context
- **Build Tool**: Vite 5+

### Backend & API
- **Runtime**: Node.js 20 LTS
- **Backend Framework**: Hono.js 4.0+
- **API Design**: RESTful with OpenAPI documentation
- **Validation**: Zod for runtime type validation

### Database & ORM
- **Database**: PostgreSQL 16+
- **ORM**: Drizzle ORM
- **Migrations**: Drizzle Kit
- **Connection Pooling**: Built-in with Drizzle

### Authentication & Security
- **Auth Solution**: Better Auth
- **Session Management**: JWT with refresh tokens
- **Password Hashing**: Argon2
- **CORS**: Configured for production

### Development Tools
- **Package Manager**: pnpm (preferred) or npm
- **Linting**: ESLint 9+ with TypeScript plugin
- **Formatting**: Prettier 3+
- **Type Checking**: TypeScript strict mode
- **Testing**: Vitest for unit tests, Playwright for E2E

### Deployment & Infrastructure
- **Platform**: Dokploy (self-hosted PaaS)
- **Container**: Docker with multi-stage builds
- **CI/CD**: GitHub Actions
- **Monitoring**: Built-in Dokploy monitoring

## Why This Default Stack

This stack is optimized for Agent OS and AI-assisted development because:

1. **Claude Code Compatibility**: React + TypeScript has proven success with Claude Code for complex codebases
2. **Cross-Platform Ready**: Quasar's "single codebase for web, mobile, desktop" aligns with Agent OS flexibility
3. **Type Safety**: Full TypeScript coverage reduces AI hallucinations and improves code generation accuracy
4. **Modern Performance**: Hono.js offers Express-like simplicity with modern performance
5. **Self-Hosted Freedom**: Dokploy provides Vercel-like experience without vendor lock-in