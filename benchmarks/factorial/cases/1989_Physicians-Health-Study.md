# Physicians' Health Study (1989) — Aspirin × Beta-Carotene 2×2 Factorial

**Family:** factorial · **Kind:** landmark primary-prevention trial · **Scope:** canonical 2×2 factorial with independent questions

## Why this case is in the corpus

- One of the largest and most influential 2×2 factorial trials in medicine.
- Established low-dose aspirin for MI primary prevention.
- Refuted beta-carotene antioxidant hypothesis for cancer prevention.
- Demonstrates factorial efficiency: two trial questions in one study at minimal marginal cost.
- Early-stopping asymmetry (aspirin stopped early, beta-carotene continued 7 more years).
- Pre-specified interaction tests showed no interaction — validated design.

## Citation

- Steering Committee of the Physicians' Health Study Research Group. *Final report on the aspirin component of the ongoing Physicians' Health Study.* N Engl J Med. 1989 Jul 20;321(3):129-135.
- Hennekens CH, Buring JE, Manson JE, et al. *Lack of effect of long-term supplementation with beta carotene on the incidence of malignant neoplasms and cardiovascular disease.* N Engl J Med. 1996 May 2;334(18):1145-1149.

## Design summary

| Parameter | Value |
|---|---|
| Indication | Primary prevention of CV disease + cancer |
| Population | 22,071 US male physicians 40-84 years, no prior MI/stroke/TIA/cancer |
| Factor A | Aspirin 325 mg every other day vs placebo |
| Factor B | Beta-carotene 50 mg every other day vs placebo |
| Arms | 4 arms, 1:1:1:1 |
| Primary (aspirin) | Fatal or non-fatal MI |
| Primary (beta-carotene) | Cancer incidence |
| Follow-up | 5 years (aspirin stopped early), 12 years (beta-carotene completed) |

## 2×2 factorial structure

|  | Beta-carotene + | Beta-carotene − |
|---|---|---|
| **Aspirin +** | n = 5,517 | n = 5,520 |
| **Aspirin −** | n = 5,517 | n = 5,517 |

**Marginal analyses** (factorial efficiency):
- Aspirin effect: all A+ vs all A− (11,037 vs 11,034).
- Beta-carotene effect: all B+ vs all B− (11,034 vs 11,037).

**Interaction**: aspirin × beta-carotene tested as secondary.

## Factorial efficiency

If no interaction between factors:
- Aspirin arm N (marginal): 22,071 / 2 = 11,037.
- Beta-carotene arm N (marginal): 22,071 / 2 = 11,034.
- **Two trials for the price of one**.

Alternative: running separate trials:
- 2 trials × 22,000 each = 44,000 total.
- Factorial saves 50% subjects, time, infrastructure.

**Loss only if interaction exists** (then factorial loses power to detect it).

## Sample-size rationale

**Aspirin component (MI prevention)**:
- Control MI rate: 5 per 1,000 per year.
- Assumed RR = 0.77 (23% reduction).
- α = 0.05 two-sided, power = 90%.
- Events needed: ~ 400.
- Expected at 22,071 × 0.005 × 5 yrs = 552 events — adequate.

**Beta-carotene component (cancer prevention)**:
- Cancer incidence: 3.5 per 1,000 per year.
- Assumed RR = 0.80.
- Needed 12-year follow-up for adequate events.
- Expected: 22,071 × 0.0035 × 12 = 927 events.

## R sample-size calculation

```r
library(gsDesign)

# Aspirin arm
nSurv(
  lambdaC = -log(1 - 0.005),       # 0.5% annual MI hazard
  hr = 0.77,
  eta = 0.01,                      # low dropout in physicians
  T = 60, minfup = 36,
  alpha = 0.025, beta = 0.10, sided = 2
)
# Events ~ 400, adequate with 22,000 × 5 years
```

## Results

### Aspirin (stopped early, December 1987)

