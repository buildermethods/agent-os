---
name: mcp-builder
description: "Guide for creating MCP (Model Context Protocol) servers. Use this skill when building custom MCP servers for API integrations, tool extensions, or external service connections."
allowed-tools: Read, Write, Bash, Grep, Glob
---

# MCP Builder Skill

Create MCP servers that extend Claude's capabilities with custom tools and integrations.

**Core Principle:** MCP SERVERS PROVIDE CLAUDE WITH NEW CAPABILITIES

## When to Use This Skill

Claude should invoke this skill:
- **When building custom API integrations**
- **When creating new tools for Claude**
- **When connecting to external services**
- **When extending Claude Code capabilities**

## MCP Server Overview

### What is MCP?

Model Context Protocol (MCP) allows Claude to:
- Call custom tools
- Access external APIs
- Read from databases
- Interact with services

### Basic Structure

```
mcp-server/
├── package.json
├── tsconfig.json (if TypeScript)
├── src/
│   └── index.ts
└── README.md
```

## Workflow

### Phase 1: Define the Server

**1.1 Identify Capabilities**
```
What should this server provide?
- Tools: Actions Claude can take
- Resources: Data Claude can read
- Prompts: Templates for common tasks
```

**1.2 Design Tool Interface**
```typescript
// Define what each tool does
{
  name: "tool_name",
  description: "What this tool does and when to use it",
  inputSchema: {
    // JSON Schema for parameters
  }
}
```

### Phase 2: Implement the Server

**2.1 Basic Server Setup (TypeScript)**
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "my-mcp-server",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {}
  }
});

// List available tools
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "my_tool",
      description: "Description of what this tool does",
      inputSchema: {
        type: "object",
        properties: {
          param1: { type: "string", description: "Parameter description" }
        },
        required: ["param1"]
      }
    }
  ]
}));

// Handle tool calls
server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "my_tool") {
    // Implement tool logic
    const result = await doSomething(args.param1);
    return { content: [{ type: "text", text: result }] };
  }

  throw new Error(`Unknown tool: ${name}`);
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

**2.2 Error Handling**
```typescript
server.setRequestHandler("tools/call", async (request) => {
  try {
    // Tool implementation
  } catch (error) {
    return {
      content: [{
        type: "text",
        text: `Error: ${error.message}`
      }],
      isError: true
    };
  }
});
```

### Phase 3: Configure for Claude Code

**3.1 Add to Claude Settings**

Location: `~/.claude/claude_desktop_config.json` or project `.claude/settings.json`

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/path/to/mcp-server/dist/index.js"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

**3.2 For npm-installed servers**
```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"]
    }
  }
}
```

### Phase 4: Test the Server

**4.1 Direct Testing**
```bash
# Run server directly
node dist/index.js

# Test with MCP inspector
npx @modelcontextprotocol/inspector node dist/index.js
```

**4.2 Integration Testing**
```
1. Start Claude Code
2. Check tool appears in available tools
3. Test tool invocation
4. Verify results
```

## Output Format

```markdown
## MCP Server: [server-name]

### Purpose
[What this server provides]

### Tools Provided

#### Tool: [tool_name]
**Description:** [What it does]
**Parameters:**
- `param1` (string, required): [description]
- `param2` (number, optional): [description]

**Example:**
```json
{
  "name": "[tool_name]",
  "arguments": {
    "param1": "value"
  }
}
```

### Installation

```bash
# Install dependencies
npm install

# Build
npm run build

# Configure
# Add to ~/.claude/claude_desktop_config.json
```

### Configuration
```json
{
  "mcpServers": {
    "[server-name]": {
      "command": "node",
      "args": ["[path]/dist/index.js"]
    }
  }
}
```

### Files Created
- `src/index.ts` - Main server implementation
- `package.json` - Dependencies and scripts
- `tsconfig.json` - TypeScript configuration
```

## Key Principles

1. **Clear Tool Descriptions**: Claude uses descriptions to decide when to call tools
2. **Proper Error Handling**: Return isError: true for failures
3. **Typed Parameters**: Use JSON Schema for input validation
4. **Minimal Scope**: Each server should have focused purpose
5. **Secure Credentials**: Use environment variables for secrets

## Common Patterns

### API Integration
```typescript
// Tool that calls external API
{
  name: "api_call",
  description: "Call external API to [purpose]",
  inputSchema: {
    type: "object",
    properties: {
      endpoint: { type: "string" },
      method: { type: "string", enum: ["GET", "POST"] }
    }
  }
}
```

### Database Query
```typescript
// Tool that queries database
{
  name: "query_db",
  description: "Query database for [data type]",
  inputSchema: {
    type: "object",
    properties: {
      query: { type: "string" },
      limit: { type: "number", default: 10 }
    }
  }
}
```

### File Operations
```typescript
// Tool that processes files
{
  name: "process_file",
  description: "Process [file type] to [output]",
  inputSchema: {
    type: "object",
    properties: {
      path: { type: "string" },
      operation: { type: "string" }
    }
  }
}
```

## Resources

- MCP SDK: `@modelcontextprotocol/sdk`
- Documentation: https://modelcontextprotocol.io
- Examples: https://github.com/anthropics/mcp-servers
