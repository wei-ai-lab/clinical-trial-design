# FOURIER (2017) — Evolocumab PCSK9i CV Outcomes

**Family:** fixed-superiority · **Kind:** landmark Phase 3 CVOT · **Scope:** event-driven superiority with dual MACE hierarchy

## Why this case is in the corpus

- **First PCSK9 inhibitor CVOT** to demonstrate MACE reduction on top of optimized statin therapy.
- Classic event-driven superiority design with **dual MACE primary-secondary hierarchy** (5-point then 3-point).
- Largest modern CV outcomes trial (N = 27,564).
- Established 59% LDL-C reduction with confirmed clinical benefit.
- Triggered post-hoc FOURIER-OLE 5-year extension for long-term mortality.

## Citation

- Sabatine MS, Giugliano RP, Keech AC, et al. *Evolocumab and clinical outcomes in patients with cardiovascular disease.* N Engl J Med. 2017 May 4;376(18):1713-1722.
- Sabatine MS, Giugliano RP, Keech A, et al. *FOURIER design.* Am Heart J. 2016;173:94-101.

## Design summary

| Parameter | Value |
|---|---|
| Indication | ASCVD + LDL-C ≥ 70 on optimized statin |
| Arms | Evolocumab 140 mg Q2W (or 420 mg monthly) SC vs placebo (1:1) |
| Primary | 5-point MACE (CV death, MI, stroke, UA hospitalization, revasc) |
| Key secondary | 3-point MACE (CV death, MI, stroke) |
| α / power | 0.05 two-sided / 90% |
| Assumed HR | 0.85 |
| Control rate | ~ 7.5%/year (5-point MACE) |
| Target events | 1,630 |
| Randomized N | 27,564 |
| Median follow-up | 2.2 years |

## Dual MACE hierarchy

Modern CVOT design pattern:
- **Broader primary (5-point)**: includes revascularization + unstable angina → more events, faster readout, more power.
- **Narrower key secondary (3-point)**: hard CV endpoints only → more stringent, clinically cleaner.
- Hierarchical testing: key secondary only tested if primary significant → no α penalty.

```r
library(gsDesign)

# Event-driven CVOT sizing
d <- gsSurv(
  k = 2,
  alpha = 0.025,
  beta = 0.10,
  lambdaC = -log(1 - 0.075),    # 7.5% annual hazard (5-point MACE)
  hr = 0.85,
  eta = 0,
  T = 48, minfup = 24,
  test.type = 2,
  sfu = sfLDOF
)
# ~1,630 events → ~27,500 randomized
```

## Hierarchical secondary order

1. 5-point MACE — primary.
2. 3-point MACE — key secondary.
3. Individual components (CV death, MI, stroke).
4. All-cause death.
5. Safety (neurocognitive, new-onset diabetes).

## LDL-C reduction

- Baseline median LDL-C: 92 mg/dL (on statin).
- Week 48 LDL-C: 30 mg/dL (median 59% reduction).
- Large absolute and relative LDL reduction.

## Results

| Outcome | Evolocumab | Placebo | HR (95% CI) | P |
|---|---|---|---|---|
| 5-point MACE | 9.8% | 11.3% | **0.85 (0.79-0.92)** | < 0.001 |
| 3-point MACE | 5.9% | 7.4% | 0.80 (0.73-0.88) | < 0.001 |
| CV death | 1.8% | 1.7% | 1.05 (0.88-1.25) | NS |
| MI | 3.4% | 4.6% | 0.73 (0.65-0.82) | < 0.001 |
| Stroke | 1.5% | 1.9% | 0.79 (0.66-0.95) | 0.01 |
| All-cause death | 3.2% | 3.1% | 1.04 | NS |

## CV death: NS controversy

Despite 59% LDL reduction, CV death alone was not significant (HR 1.05, NS). Multiple factors:
- **Short follow-up**: 2.2 years insufficient for mortality endpoint at current event rates.
- **Event-driven stopping**: trial stopped when MACE events accumulated, potentially before mortality signal matured.
- **Baseline statin protection**: already on optimal statin, leaves less room for mortality reduction.

**FOURIER-OLE extension (2022)**: 5-year open-label confirmed sustained CV benefit, including significant mortality reduction not seen in original 2-year window.

## Related lipid CVOTs

| Trial | Therapy | MACE HR |
|---|---|---|
| IMPROVE-IT (2015) | Ezetimibe + statin | 0.94 |
| FOURIER (this case) | Evolocumab (PCSK9i) | 0.85 |
| ODYSSEY OUTCOMES (2018) | Alirocumab (PCSK9i) | 0.85 |
| REDUCE-IT (2019) | Icosapent ethyl | 0.75 (in HTG) |
| CLEAR Outcomes (2023) | Bempedoic acid | 0.87 (statin-intolerant) |

## Regulatory & clinical impact

- FDA December 2017: CV event reduction label (first PCSK9i with outcome indication).
- 2018 ACC/AHA cholesterol guidelines: PCSK9i for very high-risk ASCVD on maximal statin + ezetimibe.
- Triggered extensive cost-effectiveness debates (~ $14,000/year list price); resulted in 60% price cut 2018.

## How this case validates designr

- Adds the **landmark PCSK9i CVOT** to fixed-superiority corpus.
- `designr` should reproduce dual MACE hierarchical testing via `gsDesign::gsSurv` with conservative interim boundary.
- Teaches: broad-primary/narrow-secondary hierarchy, event-driven stopping considerations for mortality, post-hoc extension trials.
- Companion to EMPA-REG OUTCOME, CANVAS, SUSTAIN-6 (all in corpus) showing CVOT era 2015-2019.