| Outcome | Aspirin | Placebo | RR (95% CI) |
|---|---|---|---|
| **Fatal or non-fatal MI** | 139 | 239 | **0.56 (0.45-0.70)** P < 0.00001 |
| Stroke | 119 | 98 | 1.22 (0.93-1.60) |
| CV death | 81 | 83 | 1.00 |
| Total mortality | 217 | 227 | 0.96 |

DMC stopped aspirin arm early using OBF-like efficacy boundary. Landmark result establishing aspirin for primary MI prevention.

### Beta-carotene (completed 1996)

| Outcome | Beta-carotene | Placebo | RR (95% CI) |
|---|---|---|---|
| **Cancer incidence** | 1,273 | 1,293 | **0.98 (0.91-1.06)** NS |
| Lung cancer | 170 | 157 | 1.08 NS |
| CV events | 927 | 949 | 0.98 NS |
| Total mortality | 979 | 968 | 1.02 NS |

No benefit on any endpoint → refuted antioxidant cancer prevention hypothesis.

## Interaction analyses

Pre-specified aspirin × beta-carotene interaction tests:
- MI: interaction P = 0.52 (no evidence).
- Cancer: interaction P = 0.91 (no evidence).

Factorial design validated — no interaction observed.

## Early-stopping asymmetry

Creative design: aspirin and beta-carotene monitored independently.

- **Aspirin**: stopped at 5 years for overwhelming benefit.
- **Beta-carotene**: continued for additional 7 years.
- Participants transitioned:
  - Aspirin arm → open-label aspirin.
  - Placebo arm → no aspirin.
  - Beta-carotene blinding maintained until 1995.

Allowed independent answers on two timescales.

## Impact

| Finding | Guideline impact |
|---|---|
| Aspirin reduces MI | 1990s-2010s: aspirin recommended for primary prevention in moderate-high CV risk |
| No cancer benefit from beta-carotene | Refuted antioxidant hypothesis, reversed supplement recommendations |
| No CV benefit from beta-carotene | Consistent with CARET (1996) and ATBC (1994) — beta-carotene neutral or harmful |

**Modern aspirin guidance (2018-2021)**:
- USPSTF 2022: aspirin no longer recommended for primary prevention > 60 (ARRIVE, ASPREE trials showed harm ≥ bleeding).
- **But PHS established the methodology and evidence base** — guidelines refined, not reversed.

## Factorial trials in corpus

| Trial | Year | Factor A | Factor B | Primary |
|---|---|---|---|---|
| ISIS-2 (in corpus) | 1988 | Aspirin | Streptokinase | Acute MI mortality |
| **PHS (this case)** | **1989** | **Aspirin** | **Beta-carotene** | **MI + cancer** |
| HPS (in corpus) | 2002 | Simvastatin | Antioxidants | CV + cancer |
| COMMIT (in corpus) | 2005 | Clopidogrel | Metoprolol | Acute MI outcomes |
| HOPE-3 (in corpus) | 2016 | Rosuvastatin | Candesartan-HCTZ | CV events |
| VITAL (companion) | 2018 | Vitamin D | Omega-3 | CV + cancer |

## Limitations & caveats

- **Male physicians cohort**: limits generalizability (high adherence, low dropout, homogeneous SES).
- **325 mg alternate-day dosing**: non-standard; modern practice uses 75-100 mg daily.
- **No interaction observed**: design vindicated; had interaction been present, factorial would be suboptimal.
- **Different timeframes**: aspirin (fast) vs beta-carotene (slow) created operational complexity.
- **Beta-carotene arm continuation**: participants lost aspirin blinding after 1988 stop — unblinded data only for aspirin; beta-carotene remained blinded.

## How this case validates designr

- Adds the **canonical 2×2 factorial primary-prevention trial**.
- `designr` should support factorial designs with (a) marginal main effects, (b) pre-specified interaction tests, (c) independent group-sequential monitoring per factor.
- Teaches: factorial efficiency (2 trials in 1), interaction-absence assumption, asymmetric early stopping, marginal vs subgroup analysis.
- Paired with 4 other factorial trials in corpus (ISIS-2, HPS, COMMIT, HOPE-3) plus VITAL (companion case).
- Complements gsDesign factorial boundary computation and `survival` package Cox factorial modeling.
