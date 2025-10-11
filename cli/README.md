# Agent OS CLI

Beautiful, reliable CLI tool for Agent OS - built with TypeScript, Bun, and Clack.

<img width="587" height="354" alt="Screenshot 2025-10-11 at 16 21 31" src="https://github.com/user-attachments/assets/646b0c2f-d0a7-41ba-bab4-1f2bdfa0a8ac" />

## Why This CLI?

The TypeScript CLI replaces the original bash scripts with a **more reliable, testable, and maintainable** solution:

- ✅ **Standalone executable** - No Node.js or dependencies required
- ✅ **Type-safe** - Built with TypeScript for reliability and fewer runtime errors
- ✅ **Testable** - Proper error handling and structured code
- ✅ **Beautiful UX** - Interactive menus powered by [Clack](https://www.clack.cc/)
- ✅ **Cross-platform** - Works on macOS, Linux, and Windows
- ✅ **Fast** - Compiled with [Bun](https://bun.sh) for native performance

## Installation

The CLI is automatically installed with Agent OS base installation:

```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/install.sh | bash
```

This installs the base system to `~/agent-os/` including the compiled `cli` executable.

For easier access, create an alias:

```bash
echo 'alias agent-os="~/agent-os/cli"' >> ~/.zshrc
source ~/.zshrc
```

## Usage

Run the CLI to see the interactive menu:

```bash
~/agent-os/cli

# Or with alias:
agent-os
```

Available commands:
- **Install Agent OS in project** - Set up Agent OS in current directory
- **Update Agent OS in project** - Update existing installation
- **Create new profile** - Create custom profile configuration
- **Create new role** - Add implementer or verifier roles
- **Update base installation** - Update `~/agent-os`

## Built With

- **[Bun](https://bun.sh)** - Fast TypeScript runtime and bundler
- **[Clack](https://www.clack.cc/)** - Beautiful CLI prompts and interactions
- **[picocolors](https://github.com/alexeyraspopov/picocolors)** - Minimal, fast terminal colors
- **TypeScript** - Type safety and modern JavaScript features

## Development

### Prerequisites

- [Bun](https://bun.sh) installed on your system

### Setup

```bash
cd cli
bun install
```

### Run in Development

```bash
bun run dev
```

### Build Executable

**For your current platform:**
```bash
bun run build
```

**For all platforms:**
```bash
bun run build:all-platforms
```

This creates executables for:
- macOS (ARM64 & x64)
- Linux (x64)
- Windows (x64)

## Why Bun?

- **Standalone executables** - Compiled binaries include everything needed
- **No runtime required** - Users don't need Node.js, Bun, or any dependencies
- **Fast compilation** - Native performance with small binary sizes
- **Modern TypeScript** - First-class TS support with built-in APIs
- **Cross-platform** - Easy to build for multiple platforms

## License

Same license as Agent OS.
