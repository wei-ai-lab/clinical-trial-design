# Benchmark corpus — research roadmap

Living document. Drives the autonomous research work to populate `benchmarks/`.

## Goals

1. Every design family in the taxonomy has **≥ 5 real-trial cases** fully specified (markdown + schema-valid YAML).
2. Every case lists the original **design parameters** and **expected outputs** from the public SAP / methods section / design paper.
3. Every case is ultimately **reproducible** by one or more R packages that `designr` wraps.

## Methodology

### Case selection (tiered)

| Tier | Source type | Preference |
|---|---|---|
| 1 | Design paper published separately (e.g. "Rationale and design of the X trial"), co-published SAPs, public registry-linked SAPs | Preferred — has explicit inputs/outputs |
| 2 | Primary results paper with a detailed methods/statistics section | Acceptable when design paper not available |
| 3 | FDA / EMA / PMDA review documents with reproducible worked examples | Good for regulatory-grounded cases |
| 4 | ICH / FDA / EMA guidance documents with worked examples | Excellent — usually the "canonical" reference |
| 5 | Textbook worked examples (Jennison & Turnbull, Wassmer & Brannath, Berry, Chow, etc.) | Good for pedagogical clarity |
| 6 | R package vignettes | Lowest tier — useful but not a real trial |

### Parameter extraction

For each case, extract:
- Indication, population, arms, allocation ratio.
- Primary endpoint definition + type.
- Comparison type (superiority / NI / equivalence) and sidedness.
- Effect assumption (`design.effect`) — specific to endpoint type.
- α, 1−β targets.
- Accrual / follow-up / dropout (for TTE and TTT designs).
- Interim analyses — timing (info fraction), α-spending, β-spending, binding.
- Adaptation rules (SSR trigger, enrichment, selection).
- **Expected outputs**: total N, per-arm N, total events (TTE), boundaries at each analysis.

### Tolerance conventions

When validating `designr` output against a benchmark:
- Sample size: **±2%** tolerance (rounding, tie-breaking in gsDesign differ across packages).
- Events: **±1%** tolerance.
- Boundary values: **±0.005** absolute on standardized z-scale.
- Power under simulation: **±1%** absolute.

Cases can override with a custom `expected.tolerance` block.

### Caveats to capture

- Trials whose assumptions were wrong in reality (e.g. PH assumed, observed delayed effect) — these are teaching cases.
- Trials where the published SAP differs from what was executed (protocol amendments).
- Trials where the computed expected output differs slightly from what was reported (rounding / external tools used).

## Per-family target counts (initial)

| Family | Target cases | Priority source pool |
|---|---|---|
| fixed-superiority | 8 | CVOT, oncology, rare-disease Phase 3 |
| fixed-non-inferiority | 6 | NOAC trials, antibiotic NI, NI guidance |
| fixed-equivalence | 4 | Biosimilars, bioequivalence (where Phase 3) |
| group-sequential | 8 | Classic CV GS trials, NCI oncology GS |
| group-sequential-futility | 5 | Modern GS with binding/non-binding futility |
| group-sequential-nph | 6 | IO oncology (PD-1, CAR-T), HF delayed effect |
| adaptive-ssr | 5 | Friede-Kieser / Cui-Hung-Wang examples |
| adaptive-enrichment | 4 | Oncology biomarker-enrichment |
| adaptive-selection | 4 | Dose-finding w/ confirmatory, MAMS-like |
| mams | 5 | STAMPEDE, RECOVERY, ROMA |
| tte-ph | 8 | Classic CVOT, oncology PH |
| tte-nph | 8 | IO oncology delayed effect, crossing curves |
| recurrent-events | 4 | HF hospitalization (LWYY, NB), COPD exacerbations |
| count-rate | 4 | Epilepsy seizure count, vaccine trials |
| bayesian | 5 | BATTLE, I-SPY2 (Phase 2/3), pediatric extrapolation |
| platform | 5 | RECOVERY, REMAP-CAP, STAMPEDE |
| basket | 4 | NCI-MATCH, Pembrolizumab TMB-H basket |
| umbrella | 4 | BATTLE-2, Lung-MAP |
| crossover | 3 | Rare disease, bioequivalence for drugs |
| factorial | 3 | 2x2 CVOT factorial (HOPE-3, COMMIT) |
| non-standard | 3 | Seamless Phase 2/3, unusual adaptive designs |

**Total target: ~110 cases.**

## Execution loop

Work proceeds in autonomous iterations (`/loop` dynamic mode):
1. Pick next unfinished family from the taxonomy.
2. Write family README (if not present) — design-family overview, common pitfalls, R packages that implement it.
3. Add cases one at a time: YAML first (validate against schema), then markdown narrative.
4. Commit per-family, push after each commit.
5. Log progress in this file (update status table below).

## Progress log

| Family | README | Cases done | Target | Status |
|---|---|---|---|---|
| framework (ROADMAP, GLOSSARY) | — | — | — | ✅ |
| fixed-superiority | ✅ | 10 | 8 | ✅ |
| fixed-non-inferiority | ✅ | 10 | 6 | ✅ |
| fixed-equivalence | ✅ | 6 | 4 | ✅ |
| group-sequential | ✅ | 10 | 8 | ✅ |
| group-sequential-futility | ✅ | 7 | 5 | ✅ |
| group-sequential-nph | ✅ | 8 | 6 | ✅ |
| adaptive-ssr | ✅ | 7 | 5 | ✅ |
| adaptive-enrichment | ✅ | 6 | 4 | ✅ |
| adaptive-selection | ✅ | 6 | 4 | ✅ |
| mams | ✅ | 9 | 5 | ✅ |
| tte-ph | ✅ | 10 | 8 | ✅ |
| tte-nph | ✅ | 10 | 8 | ✅ |
| recurrent-events | ✅ | 8 | 4 | ✅ |
| count-rate | ✅ | 8 | 4 | ✅ |
| bayesian | ✅ | 9 | 5 | ✅ |
| platform | ✅ | 9 | 5 | ✅ |
| basket | ✅ | 8 | 4 | ✅ |
| umbrella | ✅ | 8 | 4 | ✅ |
| crossover | ✅ | 7 | 3 | ✅ |
| factorial | ✅ | 5 | 3 | ✅ |
| non-standard | ✅ | 7 | 3 | ✅ |
