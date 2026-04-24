# REMAP-CAP (2020) — perpetual Bayesian adaptive platform for severe CAP / COVID-19

**Family:** platform · **Endpoint:** organ-support-free days day 21 · **Design feature:** multi-domain factorial-within-patient Bayesian adaptive

## Why this case is in the corpus

- **Canonical perpetual Bayesian adaptive platform** — pre-pandemic infrastructure pivoted to COVID.
- Multi-domain factorial-within-patient (patient can enter arms in 3-5 orthogonal domains).
- First platform to establish IL-6R antagonists (tocilizumab/sarilumab) as COVID-19 ICU SOC.

## Citation

The REMAP-CAP Investigators. *Interleukin-6 receptor antagonists in critically ill patients with Covid-19.* N Engl J Med. 2021;384(16):1491-1502. doi:10.1056/NEJMoa2100433. NCT02735707.

## Design summary

| | |
|---|---|
| Design | Perpetual Bayesian adaptive platform |
| Population | ICU-admitted severe pneumonia |
| Domains | Antiviral · Immune modulation · Antiplatelet · Anticoagulation · Statin · Plasma · Vitamin C |
| Primary | Organ-support-free days to day 21 (ordinal) |
| Adaptation | Response-adaptive allocation within domain |
| Superiority | Pr(OR > 1) > 0.99 |
| Inferiority | Pr(OR > 1) < 0.05 |
| Governance | Domain-specific DSMB + platform SAC |

## Reproducing the design

```r
library(FACTS)  # commercial; or custom Stan model

# Per-domain cumulative proportional odds model
# log(OR) ~ Normal(μ_intervention, σ²)
# μ_intervention ~ hierarchical prior across domains

# Interim decisions (per domain):
#  if Pr(OR > 1 | data) > 0.99 → superiority
#  if Pr(OR > 1 | data) < 0.05 → inferiority (arm drop)
# Adaptive allocation: prob ∝ Pr(arm is best | data)
```

## Trial outcome (IL-6R antagonist domain)

- 895 patients randomized to IL-6R antagonist or control.
- Adjusted OR for OSFD: **1.64** (95% credible 1.25-2.14).
- Posterior Pr(superior) = **99.6%** — superiority declared.
- Hospital mortality: 27% (IL-6R) vs 36% (control).
- Rapid FDA EUA (June 2021) for tocilizumab in COVID-19.

## How this case validates designr

- Perpetual Bayesian platform reference.
- Multi-domain factorial-within-patient architecture.
- Ordinal OSFD endpoint design.
- Pandemic-responsive "warm" platform infrastructure.
