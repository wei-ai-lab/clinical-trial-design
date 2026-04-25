# ClinicalTrialDesign (R package)

Core statistical computation engine. Wraps `gsDesign`, `gsDesign2`, `rpact`, `simtrial`, and others behind a consistent API. Covers Phase 2 and Phase 3 confirmatory designs.

## Install (from source)

```r
# pak::pak("wei-ai-lab/clinical-trial-design/r-package/ClinicalTrialDesign")  # once published
devtools::install_local("r-package/ClinicalTrialDesign")
```

## Development

```r
devtools::load_all("r-package/ClinicalTrialDesign")
devtools::test("r-package/ClinicalTrialDesign")
devtools::check("r-package/ClinicalTrialDesign")
```

See `../../docs/architecture.md` for how this package fits into the broader plugin.
