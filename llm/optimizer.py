#!/usr/bin/env python3
"""Transparent, provider-neutral LLM plan optimizer."""

from __future__ import annotations

import argparse
import datetime as dt
import itertools
import json
import math
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

TASK_WEIGHTS = {
    "coding": {"coding": 0.45, "reasoning": 0.25, "tools": 0.20, "speed": 0.10},
    "research": {"research": 0.40, "reasoning": 0.25, "tools": 0.20, "writing": 0.15},
    "analysis": {"reasoning": 0.55, "research": 0.20, "writing": 0.15, "tools": 0.10},
    "writing": {"writing": 0.55, "reasoning": 0.20, "research": 0.15, "speed": 0.10},
    "vision": {"vision": 0.55, "reasoning": 0.20, "research": 0.15, "speed": 0.10},
    "routine": {"speed": 0.45, "tools": 0.20, "writing": 0.15, "reasoning": 0.20},
}

STRATEGY_WEIGHTS = {
    "economy": (0.45, 0.55),
    "balanced": (0.70, 0.30),
    "quality": (0.90, 0.10),
}

ROLE_TOKENS = {
    "planner": (0.35, 0.20),
    "worker": (1.00, 1.00),
    "critic": (0.50, 0.30),
}

DATA_CLASS_ORDER = ["public", "internal", "confidential", "restricted"]


class CatalogError(ValueError):
    """Invalid catalog data."""


@dataclass(frozen=True)
class Candidate:
    raw: dict[str, Any]
    quality: float
    cost: float
    utility: float

    @property
    def id(self) -> str:
        return str(self.raw["id"])

    @property
    def provider(self) -> str:
        return str(self.raw["provider"])


