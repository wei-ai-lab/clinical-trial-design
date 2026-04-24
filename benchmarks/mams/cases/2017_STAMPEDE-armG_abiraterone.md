# STAMPEDE Arm G (2017) — Abiraterone in mHSPC

**Family:** mams · **Kind:** landmark MAMS-platform sub-arm · **Scope:** applied MAMS within platform with evolving SOC

## Why this case is in the corpus

- **Practice-changing sub-arm** of STAMPEDE platform — established abiraterone + ADT as new standard of care for metastatic hormone-sensitive prostate cancer.
- Canonical example of **MAMS framework applied to platform** with FFS intermediate endpoint gating continuation to OS primary.
- Demonstrates platform-trial efficiency: one shared SOC comparator across 10+ arms over 15+ years.
- **Separate-α philosophy** per arm (not FWER-controlled across arms) distinguishes platform from confirmatory MAMS.
- Complements STAMPEDE overall (in corpus) with arm-specific design details.

## Citation

- James ND, de Bono JS, Spears MR, et al. *Abiraterone for prostate cancer not previously treated with hormone therapy.* N Engl J Med. 2017 Jul 27;377(4):338-351.
- Sydes MR, Spears MR, Mason MD, et al. *Adding abiraterone or docetaxel to long-term hormone therapy for prostate cancer: directly randomised data from the STAMPEDE multi-arm, multi-stage platform protocol.* Ann Oncol. 2018 May 1;29(5):1235-1248.

## Design summary

| Parameter | Value |
|---|---|
| Indication | mHSPC or high-risk locally advanced hormone-sensitive PC |
| Arms | SOC (ADT ± RT) vs SOC + abiraterone + prednisolone (1:1) |
| Primary endpoint | Overall survival |
| MAMS gating endpoint | Failure-free survival (FFS) |
| α / power | 0.05 two-sided / 90% |
| Assumed HR (OS) | 0.75 |
| Target OS events | 267 |
| Randomized N | 1,917 |
| Arm G enrollment | 2011-2014 (3 years) |

## MAMS within STAMPEDE

STAMPEDE is a **multi-arm multi-stage platform**. Each arm undergoes:
- **Stage 1**: FFS HR must cross Z-threshold at ~ 40% FFS events.
- **Stage 2**: FFS HR threshold at ~ 60% FFS events.
- **Final**: OS primary at pre-specified OS event count.

Arms failing any stage are dropped; arms passing continue enrollment for OS primary.

## Separate-α philosophy

| Feature | Confirmatory MAMS | STAMPEDE platform |
|---|---|---|
| FWER | Controlled across arms | α = 0.05 per arm vs SOC |
| Arms | Pre-fixed K | Rolling — new arms added |
| Control | Fixed comparator | Evolving SOC |
| Timeline | Fixed duration | Open-ended |

Rationale: STAMPEDE treats each arm as an independent comparison with SOC. Justified because each arm is biologically distinct and interest is in adding therapy, not picking the best of several similar candidates.

## Sample-size reasoning

For arm G:
- Assumed median OS on SOC: ~ 42 months.
- Target HR: 0.75.
- Event-driven: 267 OS events needed (two-sided α = 0.05, 90% power).
- Control median 42 mo + assumed HR 0.75 → 1,917 randomized over ~ 3 years accrual.
- FFS intermediate endpoint gates at stages 1 and 2 (MAMS).

## Results

| Outcome | Arm G (abi + SOC) | SOC alone | HR (95% CI) |
|---|---|---|---|
| OS | Median NR | 4.6 yr | **0.63 (0.52-0.76)**, P < 0.001 |
| FFS | — | — | 0.29 (0.25-0.34), P < 0.001 |
| 3-yr OS | 83% | 76% | — |
| Time to skeletal event | — | — | 0.46 (0.37-0.58) |

Trial **stopped for superiority at interim** (MAMS efficacy boundary crossed).

## MAMS framework illustration

```r
library(MAMS)

# Illustrative Arm G-like design
design <- mams(
  K = 1,                # 1 experimental arm
  J = 3,                # 2 FFS interim gates + 1 OS final
  alpha = 0.025,        # one-sided
  power = 0.90,
  r = c(0.4, 0.6, 1.0),
  r0 = c(0.4, 0.6, 1.0),
  p = 0.60,
  p0 = 0.50,
  ushape = "obf",
  lshape = "obf"
)
summary(design)
```

## STAMPEDE arms overview

| Arm | Therapy added | Year | OS HR |
|---|---|---|---|
| C | Docetaxel | 2015 | 0.78 |
| E | Zoledronic acid | — | no benefit |
| F | Celecoxib | — | futility drop |
| **G (this case)** | **Abiraterone** | **2017** | **0.63** |
| J | Prostate RT (low-volume) | 2018 | 0.68 (low-vol) |
| K | Abi/enza + prostate RT | 2024 | ongoing |

## Regulatory & clinical impact

- FDA label expansion 2018: abiraterone + ADT for mHSPC.
- NCCN / ESMO guidelines updated 2018: abi + ADT or doc + ADT as frontline mHSPC standard.
- Established **STAMPEDE-style platform** as efficient Phase 3 design for common-control therapies.
- Complementary trials (LATITUDE 2017, TITAN 2019, ENZAMET 2019) independently confirmed mHSPC intensification.

## How this case validates designr

- Adds a **landmark applied MAMS-platform sub-arm** to the mams corpus, complementing methodology cases.
- `designr` should support MAMS within platform: FFS-gating intermediate endpoint + OS primary, separate-α per arm.
- Teaches: platform-trial efficiency, rolling arms, evolving SOC, intermediate endpoint MAMS gating.
- Distinct from FOCUS4 / RECOVERY MAMS platforms (also in corpus) showing different operational frameworks.
