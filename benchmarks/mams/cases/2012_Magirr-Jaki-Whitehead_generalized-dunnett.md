# Magirr-Jaki-Whitehead (2012) — Generalized Dunnett for MAMS

**Family:** mams · **Kind:** methodology-paper · **Scope:** unified Dunnett framework with GS treatment selection

## Why this case is in the corpus

- **Foundational theoretical paper** unifying multi-arm Dunnett multiple comparisons with group-sequential interim analysis + treatment selection.
- Rigorous FWER control in strong sense across all selection strategies.
- Basis of the canonical **`MAMS`** R package (Jaki-Magirr 2016).
- Underpins modern platform MAMS trials (STAMPEDE, FOCUS4, RECOVERY).

## Citation

- Magirr D, Jaki T, Whitehead J. *A generalized Dunnett test for multi-arm multi-stage clinical studies with treatment selection.* Biometrika. 2012 Jun;99(2):494-501.
- Magirr D, Stallard N, Jaki T. *Flexible sequential designs for multi-arm clinical trials.* Stat Med. 2014 Aug 30;33(19):3269-79.

## Core framework

- K experimental arms + 1 shared control.
- L stages (typically L = 2 or 3: interim + final).
- At each stage l:
  - Compute Z_{k,l} = standardized test statistic for arm k vs control.
  - Efficacy boundary u_l: if Z_{k,l} ≥ u_l → declare arm k superior, stop trial.
  - Futility boundary l_l: if Z_{k,l} ≤ l_l → drop arm k.
  - Otherwise continue arm k to stage l+1.

## Correlation structure

Test statistics form multivariate normal with:
- Within-arm across stages: ρ_{l,l'} = √(I_l / I_{l'}) where I = information.
- Between arms at same stage: ρ_{k,k'} = n_C / √((n_C + n_k)(n_C + n_{k'})).

Joint multivariate distribution preserved under standard GS + Dunnett.

## Boundary families

| Shape | Behavior | Use |
|---|---|---|
| O'Brien-Fleming | Very conservative early, liberal late | Standard — STAMPEDE, FOCUS4 |
| Pocock | Constant boundary | Earlier stopping, slight α penalty |
| Triangular | Asymmetric | Efficient with drop-the-loser selection |
| Custom | Sponsor-defined | MAMS-platform with rolling arms |

## Treatment selection rules

- **Drop-the-loser**: drop arms with Z < threshold at each stage.
- **Keep all promising**: continue all arms with Z > futility.
- **Keep top m**: continue m arms with highest Z (fixed m).
- **Combination tests**: Bauer-Köhne / CHW (Stallard 2003 extension).

## MAMS package usage

```r
library(MAMS)

# 4 experimental + 1 control, 2 stages, O'Brien-Fleming
design <- mams(
  K = 4,
  J = 2,
  alpha = 0.025,
  power = 0.90,
  r = 1:2,              # info fractions at each stage
  r0 = 1:2,             # control info fractions
  p = 0.65,             # alternative std-effect (Z-scale)
  p0 = 0.50,            # null std-effect
  ushape = "obf",
  lshape = "obf"
)
summary(design)

# Output:
# Sample size per arm at each stage
# Efficacy/futility boundaries
# Operating characteristics
```

## Sample-size implications

| Design | Total N (relative) |
|---|---|
| Single-arm single-stage | 1.0 × |
| 1 interim + final (K=1) | 1.07 × (O'Brien-Fleming) |
| 3 arms + control, 2 stages | 3.5 × (multiplicity + 2 stages) |
| 5 arms + control, 3 stages | 5.2 × |

Inflation from:
1. Dunnett multiplicity at final analysis (multivariate correction).
2. α-spending across stages (group-sequential).

## Relationship to other MAMS

| Reference | Contribution |
|---|---|
| Royston-Parmar-Qian 2003 (in corpus) | First MAMS TTE framework |
| Wason-Jaki 2012 (in corpus) | Optimal boundaries minimizing N |
| **Magirr-Jaki-Whitehead 2012** (this case) | Unified Dunnett-GS |
| Magirr-Stallard-Jaki 2014 | Flexible SSR integration |
| Bratton-Phillips-Parmar 2013 (in corpus) | MAMS for platforms |

## Real-world applications

- **STAMPEDE** (2011+, in corpus): prostate cancer MAMS-platform.
- **FOCUS4** (2014+, in corpus): colorectal biomarker-enriched MAMS.
- **RECOVERY** (2020+, in corpus): COVID-19 hybrid MAMS-platform.
- **Rosuvastatin vs atorvastatin in HIV** (MRC, 2017).
- **Industry Phase 2b/3**: AstraZeneca oncology, Roche immunology.

## How this case validates designr

- Adds the **foundational unified MAMS methodology paper** to the mams corpus.
- `designr` should wrap `MAMS::mams` with support for OBF / Pocock / triangular boundaries, drop-the-loser and keep-top-m selection.
- Teaches: shared-control multivariate correlation, boundary computation, selection-rule pre-specification.
- Complements applied cases (STAMPEDE, FOCUS4, RECOVERY) with the theoretical foundation.
