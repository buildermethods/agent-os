#!/usr/bin/env python3
"""Validate the Agent OS plugin against all three harness contracts.

Checks the Codex manifest against the contract in openai/codex's
plugin-creator skill, the Claude Code manifest and marketplace, the pi
package manifest, and the skills themselves.

Usage: scripts/validate-plugin.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import yaml

REPO = Path(__file__).resolve().parent.parent
PLUGIN = REPO / "plugins" / "agent-os"

SEMVER = re.compile(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z.-]+)?$")
HEX_COLOR = re.compile(r"^#[0-9A-Fa-f]{6}$")
SKILL_NAME = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")

# Exactly the keys openai/codex's validator accepts. Anything else is rejected
# at ingestion, so an extra field is a hard error rather than a nicety.
CODEX_MANIFEST_KEYS = {
    "id", "name", "version", "description", "skills", "apps",
    "mcpServers", "interface", "author", "homepage", "repository",
    "license", "keywords",
}
CODEX_INTERFACE_KEYS = {
    "displayName", "shortDescription", "longDescription", "developerName",
    "category", "capabilities", "websiteURL", "privacyPolicyURL",
    "termsOfServiceURL", "brandColor", "composerIcon", "logo", "logoDark",
    "screenshots", "defaultPrompt", "default_prompt",
}
CODEX_INTERFACE_REQUIRED = (
    "displayName", "shortDescription", "longDescription",
    "developerName", "category",
)

errors: list[str] = []


def fail(message: str) -> None:
    errors.append(message)


def load_json(path: Path) -> dict | None:
    if not path.is_file():
        fail(f"missing {path.relative_to(REPO)}")
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"{path.relative_to(REPO)} is not valid JSON: {exc}")
        return None


def check_codex_manifest() -> None:
    manifest = load_json(PLUGIN / ".codex-plugin" / "plugin.json")
    if manifest is None:
        return

    for key in sorted(set(manifest) - CODEX_MANIFEST_KEYS):
        fail(f"codex plugin.json: field `{key}` is not accepted by Codex plugin validation")

    for key in ("name", "version", "description"):
        if not str(manifest.get(key, "")).strip():
            fail(f"codex plugin.json: `{key}` is required")

    if manifest.get("version") and not SEMVER.match(manifest["version"]):
        fail("codex plugin.json: `version` must be strict semver")

    author = manifest.get("author")
    if not isinstance(author, dict) or not str(author.get("name", "")).strip():
        fail("codex plugin.json: `author.name` is required")

    if manifest.get("skills") is not None:
        # Codex requires this to normalize to exactly `skills`.
        if manifest["skills"].strip("./").rstrip("/") != "skills":
            fail("codex plugin.json: `skills` must resolve to `skills`")

    interface = manifest.get("interface")
    if not isinstance(interface, dict):
        fail("codex plugin.json: `interface` is required")
        return

    for key in sorted(set(interface) - CODEX_INTERFACE_KEYS):
        fail(f"codex plugin.json: `interface.{key}` is not accepted by Codex plugin validation")

    for key in CODEX_INTERFACE_REQUIRED:
        if not str(interface.get(key, "")).strip():
            fail(f"codex plugin.json: `interface.{key}` is required")

    capabilities = interface.get("capabilities")
    if not isinstance(capabilities, list) or not all(
        isinstance(v, str) and v.strip() for v in capabilities
    ):
        fail("codex plugin.json: `interface.capabilities` must be an array of strings")

    prompts = interface.get("defaultPrompt", interface.get("default_prompt"))
    if not isinstance(prompts, list) or not prompts:
        fail("codex plugin.json: `interface.defaultPrompt` is required")
    else:
        if len(prompts) > 3:
            fail("codex plugin.json: `interface.defaultPrompt` keeps at most 3 entries")
        for prompt in prompts:
            if len(prompt) > 128:
                fail(f"codex plugin.json: defaultPrompt entry over 128 chars: {prompt[:40]}...")

    color = interface.get("brandColor")
    if color is not None and not HEX_COLOR.match(color):
        fail("codex plugin.json: `interface.brandColor` must use #RRGGBB")


def check_claude_manifest() -> None:
    manifest = load_json(PLUGIN / ".claude-plugin" / "plugin.json")
    if manifest is None:
        return

    if not str(manifest.get("name", "")).strip():
        fail("claude plugin.json: `name` is required")

    for key in ("skills", "commands"):
        value = manifest.get(key)
        paths = [value] if isinstance(value, str) else (value or [])
        for raw in paths:
            if not (PLUGIN / raw.lstrip("./")).is_dir():
                fail(f"claude plugin.json: `{key}` points at missing directory {raw}")


def check_marketplaces() -> None:
    claude = load_json(REPO / ".claude-plugin" / "marketplace.json")
    if claude is not None:
        for entry in claude.get("plugins", []):
            source = entry.get("source")
            if isinstance(source, str) and not (REPO / source.lstrip("./")).is_dir():
                fail(f"claude marketplace.json: source {source} does not exist")
        if not claude.get("owner", {}).get("name"):
            fail("claude marketplace.json: `owner.name` is required")

    codex = load_json(REPO / ".agents" / "plugins" / "marketplace.json")
    if codex is not None:
        if not codex.get("plugins"):
            fail("codex marketplace.json: `plugins` is required")
        for entry in codex.get("plugins", []):
            policy = entry.get("policy", {})
            if policy.get("installation") not in {
                "NOT_AVAILABLE", "AVAILABLE", "INSTALLED_BY_DEFAULT"
            }:
                fail(f"codex marketplace.json: bad policy.installation for {entry.get('name')}")
            if policy.get("authentication") not in {"ON_INSTALL", "ON_USE"}:
                fail(f"codex marketplace.json: bad policy.authentication for {entry.get('name')}")
            if not entry.get("category"):
                fail(f"codex marketplace.json: `category` is required for {entry.get('name')}")
            source = entry.get("source", {})
            # Paths resolve against the marketplace root, which is the repo root
            # for <repo>/.agents/plugins/marketplace.json.
            if source.get("source") != "local":
                fail(f"codex marketplace.json: unexpected source type {source.get('source')}")
            elif not (REPO / source.get("path", "").lstrip("./")).is_dir():
                fail(f"codex marketplace.json: source path {source.get('path')} does not exist")


def check_pi_manifest() -> None:
    package = load_json(REPO / "package.json")
    if package is None:
        return

    pi = package.get("pi")
    if not isinstance(pi, dict):
        fail("package.json: `pi` manifest is required for pi to load this as a package")
        return

    for key in ("skills", "prompts"):
        for raw in pi.get(key, []):
            if not (REPO / raw.lstrip("./")).is_dir():
                fail(f"package.json: pi.{key} points at missing directory {raw}")

    if "pi-package" not in package.get("keywords", []):
        fail("package.json: keywords should include `pi-package` for discoverability")


def check_skills() -> None:
    skills_dir = PLUGIN / "skills"
    if not skills_dir.is_dir():
        fail("plugins/agent-os/skills/ is missing")
        return

    found = 0
    for skill_dir in sorted(skills_dir.iterdir()):
        if not skill_dir.is_dir() or skill_dir.name.startswith("."):
            continue
        found += 1
        skill_md = skill_dir / "SKILL.md"
        if not skill_md.is_file():
            fail(f"skill `{skill_dir.name}` is missing SKILL.md")
            continue

        text = skill_md.read_text(encoding="utf-8")
        if not text.startswith("---\n"):
            fail(f"skill `{skill_dir.name}`: no frontmatter")
            continue
        end = text.find("\n---", 4)
        if end == -1:
            fail(f"skill `{skill_dir.name}`: frontmatter is not closed")
            continue
        try:
            fm = yaml.safe_load(text[4:end])
        except yaml.YAMLError as exc:
            fail(f"skill `{skill_dir.name}`: frontmatter is not valid YAML: {exc}")
            continue
        if not isinstance(fm, dict):
            fail(f"skill `{skill_dir.name}`: frontmatter must be a mapping")
            continue

        name = fm.get("name", "")
        if name != skill_dir.name:
            fail(f"skill `{skill_dir.name}`: frontmatter name `{name}` must match the directory")
        if not SKILL_NAME.match(str(name)) or len(str(name)) > 64:
            fail(f"skill `{skill_dir.name}`: name must be lowercase, hyphenated, max 64 chars")

        description = str(fm.get("description", "")).strip()
        if not description:
            fail(f"skill `{skill_dir.name}`: `description` is required")
        elif len(description) > 1024:
            fail(f"skill `{skill_dir.name}`: description is {len(description)} chars, max 1024")

        disable = fm.get("disable-model-invocation", fm.get("disable_model_invocation"))
        if disable not in (None, False):
            fail(f"skill `{skill_dir.name}`: Codex requires disable-model-invocation to be false")

        command = (fm.get("metadata") or {}).get("agent-os-command")
        if not command:
            fail(f"skill `{skill_dir.name}`: metadata.agent-os-command is required")
        elif not (PLUGIN / "commands" / f"{command}.md").is_file():
            fail(f"skill `{skill_dir.name}`: no generated command for `{command}`")

    if found == 0:
        fail("no skills found")


def main() -> None:
    check_codex_manifest()
    check_claude_manifest()
    check_marketplaces()
    check_pi_manifest()
    check_skills()

    if errors:
        print("Plugin validation failed:")
        for error in errors:
            print(f"- {error}")
        sys.exit(1)
    print(f"Plugin validation passed: {PLUGIN.relative_to(REPO)}")


if __name__ == "__main__":
    main()
