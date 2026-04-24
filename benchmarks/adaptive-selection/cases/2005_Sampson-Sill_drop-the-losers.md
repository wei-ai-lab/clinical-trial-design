# Sampson-Sill (2005) — Drop-the-Losers Design: Normal Case

**Family:** adaptive-selection · **Kind:** foundational methodology · **Scope:** exact distributional results for seamless Phase 2/3 selection with normal endpoint

## Why this case is in the corpus

- **The** canonical reference for drop-the-losers design with normal endpoint — exact critical values + conditionally unbiased estimator.
- Solves the "winner's curse" problem that plagues naive post-selection analysis.
- Foundation for normal-case seamless Phase 2/3 dose-finding trials.
- Extensions to binary (Stallard-Todd), TTE, and multiple-winner cases all build on Sampson-Sill normal framework.
- Pairs with Thall-Simon-Ellenberg 1988 (first framework) and Stallard-Todd 2003 (binary extension) already in corpus.

## Citation

- Sampson AR, Sill MW. *Drop-the-losers design: normal case.* Biometrical Journal. 2005;47(3):257-268.
- Predecessor: Cohen A, Sackrowitz HB. *Two-stage conditionally unbiased estimators of the selected mean.* Stat Probab Lett. 1989;8(3):273-278.
- Foundation: Thall PF, Simon R, Ellenberg SS. *Two-stage selection and testing designs for comparative clinical trials.* Biometrika. 1988;75(2):303-310.

## Drop-the-losers framework

**Stage 1** — select winning arm:
- Randomize patients 1:1:...:1 across K experimental arms + control.
- Observe normal outcomes at stage-1 interim.
- Compute T_k = X̄_k − Ȳ for each experimental arm.
- Select k* = argmax_k T_k (pick winner).

**Stage 2** — confirmation:
- Drop K−1 losing arms.
- Continue only arm k* vs control with additional sample size.
- Final analysis combines stage-1 and stage-2 data.

**Key challenges**:
1. Selection creates winner's curse — naive Δ̂ overestimates true Δ_{k*}.
2. Final test critical value must account for selection (not 1.96).

## Sampson-Sill contributions

### 1. Exact conditional distribution

Given selection of arm k*, the joint distribution of (T_{k*}, stage-2 mean) is multivariate normal with covariance adjusted for selection. Sampson-Sill derived closed-form expressions via MVN integration.

### 2. Critical values

Critical value c such that:
```
sup_{H_0 global} P(Z_final > c | any arm selected) = α
```

Computed numerically via MVN integration over (T_1, ..., T_K).

**Approximate critical values (α = 0.025 one-sided)**:

| K arms | c_DTL |
|---|---|
| 1 | 1.96 |
| 2 | 2.08 |
| 3 | 2.15 |
| 4 | 2.20 |
| 5 | 2.24 |
| 10 | 2.38 |

Adjustment modest — because under global null, selection is "free".

### 3. Conditionally unbiased estimator

Naive Δ̂_{k*} = X̄_{k*} − Ȳ is biased upward. Sampson-Sill corrected estimator:

```
Δ̂_unbiased = Δ̂_naive − B(K, n_1, σ)
```

Bias B depends on number of arms K, stage-1 per-arm size n_1, and σ.

### 4. Sample-size formulas

Stage-2 sample size chosen to achieve target power given stage-1 selection probability.

## Test statistic

Final weighted combination:
```
Z_final = w_1 · Z_1(k*) + w_2 · Z_2(k*)
```

where:
- Z_1(k*) = stage-1 z-score for selected arm.
- Z_2(k*) = stage-2 z-score for selected arm.
- w_1² + w_2² = 1 (typically information-based: w_k ∝ √n_k).

## Numerical example

K = 3 experimental + control, σ = 1, α = 0.025, power 80%:

**Stage 1** (n_1 = 20 per arm, 80 total):
- X̄_1 − Ȳ = 0.42
- X̄_2 − Ȳ = 0.18
- X̄_3 − Ȳ = 0.05

Select arm 1 (highest).

**Stage 2** (n_2 = 100 in arm 1 and control, 200 total):
- X̄_{1,2} − Ȳ_2 = 0.28

**Combination**:
- w_1 = √(20/120) = 0.41
- w_2 = √(100/120) = 0.91
- Compare Z_final to c_DTL(K=3) ≈ 2.15 (not 1.96).

**Winner's curse correction**:
- Naive Δ̂ = 0.42.
- Bias for K=3, n_1=20 ≈ 0.18.
- Corrected Δ̂_unbiased ≈ 0.24 (realistic estimate for labeling).

## Sample-size efficiency

Drop-the-losers vs parallel fixed design:

