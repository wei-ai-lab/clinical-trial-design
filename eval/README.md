# clinical-trial-design — LLM benchmarking

This directory holds the LLM-eval harness that scores a host LLM's ability to use the `clinical-trial-design` plugin correctly. It answers the user-facing question: **"for trial design, which model should I use?"** with empirical scores rather than vibes.

## What gets scored

For each scenario, the agent receives a clinical brief and must produce a complete design. We score across **six dimensions**:

| Dimension | What the agent has to do | Scored how |
|---|---|---|
| **Tool selection** | Pick the right MCP tool given the brief | Exact-match against the scenario's `expected.tool` |
| **Parameter mapping** | Translate clinical inputs to the tool's schema | Per-parameter check against `expected.parameters`; partial credit for close-but-off values within tolerance |
| **Precedent synthesis** | Cite at least one realistic public-trial precedent for the effect-size assumption (when applicable) | LLM-judge against `expected.precedents`; human-spot-check sampled |
| **Result interpretation** | Narrative summary correctly reflects the tool's output | LLM-judge against `expected.interpretation_keys` (must mention sample size, events, boundaries where applicable) |
| **End-to-end design** | Final design hits the scenario's expected output within tolerance | Sample size, events, total alpha within `expected.tolerances` |
| **Reasoning chain quality** | Populates `reasoning_chain` with appropriate `source_type` tags | Counts of each `source_type`; flags absent reasoning chain on non-default-input scenarios |

A composite score per (model, scenario) is `mean(d_1, d_2, ..., d_6)` with each dimension on `[0, 1]`. Per-model means across scenarios go into `MODEL_GUIDANCE.md`.

## Models tested (v0.0.10 scope: Claude family only)

The default suite runs against the **Claude family** — Opus 4.7, Sonnet 4.6, Haiku 4.5 — using the user's existing Anthropic credentials. This is a deliberate v0.0.10 scope decision so the planned pharma-skills comparison runs apples-to-apples across one model lineup rather than mixing vendors.

Cross-vendor coverage (GPT, Gemini, open-weight) is **out of v0.0.10 scope**. The harness preserves vendor adapter hooks at `harness/adapters/` (stubs only); adding a real adapter is a 1–2 hour lift per vendor and is documented as future work in `BETA_HANDOFF.md`. Treat single-vendor first as a feature, not a limitation: the relevant question for the comparison is "does our MCP help the host LLM produce a correct design more reliably and cheaply than skill-only", and that answer is uncoupled from the host LLM family.

## How to run

### One scenario, one model (smoke check)

```bash
cd eval
bash harness/run_one.sh \
  --scenario scenarios/2018_KEYNOTE-189_co_primary.yaml \
  --model claude-opus-4-7
python3 harness/score.py --run-dir <RUN_DIR> --scenario scenarios/2018_KEYNOTE-189_co_primary.yaml
```

### Full suite

```bash
bash harness/run_all.sh                                # all scenarios x available models
python3 harness/aggregate_scores.py                    # writes MODEL_GUIDANCE.md
```

## Scenario file shape

See `scenarios/_schema.yaml` for the complete spec. The minimum:

```yaml
id: <YYYY>_<TRIAL>_<focus>
prompt: |
  Free-text clinical brief that an agent would receive in conversation.
expected:
  tool: design_<...>
  parameters:
    <key>: <expected value>
  precedents: ["NCT01234567", "TRIAL-NAME"]   # optional, for synthesis scoring
  result_check:
    sample_size_total: { range: [<lo>, <hi>] }
    events_total:      { range: [<lo>, <hi>] }
    driver: <hypothesis name>                  # for multi-hypothesis
  interpretation_keys: ["sample size", "events", "boundary"]   # words the narrative must mention
  reasoning_chain:
    must_have_source_types: ["llm_precedent", "user_supplied"]
  tolerances:
    sample_size_pct: 10
    events_pct: 8
```

## Methodology rules

To prevent score inflation:

1. **Single-shot.** No retries, no chain-of-thought scaffolding inserted by the harness — the agent gets the prompt as-is.
2. **No leakage.** The harness does NOT show the agent the `expected` block. Score happens after the agent has finished.
3. **Human spot-check.** The LLM-judge dimensions (precedent synthesis, result interpretation) get a 10% human-validated sample with each release.
4. **Versioned.** Each MODEL_GUIDANCE.md entry is tagged with the eval-suite version + date + model snapshot.

## When to re-run

- After a new tool ships (the surface changed; old scores are stale).
- After a new model snapshot from any vendor.
- Before each release tag (gate item).

The scoring is deterministic per (scenario, model snapshot), so a stable surface + stable model snapshots give stable scores.