def load_catalog(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise CatalogError(f"cannot read catalog: {exc}") from exc
    validate_catalog(data)
    return data


def validate_catalog(data: dict[str, Any]) -> None:
    if data.get("schema_version") != 1:
        raise CatalogError("schema_version must be 1")
    models = data.get("models")
    if not isinstance(models, list) or not models:
        raise CatalogError("models must be a non-empty list")
    seen: set[str] = set()
    required = {
        "id", "provider", "model", "enabled", "input_usd", "cached_input_usd",
        "output_usd", "context_tokens", "modalities", "data_classes",
        "capabilities", "strengths", "source", "price_checked_at",
    }
    for index, model in enumerate(models):
        missing = required - set(model)
        if missing:
            raise CatalogError(f"model {index} missing: {', '.join(sorted(missing))}")
        model_id = model["id"]
        if model_id in seen:
            raise CatalogError(f"duplicate model id: {model_id}")
        seen.add(model_id)
        if min(model["input_usd"], model["cached_input_usd"], model["output_usd"]) < 0:
            raise CatalogError(f"negative price: {model_id}")
        if model["context_tokens"] <= 0:
            raise CatalogError(f"invalid context size: {model_id}")
        router = model.get("cco_router")
        if router is not None:
            if not isinstance(router, dict) or not isinstance(router.get("selector"), str):
                raise CatalogError(f"invalid cco_router selector: {model_id}")
        for capability, score in model["capabilities"].items():
            if capability not in {"reasoning", "coding", "research", "writing", "vision", "tools", "speed"}:
                raise CatalogError(f"unknown capability {capability}: {model_id}")
            if not isinstance(score, (int, float)) or not 1 <= score <= 5:
                raise CatalogError(f"capability score outside 1..5: {model_id}/{capability}")


def estimate_cost(
    model: dict[str, Any],
    input_tokens: int,
    output_tokens: int,
    cached_ratio: float,
    batch: bool,
) -> float:
    uncached = input_tokens * (1.0 - cached_ratio)
    cached = input_tokens * cached_ratio
    cost = (
        uncached * float(model["input_usd"])
        + cached * float(model["cached_input_usd"])
        + output_tokens * float(model["output_usd"])
    ) / 1_000_000
    if batch:
        cost *= 1.0 - float(model.get("batch_discount", 0.0))
    return cost


def task_quality(model: dict[str, Any], task: str) -> float:
    weights = TASK_WEIGHTS[task]
    capabilities = model["capabilities"]
    return sum(float(capabilities.get(name, 1)) * weight for name, weight in weights.items())


def eligible_models(catalog: dict[str, Any], args: argparse.Namespace) -> list[dict[str, Any]]:
    required_modalities = set(args.modality)
    needed_context = args.input_tokens + args.output_tokens
    requested_level = DATA_CLASS_ORDER.index(args.data_class)
    eligible = []
    for model in catalog["models"]:
        if not model["enabled"]:
            continue
        if model.get("pilot") and not args.allow_pilot:
            continue
        if args.router == "cco" and not model.get("cco_router"):
            continue
        if needed_context > int(model["context_tokens"]):
            continue
        if not required_modalities.issubset(set(model["modalities"])):
            continue
        allowed_levels = {DATA_CLASS_ORDER.index(item) for item in model["data_classes"]}
        if requested_level not in allowed_levels:
            continue
        if args.provider and model["provider"] not in args.provider:
            continue
        eligible.append(model)
    return eligible


def rank_candidates(catalog: dict[str, Any], args: argparse.Namespace) -> list[Candidate]:
    models = eligible_models(catalog, args)
    if not models:
        return []
    raw = []
    for model in models:
        quality = task_quality(model, args.task)
        cost = estimate_cost(
            model, args.input_tokens, args.output_tokens,
            args.cached_input_ratio, args.batch,
        )
        raw.append((model, quality, cost))
    max_cost = max((item[2] for item in raw), default=0.0) or 1.0
    quality_weight, cost_weight = STRATEGY_WEIGHTS[args.strategy]
    ranked = []
    for model, quality, cost in raw:
        normalized_quality = quality / 5.0
        normalized_cost = cost / max_cost
        utility = quality_weight * normalized_quality + cost_weight * (1.0 - normalized_cost)
        ranked.append(Candidate(model, quality, cost, utility))
    return sorted(ranked, key=lambda item: (-item.utility, item.cost, item.id))


def role_candidate(candidate: Candidate, role: str, args: argparse.Namespace) -> dict[str, Any]:
    input_multiplier, output_multiplier = ROLE_TOKENS[role]
    role_cost = estimate_cost(
        candidate.raw,
        math.ceil(args.input_tokens * input_multiplier),
        math.ceil(args.output_tokens * output_multiplier),
        args.cached_input_ratio,
        args.batch,
    )
    selected = {
        "role": role,
        "model": candidate.id,
        "provider": candidate.provider,
        "quality_score": round(candidate.quality, 3),
        "estimated_cost_usd": round(role_cost, 6),
        "why": candidate.raw["strengths"],
    }
    if candidate.raw.get("cco_router"):
        selected["cco_router"] = candidate.raw["cco_router"]
    return selected


def build_plan(ranked: list[Candidate], args: argparse.Namespace) -> dict[str, Any]:
    if not ranked:
        return {"status": "no_eligible_models", "roles": [], "estimated_cost_usd": 0.0}

    min_quality = {"low": 2.0, "medium": 3.0, "high": 3.8}[args.risk]
    viable = [candidate for candidate in ranked if candidate.quality >= min_quality]
    if not viable:
        viable = ranked

    if args.risk == "low":
        combinations = [(candidate,) for candidate in viable]
        role_names = ("worker",)
    elif args.risk == "medium":
        combinations = [
            pair for pair in itertools.permutations(viable[:8], 2)
            if pair[0].id != pair[1].id
        ]
        role_names = ("worker", "critic")
    else:
        combinations = [
            trio for trio in itertools.permutations(viable[:8], 3)
            if len({item.id for item in trio}) == 3
            and trio[0].provider != trio[2].provider
        ]
        role_names = ("planner", "worker", "critic")

    plans = []
    for combination in combinations:
        roles = [
            role_candidate(candidate, role, args)
            for candidate, role in zip(combination, role_names, strict=True)
        ]
        total = sum(role["estimated_cost_usd"] for role in roles)
        provider_bonus = len({role["provider"] for role in roles}) * 0.03
        score = sum(candidate.utility for candidate in combination) + provider_bonus
        if args.budget_usd is not None and total > args.budget_usd:
            continue
        plans.append((score, total, roles))

    if not plans:
        cheapest = min(
            (
                sum(
                    role_candidate(candidate, role, args)["estimated_cost_usd"]
                    for candidate, role in zip(combo, role_names, strict=True)
                ),
                combo,
            )
            for combo in combinations
        ) if combinations else None
        return {
            "status": "budget_too_low",
            "roles": [],
            "estimated_cost_usd": 0.0,
            "minimum_estimated_cost_usd": round(cheapest[0], 6) if cheapest else None,
        }

    score, total, roles = max(plans, key=lambda item: (item[0], -item[1]))
    result = {
        "status": "ok",
        "roles": roles,
        "estimated_cost_usd": round(total, 6),
        "human_review_required": args.risk == "high",
        "execution_rules": [
            "Send only the minimum context required for each role.",
            "Do not send confidential data unless the catalog explicitly permits it.",
            "The critic must receive acceptance criteria and evidence, not hidden reasoning.",
            "Escalate disagreement or material uncertainty to a human reviewer.",
        ],
    }
    if args.router == "cco":
        result["execution"] = {
            "adapter": "@cloud-computing-oy/llm-router",
            "repository": "https://github.com/Cloud-Computing-Oy/cco-llm-router",
            "mode": "plan_only",
            "roles": [
                {
                    "role": role["role"],
                    "selector": role["cco_router"]["selector"],
                    "direct": bool(role["cco_router"].get("direct", True)),
                }
                for role in roles
            ],
            "rules": [
                "Resolve each selector with resolveModel(selector).",
                "Keep API keys in the router runtime; never put credentials in this plan.",
                "Record actual token usage and cost after every call.",
                "Do not silently replace a selected direct model with a lower-quality fallback.",
            ],
        }
    return result


def stale_pricing_warnings(catalog: dict[str, Any], days: int = 90) -> list[str]:
    today = dt.date.today()
    warnings = []
    for model in catalog["models"]:
        try:
            checked = dt.date.fromisoformat(model["price_checked_at"])
        except ValueError:
            warnings.append(f"{model['id']}: invalid price_checked_at")
            continue
        age = (today - checked).days
        if age > days:
            warnings.append(f"{model['id']}: pricing is {age} days old")
    return warnings


def render_text(result: dict[str, Any], ranked: list[Candidate], args: argparse.Namespace) -> str:
    lines = [
        f"LLM plan: task={args.task} risk={args.risk} strategy={args.strategy}",
        f"Status: {result['status']}",
    ]
    if result["status"] == "ok":
        lines.append(f"Estimated total: ${result['estimated_cost_usd']:.6f}")
        for role in result["roles"]:
            lines.append(
                f"- {role['role']}: {role['model']} "
                f"(${role['estimated_cost_usd']:.6f}, quality {role['quality_score']:.2f}/5)"
            )
            lines.append(f"  strengths: {', '.join(role['why'])}")
        if result.get("human_review_required"):
            lines.append("- human review: required before material action")
    elif result["status"] == "budget_too_low":
        lines.append(
            f"Minimum estimated plan cost: ${result['minimum_estimated_cost_usd']:.6f}"
        )
    lines.append("Top eligible models:")
    for candidate in ranked[:5]:
        lines.append(
            f"- {candidate.id}: quality {candidate.quality:.2f}/5, "
            f"single-call estimate ${candidate.cost:.6f}"
        )
    return "\n".join(lines)


def lesson() -> str:
    return """LLM optimization in six rules

1. Start with task requirements, not a favorite provider.
2. Use the cheapest model that clears the required quality and capability gate.
3. Spend frontier-model tokens on planning, ambiguity, and high-impact review.
4. Use efficient models for bounded execution, extraction, formatting, and repetition.
5. For material decisions, use an independent critic from another model or provider.
6. Measure real outcomes: cost, latency, acceptance rate, corrections, and incidents.

Never route confidential data from price alone. Availability, contractual data
handling, residency, and human approval are hard constraints before optimization."""


def parser() -> argparse.ArgumentParser:
    default_catalog = Path(__file__).with_name("catalog.json")
    root = argparse.ArgumentParser(description=__doc__)
    root.add_argument("--catalog", type=Path, default=default_catalog)
    sub = root.add_subparsers(dest="command", required=True)

    sub.add_parser("validate")
    sub.add_parser("list")
    sub.add_parser("lesson")

    recommend = sub.add_parser("recommend")
    recommend.add_argument("--task", choices=sorted(TASK_WEIGHTS), required=True)
    recommend.add_argument("--risk", choices=["low", "medium", "high"], default="medium")
    recommend.add_argument("--strategy", choices=sorted(STRATEGY_WEIGHTS), default="balanced")
    recommend.add_argument("--input-tokens", type=int, default=10000)
    recommend.add_argument("--output-tokens", type=int, default=2000)
    recommend.add_argument("--budget-usd", type=float)
    recommend.add_argument("--cached-input-ratio", type=float, default=0.0)
    recommend.add_argument("--batch", action="store_true")
    recommend.add_argument("--modality", action="append", default=["text"])
    recommend.add_argument("--data-class", choices=DATA_CLASS_ORDER, default="internal")
    recommend.add_argument("--provider", action="append")
    recommend.add_argument(
        "--router", choices=["none", "cco"], default="none",
        help="restrict selections to an execution adapter and emit its manifest",
    )
    recommend.add_argument(
        "--allow-pilot", action="store_true",
        help="allow explicitly opt-in public-data pilot models",
    )
    recommend.add_argument("--format", choices=["text", "json"], default="text")
    return root


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        catalog = load_catalog(args.catalog)
    except CatalogError as exc:
        print(f"catalog error: {exc}", file=sys.stderr)
        return 2

    if args.command == "validate":
        print(f"catalog valid: {len(catalog['models'])} models")
        for warning in stale_pricing_warnings(catalog):
            print(f"warning: {warning}")
        return 0
    if args.command == "list":
        for model in catalog["models"]:
            state = "enabled" if model["enabled"] else "disabled"
            print(f"{model['id']}\t{state}\t{model['context_tokens']}\t{','.join(model['modalities'])}")
        return 0
    if args.command == "lesson":
        print(lesson())
        return 0

    if args.input_tokens < 0 or args.output_tokens < 0:
        print("token counts must be non-negative", file=sys.stderr)
        return 2
    if not 0.0 <= args.cached_input_ratio <= 1.0:
        print("cached-input-ratio must be between 0 and 1", file=sys.stderr)
        return 2
    if args.budget_usd is not None and args.budget_usd < 0:
        print("budget-usd must be non-negative", file=sys.stderr)
        return 2

    ranked = rank_candidates(catalog, args)
    result = build_plan(ranked, args)
    result["request"] = {
        "task": args.task,
        "risk": args.risk,
        "strategy": args.strategy,
        "input_tokens": args.input_tokens,
        "output_tokens": args.output_tokens,
        "budget_usd": args.budget_usd,
        "data_class": args.data_class,
        "modalities": sorted(set(args.modality)),
        "router": args.router,
        "allow_pilot": args.allow_pilot,
    }
    result["catalog_updated_at"] = catalog["updated_at"]
    result["pricing_warnings"] = stale_pricing_warnings(catalog)
    if args.format == "json":
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print(render_text(result, ranked, args))
    return 0 if result["status"] == "ok" else 3


if __name__ == "__main__":
    raise SystemExit(main())
