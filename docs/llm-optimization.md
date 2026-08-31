# LLM optimization and CCO router

Agent OS can teach a repeatable model-selection method and produce an
execution plan for
[`@cloud-computing-oy/llm-router`](https://github.com/Cloud-Computing-Oy/cco-llm-router).
The optimizer is the decision layer; the router remains the credential,
availability, fallback, usage, and provider-budget layer.

The optimizer never calls a provider and never reads API keys. Its catalog is
operator-controlled because model availability, prices, contracts, and data
handling terms change independently.

## Choose a plan

```bash
./scripts/llm-optimize.sh recommend \
  --task coding \
  --risk high \
  --strategy balanced \
  --input-tokens 30000 \
  --output-tokens 5000 \
  --budget-usd 0.50 \
  --data-class internal \
  --router cco \
  --format json
```

The JSON `execution.roles[].selector` values can be passed to the router:

```ts
import { resolveModel } from '@cloud-computing-oy/llm-router';
import { generateText } from 'ai';

const { model } = resolveModel(plan.execution.roles[0].selector);
const result = await generateText({ model, prompt });
```

Direct selectors are intentional: the optimizer has already selected a
quality and price point. A product may instead map a stable task to a
service-specific alias when controlled fallback is preferable.

## Safety boundary

- `public`, `internal`, `confidential`, and `restricted` are hard catalog
  filters, not scoring hints.
- A model is never assumed safe merely because its API key exists.
- Kimi K3 is an explicit public-data pilot. It requires both
  `--allow-pilot` and `--router cco`; it is not eligible for internal,
  customer, legal, invoice, personal, confidential, or restricted content.
- High-risk work uses planner, worker, and independent critic roles and still
  requires human review before a material action.
- The catalog's capability scores are local calibration inputs, not provider
  claims. Update them using measured acceptance rate, corrections, latency,
  cost, and incidents.

## Operate the catalog

```bash
./scripts/llm-optimize.sh validate
./scripts/llm-optimize.sh list
./scripts/llm-optimize.sh lesson
```

Before production use, verify each enabled model ID, current price, supported
modalities, context window, router provider support, and approved data
classes. Add a `cco_router.selector` only when the router can resolve it.

The generated estimate is a planning estimate. The router's actual usage and
monthly provider budgets remain authoritative at runtime.
