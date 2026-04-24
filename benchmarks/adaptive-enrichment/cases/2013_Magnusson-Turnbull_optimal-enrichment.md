# Magnusson-Turnbull (2013) — Optimal Group-Sequential Enrichment

**Family:** adaptive-enrichment · **Kind:** methodology-paper · **Scope:** optimal GS enrichment with subgroup selection

## Why this case is in the corpus

- **Canonical optimal-design reference** for adaptive enrichment — first to formalize optimality criteria across configurations of true effect.
- Combines group-sequential monitoring, closed testing across H_F and H_S, and formal enrichment decision rules in one framework.
- Foundation for modern biomarker-enrichment trials that seek pre-specified, FWER-controlled, and quasi-optimal designs.
- Complements Freidlin-Simon (signature discovery), Brannath-Mehta (combination-test framework), and Jenkins-Stone-Jennison (seamless Phase 2/3) in the corpus.

## Citation

Magnusson BP, Turnbull BW. *Group sequential enrichment design incorporating subgroup selection.* Stat Med. 2013 Jul 30;32(17):2695-714.

## Core design

| Element | Value |
|---|---|
| Populations | Full (F) and biomarker-defined Subset (S ⊂ F) |
| Hypotheses | H_F (effect in F), H_S (effect in S) |
| Analyses | K group-sequential looks with at least one enrichment decision |
| Actions at interim | Continue as-is / enrich to S / stop efficacy / stop futility |
| α control | Closed testing + group-sequential spending |
| Optimality | Minimax expected N across a configuration set |

## Algorithm

```r
# Magnusson-Turnbull 2013 schematic (requires simulation for full impl)
# 1. Specify configuration set of true effects: (Δ_F, Δ_S) pairs:
#    - both null, only S effective, both effective, F effective
# 2. Specify prevalence π of S in F.
# 3. Over boundary parameters (c_F, c_S, enrichment threshold τ):
#    - simulate N under each configuration
#    - compute expected N under design weights
# 4. Solve: minimize max config expected N
#    s.t. type I error ≤ α across (H_F, H_S) via closed testing
#         power ≥ 1 - β under the "effective" configurations.
# 5. Output: boundaries at each look, enrichment rule, expected N.

# rpact + asd sketch
library(rpact)
library(asd)
# Configure 3-stage GS with adaptive subgroup selection — asd
# covers selection, rpact covers spending; integrating is
# paper-specific simulation code.
```

## Typical magnitudes

- 3-4 analyses with one interim enrichment decision.
- α = 0.025 one-sided, 1-β = 0.90.
- Prevalence π in 0.3-0.5 common — low π makes enrichment decisions harder (wider CIs at interim).
- Effect in S ~1.5-2× effect in F to make enrichment worthwhile.
- Expected-N savings of 15-30% vs a non-adaptive design that tests both H_F and H_S.

## Historical / scientific role

- First paper to optimize adaptive enrichment designs under a formal criterion.
- Informs FDA 2019 Adaptive Designs guidance on biomarker enrichment.
- Basis for several later extensions:
  - Rosenblum-van der Laan (2011) on fixed-threshold optimal enrichment.
  - Friede-Parsons-Stallard (2011) on combined dose-selection + enrichment.
  - Uozumi-Hamada (2017) on Bayesian optimal enrichment.
- Close to the design used in TAPPAS (2019, angiosarcoma) and several immunotherapy biomarker-enrichment trials.

## How this case validates designr

- Adds the **optimal-design perspective** to the adaptive-enrichment corpus — the other four cases are either foundational (Freidlin-Simon), methodological-framework (Brannath-Mehta, Jenkins-Stone-Jennison), or a real trial (TAPPAS).
- Establishes that `designr` should be able to expose configuration-set weighting and minimax expected-N optimization for the enrichment family (via asd + rpact composition or custom simulation backend).
- Canonical GS + closed-testing + selection combination that any serious enrichment design API must support.
