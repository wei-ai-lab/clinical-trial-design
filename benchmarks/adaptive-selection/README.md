# Adaptive treatment-arm selection

Phase 3 trials that start with multiple experimental arms (or doses) and, at a pre-specified interim, drop one or more arms while continuing the survivors against a shared control. Distinct from **adaptive-enrichment** (which selects populations, not arms) and from **mams** (which retains all arms through pre-specified boundaries).

## Key references

- Thall PF, Simon R, Ellenberg SS. *A two-stage design for choosing among several experimental treatments and a control in clinical trials.* Biometrics 1988.
- Bauer P, Kieser M. *Combining different phases in the development of medical treatments within a single trial.* Stat Med 1999.
- Stallard N, Todd S. *Sequential designs for phase III clinical trials incorporating treatment selection.* Stat Med 2003.
- Kelly PJ, Stallard N, Todd S. *An adaptive group sequential design for phase II/III clinical trials that select a single treatment from several.* J Biopharm Stat 2005.
- Bretz F, Schmidli H, König F, Racine A, Maurer W. *Confirmatory seamless phase II/III clinical trials with hypotheses selection at interim: general concepts.* Biometrical J 2006.
- Magirr D, Jaki T, Whitehead J. *A generalized Dunnett test for multi-arm multi-stage clinical studies with treatment selection.* Biometrika 2012.
- FDA. *Adaptive Designs for Clinical Trials of Drugs and Biologics.* 2019.

## Core statistical tools

| Method | Mechanic | Strength | Weakness |
|---|---|---|---|
| **Thall-Simon-Ellenberg (1988)** | Stage 1: all arms vs control; select best; stage 2: single arm vs control | Simple, intuitive | Strict α control via Bonferroni is conservative |
| **Stallard-Todd (2003)** | Multi-arm GS with pre-specified futility + selection at interim | Flexible stopping, GS framework | Complex boundary computation |
| **Combination test (Bauer-Kieser 1999)** | Fisher/inverse-normal combine stage-1 and stage-2 p-values; preserves α despite selection | Strong α control under any selection rule | Efficiency loss vs Dunnett when PH holds |
| **Generalized Dunnett (Magirr-Jaki-Whitehead 2012)** | Exact critical values accounting for correlation across arm-vs-control tests | Powerful when all arms share control | Computationally intensive; requires correlation structure |

## When adaptive selection is the right tool

- **Multiple candidate doses or treatments** with similar expected benefit — selection lets Phase 3 pick the winner without running separate trials.
- **Partial regulatory buy-in for a single Phase 3** — adaptive selection allows sponsor to claim a confirmatory trial even as dose is chosen mid-study, saving one Phase 3 cycle.
- **Limited patient pool** — in rare diseases, running parallel Phase 3s is infeasible; selection is often mandatory.

## When it is not

- **Asymmetric candidate strengths** — if one arm is known superior, skip selection and go direct.
- **Regulatory preference for separate trials** — some agencies (notably PMDA historically) prefer dose-specific Phase 3s for labeling clarity.
- **Correlated toxicity profiles** — if arms share a safety signal, selection based on efficacy can mislead (lower-dose may have equal efficacy but less toxicity).

## Multiplicity

Adaptive selection must control FWER across K experimental arms. Common strategies:

- **Closed testing** (Bauer-Kieser style): test each arm-vs-control hypothesis and intersection hypotheses.
- **Dunnett correction**: pre-computed critical values adjusted for correlation induced by shared control.
- **Combination test**: combine stage-1 and stage-2 p-values with pre-specified weights; α preserved via closure.

## R package landscape

- `asd` — adaptive seamless design with treatment selection (Stallard-Todd, Bauer-Kieser).
- `MAMS` — multi-arm multi-stage including treatment selection variants.
- `rpact` — inverse-normal combination test; supports arm selection via getDataSet.
- `gMCP` — graphical multiplicity verification.
- `dunnettsTest` (stats package) — conventional Dunnett.

## Corpus

Four methodology-canonical cases spanning the design space:

- 1988_Thall-Simon-Ellenberg_drop-the-loser — foundational two-stage selection
- 2003_Stallard-Todd_seamless-selection — GS-framework seamless Phase II/III
- 2006_Bretz-Schmidli_seamless-ph-ii-iii — combination test with hypothesis selection
- 2012_Magirr-Jaki-Whitehead_generalized-dunnett — MAMS with treatment selection

## Caveats

- **Real Phase 3 trials with adaptive arm selection rarely publish full SAPs** — methodology papers are the primary source. Known examples (INHANCE, ASTIN, GBM-AGILE within platform family) have partial public documentation.
- **α control under selection differs from MAMS.** MAMS keeps all arms and adjusts α by multiplicity alone; selection reduces active arms but preserves α via combination test. These are distinct families in this corpus.
