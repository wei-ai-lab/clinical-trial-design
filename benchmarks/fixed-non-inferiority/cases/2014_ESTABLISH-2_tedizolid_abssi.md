# ESTABLISH-2 (2014) — Tedizolid vs Linezolid for ABSSSI NI

**Family:** fixed-non-inferiority · **Kind:** landmark antibiotic Phase 3 · **Scope:** FDA 2013 ABSSSI Guidance NI prototype

## Why this case is in the corpus

- **Prototype FDA 2013 ABSSSI Guidance NI design** — canonical modern antibiotic NI trial.
- **Shorter-duration advantage**: 6-day tedizolid vs 10-day linezolid, clinical advantage even under NI framework.
- **Dual FDA/EMA primary endpoints**: early clinical response (FDA) + test-of-cure (EMA).
- M1/M2 methodology for NI margin derivation from historical placebo-controlled ABSSSI data.
- Analysis required in both ITT and clinically-evaluable populations.

## Citation

- Moran GJ, Fang E, Corey GR, et al. *Tedizolid for 6 days versus linezolid for 10 days for ABSSSI (ESTABLISH-2): a randomised, double-blind, phase 3, non-inferiority trial.* Lancet Infect Dis. 2014 Aug;14(8):696-705.
- Companion ESTABLISH-1 (oral): Prokocimer P, et al. *JAMA.* 2013 Feb 13;309(6):559-69.

## Design summary

| Parameter | Value |
|---|---|
| Indication | Acute bacterial skin/skin-structure infection (ABSSSI) |
| Arms | Tedizolid 200 mg IV QD × 6 d vs linezolid 600 mg IV BID × 10 d (1:1) |
| Primary (FDA) | Early clinical response at 48-72 h (≥ 20% lesion reduction) |
| Primary (EMA) | Investigator-assessed clinical success at test-of-cure (day 18-25) |
| NI margin | -10% absolute risk difference |
| α / power | 0.025 one-sided NI / 90% |
| Assumed response rate | 80% both arms |
| Randomized N | 666 |

## NI margin derivation (M1/M2)

FDA 2013 ABSSSI Guidance methodology:
1. **M1**: historical active-vs-placebo effect in ABSSSI ≈ 40% absolute difference.
2. **M2**: preserve ≥ 50% of active-drug effect → M2 ≤ 20%.
3. **Margin chosen**: 10% (conservative, preserves ~ 75% of historical effect).

This margin justification must be prospectively defended in the protocol.

## Sample-size calculation

```r
library(gsDesign)

# NI for binary endpoint (two-proportion NI)
# Approximate sample size given:
# - Assumed response rate: 80% both arms
# - NI margin: -10%
# - α = 0.025 one-sided, β = 0.10
# - Two-sided 95% CI lower bound must exceed -10%

# Using normal approximation on risk difference
n_per_arm <- 2 * (qnorm(0.975) + qnorm(0.90))^2 * 2 * 0.80 * 0.20 / 0.10^2
# ~ 330 per arm → 660 total
```

For ABSSSI with 80% response and NI margin -10%: ~ 330 per arm.

## Dual FDA/EMA primary

Pre-specified two primary endpoints for dual jurisdiction:

| Regulator | Primary | Timing |
|---|---|---|
| FDA | Early clinical response (≥ 20% area reduction) | 48-72 h |
| EMA | Investigator-assessed clinical success | Day 18-25 (TOC) |

Both must demonstrate NI for dual approval. More conservative than single-jurisdiction.

## Analysis populations

| Population | Definition | Use |
|---|---|---|
| ITT | All randomized | Primary conservatism |
| mITT | ITT minus undosed | Modified primary |
| CE (Clinically Evaluable) | mITT + adherence + evaluability | Secondary / sensitivity |
| MITT-MRSA | mITT + confirmed MRSA | Subgroup |

NI must hold in both ITT and CE for regulatory acceptance.

## Results

**Early clinical response (FDA primary, 48-72 h)**:
| Outcome | Tedizolid | Linezolid | Difference (95% CI) |
|---|---|---|---|
| Response rate | 85% | 83% | **+2.0% (-3.0 to +7.0)** |
| NI result | — | — | Lower CI -3.0 > -10% → NI achieved |

**Test-of-cure (EMA primary, day 18-25)**:
| Outcome | Tedizolid | Linezolid | Difference |
|---|---|---|---|
| Clinical success | 88% | 88% | 0% (-4 to +4) |

**Safety**:
- GI AEs: tedizolid lower.
- Thrombocytopenia: similar.
- Myelosuppression: both arms low.

## Clinical advantage of shorter duration

Even under NI framework (statistical tie expected), tedizolid offers:
- **6-day** therapy vs 10-day linezolid.
- Fewer AE-days.
- Better adherence (shorter course).
- Lower total cost.

Regulatory NI but clinical superiority in practice.

## Regulatory & clinical impact

- FDA approval June 2014 (Sivextro, Merck) for ABSSSI.
- EMA approval March 2015.
- Primary ABSSSI option for MRSA coverage + linezolid-intolerant.
- Pediatric label extension 2019.

## Related antibiotic NI trials

| Trial | Drug | NI vs | Indication |
|---|---|---|---|
| ESTABLISH-1 | Oral tedizolid | Linezolid | ABSSSI |
| ESTABLISH-2 (this case) | IV tedizolid | Linezolid | ABSSSI |
| SOLO-1/2 (in corpus) | Dalbavancin | Vancomycin | ABSSSI |
| DISCOVER-1/2 | Dalbavancin | Vancomycin | ABSSSI |
| PROCEED | Oritavancin | Vancomycin | ABSSSI |
| RESTORE-IMI-2 | Imipenem/relebactam | Pip/tazo | HAP/VAP |

## How this case validates designr

- Adds a **canonical antibiotic NI trial** under modern FDA 2013 Guidance.
- `designr` should support NI for two proportions with margin parameterization (absolute risk difference).
- Teaches: M1/M2 margin derivation, dual FDA/EMA primary, analysis-population strategy, shorter-duration clinical advantage within NI framework.
- Complements SOLO-1/2 dalbavancin (in corpus) showing range of modern ABSSSI NI approaches.
