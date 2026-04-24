# Schuirmann (1987) — Two One-Sided Tests (TOST) for Equivalence

**Family:** fixed-equivalence · **Kind:** foundational methodology · **Scope:** canonical equivalence test procedure

## Why this case is in the corpus

- **The** paper that formalized Two One-Sided Tests (TOST) as the standard for bioequivalence.
- FDA 1992 Bioequivalence Guidance adoption → EMA 2001 / 2010 adoption → ICH Q5E biosimilar.
- Still the default procedure for BE, biosimilar comparability, lot-consistency, method-transfer equivalence.
- Solves the classical "how do you prove equivalence" problem via intersection-union testing.
- Paired with every real-trial equivalence case in corpus (PLANETRA, SB5, MYL-1401O, V114).

## Citation

- Schuirmann DJ. *A comparison of the two one-sided tests procedure and the power approach for assessing the equivalence of average bioavailability.* J Pharmacokinet Biopharm. 1987;15(6):657-680.
- Predecessors: Westlake WJ (J Pharm Sci 1972); Anderson & Hauck (Commun Stat Theory Methods 1983).

## Core procedure

Equivalence null **H_0**: `|μ_T − μ_R| ≥ ε`
Equivalence alternative **H_1**: `|μ_T − μ_R| < ε`

Decompose into two one-sided nulls:

```
H_01: μ_T - μ_R ≤ -ε     vs     H_11: μ_T - μ_R > -ε
H_02: μ_T - μ_R ≥ +ε     vs     H_12: μ_T - μ_R < +ε
```

**Reject H_0 (conclude equivalence) iff BOTH one-sided tests reject at level α.**

This is an intersection-union test — overall size is α (not 2α), because rejecting the joint null requires rejecting both components.

## Equivalent CI formulation

| Overall α | Per-side α | Two-sided CI |
|---|---|---|
| 0.05 | 0.05 | **90%** |
| 0.025 | 0.025 | 95% |
| 0.10 | 0.10 | 80% |

**90% CI** for μ_T − μ_R must lie entirely inside (−ε, +ε). The 90%-not-95% rule is the single most common source of confusion.

## Canonical bioequivalence margin

FDA 1992 Generic Drugs BE Guidance:

| Scale | Margin | Equivalence interval |
|---|---|---|
| Log | ±log(1.25) ≈ ±0.2231 | (−0.2231, +0.2231) |
| Original (GMR) | — | **(0.80, 1.25)** |

The asymmetry (0.80 = 1/1.25) reflects symmetry on log scale.

**Narrow-therapeutic-index drugs** (warfarin, levothyroxine, lithium): FDA uses (0.90, 1.1111) — ±10%.

## Sample-size formula

For log-PK data, 2×2 crossover, within-subject CV = σ_w:

```
n_per_sequence = 2 · (z_{1-α} + z_{1-β/2})² · σ_w² / ε²
```

(iterated with non-central t for exact).

## Sample-size examples (2×2 crossover, GMR = 1.00, α = 0.05)

| CV_w | Power 80% | Power 90% |
|---|---|---|
| 15% | 18 | 22 |
| 20% | 28 | 36 |
| 25% | 42 | 56 |
| 30% | 60 | 78 |
| 35% | 82 | 106 |
| 40% | 108 | 140 |

Highly variable drugs (CV_w > 30%): switch to **reference-scaled BE** (FDA 2010 guidance, scABEL method in PowerTOST).

## R implementation — PowerTOST

```r
library(PowerTOST)

# Classical BE: GMR = 1.00, CV = 20%, 80% power
sampleN.TOST(
  CV = 0.20,
  theta1 = 0.80,
  theta2 = 1.25,
  theta0 = 1.00,
  targetpower = 0.80,
  design = "2x2"
)
# n = 28 total

# Expected GMR slightly off-target: GMR = 0.95
sampleN.TOST(
  CV = 0.20, theta0 = 0.95,
  targetpower = 0.80, design = "2x2"
)
# n = 40 (cushion for off-null GMR)

# Highly variable drug: reference-scaled BE
sampleN.scABEL(
  CV = 0.40, theta0 = 0.90,
  targetpower = 0.80, design = "2x3x3"
)
```

