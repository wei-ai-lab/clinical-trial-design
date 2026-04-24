# group-sequential

Group-sequential (GS) designs with pre-specified efficacy stopping boundaries. Allow the trial to stop early if convincing evidence of efficacy emerges at an interim analysis, while preserving overall type I error via α-spending.

## When this family is the right choice

- Long follow-up trials where early stopping could save years of exposure (CVOT, oncology, immunology).
- High disease burden where withholding an effective treatment is unethical past a certain evidence threshold.
- Programs with budget sensitivity where conditional stopping reduces expected cost.

## Core components

| Component | Role |
|---|---|
| **Spending function α(t)** | Allocates type I error across analyses at information fraction t |
| **Number of analyses K** | Typically 3-5 total (including final); more analyses = more power loss |
| **Information fraction (IF) at each analysis** | For TTE, events/total-events; for others, N/total-N |
| **Boundary values** | Z-scores (or nominal p-values) at each look beyond which efficacy is declared |

## Standard spending functions

| Family | Characterized by | Properties |
|---|---|---|
| O'Brien-Fleming (OBF) | Very conservative early, nearly full α at final | Early looks very hard to cross; classic choice |
| Pocock | Constant boundary on z-scale | Easier to stop early; rarely used alone |
| Lan-DeMets α-spending approximating OBF | Continuous, robust to unequal IF | De-facto standard |
| Hwang-Shih-DeCani (HSD) γ | `γ=-4` ≈ OBF, `γ=1` ≈ Pocock | Parametric family |

## Sample-size inflation

GS designs require more total events/subjects than fixed designs at the same α, power. Typical inflation under 3-4 analyses with Lan-DeMets-OBF: **~3-7%** at α=0.025, power=0.9. Inflation grows with number of analyses and with looser spending functions (Pocock ~20%).

## Expected-early-stop

Under H₁ (true effect), expected trial duration shortens because some trials stop early. Typical early-stop probability 30-50% under H₁ with 3-4 OBF analyses.

## Common pitfalls

- **Correlated interim and final tests.** Cannot independently test at 0.025 at each — spending function adjusts.
- **Unequal information fractions** from accrual variability. Lan-DeMets handles this gracefully; pre-computed OBF boundaries do not.
- **Reassessing design after first interim.** Not allowed without formal adaptive design machinery (see `adaptive-ssr/`).
- **Conditional vs unconditional estimation after early stop.** Naive point estimates are biased if reported without correction.

## R packages

| Task | Preferred packages |
|---|---|
| Design | `gsDesign::gsDesign()`, `rpact::getDesignGroupSequential()` |
| TTE sample size | `gsDesign::gsSurv()`, `rpact::getSampleSizeSurvival()` |
| Non-PH TTE | `gsDesign2::gs_design_wlr()`, `simtrial` |
| Simulation | `rpact::getSimulationSurvival()`, `simtrial::simtrial()` |

## Cases

See `cases/`.
