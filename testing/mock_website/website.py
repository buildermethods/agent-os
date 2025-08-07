#!/usr/bin/env python3
"""
Mock Agent OS website for testing setup scripts locally.
Mimics https://buildermethods.com/agent-os with local endpoints.
"""

from fastapi import FastAPI, Response
from fastapi.responses import RedirectResponse, HTMLResponse
from pathlib import Path

# Base directory for setup scripts (project root)
SETUP_DIR = Path(__file__).parent.parent / "setups_local"
LOCALREPO_DIR = Path(__file__).parent.parent.parent
print(f"Setup scripts directory: {SETUP_DIR}")
print(f"Local repo directory: {LOCALREPO_DIR}")

# Create FastAPI app
app = FastAPI(title="Agent OS Test Environment")


# API routes
@app.get("/agent-os/api/setup-{tool}.sh")
async def get_setup_script(tool: str):
    """Serve setup scripts from the project root."""
    script_path = SETUP_DIR / f"setup-{tool}.sh"
    if script_path.exists():
        content = script_path.read_text()
        return Response(content=content, media_type="text/plain")
    return Response(
        content=f"#!/bin/bash\necho 'Setup script for {tool} not found'",
        status_code=404,
    )


@app.get("/agent-os/api/setup.sh")
async def get_main_setup():
    """Serve main setup script from the project root."""
    script_path = SETUP_DIR / "setup.sh"
    if script_path.exists():
        content = script_path.read_text()
        return Response(content=content, media_type="text/plain")
    return Response(
        content="#!/bin/bash\necho 'Main setup script not found'", status_code=404
    )


@app.get("/agent-os/api/{file_path:path}")
async def get_file(file_path: str):
    """Serve files from the local repository."""
    full_path = LOCALREPO_DIR / file_path
    if full_path.exists() and full_path.is_file():
        content = full_path.read_text()
        return Response(content=content, media_type="text/plain")

    print(f"File not found: {full_path}")
    return Response(content=f"File not found: {file_path}", status_code=404)


