#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

command -v python3 >/dev/null || {
    echo "python3 is required for LLM optimization." >&2
    exit 1
}

exec python3 "$BASE_DIR/llm/optimizer.py" "$@"
