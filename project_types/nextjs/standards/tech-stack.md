# Tech Stack

## Context

NextJS-specific tech stack for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

### Core Framework
- **Framework**: Next.js 14+ with App Router
- **Language**: TypeScript 5.0+ or JavaScript ES2022+
- **Runtime**: Node.js 18 LTS or 20 LTS
- **Package Manager**: npm, yarn, or pnpm
- **Build Tool**: Next.js built-in build system

### Frontend & UI
- **UI Framework**: React 18+ with Next.js components
- **CSS Framework**: TailwindCSS 4.0+ or styled-components
- **Component Library**: Shadcn/ui, Material-UI, or custom components
- **Styling**: CSS Modules, styled-jsx, or TailwindCSS
- **Theming**: Theme providers with CSS variables

### State Management
- **Server State**: Next.js Server Components, React Server Components
- **Client State**: React Query, SWR, Zustand, or Jotai
- **Global State**: Redux Toolkit with Next.js integration
- **Local State**: React Context, useState, useReducer
- **Form State**: React Hook Form, Formik with TypeScript

### Routing & Navigation
- **Routing**: Next.js App Router (file-based routing)
- **Navigation**: Next.js Link, custom navigation components
- **Dynamic Routes**: Dynamic route parameters
- **Middleware**: Next.js middleware for authentication
- **Route Guards**: Protected routes with middleware

### Data Fetching
- **Server Data**: getServerSideProps, getStaticProps, getStaticPaths
- **Client Data**: React Query, SWR, fetch with custom hooks
- **API Routes**: Next.js API routes (REST, GraphQL)
- **GraphQL**: Apollo Client, GraphQL Yoga
- **Database**: Prisma, TypeORM, or direct database queries

### Backend & API
- **API Routes**: Next.js API routes with TypeScript
- **Serverless**: Next.js serverless functions
- **Edge Functions**: Next.js Edge Runtime
- **Middleware**: Next.js middleware for request handling
- **WebSockets**: Next.js WebSocket implementation

### Database & ORM
- **Primary Database**: PostgreSQL 15+ or MySQL 8.0+
- **ORM**: Prisma, TypeORM, or Drizzle ORM
- **Database Migrations**: Prisma migrations, custom migrations
- **Database Seeding**: Prisma seed scripts, custom seeding
- **Database Tools**: Prisma Studio, pgAdmin, phpMyAdmin

### Authentication & Security
- **Authentication**: NextAuth.js, Auth0, Firebase Auth
- **Authorization**: Role-based access control (RBAC)
- **Security**: Next.js security headers, CSRF protection
- **Session Management**: NextAuth.js sessions, JWT tokens
- **OAuth**: Google, GitHub, custom OAuth providers

### Performance Optimization
- **Static Generation**: getStaticProps for static pages
- **Server-side Rendering**: getServerSideProps for dynamic pages
- **Incremental Static Regeneration**: ISR for static content
- **Code Splitting**: Next.js automatic code splitting
- **Image Optimization**: Next.js Image component with optimization
- **Bundle Analysis**: Webpack Bundle Analyzer, custom analysis

### Testing
- **Unit Testing**: Jest, React Testing Library
- **Integration Testing**: Testing Library, Cypress
- **E2E Testing**: Playwright, Cypress, Puppeteer
- **Component Testing**: React Testing Library, Storybook
- **API Testing**: Supertest, custom API tests

### Build & Deployment
- **Build Tool**: Next.js built-in build system
- **Deployment**: Vercel, Netlify, AWS Amplify, custom servers
- **CI/CD**: GitHub Actions, GitLab CI, custom pipelines
- **Containerization**: Docker with Next.js
- **Serverless**: AWS Lambda, Google Cloud Functions

### TypeScript Integration
- **TypeScript**: Next.js TypeScript configuration
- **Typing**: React TypeScript, Next.js types
- **Generics**: Custom hooks with TypeScript
- **Interfaces**: Component props, API types
- **Utility Types**: Omit, Pick, Partial, Required