@app.get("/agent-os")
async def main_page():
    """Main landing page mimicking buildermethods.com/agent-os"""

    html_content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Agent OS - Test Environment</title>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-50 min-h-screen">
        <div class="max-w-6xl mx-auto p-8">
            <!-- Header -->
            <h1 class="text-5xl font-bold mb-4">Agent OS</h1>
            <h2 class="text-2xl text-gray-600 mb-8">AI-Powered Development Environment</h2>
            
            <!-- Hero Section -->
            <div class="bg-white rounded-lg shadow-md p-8 mb-8">
                <h3 class="text-xl mb-4">Transform your development workflow with AI assistance</h3>
                <p class="mb-4">Agent OS provides a comprehensive framework for AI-assisted software development, 
                with support for multiple AI tools and development environments.</p>
            </div>
            
            <!-- Installation Section -->
            <h2 class="text-3xl font-bold mt-12 mb-4">Installation</h2>
            
            <!-- Step 1: Base Installation -->
            <div class="bg-white rounded-lg shadow-md p-6 mb-8">
                <h3 class="text-xl font-bold mb-2">Step 1: Install Agent OS Base</h3>
                <p class="mb-4">Install the core Agent OS files to your home directory (~/.agent-os). 
                This is the foundation for all AI-powered development.</p>
                <div class="bg-gray-100 rounded p-4">
                    <code class="text-sm">curl -sSL http://localhost:8080/agent-os/api/setup.sh | bash</code>
                </div>
            </div>
            
            <!-- Step 2: Tool Installation -->
            <div class="bg-white rounded-lg shadow-md p-6">
                <h3 class="text-xl font-bold mb-2">Step 2: Install Your Preferred AI Tool</h3>
                <p class="mb-4">Choose an AI assistant to integrate with Agent OS. These commands will be installed into your project's .base directory</p>
                
                <div class="grid md:grid-cols-2 gap-4">
                    <!-- GitHub Copilot -->
                    <div class="bg-gray-50 rounded-lg p-4">
                        <h4 class="text-xl font-bold mb-2">GitHub Copilot</h4>
                        <p class="text-gray-600 mb-4">VS Code with GitHub Copilot integration</p>
                        <details class="mb-2">
                            <summary class="cursor-pointer font-semibold">Installation</summary>
                            <div class="bg-gray-100 rounded p-2 mt-2">
                                <code class="text-sm">curl -sSL http://localhost:8080/agent-os/api/setup-github-copilot.sh | bash</code>
                            </div>
                        </details>
                    </div>
                    
                    <!-- KiloCode -->
                    <div class="bg-gray-50 rounded-lg p-4">
                        <h4 class="text-xl font-bold mb-2">KiloCode</h4>
                        <p class="text-gray-600 mb-4">Advanced AI coding assistant by Kilo Kish</p>
                        <details class="mb-2">
                            <summary class="cursor-pointer font-semibold">Installation</summary>
                            <div class="bg-gray-100 rounded p-2 mt-2">
                                <code class="text-sm">curl -sSL http://localhost:8080/agent-os/api/setup-kilocode.sh | bash</code>
                            </div>
                        </details>
                    </div>
                    
                    <!-- Cursor -->
                    <div class="bg-gray-50 rounded-lg p-4">
                        <h4 class="text-xl font-bold mb-2">Cursor</h4>
                        <p class="text-gray-600 mb-4">The AI-first code editor</p>
                        <details class="mb-2">
                            <summary class="cursor-pointer font-semibold">Installation</summary>
                            <div class="bg-gray-100 rounded p-2 mt-2">
                                <code class="text-sm">curl -sSL http://localhost:8080/agent-os/api/setup-cursor.sh | bash</code>
                            </div>
                        </details>
                    </div>
                    
                    <!-- Claude Code -->
                    <div class="bg-gray-50 rounded-lg p-4">
                        <h4 class="text-xl font-bold mb-2">Claude Code</h4>
                        <p class="text-gray-600 mb-4">Anthropic's Claude for code generation</p>
                        <details class="mb-2">
                            <summary class="cursor-pointer font-semibold">Installation</summary>
                            <div class="bg-gray-100 rounded p-2 mt-2">
                                <code class="text-sm">curl -sSL http://localhost:8080/agent-os/api/setup-claude-code.sh | bash</code>
                            </div>
                        </details>
                    </div>
                </div>
            </div>
            
            <!-- Features Section -->
            <h2 class="text-3xl font-bold mt-12 mb-4">Features</h2>
            
            <div class="grid md:grid-cols-4 gap-4">
                <div class="bg-white rounded-lg shadow-md p-4 text-center">
                    <div class="text-4xl mb-2">💻</div>
                    <h4 class="font-bold">Multi-Language Support</h4>
                    <p>Python, TypeScript, Ruby, and more</p>
                </div>
                
                <div class="bg-white rounded-lg shadow-md p-4 text-center">
                    <div class="text-4xl mb-2">🤖</div>
                    <h4 class="font-bold">AI Tool Integration</h4>
                    <p>Works with leading AI assistants</p>
                </div>
                
                <div class="bg-white rounded-lg shadow-md p-4 text-center">
                    <div class="text-4xl mb-2">🏗️</div>
                    <h4 class="font-bold">Best Practices</h4>
                    <p>Built-in coding standards and patterns</p>
                </div>
                
                <div class="bg-white rounded-lg shadow-md p-4 text-center">
                    <div class="text-4xl mb-2">🔌</div>
                    <h4 class="font-bold">Plugin System</h4>
                    <p>Extensible architecture</p>
                </div>
            </div>
            
            <!-- Documentation Links -->
            <h2 class="text-3xl font-bold mt-12 mb-4">Documentation</h2>
            
            <div class="flex gap-4">
                <a href="https://buildermethods.com/#start" class="text-blue-600 hover:underline">Getting Started</a>
                <span>•</span>
                <a href="http://localhost:8080/docs" class="text-blue-600 hover:underline">API Reference</a>
                <span>•</span>
                <a href="https://github.com/buildermethods/agent-os" class="text-blue-600 hover:underline">GitHub</a>
            </div>
            
            <!-- Footer -->
            <hr class="my-8">
            <p class="text-gray-600 text-center">© 2025 Builder Methods. Licensed under MIT.</p>
        </div>
    </body>
    </html>
    """

    return HTMLResponse(content=html_content)


@app.get("/")
def root_redirect():
    return RedirectResponse(url="/agent-os")


if __name__ == "__main__":
    print(
        "Please start the app with uvicorn using: uvicorn website:app --host 0.0.0.0 --port 8080 --reload"
    )
