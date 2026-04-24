# VITAL (2018) — Vitamin D × Omega-3 2×2 Factorial Prevention

**Family:** factorial · **Kind:** modern landmark 2×2 factorial prevention · **Scope:** diverse-cohort supplement prevention RCT

## Why this case is in the corpus

- Modern 2×2 factorial with two primary endpoints per factor (cancer + CV).
- 25,871 diverse U.S. adults — 20% African American (historic under-representation addressed).
- Largest rigorous test of vitamin D + omega-3 supplement prevention.
- Bonferroni α-split across co-primary endpoints — modern α control practice.
- Companion case to PHS 1989 (earlier corpus case) — shows evolution of factorial prevention design.
- Neutral primary results but informative secondary findings (cancer death, MI reduction).

## Citation

- Manson JE, Cook NR, Lee IM, et al. *Vitamin D supplements and prevention of cancer and cardiovascular disease.* N Engl J Med. 2019 Jan 3;380(1):33-44.
- Manson JE, Cook NR, Lee IM, et al. *Marine n-3 fatty acids and prevention of cardiovascular disease and cancer.* N Engl J Med. 2019 Jan 3;380(1):23-32.

## Design summary

| Parameter | Value |
|---|---|
| Indication | Primary prevention of cancer + CV disease |
| Population | 25,871 US adults (men ≥ 50, women ≥ 55), 20% AA |
| Factor A | Vitamin D3 2000 IU/d vs placebo |
| Factor B | Omega-3 1 g/d EPA+DHA vs placebo |
| Arms | 4 arms, 1:1:1:1 |
| Co-primary (per factor) | Invasive cancer + major CV events |
| α split | 0.025/0.025 Bonferroni between co-primary |
| Power | 85% |
| Follow-up | Median 5.3 years |

## 2×2 factorial structure

|  | Omega-3 + | Omega-3 − |
|---|---|---|
| **Vitamin D +** | n = 6,464 | n = 6,466 |
| **Vitamin D −** | n = 6,468 | n = 6,473 |

**Marginal analyses**:
- Vitamin D effect: all A+ vs all A− (12,930 vs 12,941).
- Omega-3 effect: all B+ vs all B− (12,932 vs 12,939).

## Co-primary endpoints per factor

Each factor tested against TWO primary endpoints:

| Factor | Primary 1 | Primary 2 |
|---|---|---|
| Vitamin D | Invasive cancer | Major CV events |
| Omega-3 | Invasive cancer | Major CV events |

**α split**: Bonferroni — α = 0.025 two-sided for each co-primary.

Alternative not used: hierarchical (test cancer first at α = 0.05, then CV only if cancer wins).

## Sample-size rationale

**Vitamin D → cancer arm**:
- Control incidence: 6.5 per 1,000 per year.
- Assumed HR: 0.85.
- α = 0.025 (Bonferroni), 85% power.
- Events needed: ~ 1,500.
- Expected at 25,871 × 0.0065 × 5 yrs = 841 → extended follow-up required.

**Vitamin D → CV arm**:
- Control incidence: 7.5/1000/year.
- Assumed HR: 0.85.
- Events needed: ~ 1,300.

## R sample-size calculation

```r
library(gsDesign)

# Vitamin D cancer arm
nSurv(
  lambdaC = -log(1 - 0.0065),
  hr = 0.85,
  eta = 0.02,
  T = 60, minfup = 36,
  alpha = 0.025, beta = 0.15, sided = 2
)
# Events ~ 1,500
```

## Diversity recruitment

Deliberate 20% African American enrollment:
- Addressed historic under-representation.
- Enabled pre-specified race subgroup analyses (vitamin D especially relevant given lower baseline 25(OH)D).
- Suggested greater vitamin D benefit in African Americans (exploratory).

## Results

### Vitamin D

| Outcome | Vit D | Placebo | HR (95% CI) |
|---|---|---|---|
| **Cancer (primary)** | 793 | 824 | **0.96 (0.88-1.06)** P = 0.47 |
| **Major CV events (primary)** | 396 | 409 | **0.97 (0.85-1.12)** P = 0.69 |
| Cancer death (secondary) | 154 | 187 | 0.83 (0.67-1.02) suggestive |
| Total mortality | 485 | 493 | 0.99 |

**Neither primary endpoint met.**

### Omega-3