## Log transformation convention

FDA/EMA require log-transform for AUC and Cmax (multiplicative error structure of PK):

1. Log-transform observed values.
2. Fit ANOVA (crossover) or t (parallel).
3. Back-exponentiate to GMR scale.
4. Construct 90% CI on log scale → back-exponentiate for GMR CI.
5. Check GMR CI ⊂ (0.80, 1.25).

## Equivalence in biosimilars (ICH Q5E)

Biosimilar clinical comparability follows TOST-style CI containment:

| Endpoint | Margin | CI level |
|---|---|---|
| ORR (trastuzumab biosimilar) | ±10% absolute or ratio 0.80-1.25 | 90% or 95% |
| ACR20 (adalimumab biosimilar) | ±15% absolute | 95% |
| DAS28-ESR (infliximab biosimilar) | ±0.60 | 95% |
| PK Cmax/AUC | 0.80-1.25 GMR | 90% |

Industry convention uses 95% CI for clinical biosimilar endpoints (overall α = 0.025 per-side) — more conservative than standard BE.

## Regulatory adoption timeline

| Year | Agency | Document | Impact |
|---|---|---|---|
| 1972 | Westlake | J Pharm Sci | First CI-based BE |
| 1987 | Schuirmann | J PK Biopharm | **TOST formalized** |
| 1992 | FDA | Generic Drugs Guidance | TOST standard |
| 2001 | FDA/EMA | BE Statistical Approaches | Codified |
| 2003 | FDA | BE General Considerations | Retained |
| 2004 | ICH | Q5E Biologics Comparability | Biosimilar framework |
| 2010 | FDA | Highly Variable Drugs | Reference-scaled TOST |
| 2014 | EMA | Biosimilar Guideline | Clinical TOST |

## Extensions

- **Reference-scaled ABE (FDA 2010)**: widen margin proportionally to σ_wR when CV_w > 30%. Partial-replicate designs (TRR, RTR, RRT) estimate σ_wR.
- **Group-sequential TOST**: Jennison-Turnbull formalism; rarely used (BE trials are small/quick).
- **Nonparametric TOST**: Hauschke-Steinijans 1990; rank-based for skewed endpoints.
- **Individual bioequivalence**: Hyslop 2000; largely abandoned.

## Relationship to other fixed-equivalence cases in corpus

| Case | Endpoint | Margin | CI level |
|---|---|---|---|
| PLANETRA (2013) | DAS28 change | ±0.60 | 95% |
| SB5 (2017) | ACR20 | ±15% absolute | 95% |
| MYL-1401O (2017) | ORR ratio | (0.81, 1.24) | 90% |
| CT-P10 (2018) | ORR difference | ±17% absolute | 95% |
| V114 lot-consistency (2019) | IgG GMC ratio | (0.5, 2.0) | 95% |
| EMA 2014 biosimilar guideline | clinical/PK | (0.80, 1.25) | 90% |

All of these implement TOST in some form (CI containment).

## Common mistakes

- **Using 95% CI instead of 90%** for standard BE (costs power unnecessarily).
- Forgetting log transformation for PK endpoints.
- Using between-subject CV for crossover trials (overestimates n).
- Reporting 80% power assuming GMR = 1.00 when actual assumed GMR is 0.95 (true power is much lower).
- Failing to pre-specify per-protocol analysis (BE convention) vs ITT (superiority convention).
- Applying parallel-group formula to crossover data (factor-of-2 error).

## How this case validates designr

- Adds the **canonical equivalence methodology paper** — every BE, biosimilar, lot-consistency, and method-transfer trial in corpus uses TOST.
- `designr` must natively support TOST for continuous (log-PK), binary, and ordinal endpoints.
- Teaches: 90%-not-95% CI rule, log transformation default, reference-scaled extension for highly variable drugs, sample-size non-linearity near equivalence boundary.
- Paired with PLANETRA, SB5, MYL-1401O, CT-P10, V114, EMA 2014 real-trial cases in corpus — all implement TOST.
- `PowerTOST` is the canonical R package designr should wrap for BE/equivalence sample-size.
