# platform — Platform / master protocol Phase 3 designs

## Family overview

Phase 3 designs evaluating **multiple interventions under a shared master protocol**, with provisions for adding or dropping arms over time. Distinguished from MAMS (multi-arm multi-stage) in that:

- **Perpetual / open-ended** enrollment is standard — new arms enter when new agents become available.
- **Disease-focused, not drug-focused** — the trial is a standing infrastructure; individual arms are specific evaluations.
- **Bayesian decision framework** is common (but not required).
- **Shared control** — often concurrent, sometimes time-trend-adjusted.
- **New arm addition** — pre-specified in protocol; typically requires protocol amendment.

Three archetypes:

1. **Umbrella-style platform** — single disease, multiple biomarker-defined sub-groups each matched to targeted therapies (e.g., Lung-MAP, I-SPY2).
2. **Multi-drug efficacy platform** — single disease, multiple interventions vs shared control (e.g., RECOVERY, Solidarity).
3. **Perpetual adaptive platform** — Bayesian backbone with response-adaptive allocation (e.g., REMAP-CAP, GBM AGILE).

## Common design pitfalls

- **Time trends in shared control**: when using non-concurrent control, calendar-time drift can bias arm-vs-control comparison.
- **Alpha allocation across arms**: whether to control family-wise error across all arms ever run (conservative) or only concurrent arms (pragmatic, FDA-accepted in many cases).
- **Arm-entry threshold**: scientific and operational bar for adding an arm; SAC / DSMB governance.
- **Operational complexity**: single harmonized protocol, endpoint, and data collection across arms is logistically demanding.
- **Regulatory alignment upfront**: FDA/EMA master protocol guidance encourages pre-submission meetings.

## R / software packages

- **`FACTS`** — commercial Bayesian adaptive trial design (Berry Consultants), used in REMAP-CAP / I-SPY2 / GBM AGILE.
- **`rstan` / `brms`** — Bayesian posterior computation.
- **`MAMS` / `nstage`** — frequentist multi-arm platform subsets.
- **`survival`, `rpact`, `gsDesign2`** — per-arm TTE sizing within platform.

## Regulatory references

- **FDA master protocol guidance** (2018 draft, 2022 final: "Master Protocols: Efficient Clinical Trial Design Strategies").
- **EMA reflection paper** on methodological issues in master protocols (2022).
- **ICH E17** aligns multi-regional platform conduct.

## Cases in this corpus

| Case | Year | Disease | Platform style |
|---|---|---|---|
| REMAP-CAP — CAP / COVID perpetual platform | 2020 | Pneumonia / COVID-19 | Bayesian adaptive |
| Lung-MAP — biomarker umbrella-platform | 2014 | Squamous NSCLC | Master protocol, biomarker-matched |
| GBM AGILE — glioblastoma adaptive platform | 2018 | GBM | Bayesian adaptive (Berry Consultants) |
| Solidarity — WHO COVID platform | 2020 | COVID-19 | Pragmatic WHO multi-arm |
| Angus platform trial methodology | 2019 | Any | Methodology review (JAMA) |
