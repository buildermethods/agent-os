# Optimize LLM use

Create a cost-aware, capability-aware, and privacy-safe model plan before
performing substantial LLM work.

## Process

1. Classify the task as coding, research, analysis, writing, vision, or
   routine.
2. Ask for or infer the risk, data class, modalities, approximate token
   volume, and maximum budget. Never infer that confidential data is public.
3. Run:

   ```bash
   ./scripts/llm-optimize.sh recommend \
     --task <task> \
     --risk <low|medium|high> \
     --strategy <economy|balanced|quality> \
     --input-tokens <estimate> \
     --output-tokens <estimate> \
     --data-class <public|internal|confidential|restricted> \
     --router cco \
     --format json
   ```

4. Explain why each role was selected and show the estimated total cost.
5. If execution is authorized, pass each emitted selector to
   `@cloud-computing-oy/llm-router`. Keep credentials in the router runtime.
6. Capture actual cost, latency, acceptance, corrections, and incidents for
   later catalog calibration.

Do not execute when the result is `no_eligible_models` or `budget_too_low`.
High-risk plans require human review before any material action. Pilot models
require explicit user approval and `--allow-pilot`.
