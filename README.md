# designr

**A Claude Code plugin for end-to-end Phase 3 clinical trial design.**

`designr` helps biostatisticians and clinical trialists design Phase 3 studies — sample size, power, group-sequential boundaries, adaptive rules, non-inferiority margins, platform structures — through a conversational interface in Claude Code, backed by validated R statistical packages.

> ⚠️ Pre-release. Private repo. Not yet published or installable.

## What it is

`designr` has four layers:

| Layer | Role |
|---|---|
| **R package** (`r-package/designr`) | Pure R statistical computation engine. Wraps and extends established packages (`gsDesign`, `gsDesign2`, `rpact`, `simtrial`, …) behind a consistent API. |
| **MCP server** (`mcp-server/`) | Exposes R functions as tools over the Model Context Protocol so Claude Code — or any MCP client — can call them. |
| **Skill / subagent** (`skills/`, `agents/`) | The domain-expert prompt. Translates a user's design brief into the right sequence of tool calls and interprets results in clinical-trial terms. |
| **Benchmark corpus** (`benchmarks/`) | Curated public trial designs (FDA guidances, ICH, published SAPs, clinicaltrials.gov entries) used as an evaluation suite. Each case has human-readable context + machine-readable inputs/expected outputs. |

## Design families in scope

- Fixed-sample superiority, non-inferiority, equivalence
- Group-sequential (efficacy + futility; O'Brien-Fleming, Pocock, Hwang-Shih-DeCani, …)
- Adaptive: sample-size re-estimation, population enrichment, treatment selection
- Multi-arm multi-stage (MAMS)
- Time-to-event (proportional & non-proportional hazards, delayed effect, cure models)
- Recurrent events
- Count / rate endpoints
- Bayesian designs
- Platform, basket, umbrella

See `benchmarks/README.md` for the full taxonomy.

## Status

| Component | Status |
|---|---|
| Repo scaffolding | ✅ |
| Benchmark schema | ✅ |
| Benchmark corpus | ✅ (~176 cases across 20 families) |
| R package | ✅ (10 design wrappers + validator, R CMD check clean) |
| MCP server | ✅ (11 tools over stdio, TypeScript) |
| Skill / subagent | ✅ (skill in `skills/designr`) |
| Plugin packaging | ✅ (`plugin.json`, installable via `claude plugin install`) |

## MVP tool surface (v0.0.1)

Each of these is an MCP tool, each wrapping a validated function in `gsDesign` or `gsDesign2`. `comparison` ∈ `{"superiority", "non-inferiority", "equivalence"}` is a parameter, not a separate tool — same for group-sequential `k`, spending function, and `test.type`. This keeps the tool surface small and predictable.

### Fixed-sample (6)

| Tool | R backend | Covers |
|---|---|---|
| `design_fixed_binary` | `gsDesign::nBinomial` | Two-arm binary, all 3 hypothesis types. |
| `design_fixed_continuous` | `gsDesign::nNormal` | Two-arm continuous, all 3 hypothesis types. |
| `design_fixed_survival_ph` | `gsDesign::nSurv` | TTE PH log-rank, superiority / NI. |
| `design_fixed_survival_maxcombo` | `gsDesign2::fixed_design_maxcombo` | TTE NPH MaxCombo (delayed effect). |
| `design_fixed_survival_rmst` | `gsDesign2::fixed_design_rmst` | TTE restricted mean survival time at τ. |
| `design_fixed_survival_milestone` | `gsDesign2::fixed_design_milestone` | TTE milestone survival probability S(τ). |

### Group-sequential (4)

| Tool | R backend |
|---|---|
| `design_gs_binary` | `gsDesign::gsDesign` + `nBinomial` |
| `design_gs_continuous` | `gsDesign::gsDesign` + `nNormal` |
| `design_gs_survival_ph` | `gsDesign::gsSurv` |
| `design_gs_survival_nph_combo` | `gsDesign2::gs_design_combo` / `gs_design_wlr` / `gs_design_ahr` |

### Meta (1)

| Tool | Purpose |
|---|---|
| `validate_against_benchmark` | Replay a benchmark case through its matching design tool and diff against expected values within tolerance. |

## Quick start

Prerequisites: R ≥ 4.2, Node ≥ 18.

```bash
git clone https://github.com/wei-ai-lab/designr
cd designr

# R side
R -e 'install.packages(c("remotes","gsDesign","gsDesign2","yaml","jsonlite","testthat"))'
R -e 'remotes::install_local("r-package/designr")'

# MCP server
cd mcp-server && npm install && npm run build && cd ..

# Install the plugin into Claude Code
claude plugin install "$(pwd)"
```

If `Rscript` isn't on your `PATH`, set `DESIGNR_RSCRIPT=/full/path/to/Rscript` in your shell. The MCP server reads that env var when spawning R.

## Try it

Three conversational prompts you can paste into Claude Code once the plugin is installed. Each one should invoke a specific MCP tool and return a design:

1. **Fixed binary superiority (CAPTURE-style)**
   > *"Design a Phase 3 trial for refractory unstable angina. Control 30-day event rate ≈ 15%, hoped-for treatment rate ≈ 9%, two-sided α = 0.05, power 80%, 1:1 allocation."*
   Expect `design_fixed_binary` with N ≈ 1,100.

2. **TTE PH group-sequential (PARADIGM-HF-style)**
   > *"I need a 2-analysis GS design for a CV outcome trial. Control median OS ≈ 30 months, target HR = 0.75, accrual 100/month over 30 months, 24 months minimum follow-up, OBF spending, α = 0.025 one-sided, power 90%."*
   Expect `design_gs_survival_ph` with events ≈ 380 at final analysis.

3. **TTE NPH MaxCombo (KEYNOTE-024-style)**
   > *"Design an immunotherapy trial with delayed effect: 4-month delay, post-delay HR 0.60, control median 10 months, accrual 20/month for 18 months, 30-month study duration, α = 0.025, power 90%."*
   Expect `design_fixed_survival_maxcombo` with a MaxCombo design summary.

See `mcp-server/SMOKE.md` for the full 10-tool smoke matrix.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
