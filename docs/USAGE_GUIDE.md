# Agent OS Complete Usage Guide

This guide explains how to install, operate, customize, and maintain this
Agent OS distribution. It also covers the provider-neutral LLM optimizer and
its integration with
[`@cloud-computing-oy/llm-router`](https://github.com/Cloud-Computing-Oy/cco-llm-router).

## 1. What Agent OS does

Agent OS stores durable product knowledge, engineering standards, and agent
workflows inside a repository. This gives every supported coding assistant the
same operating context without depending on a particular chat history or
vendor.

The system has four main layers:

1. **Profiles** define reusable organization and team standards.
2. **Project installation** places resolved standards and tool-specific
   commands into a target repository.
3. **Agent adapters** expose the workflows to Claude Code, Codex, Cursor, and
   Antigravity.
4. **LLM optimization** recommends an economical and safe combination of
   models, then emits an optional execution plan for `cco-llm-router`.

The installer manages only paths recorded in its manifest. Existing project
content and unrelated agent skills are preserved.

## 2. Requirements

- Bash 4 or newer
- Python 3.10 or newer for LLM optimization
- `awk`, `find`, `sort`, `sha256sum`, and `realpath`
- Git for bootstrap installation
- API credentials only if a separate application executes an LLM plan

Agent OS itself does not need an LLM API key. The optimizer reads model
metadata and produces a plan; it does not send prompts to providers.

## 3. Reproducible installation

Clone or download a fixed release:

```bash
git clone https://github.com/jarmo-blip/agent-os.git
cd agent-os
git checkout v3.1.1
```

Install Agent OS into a project:

```bash
./scripts/project-install.sh \
  --project-dir /absolute/path/to/project \
  --profile default \
  --target claude,codex \
  --dry-run

./scripts/project-install.sh \
  --project-dir /absolute/path/to/project \
  --profile default \
  --target claude,codex \
  --yes
```

Always use `--dry-run` first in an existing project. It validates the profile,
target adapters, managed paths, and conflicts without writing files.

You can also bootstrap directly from a checked-out installer:

```bash
./install_agent_os.sh \
  --project-dir /absolute/path/to/project \
  --target claude,codex,cursor,antigravity \
  --ref v3.1.1
```

Pin a release tag or commit in production. Avoid a moving branch such as
`main` when reproducibility matters.

## 4. Agent adapters

Select one or more comma-separated targets:

| Target | Installed location | Typical use |
| --- | --- | --- |
| `claude` | `.claude/commands/agent-os/` | Claude Code commands |
| `codex` | `.agents/skills/agent-os-*/SKILL.md` | Codex skills |
| `cursor` | `.cursor/commands/agent-os/` | Cursor commands |
| `antigravity` | `.agent/workflows/agent-os/` | Antigravity workflows |

Example:

```bash
./scripts/project-install.sh \
  --project-dir "$PWD/../my-product" \
  --profile default \
  --target claude,codex,cursor,antigravity \
  --yes
```

An adapter update does not need to rewrite project standards:

```bash
./scripts/project-install.sh \
  --project-dir /absolute/path/to/project \
  --target codex \
  --commands-only \
  --yes
```

Agent OS preserves unrelated skills and commands outside its owned adapter
directories.

## 5. Profiles and standards

Profiles live under:

```text
profiles/<profile>/standards/
```

The default profile includes global technology and LLM-routing guidance.
Create a team profile when multiple projects share additional rules:

```yaml
# config.yml
version: 3.1
default_profile: team
profiles:
  team:
    inherits_from: default
```

Parent standards are applied first. A child profile overrides a parent file
only when both use the same relative path.

Recommended structure:

```text
profiles/team/standards/
├── global/
│   ├── security.md
│   └── llm-routing.md
├── backend/
│   └── api.md
└── frontend/
    └── accessibility.md
```

Use lowercase profile names containing letters, numbers, hyphens, or
underscores. Path traversal and symbolic-link escapes are rejected.

## 6. Updating an installed project

Run the same installation command again:

```bash
./scripts/project-install.sh \
  --project-dir /absolute/path/to/project \
  --profile team \
  --target claude,codex \
  --dry-run
```

During an update Agent OS:

1. resolves profile inheritance;
2. stages the complete installation;
3. validates all managed paths;
4. checks the previous manifest and local modifications;
5. replaces the managed standards atomically;
6. writes a new manifest.

If a manifest-managed standard was edited locally, the update stops. Move the
intentional change into the source profile or explicitly use `--force` after
reviewing the diff:

```bash
./scripts/project-install.sh \
  --project-dir /absolute/path/to/project \
  --profile team \
  --target claude,codex \
  --force \
  --yes
```

Do not use `--force` as a routine update option.

## 7. Synchronizing project knowledge back to a profile

Preview all project standards:

```bash
./scripts/sync-to-profile.sh \
  --project-dir /absolute/path/to/project \
  --profile team \
  --all \
  --dry-run
```

Apply reviewed changes:

```bash
./scripts/sync-to-profile.sh \
  --project-dir /absolute/path/to/project \
  --profile team \
  --all \
  --overwrite
```

When `--overwrite` replaces profile content, Agent OS creates a recoverable
backup under `profiles/<profile>/.backups/`.

Use synchronization to promote proven project practices into reusable team
standards. Do not synchronize secrets, customer data, generated output, or
project-specific credentials.

## 8. LLM optimization concepts

Start model selection from requirements instead of provider preference. The
optimizer evaluates:

- task type: coding, research, analysis, writing, vision, or routine;
- risk: low, medium, or high;
- strategy: economy, balanced, or quality;
- expected input and output tokens;
- context-window and modality requirements;
- public, internal, confidential, or restricted data;
- maximum estimated cost;
- cached-input ratio and batch discounts;
- provider allow-lists and execution-adapter support.

Low-risk work uses one worker. Medium-risk work adds a critic. High-risk work
uses planner, worker, and critic roles and requires human review before a
material action.

The capability scores in `llm/catalog.json` are local calibration inputs, not
provider guarantees. Update them using measured outcomes.

## 9. Learning the selection strategy

Display the built-in lesson:

```bash
./scripts/llm-optimize.sh lesson
```

List catalog models:

```bash
./scripts/llm-optimize.sh list
```

Validate catalog structure and pricing freshness:

```bash
./scripts/llm-optimize.sh validate
```

The validation command warns when recorded prices are older than 90 days.
Before production use, verify model IDs, prices, context windows, modalities,
contractual data handling, and regional availability with each provider.

## 10. Creating an optimization plan

Balanced coding plan:

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

Economical batch-writing plan with cached input:

```bash
./scripts/llm-optimize.sh recommend \
  --task writing \
  --risk medium \
  --strategy economy \
  --input-tokens 100000 \
  --output-tokens 20000 \
  --cached-input-ratio 0.70 \
  --batch \
  --budget-usd 1.00 \
  --data-class public \
  --router cco \
  --format json
```

Multimodal research plan:

```bash
./scripts/llm-optimize.sh recommend \
  --task research \
  --risk medium \
  --strategy quality \
  --modality image \
  --input-tokens 50000 \
  --output-tokens 8000 \
  --data-class internal \
  --router cco
```

Restrict candidates to a provider by repeating `--provider`:

```bash
./scripts/llm-optimize.sh recommend \
  --task analysis \
  --provider openai \
  --provider google \
  --data-class internal
```

Exit status `0` means a plan was produced. Exit status `3` means no eligible
model or an insufficient budget. Invalid input or catalog data returns `2`.

## 11. Understanding the JSON result

A successful CCO plan contains:

```json
{
  "status": "ok",
  "estimated_cost_usd": 0.13725,
  "roles": [
    {
      "role": "planner",
      "model": "openai/gpt-5.6-terra",
      "provider": "openai",
      "estimated_cost_usd": 0.04125
    }
  ],
  "execution": {
    "adapter": "@cloud-computing-oy/llm-router",
    "mode": "plan_only",
    "roles": [
      {
        "role": "planner",
        "selector": "openai:gpt-5.6-terra",
        "direct": true
      }
    ]
  }
}
```

The estimate supports planning and approval. Actual router usage and
provider-budget records are authoritative after execution.

## 12. Executing with cco-llm-router

Install the private router according to its repository instructions, then
resolve each selected role:

```ts
import { resolveModel } from '@cloud-computing-oy/llm-router';
import { generateText } from 'ai';

type PlannedRole = {
  role: string;
  selector: string;
  direct: boolean;
};

async function executeRole(role: PlannedRole, prompt: string) {
  const { model, specs } = resolveModel(role.selector);
  const result = await generateText({ model, prompt });
  return {
    role: role.role,
    text: result.text,
    resolvedSpecs: specs,
    usage: result.usage
  };
}
```

Keep API keys in the router's runtime environment. Never add credentials to
the optimizer catalog, generated plan, source control, prompts, or logs.

Direct selectors preserve the optimizer's selected quality and price point.
A service-specific router alias is appropriate when a controlled fallback
chain is more important than exact-model execution.

## 13. Privacy and pilot models

Data class is a hard eligibility filter:

- **public**: approved public information;
- **internal**: non-public operational information;
- **confidential**: customer, employee, legal, financial, or sensitive
  business information;
- **restricted**: secrets or specially controlled information.

If the catalog has no approved model for the selected class, optimization
stops with `no_eligible_models`. Do not weaken the data class to obtain a
cheaper result.

Kimi K3 is an explicit public-data pilot. It is excluded unless all of the
following are true:

1. the data is genuinely public;
2. the user explicitly chooses pilot participation;
3. `--allow-pilot` is supplied;
4. the CCO router adapter is selected.

Example:

```bash
./scripts/llm-optimize.sh recommend \
  --task coding \
  --risk low \
  --strategy quality \
  --provider moonshot \
  --data-class public \
  --router cco \
  --allow-pilot \
  --format json
```

Never use this pilot for customer, legal, invoice, personal, internal,
confidential, or restricted data. It must not be added to a default fallback
chain.

## 14. Cost and quality operations

For every repeated workflow, record:

- planned and actual cost;
- input, cached-input, and output tokens;
- latency and failure rate;
- first-pass acceptance rate;
- human corrections;
- critic disagreements;
- incidents and data-handling exceptions.

Recalibrate catalog scores using evidence. A cheap model with frequent
corrections may be more expensive than a stronger model. Conversely, a
frontier model adds little value to deterministic extraction, formatting, or
classification that a smaller model already performs reliably.

Recommended pattern:

1. spend high-quality tokens on task shaping and ambiguity;
2. use an efficient worker for bounded execution;
3. use an independent critic for material outcomes;
4. escalate unresolved disagreement to a human;
5. cache stable shared context and batch latency-tolerant work;
6. minimize context independently for each role.

## 15. Diagnostics and removal

Inspect an installation:

```bash
./scripts/doctor.sh --project-dir /absolute/path/to/project
```

Preview removal:

```bash
./scripts/uninstall.sh \
  --project-dir /absolute/path/to/project \
  --dry-run
```

Remove only manifest-managed Agent OS content:

```bash
./scripts/uninstall.sh \
  --project-dir /absolute/path/to/project \
  --yes
```

The uninstaller preserves unmanaged project standards. It refuses broad
removal when a compatible manifest is absent.

## 16. Troubleshooting

### Installation reports local changes

A manifest-managed standard was edited in the target project. Review the
change and synchronize it into a profile, restore the managed version, or use
`--force` only after deciding which version is authoritative.

### Installation rejects a symbolic link

Managed paths may not traverse symbolic links. Replace the link with a normal
directory or choose a different project path.

### No eligible LLM models

Check the data class, required modalities, context estimate, provider filter,
pilot setting, and `cco_router` mapping. Do not bypass a privacy restriction.

### Budget is too low

The JSON result includes `minimum_estimated_cost_usd` when a valid plan exists
above the requested budget. Reduce token volume, use a more economical
strategy, enable legitimate caching or batching, or obtain budget approval.

### Router reports a missing provider

The generated plan does not prove that runtime credentials are configured.
Set the provider key in the router environment or rerun optimization with a
provider allow-list that matches the deployed environment.

### Pricing warning

Update the relevant catalog entry only after checking an authoritative
provider source. Record the verification date in `price_checked_at`.

## 17. Development and validation

Run the same checks used by CI:

```bash
bash -n scripts/*.sh install_agent_os.sh tests/run.sh
shellcheck -x scripts/*.sh install_agent_os.sh tests/run.sh
./tests/run.sh
git diff --check
```

Tests operate in isolated temporary directories. They cover installation,
adapter preservation, path and symlink safety, nested standards, local-change
protection, synchronization backups, scoped uninstall, diagnostics, catalog
validation, CCO router plans, confidential-data denial, and explicit Kimi
pilot selection.

## 18. Production checklist

Before adopting Agent OS in a production repository:

- pin a release tag or exact commit;
- preview installation with `--dry-run`;
- review resolved standards and adapter targets;
- confirm the manifest contains only intended paths;
- verify model IDs, pricing, privacy approvals, and runtime router support;
- set provider budgets and alerts in `cco-llm-router`;
- keep credentials outside source control;
- require human approval for high-risk or material actions;
- measure real cost and quality;
- run diagnostics and CI after updates;
- keep rollback information and profile backups.

Agent OS should make model use more deliberate and measurable. It must not
turn cost optimization into silent quality degradation or weaken privacy,
human-review, and provider-governance requirements.
