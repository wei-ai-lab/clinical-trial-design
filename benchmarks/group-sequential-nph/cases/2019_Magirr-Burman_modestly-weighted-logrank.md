# Magirr-Burman (2019) — Modestly Weighted Logrank / MaxCombo

**Family:** group-sequential-nph · **Kind:** methodology-paper · **Scope:** weighted logrank tests under NPH with type-I control under crossing-harm

## Why this case is in the corpus

- **Canonical modern methodology** for NPH-aware test construction — addresses the 'delayed-effect' IO problem without the FH(0,1) type-I pathology under early crossing.
- Paired with MaxCombo (Lin et al. 2020) as the de-facto standard for NPH-aware Phase 3 primary-test choice.
- FDA 2021 NPH Workshop endorsed as acceptable primary test when NPH is anticipated.
- Complements Uno (2014) RMST methodology in the corpus with the weighted-logrank line.

## Citation

- Magirr D, Burman CF. *Modestly weighted logrank tests.* Stat Med. 2019 Sep 20;38(20):3782-3790.
- Lin R, Lin J, Roychoudhury S, Anderson KM, Hu T, Huang B, et al. *Alternative analysis methods for time to event endpoints under non-proportional hazards: a comparative analysis.* Stat Biopharm Res. 2020;12(2):187-198.

## Core framework

| Test | Weight w(t) | Best for |
|---|---|---|
| Logrank | 1 | PH |
| FH(0,1) | S(t) | Late-effect (but poor under crossing harm) |
| FH(1,0) | 1 - S(t) | Early-effect |
| FH(1,1) | S(t)·(1-S(t)) | Mid-effect |
| Modestly-weighted (MB) | max(S(t), 0.5) | Late-effect with type-I safety |
| MaxCombo | max of logrank, FH(0,1), FH(1,0), FH(1,1) | Robust across NPH types |

## Algorithm

```r
# Modestly-weighted logrank (Magirr-Burman 2019)
library(nph)
logrank.test(
  time = df$time,
  event = df$event,
  group = df$arm,
  rho = 0, gamma = 1      # FH(0,1)
)
# Modestly-weighted variant: custom weight function capped at 0.5

# MaxCombo (Lin et al. 2020) via simtrial
library(simtrial)
result <- sim_fixed_n(
  n_sim = 1,
  sample_size = 400,
  stratum = NULL,
  fail_rate = tibble::tibble(
    stratum = "All", period = 1:2,
    duration = c(3, 100),
    fail_rate = c(log(2)/12, log(2)/18),
    hr = c(1.0, 0.6)    # delayed effect: no diff months 0-3, HR 0.6 after
  )
)
result |> cut_data_by_event(250) |> maxcombo(rho = c(0,0,1), gamma = c(0,1,1))

# GS design with weighted logrank
library(gsDesign2)
gs_design <- gs_design_wlr(
  analysis_time = c(12, 24, 36),
  alpha = 0.025, beta = 0.10,
  weight = fh(0, 1),
  enroll_rate = define_enroll_rate(duration = 18, rate = 25),
  fail_rate = define_fail_rate(...),
  test = wlr()
)
```

## Design implications

- Under moderate delayed effect, modestly-weighted logrank or FH(0,1) saves 15-25% events vs logrank.
- MaxCombo closed-testing multiplicity adjustment costs ~5-10% power vs best single test.
- Pre-specification of weights / test family is essential for regulatory acceptance.
- GS with weighted logrank requires information-time accounting different from standard logrank — handled by `gsDesign2` and `rpact`.

## Relationship to other NPH methods

- **RMST** (Uno 2014): complementary; model-free but can lose power if τ choice is poor.
- **Piecewise HR / Royston-Parmar**: parametric; sensitive to specification.
- **Milestone analysis**: single-time survival; extreme case.
- **Weighted KM (Pepe-Fleming)**: similar information to RMST.

## Regulatory / industry status

- **FDA 2021 NPH Workshop**: endorsed modestly-weighted logrank and MaxCombo.
- **EMA**: similar stance with pre-specification requirement.
- **POLARIX** (2022 DLBCL): used FH(0,1).
- Multiple recent CAR-T and checkpoint-inhibitor trials pre-specified MaxCombo.

## How this case validates designr

- Adds the **weighted-logrank methodology line** to the GS-NPH corpus, complementing Uno's RMST line.
- `designr` should expose MaxCombo and modestly-weighted logrank as first-class design options via `gsDesign2::gs_design_wlr` and `simtrial`.
- Teaching case: when NPH is anticipated, pre-specify either RMST, MaxCombo, or modestly-weighted logrank as the primary test — logrank alone under-powers the delayed-effect scenario.