| Design | Total N |
|---|---|
| Fixed K-arm parallel | K × n + n_control |
| Sequential K Phase 3s | K × (2n) |
| Drop-the-losers | K × n_1 + n_2 + (K+1) × n_control-share |

**Savings**: 20-40% of total sample size vs sequential confirmatory trials, while maintaining α control.

## Winner's curse magnitude

Bias in naive Δ̂ for selected arm (normal case, σ = 1):

| K | n_1 | Bias (units of σ) |
|---|---|---|
| 2 | 20 | 0.12 |
| 3 | 20 | 0.18 |
| 5 | 20 | 0.25 |
| 10 | 20 | 0.35 |
| 3 | 50 | 0.11 |
| 3 | 100 | 0.08 |

Bias **increases with K** (more arms → more selection pressure) and **decreases with n_1** (more data → less noise in selection).

## R implementation

```r
# Sampson-Sill methodology — typically custom code
library(mvtnorm)
library(asd)                        # Parsons/Friede adaptive seamless

# Drop-the-losers 3-arm design
K <- 3                              # experimental arms
n1 <- 25                            # stage-1 per arm
n2 <- 75                            # stage-2 per arm (selected only)
sigma <- 1
alpha <- 0.025

# Weights
w1 <- sqrt(n1 / (n1 + n2))
w2 <- sqrt(n2 / (n1 + n2))

# Critical value (approximate for K=3)
c_alpha <- 2.15

# Simulate operating characteristics
sim_dtl <- function(delta_true, n_sim = 10000) {
  sims <- replicate(n_sim, {
    # Stage 1 ----
    T1 <- rnorm(K, mean = delta_true, sd = sigma * sqrt(2/n1))
    kstar <- which.max(T1)

    # Stage 2 ----
    T2 <- rnorm(1, mean = delta_true[kstar], sd = sigma * sqrt(2/n2))

    # Weighted combination
    Z <- w1 * (T1[kstar] / (sigma * sqrt(2/n1))) +
         w2 * (T2 / (sigma * sqrt(2/n2)))
    Z > c_alpha
  })
  mean(sims)
}
```

## Comparison to other adaptive-selection methods

| Method | Year | Endpoint | Key feature |
|---|---|---|---|
| Thall-Simon-Ellenberg (in corpus) | 1988 | Generic | First framework |
| Stallard-Todd (in corpus) | 2003 | Binary | α-spending + GS |
| **Sampson-Sill (this case)** | **2005** | **Normal** | **Exact critical + bias correction** |
| Posch-Koenig (in corpus) | 2005 | Normal | GS + selection |
| Bretz-Schmidli (in corpus) | 2006 | Multi | Bretz closed-testing |
| Friede-Stallard (in corpus) | 2008 | Comparison | Multi-winner |
| Magirr-Jaki-Whitehead (in corpus) | 2012 | MAMS | Generalized Dunnett |

## Regulatory acceptance

| Agency | Document | Position |
|---|---|---|
| FDA | 2019 Adaptive Designs Guidance | Seamless Ph 2/3 accepted |
| EMA | 2007 CHMP Reflection Paper | Pre-specified rules OK |
| ICH | E9 (R1) | Adaptive framework |

All critical values, selection rules, and bias correction methods must be **pre-specified in the protocol**.

## Modern applications

- **ADVENT-HF** (sleep apnea 2-dose selection).
- **INITIATE** (neuroscience 3-dose seamless Ph 2/3).
- **Various CRT-D cardiac device** dose-selection trials.
- **Pharma Phase 2b/3 dose-finding** — common in oncology, neurology, immunology.

## Limitations & caveats

- **Known σ assumption** in original 2005: extensions for unknown σ plug in σ̂ with some efficiency loss.
- **Selection rule sensitivity**: "pick maximum" is optimal under normal but alternative rules (threshold, ranked) behave differently.
- **Multiple winners**: framework extends via ranked selection; Friede-Stallard 2008 addresses directly.
- **Early futility**: protocol typically adds futility boundary; Sampson-Sill framework extends.
- **Conservatism of critical value**: c_DTL(K) can be slightly conservative — simulation-tuned procedures (asd package) more precise.

## How this case validates designr

- Adds the **canonical drop-the-losers methodology for normal endpoints** — foundational for seamless Phase 2/3.
- `designr` should support drop-the-losers with (a) pre-specified critical values, (b) conditionally unbiased estimator, (c) simulated operating characteristics.
- Teaches: winner's curse concept and correction, critical-value inflation with K, sample-size efficiency vs sequential Phase 3s.
- Paired with 6 adaptive-selection methodology cases in corpus — covers broad methodology landscape.
- `asd` (Parsons/Friede) is the canonical R package to wrap for seamless designs.
