# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- App Framework: Ruby on Rails 8.0+
- Language: Ruby 3.2+
- Primary Database: PostgreSQL 17+
- ORM: Active Record
- JavaScript Framework: React latest stable
- Build Tool: Vite
- Import Strategy: Node.js modules
- Package Manager: npm
- Node Version: 22 LTS
- CSS Framework: TailwindCSS 4.0+
- UI Components: Instrumental Components latest
- UI Installation: Via development gems group
- Font Provider: Google Fonts
- Font Loading: Self-hosted for performance
- Icons: Lucide React components
- Application Hosting: Digital Ocean App Platform/Droplets
- Hosting Region: Primary region based on user base
- Database Hosting: Digital Ocean Managed PostgreSQL
- Database Backups: Daily automated
- Asset Storage: Amazon S3
- CDN: CloudFront
- Asset Access: Private with signed URLs
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to main/staging branches
- Tests: Run before deployment
- Production Environment: main branch
- Staging Environment: staging branch

## Language-Specific Stacks

### TypeScript Projects

When TypeScript is detected or specified, Agent OS uses an optimized stack selected based on project requirements:

- **Default**: Modern TypeScript stack with React, Hono.js, PostgreSQL, and Dokploy
- **MERN**: MongoDB, Express.js, React, Node.js
- **MEAN**: MongoDB, Express.js, Angular, Node.js

See [TypeScript Plugin](../plugins/typescript/README.md) for detailed stack specifications.

#### Why the Default TypeScript Stack?

The default TypeScript stack is optimized for AI-assisted development:

- **Claude Code Compatibility**: React + TypeScript has the most proven success stories with Claude Code
- **Cross-Platform Needs**: Quasar's unified approach aligns with Agent OS's multi-platform goals
- **Type Safety**: Full TypeScript coverage improves AI code generation accuracy
- **Modern Performance**: Hono.js provides Express-like simplicity with better performance
- **Self-Hosted Deployment**: Dokploy offers PaaS convenience without vendor lock-in
