# EMPA-REG OUTCOME (2015) — Empagliflozin CV Outcomes in T2DM

**Family:** fixed-superiority · **Kind:** landmark Phase 3 CVOT · **Scope:** NI → superiority with 3-point MACE primary

## Why this case is in the corpus

- **First SGLT2 inhibitor CVOT** to demonstrate cardiovascular superiority — paradigm-shifting for T2DM management.
- Classic **FDA 2008 Guidance CVOT** design: NI vs HR 1.30 → superiority if NI met.
- **3-point MACE composite** with hierarchical secondary testing (CV death, all-cause death, HF hospitalization).
- Spawned the SGLT2i CVOT era: CANVAS, DECLARE, VERTIS-CV, EMPEROR, DAPA-HF.
- First glucose-lowering drug with FDA CV mortality reduction label.

## Citation

- Zinman B, Wanner C, Lachin JM, et al. *Empagliflozin, cardiovascular outcomes, and mortality in type 2 diabetes.* N Engl J Med. 2015 Nov 26;373(22):2117-28.
- Zinman B, Inzucchi SE, Lachin JM, et al. *EMPA-REG OUTCOME design.* Cardiovasc Diabetol. 2014;13:102.

## Design summary

| Parameter | Value |
|---|---|
| Indication | T2DM + established CV disease |
| Arms | Empa 10 mg : Empa 25 mg : placebo (1:1:1) |
| Primary endpoint | 3-point MACE (CV death, non-fatal MI, non-fatal stroke) |
| Regulatory threshold | NI vs HR 1.30 (FDA 2008) |
| Superiority | One-sided α = 0.025 (if NI met) |
| Power | 90% |
| Assumed HR (superiority) | 0.82 |
| Control MACE rate | ~ 4%/year |
| Target events | 691 |
| Randomized N | 7,020 |
| Median follow-up | 3.1 years |

## NI → superiority closed test

FDA 2008 Guidance for Industry (diabetes drugs):
1. Primary objective: **rule out HR > 1.30** (NI margin).
2. Secondary: test superiority if NI achieved.
3. No α penalty for superiority test — closed testing preserves FWER.

```r
library(gsDesign)

d <- gsSurv(
  k = 2,
  alpha = 0.025,             # one-sided NI (upper CI < 1.30)
  beta = 0.10,
  lambdaC = -log(0.96),      # 4% annual hazard
  hr = 0.82,
  eta = 0,
  T = 48, minfup = 24,
  test.type = 2,
  sfu = sfLDOF,
  ratio = 2                  # pooled 2:1 vs placebo
)
# ~ 691 events, ~ 7000 randomized
```

## Hierarchical secondary testing

Pre-specified order (each tested only if prior significant):
1. 3-point MACE — **primary**.
2. 4-point MACE (add unstable angina hospitalization).
3. CV death alone.
4. All-cause death.
5. Hospitalization for heart failure.

## Pooled dose design

Pre-specified: pool 10 mg + 25 mg vs placebo for primary.
- Rationale: similar PK/PD between doses; power advantage.
- Individual dose analyses reported secondarily.
- Standard for multi-dose CVOT.

## Results

| Outcome | Empa (pooled) | Placebo | HR (95% CI) | P |
|---|---|---|---|---|
| 3-point MACE | 10.5% | 12.1% | **0.86 (0.74-0.99)** | 0.04 |
| CV death | 3.7% | 5.9% | 0.62 (0.49-0.77) | < 0.001 |
| All-cause death | 5.7% | 8.3% | 0.68 (0.57-0.82) | < 0.001 |
| HF hospitalization | 2.7% | 4.1% | 0.65 (0.50-0.85) | 0.002 |
| Non-fatal MI | — | — | 0.87 (0.70-1.09) | NS |
| Non-fatal stroke | — | — | 1.18 (0.89-1.56) | NS |

## Early curve separation

Primary MACE and CV death curves separated within ~ 3 months — unexpected for a glucose-lowering drug. Triggered:
- **Non-glycemic mechanism theories**: natriuresis/preload reduction, ketone metabolism, cardiac energetics.
- **HF-focused trials**: EMPEROR-Reduced, EMPEROR-Preserved, DAPA-HF — all positive.
- **Renal-focused trials**: EMPA-KIDNEY, DAPA-CKD — both positive.
- **Reframed** SGLT2i as cardio-renal drugs, not glucose-centric.

## Regulatory & clinical impact

- FDA December 2016: CV mortality reduction label (first for glucose-lowering drug).
- EMA: CV event reduction label.
- 2018 ADA/EASD consensus: SGLT2i preferred for T2DM + CV disease.
- 2022 KDIGO, 2023 AHA/ACC guidelines: SGLT2i Class I for T2DM + CKD or HFrEF.

## Related CVOTs

| Trial | Year | Class | MACE HR |
|---|---|---|---|
| TRANSCEND (in corpus) | 2008 | ARB (tel) | 0.99 (NI only) |
| SAVOR-TIMI 53 | 2013 | DPP-4 (sax) | 1.00 (NI) |
| EMPA-REG OUTCOME (this case) | 2015 | SGLT2i | 0.86 |
| LEADER | 2016 | GLP-1 (lira) | 0.87 |
| SUSTAIN-6 (in corpus) | 2016 | GLP-1 (sema) | 0.74 |
| CANVAS (in corpus) | 2017 | SGLT2i (cana) | 0.86 |
| DECLARE-TIMI 58 | 2019 | SGLT2i (dapa) | 0.93 (NI + HFH) |
| FOURIER (in corpus) | 2017 | PCSK9i (evo) | 0.85 |

## How this case validates designr

- Adds the **foundational SGLT2i CVOT** to fixed-superiority corpus, complementing CANVAS and SUSTAIN-6.
- `designr` should reproduce NI → superiority closed test via `gsDesign::gsSurv`.
- Teaches: FDA 2008 Guidance framework, pooled-dose design, hierarchical secondary testing, 3-point MACE.
- Motivates the CVOT pattern in modern metabolic drug development (2008-present).
