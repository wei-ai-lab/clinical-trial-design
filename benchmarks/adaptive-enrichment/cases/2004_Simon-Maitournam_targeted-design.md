# Simon-Maitournam (2004) — Targeted Design Efficiency for Biomarker Trials

**Family:** adaptive-enrichment · **Kind:** foundational methodology · **Scope:** targeted vs untargeted vs stratified trial-design efficiency

## Why this case is in the corpus

- **The** foundational paper comparing targeted, untargeted, and stratified trial designs for biomarker-defined subgroups.
- Establishes the efficiency calculus underlying every modern oncology predictive-biomarker trial (HER2+, EGFR, BRAF, MSI-H, PD-L1, BRCA).
- Simon-Maitournam framework is implicit in every adaptive enrichment methodology extension (Wang-O'Neill-Hung, Jenkins-Stone-Jennison, Magnusson-Turnbull).
- Establishes **when targeted dominates** (Δ- ≈ 0) vs **when untargeted dominates** (Δ- ≈ Δ+).

## Citation

- Simon R, Maitournam A. *Evaluating the efficiency of targeted designs for randomized clinical trials.* Clin Cancer Res. 2004 Oct 15;10(20):6759-6763.
- Companion: Maitournam A, Simon R. *On the efficiency of targeted clinical trials.* Stat Med. 2005 Feb 15;24(3):329-339.
- Overview: Simon R. *Clinical trials for predictive medicine.* Stat Med. 2012;31(25):3031-3040.

## The three design strategies

**1. Untargeted (all-comer)**:
- Enroll all patients.
- Primary: treatment effect in overall population.
- Optional: biomarker subgroup as secondary.

**2. Targeted (enrichment)**:
- Screen biomarker first.
- Enroll ONLY marker-positive patients.
- Primary: treatment effect in marker-positive.

**3. Stratified (interaction)**:
- Enroll all patients.
- Stratify by biomarker.
- Co-primary: marker-positive AND overall (or test interaction).

## Efficiency comparison

Let:
- **γ** = marker-positive prevalence.
- **Δ+** = true treatment effect in marker-positive.
- **Δ-** = true treatment effect in marker-negative.

**Key result**: sample-size ratio (targeted / untargeted) depends on Δ- / Δ+ ratio and γ.

| Regime | Targeted vs Untargeted |
|---|---|
| Δ- / Δ+ = 0 (no benefit in marker-neg) | **Targeted DOMINATES** (often by 10×+) |
| Δ- / Δ+ ≈ 0.5 | Targeted usually wins |
| Δ- / Δ+ = 1 (no differential) | Untargeted wins by factor 1/γ |

## Efficiency table (α = 0.025, 90% power)

| γ | Δ- / Δ+ | Untargeted N / Targeted N (randomized) |
|---|---|---|
| 0.1 | 0.0 | 10× |
| 0.1 | 0.5 | 2× |
| 0.1 | 1.0 | 0.5× |
| 0.3 | 0.0 | 11× |
| 0.3 | 0.5 | 2.8× |
| 0.5 | 0.0 | 4× |
| 0.5 | 1.0 | 1× |

## Screen burden — the hidden cost

Targeted design must **screen more to randomize fewer**:

```
N_screen = N_randomized / γ
```

If γ = 0.1 (rare biomarker): 10× screening volume. Assay cost dominates if:
- Next-gen sequencing (~ $500/sample): substantial.
- IHC (~ $20/sample): negligible.
- PCR hotspot (~ $100/sample): moderate.

**Optimal targeted design**: Δ- ≈ 0 AND γ moderate (0.2-0.5) AND cheap assay.

## Numerical example — HER2+ breast cancer

Trastuzumab benefit concentrated in HER2+ subgroup:

| Parameter | Value |
|---|---|
| γ (HER2+ prevalence) | 0.25 |
| Δ+ (marker-positive HR) | 0.67 (log HR = -0.40) |
| Δ- (marker-negative HR) | 1.00 (no benefit) |
| α / power | 0.025 / 90% |

**Untargeted design**:
- Pooled log HR = 0.25 × (-0.40) + 0.75 × 0 = -0.10
- Events needed for pooled HR = 0.905: ~ 988 events.

**Targeted design (HER2+ only)**:
- Target HR = 0.67 → log HR = -0.40
- Events needed: ~ 62 events.
- Screen ~ 4× more patients than randomized.

**Targeted wins by factor ~16× in events** — explains why every HER2+ therapy (trastuzumab, pertuzumab, T-DM1, T-DXd) uses targeted design.

## R implementation

```r
library(gsDesign)

# Parameters
gamma <- 0.25                     # marker prevalence
hr_pos <- 0.67                    # treatment effect (HR) in marker+
hr_neg <- 1.00                    # treatment effect in marker-

# Untargeted: pooled log HR
log_hr_pooled <- gamma * log(hr_pos) + (1 - gamma) * log(hr_neg)
hr_pooled <- exp(log_hr_pooled)

# Events needed
ev_untargeted <- nEvents(
  hr = hr_pooled, alpha = 0.025, beta = 0.10, sided = 1
)
ev_targeted <- nEvents(
  hr = hr_pos, alpha = 0.025, beta = 0.10, sided = 1
)

ratio <- ev_untargeted / ev_targeted
# ~ 15.9× — targeted massively more efficient
```

## When targeted DOES NOT dominate

- **Uncertain biomarker validity**: if Δ-/Δ+ uncertain, stratified design hedges (enrolls both, tests interaction).
- **Low γ + cheap drug**: if assay more expensive than randomization, untargeted cheaper per answer.
- **Need marker-negative evidence**: if label scope includes marker-negative, must enroll both arms.
- **Biomarker assay uncertainty**: if assay itself is being validated, can't pre-select cleanly.

## When targeted DOMINATES

- **Biological rationale strong**: mechanism links biomarker to drug target (e.g., HER2 → trastuzumab).
- **Δ- genuinely expected zero**: pathway absent in marker-negative tumors.
- **Assay cheap + fast**: IHC or PCR hotspot.
- **γ moderate**: 0.2-0.5 sweet spot.

## Relationship to adaptive enrichment

Simon-Maitournam is **FIXED** enrichment (decided a priori). Adaptive enrichment (downstream extensions) allows interim decision:

| Method | Year | Contribution |
|---|---|---|
| **Simon-Maitournam (this case)** | **2004** | **Fixed enrichment efficiency** |
| Freidlin-Simon (in corpus) | 2005 | Adaptive signature design |
| Wang-O'Neill-Hung (in corpus) | 2007 | Adaptive enrichment framework |
| Brannath-Mehta (in corpus) | 2009 | Confirmatory adaptive enrichment |
| Jenkins-Stone-Jennison (in corpus) | 2011 | Two-stage enrichment |
| Magnusson-Turnbull (in corpus) | 2013 | Optimal enrichment design |

All adaptive methods extend Simon-Maitournam's targeted efficiency to in-trial decisions.

## Modern applications — every one of these follows Simon-Maitournam

| Drug / Indication | Biomarker | Design |
|---|---|---|
| Trastuzumab / breast | HER2+ | Targeted (IHC 3+ or FISH) |
| Pertuzumab / breast (CLEOPATRA) | HER2+ | Targeted |
| Gefitinib / NSCLC (IPASS) | EGFR-mutant | Targeted (retrospective then prospective) |
| Osimertinib / NSCLC | EGFR T790M | Targeted |
| Vemurafenib / melanoma | BRAF V600E | Targeted |
| Pembrolizumab / NSCLC (KEYNOTE-024, in corpus) | PD-L1 ≥ 50% | Targeted |
| Olaparib / ovarian | BRCA1/2 germline | Targeted |
| Erdafitinib / urothelial | FGFR alterations | Targeted |
| Pembrolizumab / solid tumors | MSI-H or dMMR | Targeted (site-agnostic) |

## How this case validates designr

- Adds the **foundational biomarker-targeted design methodology paper** — underpinning every adaptive enrichment framework in corpus.
- `designr` should support explicit comparison of targeted vs untargeted sample-size (efficiency ratio calculator).
- Teaches: γ × Δ-/Δ+ regime dependence, screen burden trade-off, when targeted dominates, regulatory label-scope implications.
- Paired with 5 adaptive enrichment methodology cases in corpus (Freidlin-Simon, Wang-O'Neill-Hung, Brannath-Mehta, Jenkins-Stone-Jennison, Magnusson-Turnbull).
- Complements KEYNOTE-024 (in corpus) and other real-trial targeted designs.
