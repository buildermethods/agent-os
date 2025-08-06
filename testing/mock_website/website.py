#!/usr/bin/env python3
"""
Mock Agent OS website for testing setup scripts locally.
Mimics https://buildermethods.com/agent-os with local endpoints.
"""

from fastapi import FastAPI, Response
from nicegui import app, ui
import uvicorn
from pathlib import Path
import asyncio

# FastAPI instance for serving setup scripts
fastapi_app = FastAPI()

# Base directory for setup scripts (project root)
SETUP_DIR = Path(__file__).parent.parent.parent
print(f"Setup scripts directory: {SETUP_DIR}")
BASE_URL = "http://localhost:8080"


# Serve setup scripts via FastAPI
@fastapi_app.get("/setup-{tool}.sh")
async def get_setup_script(tool: str):
    """Serve setup scripts from the project root."""
    script_path = SETUP_DIR / f"setup-{tool}.sh"
    if script_path.exists():
        content = script_path.read_text()
        return Response(content=content, media_type="text/plain")
    return Response(
        content="#!/bin/bash\necho 'Setup script not found'", status_code=404
    )


@fastapi_app.get("/setup.sh")
async def get_main_setup():
    """Serve main setup script from the project root."""
    script_path = SETUP_DIR / "setup.sh"
    if script_path.exists():
        content = script_path.read_text()
        return Response(content=content, media_type="text/plain")
    return Response(
        content="#!/bin/bash\necho 'Main setup script not found'", status_code=404
    )


# Mount FastAPI to NiceGUI
app.mount("/api", fastapi_app)


# NiceGUI Pages
@ui.page("/")
def main_page():
    """Main landing page mimicking buildermethods.com/agent-os"""

    with ui.column().classes("w-full max-w-6xl mx-auto p-8"):
        # Header
        ui.label("Agent OS").classes("text-5xl font-bold mb-4")
        ui.label("AI-Powered Development Environment").classes(
            "text-2xl text-gray-600 mb-8"
        )

        # Hero Section
        with ui.card().classes("w-full p-8 mb-8"):
            ui.label("Transform your development workflow with AI assistance").classes(
                "text-xl mb-4"
            )
            ui.label(
                "Agent OS provides a comprehensive framework for AI-assisted software development, "
                "with support for multiple AI tools and development environments."
            ).classes("mb-4")

        # -- INSTALLATION --
        ui.label("Installation").classes("text-3xl font-bold mt-12 mb-4")

        # Step 1: Base Installation
        with ui.card().classes("w-full p-6 mb-8"):
            ui.label("Step 1: Install Agent OS Base").classes("text-xl font-bold mb-2")
            ui.label(
                "Install the core Agent OS files to your home directory (~/.agent-os). "
                "This is the foundation for all AI-powered development."
            ).classes("mb-4")
            ui.code(
                f"curl -sSL {BASE_URL}/api/setup.sh | bash", language="bash"
            ).classes("w-full")

        # Step 2: Tool Installation
        with ui.card().classes("w-full p-6"):
            ui.label("Step 2: Install Your Preferred AI Tool").classes(
                "text-xl font-bold mb-2"
            )
            ui.label(
                "Choose an AI assistant to integrate with Agent OS. These commands will be installed into your project's .base directory"
            ).classes("mb-4")

            with ui.row().classes("w-full gap-4 flex-wrap"):
                # GitHub Copilot
                with ui.card().classes("flex-1 min-w-80"):
                    ui.label("GitHub Copilot").classes("text-xl font-bold mb-2")
                    ui.label("VS Code with GitHub Copilot integration").classes(
                        "text-gray-600 mb-4"
                    )
                    with ui.expansion("Installation", icon="terminal").classes(
                        "w-full"
                    ):
                        ui.code(
                            f"curl -sSL {BASE_URL}/api/setup-github-copilot.sh | bash",
                            language="bash",
                        ).classes("w-full")

                # KiloCode
                with ui.card().classes("flex-1 min-w-80"):
                    ui.label("KiloCode").classes("text-xl font-bold mb-2")
                    ui.label("Advanced AI coding assistant by Kilo Kish").classes(
                        "text-gray-600 mb-4"
                    )
                    with ui.expansion("Installation", icon="terminal").classes(
                        "w-full"
                    ):
                        ui.code(
                            f"curl -sSL {BASE_URL}/api/setup-kilocode.sh | bash",
                            language="bash",
                        ).classes("w-full")

                # Cursor
                with ui.card().classes("flex-1 min-w-80"):
                    ui.label("Cursor").classes("text-xl font-bold mb-2")
                    ui.label("The AI-first code editor").classes("text-gray-600 mb-4")
                    with ui.expansion("Installation", icon="terminal").classes(
                        "w-full"
                    ):
                        ui.code(
                            f"curl -sSL {BASE_URL}/api/setup-cursor.sh | bash",
                            language="bash",
                        ).classes("w-full")

                # Claude Code
                with ui.card().classes("flex-1 min-w-80"):
                    ui.label("Claude Code").classes("text-xl font-bold mb-2")
                    ui.label("Anthropic's Claude for code generation").classes(
                        "text-gray-600 mb-4"
                    )
                    with ui.expansion("Installation", icon="terminal").classes(
                        "w-full"
                    ):
                        ui.code(
                            f"curl -sSL {BASE_URL}/api/setup-claude-code.sh | bash",
                            language="bash",
                        ).classes("w-full")

        # Features Section
        ui.label("Features").classes("text-3xl font-bold mt-12 mb-4")

        with ui.row().classes("w-full gap-4 flex-wrap"):
            with ui.card().classes("flex-1 min-w-64"):
                ui.icon("code", size="xl").classes("mb-2")
                ui.label("Multi-Language Support").classes("font-bold")
                ui.label("Python, TypeScript, Ruby, and more")

            with ui.card().classes("flex-1 min-w-64"):
                ui.icon("smart_toy", size="xl").classes("mb-2")
                ui.label("AI Tool Integration").classes("font-bold")
                ui.label("Works with leading AI assistants")

            with ui.card().classes("flex-1 min-w-64"):
                ui.icon("architecture", size="xl").classes("mb-2")
                ui.label("Best Practices").classes("font-bold")
                ui.label("Built-in coding standards and patterns")

            with ui.card().classes("flex-1 min-w-64"):
                ui.icon("extension", size="xl").classes("mb-2")
                ui.label("Plugin System").classes("font-bold")
                ui.label("Extensible architecture")

        # Documentation Links
        ui.label("Documentation").classes("text-3xl font-bold mt-12 mb-4")

        with ui.row().classes("gap-4"):
            ui.link("Getting Started", "https://buildermethods.com/#start").classes(
                "text-blue-600"
            )
            # ui.label("•")
            # ui.link("Plugin Development", f"{BASE_URL}/docs/plugins").classes(
            #     "text-blue-600"
            # )
            ui.label("•")
            ui.link("API Reference", f"{BASE_URL}/api/docs/").classes("text-blue-600")
            ui.label("•")
            ui.link("GitHub", "https://github.com/buildermethods/agent-os").classes(
                "text-blue-600"
            )

        # Footer
        ui.separator().classes("my-8")
        ui.label("© 2025 Builder Methods. Licensed under MIT.").classes(
            "text-gray-600 text-center"
        )


# Run the application
if __name__ == "__main__":
    ui.run(
        title="Agent OS - Test Environment",
        favicon="🤖",
        host="localhost",
        port=8080,
        reload=False,
    )