### API Development
- **REST API**: Next.js API routes with TypeScript
- **GraphQL**: Apollo Server, GraphQL Yoga
- **OpenAPI**: Swagger/OpenAPI documentation
- **Rate Limiting**: Custom rate limiting middleware
- **CORS**: CORS configuration for cross-origin requests

### Forms & Validation
- **Form Library**: React Hook Form, Formik
- **Validation**: Zod, Yup, or custom validation
- **State Management**: Form state with React Query or Context
- **Accessibility**: ARIA labels, keyboard navigation
- **File Upload**: Next.js file upload handling

### Internationalization (i18n)
- **i18n Library**: next-i18next, formatjs
- **Translation**: JSON files, PO files
- **RTL Support**: Right-to-left layouts
- **Dynamic Content**: Dynamic content based on locale
- **SEO**: International SEO with hreflang tags

### Analytics & Monitoring
- **Analytics**: Google Analytics, Plausible, custom analytics
- **Monitoring**: Sentry, custom error tracking
- **Performance**: Web Vitals, custom performance metrics
- **User Tracking**: Custom user tracking hooks
- **Heatmaps**: Hotjar, custom heatmaps

### Caching & Performance
- **CDN**: Vercel Edge Network, Cloudflare, AWS CloudFront
- **Caching**: Next.js caching strategies, Redis caching
- **Compression**: Next.js compression middleware
- **Optimization**: Next.js optimization features
- **Bundle Size**: Bundle size optimization, code splitting

### Development Tools
- **IDE**: VS Code with Next.js extensions
- **Code Quality**: ESLint, Prettier, TypeScript
- **Debugging**: Next.js DevTools, React DevTools
- **Hot Reload**: Next.js hot module replacement
- **Type Checking**: TypeScript compiler, ESLint

### Content Management
- **Static Content**: MDX, Markdown files
- **Dynamic Content**: CMS integration (Contentful, Strapi)
- **Headless CMS**: Contentful, Strapi, Sanity
- **File Management**: Next.js file system, cloud storage
- **Media**: Image optimization, video handling

### E-commerce (if applicable)
- **E-commerce**: Shopify, BigCommerce, custom solutions
- **Payment**: Stripe, PayPal, custom payment gateways
- **Cart**: Custom cart implementation, third-party carts
- **Inventory**: Inventory management systems
- **Order Management**: Order processing, fulfillment

### Mobile & PWA
- **PWA**: Next.js PWA configuration
- **Mobile**: React Native, Capacitor, Ionic
- **Progressive Web App**: Service workers, web app manifest
- **Offline Support**: Service Workers, IndexedDB
- **Push Notifications**: Web Push API, Firebase

### Microservices & Architecture
- **Microservices**: Next.js API routes, external services
- **Service Communication**: REST API, GraphQL, gRPC
- **API Gateway**: Custom API gateway, Kong
- **Load Balancing**: Nginx, cloud load balancers
- **Container Orchestration**: Kubernetes, Docker Swarm

### Security & Compliance
- **Security**: Next.js security features, custom security
- **Compliance**: GDPR, CCPA, SOC 2 compliance
- **Data Protection**: Data encryption, secure storage
- **Authentication**: Multi-factor authentication, SSO
- **Authorization**: Role-based access control, permissions

### Documentation
- **API Documentation**: Swagger/OpenAPI, custom documentation
- **Component Documentation**: Storybook, custom docs
- **Code Documentation**: JSDoc, custom documentation
- **Architecture Documentation**: Mermaid diagrams
- **Deployment Documentation**: Custom deployment guides

### Development Workflow
- **Git Workflow**: Git Flow, GitHub Flow
- **Code Review**: Pull requests, code review process
- **Branching Strategy**: Feature branches, release branches
- **Version Control**: Semantic versioning, changelog
- **Release Management**: Automated releases, release notes
