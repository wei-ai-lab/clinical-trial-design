# Example 02 — PARADIGM-HF (2014)

## Trial

McMurray JJV et al. (2014). *Angiotensin-neprilysin inhibition versus enalapril in heart failure.* N Engl J Med 371:993-1004.

Phase 3 trial of sacubitril-valsartan vs enalapril in symptomatic HFrEF (NYHA II-IV, EF ≤ 40%). Primary endpoint: composite of CV death + first HHF.

## Published design

- Time-to-event, log-rank under PH (per published SAP).
- α = 0.025 one-sided, 80% power, 1:1 randomization.
- HR 0.80 expected (~20% relative reduction).
- ~2 years median time-to-event in standard-of-care arm.
- Planned events ~1,500-2,300 (varying with assumed event rate).
- Trial stopped early at IA at ~21% relative reduction observed.

## Reproduction

```bash
R -e 'source("examples/02_paradigm_hf_survival/run.R")'
```

Expected: ~700 events using HR=0.80 / median 30 / 1:1 + dropout 1%/month. The published planned number was higher because the assumed event rate in the SAP was lower (control median ~3 years rather than 2.5).

## What this example demonstrates

- `design_survival(model = "ph", design_class = "fixed")` for a CVOT.
- Reasoning chain with mixed source types: LLM precedent for the effect-size assumption and the control event rate, user-supplied for the operational dropout assumption.
