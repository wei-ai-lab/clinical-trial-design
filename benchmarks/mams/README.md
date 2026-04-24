# Multi-arm multi-stage (MAMS) trials

Phase 3 trials that randomize patients to K experimental arms plus a shared control across J pre-specified stages, with formal efficacy and futility boundaries at each stage. Distinct from adaptive-selection (which emphasizes arm-dropping decisions) — MAMS retains all arms through pre-specified boundaries, dropping only if statistical evidence crosses a threshold.

## Key references

- Royston P, Parmar MKB, Qian W. *Novel designs for multi-arm clinical trials with survival outcomes with an application in ovarian cancer.* Stat Med 2003.
- Parmar MKB, Barthel FMS, Sydes M, et al. *Speeding up the evaluation of new agents in cancer.* J Natl Cancer Inst 2008.
- Royston P, Barthel FMS, Parmar MKB, et al. *Designs for clinical trials with time-to-event outcomes based on stopping guidelines for lack of benefit.* Trials 2011.
- Magirr D, Jaki T, Whitehead J. *A generalized Dunnett test for MAMS with treatment selection.* Biometrika 2012.
- Bratton DJ, Phillips PPJ, Parmar MKB. *A multi-arm multi-stage clinical trial design for binary outcomes with application to tuberculosis.* BMC Med Res Methodol 2013.
- Wason JMS, Jaki T. *Optimal design of multi-arm multi-stage trials.* Stat Med 2012.
- Choodari-Oskooei B, Bratton DJ, Parmar MKB. *Facilities for FWER control in multi-arm multi-stage designs (extended).* J Stat Software 2020.
- FDA. *Adaptive Designs for Clinical Trials of Drugs and Biologics.* 2019.

## Core design mechanics

At each stage j = 1, ..., J:

1. Compute pairwise z-statistics Z_k^(j) for each active experimental arm k vs control.
2. Compare to pre-specified **upper boundary u_j** (efficacy) and **lower boundary l_j** (futility / lack of benefit):
   - Z_k^(j) > u_j → reject H_k (claim efficacy).
   - Z_k^(j) < l_j → drop arm k (futility).
   - Otherwise → continue arm k to next stage.
3. After the last stage, compare final Z_k^(J) to u_J for active arms; any above boundary rejects H_k.

**Boundaries** are computed from multivariate normal theory (or simulation under correlated tests) such that strong FWER ≤ α across all K arms and J stages.

## MAMS vs adaptive-selection

- **MAMS**: boundaries pre-specified; arm-dropping is automatic if z < l_j. No interim "data-driven" selection beyond the boundary.
- **Adaptive-selection**: explicitly chooses arms based on interim data, often without pre-specified boundaries — requires combination test for α control.

Both share the shared-control efficiency gain and the FWER challenge; they differ in whether "selection" is boundary-driven or rule-driven.

## R package landscape

- `MAMS` — canonical R package for MAMS design with binary, continuous, and survival endpoints (Jaki et al., well-maintained).
- `mvtnorm` — multivariate normal boundary computation (used by MAMS under the hood).
- `simtrial` — simulation validation of operating characteristics.
- `nstage` — UK MRC CTU platform trials software (used for STAMPEDE).

## When MAMS is the right tool

- **Multiple promising experimental arms** with similar expected benefit — MAMS allows parallel testing without separate Phase 3s.
- **Shared control pool** — one control arm serves all experimental arms, reducing total N by up to 40% vs parallel trials.
- **Long-duration trials** — TTE oncology with slow event accumulation benefits from staged analysis.
- **Platform-trial substrate** — MAMS is the statistical core of most adaptive platform trials (STAMPEDE, RECOVERY, FOCUS4).

## Corpus

Five Phase 3 MAMS and platform trials spanning oncology, infectious disease, and cardiovascular:

- 2011_STAMPEDE_prostate — prostate cancer MAMS flagship (Royston-Parmar design)
- 2020_RECOVERY_covid — pandemic platform MAMS (oxford-led COVID treatments)
- 2013_FOCUS4_colorectal — biomarker-stratified MAMS for mCRC
- 2014_ROMA_cabg — internal mammary artery revascularization multi-arm
- 2013_Bratton-Phillips-Parmar_methodology — MAMS for binary tuberculosis outcomes

## Caveats

- **Strong FWER is the gold standard**, but some MAMS trials have opted for weak FWER + pre-specified hierarchical testing when arm independence is assumed. Always check the SAP.
- **Platform vs MAMS**: a platform trial can add/remove arms over time; classical MAMS fixes the arm set at design. In this corpus, STAMPEDE and RECOVERY span both categories (platform mechanics layered on MAMS math) — see also platform family.
