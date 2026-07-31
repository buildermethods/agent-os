# Learn LLM strategy

Teach the user to choose models by requirements instead of brand.

1. Run `./scripts/llm-optimize.sh lesson`.
2. Use the user's real task as an example.
3. Compare economy, balanced, and quality plans with the same token estimate.
4. Explain hard constraints: data approval, context, modality, availability,
   and budget.
5. Explain role specialization: planner reduces ambiguity, worker performs
   bounded work economically, and an independent critic challenges important
   results.
6. End with a measurable experiment and success criteria.

State clearly that catalog capability scores are local calibration inputs and
that provider prices and model availability must be revalidated.
