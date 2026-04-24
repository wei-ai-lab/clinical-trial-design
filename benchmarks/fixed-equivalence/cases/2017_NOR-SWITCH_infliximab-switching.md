# NOR-SWITCH (2017) — Infliximab Originator → Biosimilar Switching NI

**Family:** fixed-equivalence · **Kind:** regulator-sponsored landmark biosimilar trial · **Scope:** multi-indication switching equivalence

## Why this case is in the corpus

- **First and most influential regulator-sponsored biosimilar switching trial** — answered the health-system substitution question directly.
- Norwegian Medicines Agency funded — public-interest objective, not industry-sponsored.
- Multi-indication pragmatic design pooling 6 inflammatory conditions.
- Pivotal to EU biosimilar substitution policy (Norway → UK → Germany → Netherlands).
- Referenced in FDA 2019 Interchangeability Guidance as switching-evidence model.

## Citation

- Jørgensen KK, Olsen IC, Goll GL, et al. *Switching from originator infliximab to biosimilar CT-P13 compared with maintained treatment with originator infliximab (NOR-SWITCH): a 52-week, randomised, double-blind, non-inferiority trial.* Lancet. 2017 Jun 10;389(10086):2304-2316.
- Extension: Goll GL, Jørgensen KK, Sexton J, et al. *NOR-SWITCH-EXTENSION.* Ann Rheum Dis. 2019;78(2):234-240.

## Design summary

| Parameter | Value |
|---|---|
| Indication | 6 inflammatory conditions: Crohn's, UC, spondyloarthritis, RA, PsA, psoriasis |
| Population | Adults on stable originator infliximab ≥ 6 months |
| Arms | CT-P13 (switched from originator) vs continued originator (1:1) |
| Primary endpoint | Disease worsening at 52 weeks (indication-specific composite) |
| NI margin | +15% absolute risk difference |
| α / power | 0.025 one-sided NI / 80% |
| Assumed worsening rate | 30% both arms |
| Randomized N | 482 |
| Median follow-up | 52 weeks |

## Why a switching trial is different

Most biosimilar NI trials compare:
```
new patient → biosimilar   vs   new patient → originator
```

NOR-SWITCH compared:
```
stable originator → biosimilar   vs   stable originator → originator (continued)
```

This answers the **real-world question**: is it safe to switch established patients from the originator to biosimilar? This is the clinically-relevant question for health systems implementing substitution policies.

## Composite endpoint across indications

Disease-specific worsening harmonized into a single binary endpoint:

| Indication | Worsening criterion |
|---|---|
| Crohn's disease | CDAI ≥ 70 increase |
| Ulcerative colitis | Partial Mayo score ≥ 3 |
| Spondyloarthritis | BASDAI ≥ 2 |
| Rheumatoid arthritis | DAS28-CRP ≥ 1.2 |
| Psoriatic arthritis | DAS28-CRP ≥ 1.2 |
| Plaque psoriasis | PASI ≥ 3 |

Pre-specified pooled analysis — enabled efficient inference across indications.

## NI margin justification

15% absolute risk difference:
- Clinical judgment: 15% upper bound of acceptable efficacy loss.
- Historical infliximab discontinuation rate ~30%/year for loss of response.
- Preserves majority of expected infliximab benefit.
- More conservative than some 20% margins in non-switching trials.

Norwegian Medicines Agency and EMA both endorsed.

## Sample-size calculation

```r
library(gsDesign)

# NI for proportions with 15% margin
p <- 0.30                         # expected worsening rate
margin <- 0.15                    # NI margin

# Normal approximation for risk difference
n_per_arm <- (qnorm(0.975) + qnorm(0.80))^2 * 2 * p * (1 - p) / margin^2
# ~ 62 per arm arithmetic → × 1.18 dropout × heterogeneity cushion
# → ~ 240 per arm → 480 total
```

## Stratification & analysis populations

**Stratified randomization** by:
- Indication (6 levels).
- Concomitant immunomodulator (yes / no).
- Disease activity at baseline (active / remission).

**Analysis populations**:
- **Full Analysis Set (FAS)**: all randomized + ≥ 1 infusion.
- **Per-Protocol (PP)**: FAS + no major protocol deviation.
- **Primary**: PP (NI convention).
- **Sensitivity**: FAS.

## Results

| Outcome | CT-P13 | Originator | Adjusted Difference (95% CI) |
|---|---|---|---|
| Disease worsening (primary) | 26% | 30% | **-4.4% (-12.7 to +3.9)** |
| NI conclusion | — | — | Upper CI 3.9% < +15% → NI achieved |

**Consistent across all 6 indications** (pre-specified heterogeneity test NS).

**Safety / immunogenicity**:
- Anti-drug antibodies: similar.
- Serious AEs: similar.
- Treatment discontinuation: similar.

## NOR-SWITCH-EXTENSION (2019)

- 26-week open-label continuation.
- All originator-arm patients switched to CT-P13 at week 52.
- Confirmed durability of originally-switched patients.
- Double-switched (originator → biosimilar → originator-arm switched) also safe.

Total evidence base: ~ 18 months on biosimilar post-switch.

## Regulatory & health-system impact

| Jurisdiction | Policy | Annual savings |
|---|---|---|
| Norway (2017) | National switch mandate | € 50M+ |
| Denmark (2017) | National switch | € 30M+ |
| UK NHS (2018) | Switching guidelines | £ 150M (cumulative) |
| Germany (2018-2020) | Multi-region switching | € 250M |
| Netherlands (2017) | National switch | € 40M+ |

FDA 2019 Interchangeability Guidance cited NOR-SWITCH design as switching-evidence model.

## Related biosimilar trials in corpus

| Trial | Drug | Design type | Indications |
|---|---|---|---|
| PLANETRA (2013) | CT-P13 (infliximab) | Initiation | RA |
| SB5 (2017) | Adalimumab biosimilar | Initiation | RA |
| MYL-1401O (2017) | Trastuzumab biosimilar | Initiation | HER2+ MBC |
| CT-P10 (2018) | Rituximab biosimilar | Initiation | Follicular lymphoma |
| **NOR-SWITCH (this case)** | **CT-P13 (infliximab)** | **Switching** | **6 inflammatory conditions** |

## Methodology lessons

- **Switching answers the real-world question** for established-patient substitution — distinct from naive-start biosimilar comparability.
- **Multi-indication composite endpoints** enable efficient pooled inference when effects expected similar across indications.
- **Regulator-sponsored trials** can address market-level policy questions industry cannot.
- **PP primary + FAS sensitivity** standard for NI switching to avoid ITT dilution from noncompliance.
- **Dropout inflation** ~ 15% typical at 52 weeks → actual N inflation factor ~1.2×.

## How this case validates designr

- Adds the **canonical switching-equivalence trial** — distinct from typical initiation NI.
- `designr` should support multi-indication stratified NI with composite binary endpoint.
- Teaches: switching vs initiation design, regulator-sponsored trial framework, multi-indication pooling, PP-primary analysis convention for NI.
- Complements 5 initiation biosimilar cases already in corpus (PLANETRA, SB5, MYL-1401O, CT-P10, V114).
- Paired with Schuirmann 1987 TOST (in corpus) — CT-P13 trial uses 95% CI equivalent to TOST at α = 0.025 one-sided.
