# Perampanel Study 304 (2012) — adjunctive AED for partial-onset seizures

**Family:** count-rate · **Endpoint:** median %Δ seizure frequency + responder rate · **N:** 387 · **Design feature:** FDA AED adjunctive convention

## Why this case is in the corpus

- **Classical FDA adjunctive AED convention** — median %Δ 28-day seizure frequency + ≥ 50% responder rate as co-primary.
- Dose-response three-arm design (8 mg, 12 mg, placebo).
- First-in-class AMPA receptor antagonist approval archetype.

## Citation

French JA, Krauss GL, Biton V, et al. *Adjunctive perampanel for refractory partial-onset seizures: randomized phase III study 304.* Neurology. 2012;79(6):589-596. doi:10.1212/WNL.0b013e3182635735. NCT00699972.

## Design summary

| | |
|---|---|
| Design | RDBPC, 3-arm (8 mg + 12 mg + placebo) |
| Population | Refractory partial-onset seizures, on 1-3 AEDs |
| Run-in | 6-week prospective baseline |
| Treatment | 6-wk titration + 13-wk maintenance |
| Primary US | Median %Δ in 28-day seizure rate (Wilcoxon) |
| Primary EU | ≥ 50% responder rate |
| α / power | 0.05 (two-sided) / 0.90 |
| Planned N | ~390 |

## Reproducing the design

```r
# Sample size via historical effect-size extrapolation
library(rpact)
# NB sensitivity analysis:
d <- getSampleSizeCounts(
  alpha = 0.025, beta = 0.10,
  lambda1 = 0.74, lambda2 = 1.00,  # rate ratio 0.74
  overdispersion = 2.5
)
```

Analysis:

```r
library(stats)
# Primary — Wilcoxon %Δ (US)
wilcox.test(pct_change_seizure ~ arm, data = df)

# Co-primary — ≥50% responder (EU)
# Cochran-Mantel-Haenszel stratified by region
```

## Trial outcome

- Median %Δ: **-26.3% (8 mg), -34.5% (12 mg), -21.0% (placebo)**.
- ≥ 50% responder rate: 33.3% (8 mg) and 33.9% (12 mg) vs 14.7% (placebo), p < 0.01.
- Both doses significantly superior to placebo.
- FDA approval October 2012 (Fycompa).

## How this case validates designr

- FDA AED adjunctive convention reference (%Δ + responder co-primary).
- Three-arm dose-response epilepsy design.
- Pre-baseline run-in + stratified randomization pattern.
