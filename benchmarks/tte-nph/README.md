# tte-nph — Time-to-event under non-proportional hazards

## Family overview

Time-to-event Phase 3 designs where the proportional hazards (PH) assumption does **not** hold. The family covers the methodology and trial patterns that arise when:

- **Delayed treatment effect** — hazard ratio near 1.0 early, then diverges (common in immuno-oncology).
- **Crossing hazards** — one arm worse early, better late (or vice versa).
- **Cure fraction** — long plateau in survival curve (CAR-T, some immunotherapies).
- **Waning efficacy** — effect strongest early, attenuates over time (vaccines).
- **Early separation then convergence** — effect concentrated in early follow-up.

Under NPH, the standard log-rank test and Cox HR are **mis-specified summaries**: valid as tests but not efficient, and the HR estimate is a time-averaged artifact, not a causal quantity. Design choices fall into three camps:

1. **Stick with log-rank + HR**, accept the efficiency loss, and size conservatively using an "average HR" or piecewise-exponential model.
2. **Switch to a weighted or alternative test** — Fleming-Harrington weighted log-rank FH(ρ,γ), max-combo, RMST difference, milestone survival.
3. **Report and power on a primary non-HR estimand** — RMST at τ, milestone survival difference, landmark analyses.

## Common design pitfalls

- **Under-powering due to delayed effect**: assuming constant HR understates event requirement when true effect is delayed.
- **Over-reliance on HR**: regulators increasingly accept non-HR estimands but sponsors often pre-specify HR reflexively.
- **Weighted log-rank bias**: FH(0,1) is unbiased only under H0; under H1 it up-weights late events which can inflate Type I error if weighting is data-dependent.
- **Max-combo multiplicity**: naïve max over tests inflates α unless asymptotic joint distribution used.
- **Timing of events matters**: under NPH, more events ≠ more information uniformly across follow-up — timing changes the estimand.

## R packages that implement this family

- **`nphDesign`** — Tsiatis-Mehrotra, piecewise HR sample size, weighted log-rank.
- **`gsDesign2`** — piecewise exponential, AHR (average HR), weighted log-rank boundaries.
- **`simtrial`** — simulation-based NPH designs, max-combo test.
- **`rpact::getSampleSizeSurvival`** — piecewise accrual + exponential survival (can approximate NPH).
- **`nph`** — NPH simulation and plotting.

## Cases in this corpus

| Case | Year | NPH pattern | Design feature |
|---|---|---|---|
| Pfizer/BioNTech BNT162b2 COVID vaccine | 2020 | Waning efficacy | VE sized on early interim (94-case) |
| ZUMA-1 axi-cel CAR-T (DLBCL) | 2017 | Cure fraction | Long-tail survival, response-based |
| Uno-Claggett-Wei RMST methodology | 2014 | Any NPH | RMST-at-τ as primary estimand |
| Lin-Chen-Yang max-combo methodology | 2020 | Unknown NPH shape | FH(0,0)+FH(0,1)+FH(1,0) max test |
| CheckMate 9LA (NSCLC 1L IO+chemo) | 2020 | Early-plus-delayed | Dual-mechanism (IO+chemo) PFS/OS |
| MONALEESA-7 ribociclib (premenopausal BC) | 2017 | Delayed-then-crossing | CDK4/6i + endocrine therapy |
| ALCYONE dara-VMP (myeloma) | 2017 | Deep-response tail | Newly diagnosed MM, PFS primary |
| Fleming-Harrington weighted LR | 2011 | Any late-weight | FH(ρ,γ) design methodology |
