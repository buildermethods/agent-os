# Python Style Guide

## Context

Python-specific code style rules for Agent OS projects using NiceGUI, FastAPI, and SQLModel.

## Indentation and Formatting

- Use 4 spaces for indentation (never tabs) - **overrides global 2-space rule for Python**
- Maximum line length: 88 characters (Black formatter standard)
- Use trailing commas in multi-line data structures
- Use double quotes for strings: `"Hello World"`
- Use f-strings for string interpolation: `f"Hello {name}"`

## Import Organization

```python
# Standard library imports
import asyncio
from pathlib import Path
from typing import Optional, List, Dict

# Third-party imports
from fastapi import FastAPI, HTTPException
from sqlmodel import SQLModel, Field, Session, create_engine

# NiceGUI imports
from nicegui import ui, app

# Local imports
from .models import User, Product
from .database import get_session
```

## Naming Conventions

- **Functions and Variables**: `snake_case` (e.g., `user_profile`, `calculate_total`)
- **Classes**: `PascalCase` (e.g., `UserProfile`, `PaymentProcessor`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`, `DATABASE_URL`)
- **Private methods**: Prefix with single underscore `_private_method`
- **Files**: `snake_case.py` (e.g., `user_service.py`, `payment_models.py`)

## FastAPI Patterns

### Route Definitions

```python
@app.get("/users/{user_id}")
async def get_user(user_id: int) -> User:
    """Get user by ID."""
    # Implementation here
```

### Dependency Injection

```python
from fastapi import Depends

async def get_current_user(session: Session = Depends(get_session)) -> User:
    """Get current authenticated user."""
    # Implementation here

@app.get("/profile")
async def get_profile(user: User = Depends(get_current_user)) -> UserProfile:
    """Get user profile."""
    # Implementation here
```

## SQLModel Patterns

### Model Definitions
```python
from sqlmodel import SQLModel, Field
from typing import Optional

class UserBase(SQLModel):
    """Base user model with shared fields."""
    email: str = Field(unique=True, index=True)
    full_name: str
    is_active: bool = True

class User(UserBase, table=True):
    """User database model."""
    id: Optional[int] = Field(default=None, primary_key=True)
    hashed_password: str

class UserCreate(UserBase):
    """User creation model."""
    password: str

class UserPublic(UserBase):
    """Public user model (no sensitive data)."""
    id: int
```

### Database Sessions
```python
# Always use context managers for sessions
with Session(engine) as session:
    user = session.get(User, user_id)
    if user:
        session.add(user)
        session.commit()
        session.refresh(user)

# For async operations
async def create_user(user_data: UserCreate) -> User:
    """Create a new user."""
    with Session(engine) as session:
        db_user = User.model_validate(user_data)
        session.add(db_user)
        session.commit()
        session.refresh(db_user)
        return db_user
```

### Database Initialization
```python
def create_db_and_tables():
    """Create database and tables."""
    SQLModel.metadata.create_all(engine)

def init_db():
    """Initialize database with sample data."""
    create_db_and_tables()
    # Add sample data if needed
```

## NiceGUI Patterns

### Component Organization
```python
from nicegui import ui

def create_user_card(user: User) -> ui.card:
    """Create a user display card."""
    with ui.card().classes("w-64 h-32") as card:
        ui.label(user.full_name).classes("text-lg font-bold")
        ui.label(user.email).classes("text-sm text-gray-600")
        if user.is_active:
            ui.badge("Active", color="green")
    return card

def create_user_list(users: List[User]) -> ui.column:
    """Create a list of user cards."""
    with ui.column().classes("gap-4") as container:
        for user in users:
            create_user_card(user)
    return container
```

### Value Binding
```python
from nicegui import ui

class UserForm:
    """User form with reactive data binding."""
    
    def __init__(self):
        self.email = ""
        self.full_name = ""
        
    def create_form(self) -> ui.column:
        """Create form UI with bound values."""
        with ui.column().classes("gap-4 w-96") as form:
            ui.input("Email").bind_value(self, "email")
            ui.input("Full Name").bind_value(self, "full_name")
            ui.button("Submit", on_click=self.submit)
        return form
    
    async def submit(self):
        """Handle form submission."""
        # Validation and submission logic
        ui.notify(f"User {self.full_name} created!")
```

### Page Structure
```python
@ui.page("/")
def main_page():
    """Main application page."""
    with ui.header().classes("items-center justify-between"):
        ui.label("My App").classes("text-xl font-bold")
        ui.button("Settings", icon="settings")
    
    with ui.column().classes("flex-grow p-8"):
        ui.label("Welcome to the app!").classes("text-2xl")
        # Main content here

@ui.page("/users")
def users_page():
    """Users management page."""
    ui.label("Users").classes("text-3xl font-bold mb-4")
    
    # Create user form and list
    form = UserForm()
    form.create_form()
```

### Styling with Tailwind CSS
```python
# Use Tailwind classes for consistent styling
ui.button("Primary Action").classes("bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded")
ui.card().classes("max-w-sm mx-auto bg-white shadow-lg rounded-lg overflow-hidden")
ui.column().classes("space-y-4 p-6")

# Responsive design
ui.grid(columns=3).classes("gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-3")
```

## Async/Await Patterns
```python
# Use async/await for I/O operations
async def fetch_user_data(user_id: int) -> Optional[User]:
    """Fetch user data asynchronously."""
    with Session(engine) as session:
        return session.get(User, user_id)

# Handle async operations in UI
async def load_users():
    """Load and display users."""
    users = await fetch_all_users()
    user_container.clear()
    with user_container:
        create_user_list(users)

# Use in button handlers
ui.button("Load Users", on_click=load_users)
```

## Error Handling
```python
from fastapi import HTTPException
from nicegui import ui

async def get_user_safely(user_id: int) -> Optional[User]:
    """Get user with proper error handling."""
    try:
        with Session(engine) as session:
            user = session.get(User, user_id)
            if not user:
                raise HTTPException(status_code=404, detail="User not found")
            return user
    except Exception as e:
        ui.notify(f"Error loading user: {str(e)}", color="negative")
        return None
```

## Testing Patterns
```python
import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, create_engine, SQLModel
from sqlmodel.pool import StaticPool

@pytest.fixture
def session():
    """Create test database session."""
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        yield session

def test_create_user(session: Session):
    """Test user creation."""
    user_data = UserCreate(email="test@example.com", full_name="Test User", password="secret")
    user = create_user(user_data)
    assert user.email == "test@example.com"
    assert user.full_name == "Test User"
```

## Code Comments
```python
def calculate_user_metrics(user_id: int) -> UserMetrics:
    """
    Calculate comprehensive user metrics.
    
    Args:
        user_id: The ID of the user to analyze
        
    Returns:
        UserMetrics object containing calculated metrics
        
    Raises:
        UserNotFoundError: If user doesn't exist
        CalculationError: If metrics calculation fails
    """
    # Fetch user data from database
    user = get_user(user_id)
    
    # Calculate engagement score based on activity
    engagement_score = calculate_engagement(user.activities)
    
    return UserMetrics(
        user_id=user_id,
        engagement_score=engagement_score,
        # Add other metrics here
    )
```

## File Organization
```
project/
├── main.py                 # Application entry point
├── models/
│   ├── __init__.py
│   ├── user.py            # User-related models
│   └── product.py         # Product-related models
├── services/
│   ├── __init__.py
│   ├── user_service.py    # User business logic
│   └── auth_service.py    # Authentication logic
├── ui/
│   ├── __init__.py
│   ├── components/        # Reusable UI components
│   │   ├── user_card.py
│   │   └── forms.py
│   └── pages/            # Page definitions
│       ├── home.py
│       └── users.py
├── database/
│   ├── __init__.py
│   └── connection.py     # Database setup
└── tests/
    ├── test_models.py
    ├── test_services.py
    └── test_ui.py
```
