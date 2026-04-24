# Spiegelhalter-Abrams-Myles (2004) — Bayesian textbook

**Family:** bayesian · **Kind:** methodology-textbook · **Scope:** Phase 3 Bayesian inference and decision-theoretic stopping

## Why this case is in the corpus

- Most widely-cited textbook on Bayesian clinical trials (8,000+ citations).
- Canonical taxonomy for prior elicitation (sceptical, enthusiastic, reference, community).
- Defines Bayesian monitoring (posterior probability + predictive probability) used in modern Phase 3 adaptive protocols.
- Foundation for FDA 2010 Bayesian Medical Device Guidance and EMA Bayesian Reflection Paper.

## Citation

Spiegelhalter DJ, Abrams KR, Myles JP. *Bayesian Approaches to Clinical Trials and Health-Care Evaluation.* Wiley; 2004. ISBN 978-0-471-49975-5. Companion tutorial: Spiegelhalter DJ. *Incorporating Bayesian ideas into health-care evaluation.* Stat Sci. 2004;19(1):156-174.

## Core framework

| Concept | Meaning | Phase 3 application |
|---|---|---|
| **Sceptical prior** | Centered on null, variance set so p(HR < 0.80) is small | Regulator's "show me the evidence" stance |
| **Enthusiastic prior** | Centered on designed effect, variance small | Sponsor / community optimism |
| **Reference prior** | Vague / non-informative | Objective sensitivity analysis |
| **Community prior** | Formally elicited from clinicians | Stakeholder decision framework |
| **Posterior probability** | P(HR < 1 \| data) | Interim / final decision rule |
| **Predictive probability** | P(will reach success \| current data) | Bayesian conditional power |
| **Power prior** | Likelihood raised to discount α ∈ [0,1] | Historical borrowing with controlled influence |
| **Hierarchical model** | Shrinkage across subgroups / centers | Biomarker / center borrowing |

## Reproducing the framework

```r
library(rstan)
# Sceptical vs enthusiastic prior analysis
stan_fit_sceptical <- stan(
  model_code = "
    data { int y1; int n1; int y2; int n2; }
    parameters { real<lower=0, upper=1> p1; real<lower=0, upper=1> p2; }
    model {
      // sceptical prior on log OR: centered at 0, sd ~ log(2)/2
      target += normal_lpdf(log(p1/(1-p1)) - log(p2/(1-p2)) | 0, log(2)/2);
      y1 ~ binomial(n1, p1);
      y2 ~ binomial(n2, p2);
    }
  ",
  data = list(y1 = observed_y1, n1 = n1, y2 = observed_y2, n2 = n2)
)

# Posterior prob of benefit
mean(extract(stan_fit_sceptical)$p1 < extract(stan_fit_sceptical)$p2)

# Predictive probability of success at trial end (Bayesian conditional power)
library(RBesT)
# ... via postmix + pmixture
```

## Key applications in corpus context

- **Posterior probability thresholds** for Phase 3 adaptive stopping (used in I-SPY2, BATTLE, REMAP-CAP, PRINCIPLE).
- **Predictive probability** for Bayesian futility analogous to conditional power (used in ISPY, DIAN-TU).
- **Power / MAP priors** for historical borrowing (formalized further by Neuenschwander 2010).
- **Sceptical prior** as sensitivity analysis for regulatory submissions claiming non-trivial prior influence.

## How this case validates designr

- Foundational textbook reference for the bayesian family.
- Prior-elicitation taxonomy enables designr's Bayesian prior-specification API.
- Posterior / predictive probability decision rules are directly implementable via rstan / brms / RBesT backends.
- Links subsequent corpus entries (Neuenschwander MAP 2010, Gamalo-Siebers pediatric 2014, Berry textbook 2011) to their common ancestor.
