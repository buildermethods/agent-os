# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- App Framework: Wheels.dev Framework 3.0 (formerly CFWheels)
- Language: Lucee CFML 6.2+
- Primary Database: PostgreSQL 17+
- ORM: Wheels based ORM
- JavaScript Framework: HTMX and Alpine.js
- Build Tool: none, standard delivery
- Package Manager: CommandBox and ForgeBox.io
- CSS Framework: TailwindCSS 4.0+
- Font Provider: Google Fonts
- Font Loading: Self-hosted for performance
- Icons: Lucide React components
- Application Hosting: Self hosted in own Datacenter
- Database Hosting: Self hosted in own Datacenter
- Asset Storage: Wasabi S3 bucket
- CDN: Fastly
- Email Platform: PostMarkApp integrated via SMTP
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to main/develop branches
- Tests: Run before deployment
- Production Environment: main branch
- Staging Environment: develop branch