| Outcome | Omega-3 | Placebo | HR (95% CI) |
|---|---|---|---|
| Cancer (primary) | 820 | 797 | 1.03 (0.93-1.13) P = 0.56 |
| Major CV events (primary) | 386 | 419 | 0.92 (0.80-1.06) P = 0.24 |
| **MI (secondary)** | 145 | 200 | **0.72 (0.59-0.90)** P = 0.003 |
| Total mortality | 466 | 499 | 0.93 |

**Neither primary met** — but MI reduction (secondary) is clinically noteworthy.

### Interaction tests

- Cancer: no significant Vit D × Omega-3 interaction.
- CV: no significant interaction.

Factorial design validated.

## Subgroup findings

| Subgroup | Effect direction | Pre-specified |
|---|---|---|
| Vit D cancer death, ≥ 2 years exposure | Stronger HR 0.75 | Yes |
| Omega-3 CV, low fish intake | HR 0.81 | Yes |
| Vit D in African Americans | Suggestion of greater benefit | Yes |
| Omega-3 MI in non-fish eaters | Larger MI reduction | Yes |

## Impact

- **USPSTF 2021**: vitamin D not recommended for primary prevention.
- **Omega-3 guidance**: icosapent ethyl (purified) endorsed for TG ≥ 150 mg/dL; general population supplementation not recommended.
- **Supplement-prevention nihilism**: VITAL + D-Health + ARRIVE + ASPREE collectively dampened enthusiasm for universal supplementation.
- **Methodology benchmark**: large diverse 2×2 factorial with co-primary endpoints.

## Related factorial trials in corpus

| Trial | Year | Factor A | Factor B | Result |
|---|---|---|---|---|
| ISIS-2 | 1988 | Aspirin | Streptokinase | Both positive, additive |
| PHS | 1989 | Aspirin | Beta-carotene | Aspirin+, beta-carotene neutral |
| HPS | 2002 | Simvastatin | Antioxidants | Simvastatin+, antioxidants neutral |
| COMMIT | 2005 | Clopidogrel | Metoprolol | Clopidogrel+, metoprolol mixed |
| HOPE-3 | 2016 | Rosuvastatin | Candesartan-HCTZ | Statin+, BP-lowering+ (jointly) |
| **VITAL (this case)** | **2018** | **Vitamin D** | **Omega-3** | **Both neutral primary, promising secondary** |

Pattern: factorial ideal when factors are independent mechanistically and null results still informative.

## R sample-size with factorial structure

```r
library(pwr)
library(survival)

# Conceptual: 2×2 factorial with Cox model
# Main effect of each factor tested marginally
# Interaction pre-specified as secondary

# Mock data ----
d <- data.frame(
  vit_d  = rep(c(0, 1), each = 12935),
  omega3 = rep(c(0, 1, 0, 1), each = 6467),
  time   = rexp(25871, rate = 0.001),
  event  = rbinom(25871, 1, 0.15)
)

# Factorial Cox with interaction
fit <- coxph(Surv(time, event) ~ vit_d * omega3, data = d)
summary(fit)

# Main effects tested via:
#  - vit_d main: summary(fit)$coefficients["vit_d", ]
#  - omega3 main: summary(fit)$coefficients["omega3", ]
#  - interaction: summary(fit)$coefficients["vit_d:omega3", ]
```

## Limitations & caveats

- **Two co-primary per factor**: Bonferroni α split costs power; hierarchical alternative not used.
- **Short latency for supplement effects**: 5 years may be inadequate for maximal cancer prevention. Post-hoc 2-year exclusion partially addressed.
- **No baseline 25(OH)D stratification**: dilutes effect in already-sufficient participants.
- **Open-label supplement use**: ~ 20% took outside vitamin D/fish oil → diluted contrast.
- **Neutral primary**: factorial design still valid; neutral results inform guidelines.

## Design innovations

- **Diverse cohort**: 20% African American, rare for large prevention trial.
- **Bonferroni α split** for co-primary: modern α-control practice.
- **Pre-specified subgroup by baseline levels**: mitigates baseline-sufficiency dilution.
- **Extension trials ongoing**: VITAL-2, VITAL-depression — same cohort, new endpoints.

## How this case validates designr

- Adds a **modern large-scale 2×2 factorial** with two co-primary endpoints per factor.
- `designr` should support factorial designs with (a) marginal main-effect testing, (b) co-primary α-split (Bonferroni or hierarchical), (c) pre-specified interaction tests, (d) subgroup analyses.
- Teaches: modern factorial design (vs PHS 1989), co-primary α management, supplement-trial operational challenges (open-label use, baseline levels), diverse-cohort recruitment.
- Paired with 5 earlier factorial trials in corpus — spans 30 years of factorial methodology evolution.
