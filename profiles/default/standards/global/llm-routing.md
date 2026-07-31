# LLM routing

- Classify the task, data, risk, modalities, context size, and budget before
  choosing a model.
- Use the cheapest eligible model that clears the required quality gate.
- Reserve frontier models for ambiguity, planning, difficult reasoning, and
  high-impact review; use efficient models for bounded and repetitive work.
- For material work, separate planner, worker, and critic roles and prefer an
  independent provider for critique.
- Treat provider data-handling approval as a hard constraint.
- Use `./scripts/llm-optimize.sh recommend --router cco` to create a
  machine-readable plan for `@cloud-computing-oy/llm-router`.
- Never include API keys in prompts, plans, logs, or catalog files.
- Keep pilot models explicit-only. Kimi K3 is public-data-only and must never
  enter a default fallback chain.
- Measure actual cost, latency, acceptance, corrections, and incidents; use
  those measurements to recalibrate the catalog.
