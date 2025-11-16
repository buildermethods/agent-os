# Tech Stack Documentation Template

Use this guide when creating `agent-os/product/tech-stack.md`.

## Purpose

The tech stack document provides a comprehensive reference for all technology choices across the entire product codebase. This ensures consistency and helps developers understand the technical foundation.

## Information Sources (Priority Order)

1. **User-Provided Information** (HIGHEST PRIORITY)
   - Any tech stack details mentioned in current conversation
   - User's specific requirements or preferences
   - These ALWAYS take precedence

2. **Global User Standards**
   - `~/.claude/CLAUDE.md` - User's personal development standards
   - Look for sections on tech preferences, frameworks, tools

3. **Project Documentation**
   - `CLAUDE.md` - Project-specific instructions
   - `agents.md` - Agent-specific tech choices
   - `README.md` - Project setup and requirements
   - `package.json` / `requirements.txt` / etc. - Actual dependencies

## Document Structure

```markdown
# Tech Stack

## Frontend

### Framework
[Framework name and version]

### UI Components
- [Component library]
- [Styling approach]

### State Management
[State management solution]

### Build Tools
- [Bundler]
- [Dev server]

## Backend

### Runtime/Language
[Language and version]

### Framework
[Web framework]

### Database
- **Type:** [Database type]
- **ORM/Query Builder:** [Tool name]

### API Design
[REST, GraphQL, tRPC, etc.]

## Infrastructure

### Hosting
- **Frontend:** [Hosting service]
- **Backend:** [Hosting service]
- **Database:** [Database hosting]

### CI/CD
[Deployment pipeline tools]

## Development Tools

### Code Quality
- **Linting:** [Tool]
- **Formatting:** [Tool]
- **Type Checking:** [Tool if applicable]

### Testing
- **Unit Tests:** [Framework]
- **Integration Tests:** [Framework]
- **E2E Tests:** [Framework if applicable]

### Version Control
[Git workflow, branching strategy]

## Third-Party Services

### Authentication
[Auth provider if applicable]

### Payments
[Payment provider if applicable]

### Other Services
- [Service name]: [Purpose]
```

## Writing Tips

### Be Specific

- ✅ "Next.js 14 with App Router"
- ❌ "Next.js"

### Include Versions

- ✅ "Python 3.12+"
- ❌ "Python"

### Explain Non-Standard Choices

If deviating from user's usual stack, briefly explain why:

```markdown
### Database
**PostgreSQL 16** - Chosen for advanced JSON support and full-text search requirements
```

### Keep It Current

Document what will be used, not possibilities:

- ✅ "Tailwind CSS for styling"
- ❌ "Tailwind CSS or styled-components"

## Example Tech Stack Document

```markdown
# Tech Stack

## Frontend

### Framework
Next.js 14 (App Router)

### UI Components
- shadcn/ui component library
- Tailwind CSS for styling
- Radix UI primitives

### State Management
React Context + Hooks for global state

### Build Tools
- Next.js built-in bundler (Turbopack)
- TypeScript for type safety

## Backend

### Runtime/Language
Node.js 20+ with TypeScript

### Framework
Next.js API Routes (App Router)

### Database
- **Type:** PostgreSQL 16
- **ORM:** Prisma

### API Design
RESTful API with TypeScript types shared between frontend/backend

## Infrastructure

### Hosting
- **Full Stack:** Vercel
- **Database:** Vercel Postgres

### CI/CD
- GitHub Actions for testing
- Vercel automatic deployments

## Development Tools

### Code Quality
- **Linting:** ESLint
- **Formatting:** Prettier
- **Type Checking:** TypeScript strict mode

### Testing
- **Unit Tests:** Vitest
- **Integration Tests:** Vitest + Supertest
- **E2E Tests:** Playwright

### Version Control
Git with feature branch workflow (main branch protected)

## Third-Party Services

### Authentication
Clerk (social auth + email/password)

### Email
Resend (transactional emails)
```

## Common Patterns

### Full-Stack JavaScript/TypeScript

- Next.js (frontend + API routes)
- TypeScript throughout
- PostgreSQL with Prisma
- Deployed to Vercel

### Python Backend + React Frontend

- FastAPI or Django (backend)
- React with Vite (frontend)
- PostgreSQL with SQLAlchemy
- Docker for deployment

### Serverless/Edge

- Next.js App Router
- Vercel Edge Functions
- Vercel KV or PostgreSQL
- No traditional backend server

## Validation Checklist

Before finalizing tech-stack.md:

- [ ] All major categories covered (Frontend, Backend, Infrastructure, Dev Tools)
- [ ] Versions specified where relevant
- [ ] Choices align with user's standards (or deviations explained)
- [ ] User-provided preferences incorporated
- [ ] Non-standard choices justified
- [ ] Document is specific, not vague
- [ ] Testing strategy documented
- [ ] CI/CD approach specified
