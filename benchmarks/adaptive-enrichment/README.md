# Adaptive population enrichment

Phase 3 trials that begin in a broad population and, at a pre-specified interim, either (a) narrow to a biomarker-defined subgroup, (b) enrich recruitment toward that subgroup, or (c) continue in the full population — based on interim treatment-effect evidence.

## Key references

- Wang S-J, O'Neill RT, Hung HMJ. *Approaches to evaluation of treatment effect in randomized clinical trials with genomic subset.* Pharm Stat 2007.
- Brannath W, Zuber E, Branson M, et al. *Confirmatory adaptive designs with Bayesian decision tools for a targeted therapy in oncology.* Stat Med 2009.
- Jenkins M, Stone A, Jennison C. *An adaptive seamless phase II/III design for oncology trials with subpopulation selection.* Pharm Stat 2011.
- Freidlin B, Simon R. *Adaptive signature design: an adaptive clinical trial design for generating and prospectively testing a gene expression signature for sensitive patients.* Clin Cancer Res 2005.
- Mehrotra DV, Su S-C, Li X. *An efficient alternative to the stratified Cox model analysis.* Stat Med 2012.
- FDA. *Enrichment Strategies for Clinical Trials to Support Determination of Effectiveness of Human Drugs and Biological Products.* 2019.
- EMA. *Reflection paper on methodological issues in confirmatory clinical trials with flexible design and analysis plan.* 2007.

## Core statistical tools

| Method | Decision mechanic | Strength | Weakness |
|---|---|---|---|
| **Adaptive signature (Freidlin-Simon 2005)** | Learn signature from first stage, validate on second | Hypothesis-generating + testing in one trial | Low power for signature learning if N₁ small |
| **Subpopulation selection (Jenkins-Stone-Jennison)** | At interim, choose full / biomarker+ / both to carry forward | Flexible, uses combination test | Strong α control needs FWER adjustment |
| **Confirmatory adaptive with Bayesian prior (Brannath 2009)** | Bayesian posterior drives selection | Incorporates external evidence | Requires calibrated prior; regulator skepticism |
| **Group-sequential + enrichment recruitment (Wang-O'Neill-Hung 2007)** | Unchanged α spending; enrichment affects recruitment not test | Simple α control | Slower if biomarker prevalence is low |

## When adaptive enrichment is the right tool

- **Biomarker is well-characterized mechanistically** but clinical predictive value is uncertain at design time.
- **Prevalence of biomarker+ is moderate** (~20-60%) — too low and enrichment becomes the entire design; too high and unselected trial works fine.
- **Early Phase 2 data suggests differential effect** but confidence interval is wide enough that committing to a single population upfront is risky.

## When it is not

- **Weak biological rationale** for subgroup — enrichment then becomes data dredging with expensive α price.
- **Logistics impractical** — biomarker assay not fast or cheap enough to guide enrollment decisions at interim.
- **Regulatory appetite** — some agencies prefer separate Phase 3s in selected vs unselected populations (cleaner labeling).

## Multiplicity considerations

Adaptive enrichment trials must control FWER across at least three populations/hypotheses:
- H_F: treatment effect in full population
- H_B+: treatment effect in biomarker+ subgroup
- H_B−: treatment effect in biomarker− subgroup

Standard approaches:
- **Closed testing** + weighted inverse-normal combination test.
- **Graphical multiplicity (Bretz-Maurer)** — transfers α between H_F and H_B+ when the "other" hypothesis succeeds.
- **Pre-specified gatekeeping** — fixed sequence H_B+ → H_F or vice versa.

## R package landscape

- `adaptest` — adaptive design with subpopulation selection.
- `rpact` — inverse-normal combination test supporting enrichment stage 2.
- `asd` — adaptive seamless design; supports treatment and subgroup selection.
- `AdaptiveSubgrpSelect` — (less maintained) dedicated to Jenkins-Stone-Jennison workflow.
- `gMCP` — graphical multiplicity verification.

## Corpus

Four cases spanning methodology + one real-trial failure:

- 2007_Wang-ONeill-Hung_methodology — FDA-style framework for biomarker + enrichment
- 2009_Brannath-Mehta_confirmatory-adaptive — Bayesian-informed adaptive selection
- 2011_Jenkins-Stone-Jennison_methodology — adaptive seamless Ph II/III with subpopulation
- 2015_TAPPAS_angiosarcoma — real Phase 3 adaptive enrichment (TRC105, ultimately failed)

## Caveats

- Adaptive enrichment is **regulatory-sensitive**. FDA accepts it with rigorous pre-specification; EMA is similarly positive but expects strong biological rationale. PMDA has historically been more conservative.
- **Learning vs confirming tension.** Freidlin-Simon-style signature-learning designs risk low power. Pre-specified binary biomarkers (PD-L1 status, HER2+, KRAS) fare better.
