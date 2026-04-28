# Examples gallery

Runnable end-to-end reproductions of published Phase 3 designs through the `clinical-trial-design` R package. Each subdirectory has a `run.R` (the calculation) and a `README.md` (the narrative — what the trial was, what the design parameters mean, how the reproduction matches the published values within tolerance).

| # | Trial | Design family | Tool exercised |
|---|---|---|---|
| 01 | CAPTURE (1997, NEJM) | Binary fixed superiority | `design_binary` |
| 02 | PARADIGM-HF (2014, NEJM) | TTE PH fixed superiority | `design_survival(model="ph")` |
| 03 | KEYNOTE-024 (2016, NEJM) | TTE NPH MaxCombo | `design_survival(model="maxcombo")` |
| 04 | KEYNOTE-189 (2018, NEJM) | Co-primary PFS+OS, hierarchical | `design_co_primary` |
| 05 | KEYNOTE-042 (2019, Lancet) | Nested multi-population | `design_multi_population` |

To run all:

```r
# From the repo root, after installing the package:
for (e in list.dirs("examples", recursive = FALSE)) {
  cat("== ", basename(e), " ==\n")
  source(file.path(e, "run.R"))
}
```

Each script's expected output is documented in its `README.md` — usually total N or events plus the boundary Z-values for GS designs. Differences within ±10% on N or ±5% on events are normal and reflect operational-input choices the published trials specify in their SAPs but not always in their methods sections.
