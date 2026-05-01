# ClinicalTrialDesign (R package)

Core statistical computation engine for the `clinical-trial-design` Claude Code plugin. Wraps `gsDesign`, `gsDesign2`, and `graphicalMCP` behind a unified result schema. Covers Phase 2 and Phase 3 confirmatory designs (single-primary + multi-hypothesis); `simtrial` and `officer` / `rmarkdown` are optional `Suggests:` for `verify_design` Monte-Carlo and `design_report(format="docx"|"pdf")` respectively.

Twelve exported design / meta functions; **288/288 testthat assertions pass** at v0.0.13.

## Install (from source)

```r
# Future: pak::pak("wei-ai-lab/clinical-trial-design/r-package/ClinicalTrialDesign")
# Current — install from a checkout:
devtools::install_local("r-package/ClinicalTrialDesign")
```

The package is **not yet on CRAN**. CRAN submission is a v1.0 milestone. The `Package:` name is `ClinicalTrialDesign` (camelCase, CRAN convention); the npm package that bundles it is `clinical-trial-design` (hyphenated, npm convention).

## Development

```r
devtools::load_all("r-package/ClinicalTrialDesign")
devtools::test("r-package/ClinicalTrialDesign")    # expect 288/288 pass
devtools::check("r-package/ClinicalTrialDesign")   # R CMD check --as-cran
```

See [`../../docs/architecture.md`](../../docs/architecture.md) for how this package fits into the broader plugin.
