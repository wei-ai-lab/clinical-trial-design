# Time-to-event trials under proportional hazards (PH)

Phase 3 trials with a time-to-event primary where the hazard ratio is constant (or approximately so) across follow-up. The workhorse design pattern of cardiovascular outcome trials (CVOTs), renal progression trials, and many oncology Phase 3s.

## When PH is reasonable

- **Drug mechanism** produces sustained, immediate effect (statins on LDL → CV events).
- **Event process** is roughly homogeneous over follow-up (atherosclerotic disease progression).
- **No crossover or waning response** (contrast: IO with delayed effect, vaccine with waning immunity).

## When PH is not (see tte-nph family)

- Delayed-effect therapies (checkpoint IO, consolidation).
- Crossing hazards (early harm, late benefit).
- Diminishing effect (waning vaccine efficacy).
- Cure-fraction models (long-term IO responders).

## Classical design mechanics

Using Schoenfeld's formula: events needed = [(z_α + z_β)² / (log HR)²] × (1/p(1−p)), where p is treatment allocation fraction.

Freedman's formula (more conservative): events = [(z_α + z_β)² × (1+HR)²] / [(1−HR)² × 4p(1−p)].

Both approximations give the same answer in the limit of large N and moderate HR.

## Standard assumptions to verify

- **Proportional hazards** — log-log KM plot parallel; Schoenfeld residual test p > 0.1 at interim.
- **Constant censoring distribution** — administrative censoring at end-of-study is handled exactly; informative dropout needs sensitivity analysis.
- **Accrual pattern** — uniform or step-function; time-varying accrual affects expected event accrual rate.

## R package landscape

- `gsDesign::gsSurv` — canonical TTE GS design.
- `gsDesign2::gs_design_ahr` — handles PH + minor deviations via average HR.
- `rpact::getSampleSizeSurvival` — equivalent, with Freedman or Schoenfeld.
- `Hmisc::cpower` — Schoenfeld sample size.
- `simtrial` — event simulation for validation.

## Corpus

Eight canonical PH Phase 3s covering cardiology, lipid, renal, and HF:

- 1994_4S_simvastatin — Scandinavian Simvastatin Survival Study, landmark secondary prevention
- 1999_LIFE_losartan — ARB vs β-blocker in hypertension with LVH
- 2001_RENAAL_losartan — losartan in diabetic nephropathy
- 2001_SOLVD-treatment_enalapril — enalapril in HF (reference: historical redesign per PH standards)
- 2002_HPS_simvastatin — MRC/BHF Heart Protection Study, 20k+ patients
- 2003_IDNT_irbesartan — irbesartan in type 2 diabetic nephropathy
- 2004_PROVE-IT_atorvastatin — intensive vs moderate statin post-ACS
- 2010_SHIFT_ivabradine — heart rate reduction in HFrEF

## Caveats

- Many of these trials had robust PH — verify with published post-hoc Cox-PH diagnostics where available.
- Some assumed PH but showed mild deviation (LIFE showed slight time-varying HR in later years) — still PH-design-valid since power loss was minimal.
- The group-sequential and tte-ph families overlap: trials with pre-specified interim analyses would be in GS; trials with single end-of-study analysis belong here. Some borderline cases (4S had a pre-specified interim) are placed per design-paper emphasis.
