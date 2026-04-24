# designr benchmark corpus

A curated set of **public, real-world Phase 3 trial designs** used as a ground-truth evaluation suite for the `designr` agent and R package.

## Purpose

Every design family `designr` claims to support must have at least one real trial in this corpus for which `designr` reproduces the published sample size / events / boundaries within a defined tolerance. Every case is both:

- **Human-readable** (`<case>.md`): narrative description, citations, design rationale, caveats.
- **Machine-readable** (`<case>.yaml`): structured inputs + expected outputs, validated against `schema/design.schema.json`.

## Taxonomy (design families in scope)

```
benchmarks/
├── schema/
│   └── design.schema.json
├── fixed-superiority/       Fixed-sample superiority designs
├── fixed-non-inferiority/   Fixed-sample NI designs (incl. margin derivation)
├── fixed-equivalence/       Two-sided equivalence / TOST
├── group-sequential/        GS efficacy-only
├── group-sequential-futility/  GS with non-binding / binding futility
├── group-sequential-nph/    GS under non-proportional hazards (gsDesign2)
├── adaptive-ssr/            Sample-size re-estimation (unblinded & blinded)
├── adaptive-enrichment/     Population enrichment at interim
├── adaptive-selection/      Treatment selection / pick-the-winner
├── mams/                    Multi-arm multi-stage
├── tte-ph/                  Time-to-event, proportional hazards
├── tte-nph/                 Non-proportional hazards (delayed effect, cure, crossing)
├── recurrent-events/        Recurrent event endpoints (negative binomial, LWYY)
├── count-rate/              Count / rate endpoints
├── bayesian/                Bayesian Phase 3 (predictive power, BPP, pp-stopping)
├── platform/                Platform trials with shared control
├── basket/                  Tumor-agnostic / biomarker-defined baskets
├── umbrella/                Single-indication, multiple treatment strata
├── crossover/               AB/BA and higher-order crossover
├── factorial/               2x2 and higher factorial
└── non-standard/            Anything that doesn't fit above — seed for new families
```

## Source pool (for case selection)

1. **FDA guidance documents** — worked examples and reference designs.
2. **ICH guidelines** — E9, E9(R1), E10, E20, E17, E18.
3. **EMA reflection papers and scientific advice** (public portions).
4. **ClinicalTrials.gov** — entries with public Statistical Analysis Plans, especially those with published primary results in major journals.
5. **Textbooks & methodology papers** — Jennison & Turnbull; Wassmer & Brannath; Berry et al. (Bayesian); Chow et al.; Friede & Kieser (SSR); Magirr et al. (MAMS); Lin et al. (master protocols).
6. **R package vignettes** — `gsDesign`, `gsDesign2`, `rpact`, `simtrial` documentation examples (useful but lower-tier than real trials).

## Case-selection principles

- **Prefer trials with a public SAP or detailed methods section** that specifies all design parameters.
- **Diversity over volume** — 3–5 well-documented cases per family beats 20 shallow ones.
- **Include notable failures** where assumptions proved wrong (e.g. trials with delayed effects that assumed PH) — they are teaching cases.
- **Redact nothing** — only public data. No proprietary SAPs.

## Case file naming

```
<family>/cases/<YYYY>_<first-author-or-trial-acronym>_<short-slug>.{md,yaml}
```

Examples:
- `group-sequential/cases/2007_CHARM-PRESERVED_hf.md`
- `tte-nph/cases/2020_KEYNOTE-189_nsclc.md`
- `adaptive-ssr/cases/2015_TRILOGY-ACS_post-acs.md`

## Status

This README and the schema are scaffolded. Population of the corpus is the next major work item — see `benchmarks/ROADMAP.md` (TBA) for the research plan.
