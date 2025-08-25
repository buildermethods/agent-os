# Tech Stack

## Context

ReactJS-specific tech stack for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

### Core Framework
- **Frontend Framework**: React 18+ with Hooks
- **Language**: JavaScript ES2022+ or TypeScript 5.0+
- **Build Tool**: Vite 4+ or Create React App
- **Package Manager**: npm, yarn, or pnpm
- **Node Version**: 18 LTS or 20 LTS

### State Management
- **Primary State**: Redux Toolkit with RTK Query
- **Alternative State**: Zustand, Jotai, or React Query
- **Local State**: React Context API, useState, useReducer
- **Server State**: React Query, SWR, or Apollo Client
- **Global State**: Redux Toolkit with Redux Persist

### UI Components & Styling
- **Component Library**: Material-UI, Chakra UI, or custom components
- **CSS Framework**: TailwindCSS 4.0+ or Styled Components
- **Animation**: Framer Motion, React Spring, or Lottie
- **Icons**: Lucide React, Heroicons, or Material Icons
- **Theming**: Theme providers with CSS variables

### Development Tools
- **IDE**: VS Code with React extensions
- **Code Quality**: ESLint, Prettier, TypeScript
- **Testing**: Jest, React Testing Library, Cypress
- **Debugging**: React DevTools, Redux DevTools
- **Performance**: React Profiler, Webpack Bundle Analyzer

### Routing & Navigation
- **Routing**: React Router DOM v6+
- **Navigation**: Custom hooks, route guards
- **Code Splitting**: React.lazy, Suspense
- **Dynamic Imports**: Dynamic imports for route components
- **Navigation Guards**: Protected routes, role-based access

### API Integration
- **HTTP Client**: Axios, fetch with custom hooks
- **GraphQL**: Apollo Client, Relay Modern
- **REST API**: Custom hooks with TypeScript
- **WebSocket**: Socket.io client or custom WebSocket
- **Real-time**: Server-Sent Events, WebSockets

### Form Management
- **Form Library**: React Hook Form, Formik
- **Validation**: Yup, Zod, or custom validation
- **State Management**: Form state with Redux or Context
- **Accessibility**: ARIA labels, keyboard navigation
- **UI Components**: Custom form components

### Testing
- **Unit Testing**: Jest, React Testing Library
- **Integration Testing**: Testing Library, Cypress
- **E2E Testing**: Cypress, Playwright, or Puppeteer
- **Component Testing**: React Testing Library
- **Visual Testing**: Storybook, Chromatic

### Performance Optimization
- **Code Splitting**: React.lazy, dynamic imports
- **Lazy Loading**: React.lazy, Suspense
- **Memoization**: React.memo, useMemo, useCallback
- **Virtualization**: React Window, React Virtualized
- **Bundle Analysis**: Webpack Bundle Analyzer

### Build & Deployment
- **Build Tool**: Vite, Create React App, Next.js
- **Bundling**: Webpack, Rollup, esbuild
- **Minification**: Terser, SWC
- **Deployment**: Vercel, Netlify, AWS Amplify
- **CI/CD**: GitHub Actions, GitLab CI

### TypeScript Integration
- **TypeScript**: React TypeScript templates
- **Typing**: React DnD, React Router types
- **Generics**: Custom hooks with TypeScript
- **Interfaces**: Component props, state types
- **Utility Types**: Omit, Pick, Partial, Required

### Animation & Interactions
- **Animation**: Framer Motion, React Spring
- **Transitions**: React Transition Group
- **Micro-interactions**: Custom hooks, CSS animations
- **Gestures**: React DnD, react-use-gesture
- **3D**: React Three Fiber, Three.js

### Internationalization (i18n)
- **i18n Library**: react-i18next, formatjs
- **Translation**: JSON files, PO files
- **RTL Support**: Right-to-left layouts
- **Date/Time**: date-fns, luxon, moment
- **Currency**: currency.js, custom formatters

### Accessibility (a11y)
- **Accessibility**: WCAG 2.1 AA compliance
- **Screen Readers**: ARIA labels, landmarks
- **Keyboard Navigation**: Full keyboard support
- **Color Contrast**: Proper contrast ratios
- **Testing**: axe-core, accessibility testing

### Security
- **XSS Protection**: React built-in protections
- **CSRF Protection**: Custom CSRF tokens
- **Content Security**: CSP headers, nonce
- **Authentication**: Auth0, Firebase Auth, custom
- **Authorization**: Role-based access control

### Data Fetching
- **Data Fetching**: React Query, SWR, Axios
- **Caching**: React Query caching, SWR caching
- **Prefetching**: React Query prefetch, SWR prefetch
- **Background Sync**: Background sync strategies
- **Offline Support**: Service Workers, IndexedDB

### State Management Patterns
- **Global State**: Redux Toolkit, Zustand
- **Local State**: React Context, useState
- **Derived State**: useMemo, useReducer
- **Server State**: React Query, SWR
- **Form State**: React Hook Form, Formik

### Component Architecture
- **Component Patterns**: Higher-order components, render props
- **Custom Hooks**: Reusable logic hooks
- **Compound Components**: Compound component patterns
- **Render Props**: Flexible component composition
- **Hooks API**: Custom hooks with TypeScript

### Error Handling
- **Error Boundaries**: React error boundaries
- **Error Display**: Custom error components
- **Logging**: Sentry, custom error logging
- **Fallback UI**: Error fallback components
- **Error Recovery**: Error recovery strategies

### Mobile & PWA
- **PWA**: Create React App PWA, custom service workers
- **Mobile**: React Native, Capacitor, Ionic
- **Progressive Web App**: Service workers, web app manifest
- **Offline Support**: Service Workers, IndexedDB
- **Push Notifications**: Web Push API, Firebase

### Analytics & Monitoring
- **Analytics**: Google Analytics, Mixpanel, custom
- **Monitoring**: Sentry, custom error tracking
- **Performance**: Web Vitals, custom performance metrics
- **User Tracking**: Custom user tracking hooks
- **Heatmaps**: Hotjar, custom heatmaps

### Documentation
- **Component Documentation**: Storybook, custom docs
- **API Documentation**: Swagger, custom API docs
- **Code Documentation**: JSDoc, custom documentation
- **Architecture Documentation**: Mermaid diagrams
- **Deployment Documentation**: Custom deployment guides

### Development Workflow
- **Git Workflow**: Git Flow, GitHub Flow
- **Code Review**: Pull requests, code review process
- **Branching Strategy**: Feature branches, release branches
- **Version Control**: Semantic versioning, changelog
- **Release Management**: Automated releases, release notes
