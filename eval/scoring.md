# Scoring rubric

Each scored dimension returns a number in `[0, 1]`. The composite per (model, scenario) is the simple mean across the six dimensions; missing dimensions are dropped from the mean (not scored as 0).

## 1. Tool selection

| Outcome | Score |
|---|---|
| Agent invoked exactly the expected tool name | 1.0 |
| Agent invoked a related but wrong tool (e.g., `design_survival` instead of `design_co_primary` on a co-primary brief) | 0.5 |
| Agent invoked a clearly wrong tool, or no design tool at all | 0.0 |

`expected.tool` is the canonical tool name (`mcp__plugin_clinical-trial-design_clinical-trial-design__<tool_name>`). Match against the basename.

## 2. Parameter mapping

Per-parameter check. `expected.parameters` is a dict.

For each key in `expected.parameters`:

| Outcome | Score for this key |
|---|---|
| Numeric value exact (or within `range: [lo, hi]`) | 1.0 |
| Numeric value within ±20% of expected, but outside the explicit range | 0.5 |
| String value exact match | 1.0 |
| String value semantically equivalent (e.g., `"fixed-sequence"` vs `"hierarchical"`) | 0.7 |
| Missing or wrong | 0.0 |

Parameter dimension score = mean across all expected parameter keys.

## 3. Precedent synthesis

If `expected.precedents` is empty, this dimension is skipped (not scored as 0).

Otherwise, an LLM-judge sees the agent's narrative and the list of expected precedents, and scores:

| Outcome | Score |
|---|---|
| Narrative cites at least one precedent and uses it correctly to motivate an effect-size assumption | 1.0 |
| Narrative mentions a precedent but does not use it for a load-bearing assumption | 0.5 |
| No precedent cited, or precedent cited is implausible / fabricated | 0.0 |

10% of LLM-judge calls each release are human-spot-checked.

## 4. Result interpretation

`expected.interpretation_keys` is a list of words/phrases the narrative must mention.

```
score = | keys present in narrative | / | expected keys |
```

Case-insensitive substring match. A narrative that mentions every expected key gets 1.0; missing some scales linearly.

## 5. End-to-end design

Per-key check on `result_check`:

For numeric values:

| Outcome | Score |
|---|---|
| Within `range: [lo, hi]` (or within tolerance for plain numbers) | 1.0 |
| Within 2× tolerance | 0.5 |
| Outside | 0.0 |

For string-valued fields like `driver`: exact match → 1.0, else 0.0.

End-to-end score = mean across all `result_check` keys.

## 6. Reasoning-chain quality

`expected.reasoning_chain.must_have_source_types` lists the `source_type` tags that should appear at least once.

```
score = | required types present | / | required types |
```

Plus a penalty: if `expected.parameters_required` includes `reasoning_chain` and the agent's `reasoning_chain` is null or empty, this dimension scores 0.0 regardless of other content.

## Composite

```
composite_score(model, scenario) = mean({d for d in dims if d is not None})
```

Per-model means across all scenarios go into MODEL_GUIDANCE.md.

## What we deliberately do NOT score

- **Speed / token usage.** Captured but not scored. Token efficiency lands in a separate "operational cost" column in MODEL_GUIDANCE.md, not in the composite.
- **Error recovery.** If the agent encounters a `designr_input_error` and recovers, that doesn't penalize. We score the final result.
- **Format adherence.** As long as the answer is parseable, we don't score markdown vs prose.

These could move into the rubric in a future eval-suite version if user feedback says they should.
