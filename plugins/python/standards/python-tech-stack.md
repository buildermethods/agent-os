# Python Tech Stack

## Context

Global tech stack defaults for Agent OS projects, that will influence project-specific `.agent-os/product/tech-stack.md`.

## Core Technologies
- **Language**: Python 3.12+
- **Backend Framework**: FastAPI 0.116.1+
- **UI Framework**: NiceGUI 2.21.1+

### Database & ORM
- **ORM**: SQLModel 0.0.24+ (Pydantic + SQLAlchemy)
- **Database Migrations**: SQLModel.metadata.create_all()
- **Session Management**: Context managers with SQLModel Session
- **Validation**: Pydantic (via SQLModel) for  data validation

### Frontend & Styling
- **CSS Framework**: Tailwind CSS (integrated with NiceGUI)
- **UI Components**: NiceGUI built-in components + Quasar Framework
- **Mobile Design**: Mobile-first responsive (400px × 800px target)
- **Icons**: Material Design Icons (via NiceGUI/Quasar)
- **Dark Mode**: NiceGUI dark mode support

### Development Tools
- **Package Manager**: uv (modern Python package manager)
- **Linting**: Ruff 0.12.5+ (Python linter/formatter)
- **Testing**: Pytest 8.4.1+ with pytest-asyncio
