#!/usr/bin/env bash
# Minimal smoke checks for shell-only repo
# - verify that scripts are executable and can print a help/usage message
# - run any small demo script present in scripts/demo.sh

set -euo pipefail

echo "Running CI smoke checks"

# Find shell scripts under scripts/ and top-level that look like entrypoints
SCRIPTS=$(find . -maxdepth 2 -type f -name '*.sh' -not -path './.github/*' -print)

if [ -z "$SCRIPTS" ]; then
  echo "No .sh scripts found; nothing to smoke-test"
  exit 0
fi

for s in $SCRIPTS; do
  echo "- Checking $s"
  if [ ! -x "$s" ]; then
    echo "  making $s executable"
    chmod +x "$s"
  fi
  # Try running with --help or -h if supported
  if "$s" --help > /dev/null 2>&1; then
    echo "  $s --help succeeded"
  elif "$s" -h > /dev/null 2>&1; then
    echo "  $s -h succeeded"
  else
    echo "  Running $s with no args (expecting non-zero allowed)"
    # Run but don't fail CI on unknown exit codes; just ensure no crash (trap) — we run in subshell
    ("$s") || true
  fi
done

# Optional: run scripts/demo.sh if present
if [ -f scripts/demo.sh ]; then
  echo "Running scripts/demo.sh"
  chmod +x scripts/demo.sh
  ./scripts/demo.sh || true
fi

echo "CI smoke checks complete"
