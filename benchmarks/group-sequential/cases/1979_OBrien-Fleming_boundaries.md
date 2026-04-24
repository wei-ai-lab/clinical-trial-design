# O'Brien-Fleming (1979) — Group-Sequential Efficacy Boundaries

**Family:** group-sequential · **Kind:** foundational methodology · **Scope:** canonical efficacy boundary family for GS trials

## Why this case is in the corpus

- **The** defining paper for group-sequential efficacy boundaries — OBF is the default in every modern confirmatory GS trial.
- Formula `c_k = c_K · √(I_K / I_k)` — conservative early, approaches fixed-sample critical at final.
- Very small maximum-sample-size inflation (~2-3%) vs fixed-sample while enabling early efficacy stopping.
- FDA 2019 Adaptive Designs Guidance default; EMA 2007 CHMP Reflection Paper preferred.
- Basis for Lan-DeMets α-spending (1983) generalization to flexible timing.

## Citation

- O'Brien PC, Fleming TR. *A multiple testing procedure for clinical trials.* Biometrics. 1979 Sep;35(3):549-56.
- Building on: Pocock SJ. *Group sequential methods in the design and analysis of clinical trials.* Biometrika. 1977;64(2):191-199.

## Methodology summary

| Parameter | Value |
|---|---|
| Boundary shape | OBF: decreasing with information |
| Formula (two-sided) | `c_k = c_K · √(I_K / I_k)` |
| Information fractions | `I_1 ≤ I_2 ≤ ... ≤ I_K = 1` |
| Pocock alternative | `c_k = c` constant for all `k` |
| Sample-size inflation (K=5) | OBF ~ 1.026× · Pocock ~ 1.206× |

## Numerical example (K = 5, two-sided α = 0.05)

**OBF boundary Z-values:**

| k | Information I_k | Z-boundary | Nominal P |
|---|---|---|---|
| 1 | 0.2 | 4.56 | 0.000005 |
| 2 | 0.4 | 3.23 | 0.0013 |
| 3 | 0.6 | 2.63 | 0.0085 |
| 4 | 0.8 | 2.28 | 0.022 |
| 5 | 1.0 | 2.04 | 0.041 |

**Pocock boundary Z-values:** 2.41, 2.41, 2.41, 2.41, 2.41 (nominal P = 0.016 each).

OBF final boundary (2.04) only slightly more stringent than fixed (1.96).

## Derivation intuition

For independent increments on the canonical Brownian scale:
- Cumulative Z-statistic `Z_k` has variance `I_k` (before standardization).
- OBF: `B_k = Z_k · √I_k` (B-value) is crossed by constant `b = c_K`.
- Translating back: `Z_k` boundary is `c_K / √(I_k)` = `c_K · √(I_K / I_k)` since `I_K = 1`.

This makes OBF a **constant B-value boundary** — geometrically the simplest linear boundary on the Brownian motion scale.

## Sample-size impact

| K (looks) | OBF inflation | Pocock inflation |
|---|---|---|
| 2 | 1.008× | 1.097× |
| 3 | 1.017× | 1.152× |
| 4 | 1.022× | 1.187× |
| 5 | 1.026× | 1.206× |
| 10 | 1.036× | 1.252× |

OBF dominates because early boundaries are so conservative that their contribution to α is tiny, preserving nearly all of α for the final analysis.

## R implementation

```r
library(gsDesign)

# 5-look OBF design, α = 0.025 one-sided, 90% power
d <- gsDesign(
  k = 5,
  test.type = 2,      # symmetric OBF upper + lower
  alpha = 0.025,
  beta = 0.10,
  sfu = sfOF,         # Lan-DeMets OBF spending
  sfl = sfOF,
  timing = c(0.2, 0.4, 0.6, 0.8, 1.0)
)
print(d)
# Boundaries at each analysis, sample-size inflation, OC curves
```

```r
library(rpact)

design <- getDesignGroupSequential(
  kMax = 5,
  typeOfDesign = "OF",
  alpha = 0.025,
  beta = 0.10,
  sided = 1
)
# rpact uses classical OBF (equally-spaced) or OBF-like α-spending
```

## Relationship to other boundary families

| Family | Early boundary | Final boundary | Expected N under H1 |
|---|---|---|---|
| Fixed (no interim) | — | 1.960 | 1.00 × N_fixed |
| **OBF (5 looks)** | **4.56** | **2.04** | ~ 0.85 × N_fixed |
| Pocock (5 looks) | 2.41 | 2.41 | ~ 0.73 × N_fixed |
| Wang-Tsiatis Δ=0.25 | 2.96 | 2.17 | ~ 0.78 × N_fixed |
| Haybittle-Peto | 3.00 fixed | 1.96 | ~ 0.90 × N_fixed |

Pocock stops earlier (lower expected N under H1) but pays more at final → more inflation.

## Wang-Tsiatis power family

Wang & Tsiatis (1987) generalized: `c_k = c · I_k^(Δ - 0.5)`
- Δ = 0 → OBF
- Δ = 0.5 → Pocock
- Δ = 0.25 → intermediate (popular compromise)

`gsDesign::gsDesign(sfupar = ...)` parameterizes via Δ or α-spending exponent.

## Historical context

- **Pocock 1977** (Biometrika): first systematic GS boundary — constant critical value.
- **O'Brien-Fleming 1979** (Biometrics): decreasing boundary, became dominant.
- **Lan-DeMets 1983** (Biometrika, companion corpus case): α-spending function generalizing OBF/Pocock to flexible timing.
- **Wang-Tsiatis 1987**: power family parameterization.
- **Hwang-Shih-DeCani 1990**: exponential-family α-spending.
- **Jennison-Turnbull 2000**: canonical textbook reference.

## Modern applications

- **Essentially all confirmatory GS trials** use OBF or OBF-style α-spending (`sfLDOF` in gsDesign).
- **FDA 2019 Adaptive Designs Guidance**: OBF default recommendation.
- **EMA 2007 CHMP Reflection Paper on Adaptive Designs**: OBF preferred.
- **All GS oncology trials** (CheckMate, KEYNOTE, CHECKMATE series): OBF efficacy.
- **DMC charters**: routinely specify OBF for efficacy stopping.

## Limitations & caveats

- **Equal information spacing (1979 original)**: closed-form requires equally-spaced info fractions. Lan-DeMets α-spending (1983) removed this constraint.
- **Type of bound**: two-sided OBF, one-sided OBF, asymmetric upper/lower all exist. Most confirmatory trials use one-sided OBF for efficacy + non-binding futility.
- **Z-statistic assumption**: OBF formulated for standardized normal with independent increments. Log-rank, Cox score, t, binary tests approximately satisfy this.
- **Power loss vs fixed**: ~1-2% under alternative — tiny cost of flexibility.
- **Very conservative early**: unable to stop unless effect is truly huge at first interim.

## How this case validates designr

- Adds the **canonical GS efficacy boundary family** — foundational methodology paper.
- `designr` must natively support OBF (equally-spaced) and OBF-like α-spending (`sfLDOF`) since these dominate modern GS practice.
- Teaches: why OBF is preferred (minimal max-N inflation), geometric intuition (constant B-value), Pocock vs OBF trade-off (early stopping vs final-analysis cost), Wang-Tsiatis parameterization.
- Paired with Lan-DeMets α-spending (in corpus) which generalizes OBF to flexible information timing.
- Complements every real-trial GS case in corpus (e.g., PARADIGM-HF, DAPA-HF, FOURIER, EMPA-REG OUTCOME) which all use OBF efficacy boundaries.
