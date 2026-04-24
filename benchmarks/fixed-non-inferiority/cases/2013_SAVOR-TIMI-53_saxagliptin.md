# SAVOR-TIMI 53 (2013) — Saxagliptin DPP-4 NI CVOT

**Family:** fixed-non-inferiority · **Kind:** landmark Phase 3 CVOT · **Scope:** FDA 2008 Guidance NI margin prototype

## Why this case is in the corpus

- **Prototype FDA 2008 Guidance CVOT** — pure NI design (no superiority pre-specified), rule out HR > 1.30.
- First DPP-4 inhibitor CVOT to complete.
- Discovered **unexpected HF hospitalization signal** (HR 1.27) — informed subsequent CVOT design.
- Very large trial (N = 16,492) characteristic of NI-margin CVOTs with low event rates.
- Established the NI CVOT pattern that dominated diabetes drug development 2008-2020.

## Citation

- Scirica BM, Bhatt DL, Braunwald E, et al. *Saxagliptin and cardiovascular outcomes in patients with type 2 diabetes mellitus.* N Engl J Med. 2013 Oct 3;369(14):1317-26.
- Mosenzon O, Raz I, Scirica BM, et al. *SAVOR-TIMI 53 baseline.* Am Heart J. 2013;166(2):264-71.e1.

## Design summary

| Parameter | Value |
|---|---|
| Indication | T2DM + established CV disease or ≥ 2 CV risk factors |
| Arms | Saxagliptin 2.5-5 mg OD vs placebo (1:1) |
| Primary endpoint | 3-point MACE (CV death, non-fatal MI, non-fatal stroke) |
| Regulatory objective | **Non-inferiority** — rule out HR > 1.30 |
| α / power | 0.025 one-sided NI / 90% |
| Assumed true HR | 1.00 (no CV harm) |
| NI margin (HR) | 1.30 |
| Control event rate | ~ 4.5%/year |
| Target events | 1,040 |
| Randomized N | 16,492 |
| Median follow-up | 2.1 years |

## FDA 2008 Guidance framework

Post-drug-withdrawal (rosiglitazone) CV safety framework:
- **Pre-market**: upper CI < 1.80 (smaller trials OK).
- **Post-market**: upper CI < 1.30 (large CVOT required).

SAVOR-TIMI 53 addressed the post-market threshold.

Framework updated/softened in 2019 FDA Diabetes Drugs Guidance revision.

## NI sample-size calculation

```r
library(gsDesign)

# Pure NI CVOT (no pre-specified superiority)
d <- gsSurv(
  k = 1,                       # fixed design
  alpha = 0.025,               # one-sided NI at α = 0.025
  beta = 0.10,                 # 90% power
  lambdaC = -log(1 - 0.045),   # 4.5% annual MACE hazard
  hr = 1.00,                   # true HR assumed under alternative
  hr0 = 1.30,                  # NI margin (null HR)
  eta = 0,
  T = 36, minfup = 24
)
# ~ 1040 events, ~ 16,500 randomized
```

Why so large:
- NI margin HR = 1.30 means null distribution peaks at HR = 1.30.
- Alternative HR = 1.00 very close to null → need many events.
- Delta-log-HR = log(1.30) ≈ 0.26 — small.

## Hierarchical testing

Original pre-specified:
1. Primary MACE NI (HR upper CI < 1.30).
2. Expanded MACE (add HF hospitalization).
3. Component analyses (CV death, MI, stroke individually).

**No superiority pre-specified** — NI-only CVOT framework.

## Results

| Outcome | Saxa | Placebo | HR (95% CI) | Interpretation |
|---|---|---|---|---|
| Primary MACE | 7.3% | 7.2% | **1.00 (0.89-1.12)** | NI achieved (upper 1.12 < 1.30) |
| CV death | 3.2% | 3.1% | 1.03 | NS |
| MI | 3.2% | 3.4% | 0.95 | NS |
| Stroke | 1.7% | 1.5% | 1.11 | NS |
| HF hospitalization | 3.5% | 2.8% | **1.27 (1.07-1.51)** | **Unexpected harm signal** |
| All-cause death | 4.9% | 4.2% | 1.11 (0.96-1.27) | NS |

## HF hospitalization signal

- **Pre-specified secondary** but not primary.
- HR 1.27 (95% CI 1.07-1.51, P = 0.007).
- Surprised clinical community — DPP-4i not previously implicated in HF.
- **Not replicated** by EXAMINE (alogliptin) or TECOS (sitagliptin) — class effect disputed.
- **FDA 2016 label update**: saxagliptin / alogliptin HF warning.
- Established HF hospitalization as **mandatory CVOT secondary** in subsequent designs.

## Related NI CVOTs

| Trial | Year | Drug | Primary MACE HR | HF signal |
|---|---|---|---|---|
| SAVOR-TIMI 53 (this case) | 2013 | Saxagliptin | 1.00 (NI met) | **HR 1.27** |
| EXAMINE | 2013 | Alogliptin | 0.96 (NI met) | NS |
| TECOS | 2015 | Sitagliptin | 0.98 (NI met) | NS |
| CARMELINA | 2019 | Linagliptin | 1.02 (NI met) | NS |
| EMPA-REG OUTCOME (in corpus) | 2015 | Empagliflozin (SGLT2i) | 0.86 (superior) | HR 0.65 ↓ |

## Clinical / regulatory impact

- Saxagliptin approved for T2DM glucose control; CVOT confirmed safety.
- HF signal prompted FDA label warning (2016).
- Motivated pre-specification of HF hospitalization in all subsequent CVOTs.
- SGLT2i (EMPA-REG 2015+) showed opposite effect (HF reduction) — reshaped diabetes prescribing.

## How this case validates designr

- Adds the **first pure-NI DPP-4 CVOT** — prototype of FDA 2008 Guidance framework.
- `designr` should support NI margin parameterization (`hr0 = 1.30`) with NI-only testing.
- Teaches: why pure-NI trials are large (event-driven near null), HF hospitalization pre-specification lessons from unexpected signal.
- Contrasts with EMPA-REG OUTCOME (in corpus) showing transition from NI-only to NI → superiority CVOT design.
