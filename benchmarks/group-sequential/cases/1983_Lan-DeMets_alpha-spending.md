# Lan-DeMets (1983) — α-Spending Function for Group-Sequential Trials

**Family:** group-sequential · **Kind:** foundational methodology · **Scope:** flexible-timing generalization of OBF/Pocock

## Why this case is in the corpus

- **The** generalization that made group-sequential boundaries practical for real trials with flexible interim scheduling.
- Removed the OBF/Pocock requirement for equally-spaced information fractions.
- `sfLDOF` (Lan-DeMets OBF-like spending) is the default in essentially every modern confirmatory GS trial.
- Foundation for all downstream spending-function developments (Hwang-Shih-DeCani, Kim-DeMets power, Pampallona-Tsiatis).
- ICH E9 (R1) and FDA 2019 Adaptive Designs Guidance both explicitly endorse α-spending.

## Citation

- Lan KKG, DeMets DL. *Discrete sequential boundaries for clinical trials.* Biometrika. 1983;70(3):659-663.
- Companion tutorial: DeMets DL, Lan KKG. *Interim analysis: the alpha spending function approach.* Stat Med. 1994;13(13-14):1341-1352.

## Core idea

Define a function **α(t)** where `t ∈ [0, 1]` is the information fraction and α(t) is the cumulative type I error spent by that fraction. Requirements:

- α(0) = 0
- α(1) = α (full type I error)
- α(t) non-decreasing

Then at each interim at information t_k, the boundary c_k is determined so that:

```
P(|Z_1| ≤ c_1, ..., |Z_{k-1}| ≤ c_{k-1}, |Z_k| > c_k | H_0) = α(t_k) - α(t_{k-1})
```

**Key property**: boundaries computed sequentially — interim timing need not be pre-specified, only the spending function.

## Why this was revolutionary

Original GS methods required:

| Method | Requirement | Real-world issue |
|---|---|---|
| Pocock 1977 | K known, equal spacing | DMC meetings are calendar-driven |
| OBF 1979 | K known, equal spacing | Event-driven interims hit unevenly |
| Lan-DeMets 1983 | Only α(·) specified | ANY interim schedule ok |

Event-driven oncology trials, calendar-scheduled DMC reviews, adaptive sample-size re-estimation — none produce equally-spaced information. α-spending accommodates all.

## Canonical spending functions

**OBF-like (Lan-DeMets approximation to OBF)**:
```
α_OF(t) = 2 · [1 - Φ(z_{α/2} / √t)]
```
Matches OBF 1979 very closely when interims are equally spaced.

**Pocock-like**:
```
α_P(t) = α · log(1 + (e - 1) · t)
```
Matches Pocock 1977 — near-constant nominal boundary.

**Kim-DeMets power family**:
```
α_ρ(t) = α · t^ρ
```
- ρ = 1: uniform linear spending
- ρ = 3: intermediate
- ρ → ∞: all α at final
- ρ → 0: OBF-like behavior

**Hwang-Shih-DeCani (1990)** — exponential family:
```
α_γ(t) = α · (1 - e^{-γt}) / (1 - e^{-γ})   γ ≠ 0
α_0(t) = α · t                               γ = 0
```
Smooth interpolation: γ = −4 ≈ OBF, γ = +1 ≈ Pocock.

## Numerical example

K = 5 planned interims with uneven info fractions t = (0.18, 0.35, 0.55, 0.78, 1.00) and OBF-like spending:

| t_k | α_OF(t_k) | Z-boundary |
|---|---|---|
| 0.18 | 0.0000037 | 4.64 |
| 0.35 | 0.0012 | 3.35 |
| 0.55 | 0.0075 | 2.71 |
| 0.78 | 0.0210 | 2.31 |
| 1.00 | 0.0500 | 2.04 |

Nearly identical to OBF 1979 closed-form despite uneven spacing.

## Independent-increments requirement

α-spending relies on `Z_k · √t_k` being a standard Brownian motion:
```
Cov(Z_j · √t_j, Z_k · √t_k) = √(t_j / t_k)   j ≤ k
```

Holds (exactly or asymptotically) for:
- Sample means of iid data (t/Z tests).
- Log-rank statistic under PH (TTE).
- Cox partial-likelihood score.
- Binomial / Wald statistics.

Fails for some non-standard statistics — simulation needed to verify.

## Spending function comparison (α = 0.025 one-sided, K = 5)

| t | α_OF(t) | α_P(t) | Z-OBF | Z-Pocock |
|---|---|---|---|---|
| 0.2 | 0.000002 | 0.0052 | 4.56 | 2.44 |
| 0.4 | 0.0006 | 0.0094 | 3.23 | 2.42 |
| 0.6 | 0.0038 | 0.0129 | 2.63 | 2.41 |
| 0.8 | 0.0110 | 0.0181 | 2.28 | 2.40 |
| 1.0 | 0.0250 | 0.0250 | 2.04 | 2.41 |

## R implementation — gsDesign

```r
library(gsDesign)

# 5-look design with flexible OBF-like α-spending
d <- gsDesign(
  k = 5,
  test.type = 2,
  alpha = 0.025,
  beta = 0.10,
  sfu = sfLDOF,                            # OBF-like α-spending
  sfl = sfLDOF,
  timing = c(0.18, 0.35, 0.55, 0.78, 1.0)  # unequal info allowed
)
print(d)

# Recompute when actual interim differs from planned
d2 <- gsDesign(
  k = 5,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF, sfl = sfLDOF,
  timing = c(0.20, 0.35, 0.55, 0.78, 1.0), # interim 1 came late
  maxn.IPlan = d$n.I[5]
)
```

Common `gsDesign` spending functions:
- `sfLDOF` — Lan-DeMets OBF-like (**most common default**).
- `sfLDPocock` — Lan-DeMets Pocock-like.
- `sfHSD(param = -4)` — OBF-like via Hwang-Shih-DeCani.
- `sfHSD(param = 1)` — Pocock-like via HSD.
- `sfPower(param = 3)` — Kim-DeMets power.
- `sfExponential(param = 0.8)` — smooth early-spending.

## R implementation — rpact

```r
library(rpact)

design <- getDesignGroupSequential(
  kMax = 5,
  typeOfDesign = "asOF",                  # OBF-like α-spending
  alpha = 0.025, beta = 0.10,
  sided = 1,
  informationRates = c(0.18, 0.35, 0.55, 0.78, 1.0)
)
```

rpact spending codes:
- `asOF` — OBF-like α-spending.
- `asP` — Pocock-like α-spending.
- `asKD` — Kim-DeMets power.
- `asHSD` — Hwang-Shih-DeCani.
- `asUser` — user-specified spending table.

## Non-binding vs binding futility

α-spending separately handles efficacy and futility spending:

| Design | Efficacy | Futility | α preservation |
|---|---|---|---|
| Non-binding futility | `sfu` | `sfl` | ✅ Always α (futility ignorable) |
| Binding futility | `sfu` | `sfl` | ✅ α reclaimed (committed stop) |

**FDA 2019 Guidance preference**: non-binding futility — allows the DMC to override futility boundary without α inflation. gsDesign parameter: `test.type = 4` (non-binding) vs `test.type = 3` (binding).

## Relationship to other methodology cases

| Paper | Year | Contribution |
|---|---|---|
| Pocock | 1977 | Constant boundary, equal spacing |
| O'Brien-Fleming (in corpus) | 1979 | Decreasing boundary `c_K·√(I_K/I_k)`, equal spacing |
| **Lan-DeMets (this case)** | **1983** | **α-spending — any timing** |
| Kim-DeMets | 1987 | Power family `α·t^ρ` |
| Wang-Tsiatis | 1987 | Boundary power family Δ |
| Hwang-Shih-DeCani | 1990 | Exponential spending family |
| Pampallona-Tsiatis | 1994 | Unified binding/non-binding |
| DeMets-Lan | 1994 | Tutorial companion |
| Jennison-Turnbull | 2000 | Canonical textbook |

## Modern applications

- **Default in essentially every confirmatory GS trial**: FOURIER, PARADIGM-HF, DAPA-HF, EMPA-REG OUTCOME, FINEARTS-HF — all in corpus.
- **Oncology GS**: KEYNOTE, CheckMate, STAMPEDE arms — all use sfLDOF or equivalent.
- **Event-driven designs**: α-spending essential because event-milestone timing is unpredictable.
- **Adaptive designs**: α-spending foundation for SSR and adaptive allocation.

## Limitations & caveats

- **Independent-increments**: assumes canonical Brownian-motion covariance for Z-statistics. Holds for standard estimators; verify via simulation for non-standard ones.
- **Information-fraction calibration**: for TTE = events/total-events, for continuous/binary = subjects/total-subjects, for Cox = events/total-events.
- **Mis-calibrated spending**: if actual info fraction differs from planned, must recompute remaining boundaries using observed information (error-spending recalculation).
- **Maximum-information approach**: modern practice fixes maximum information (max events or max N) up front; boundaries recomputed at each look given observed info.

## How this case validates designr

- Adds the **foundational α-spending methodology** paper — the single most important GS methodology generalization.
- `designr` MUST support `sfLDOF` (OBF-like) and `sfLDPocock` at minimum, plus `sfHSD` and `sfPower` families, since these dominate modern practice.
- Teaches: why α-spending matters (flexible timing), the independent-increments assumption, binding vs non-binding futility, information-fraction definitions by endpoint type.
- Paired with O'Brien-Fleming 1979 (companion corpus case) which α-spending generalizes.
- Referenced implicitly by every GS trial in corpus (OBF-like α-spending in sfLDOF form is ubiquitous).
