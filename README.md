# designr

**A Claude Code plugin for end-to-end Phase 3 clinical trial design.**

`designr` helps biostatisticians and clinical trialists design Phase 3 studies through a conversational interface in Claude Code, backed by validated R statistical packages.

> **v0.0.1 alpha.** Public repo, installable. The current release covers fixed-sample and group-sequential designs (see [MVP tool surface](#mvp-tool-surface-v001)). Adaptive / MAMS / platform / Bayesian / recurrent-events / count-rate wrappers are roadmap, not shipped — see [Roadmap](#roadmap).

## What it is

`designr` has four layers:

| Layer | Role |
|---|---|
| **R package** (`r-package/designr`) | Pure R statistical computation engine. Wraps and extends established packages (`gsDesign`, `gsDesign2`, `rpact`, `simtrial`, …) behind a consistent API. |
| **MCP server** (`mcp-server/`) | Exposes R functions as tools over the Model Context Protocol so Claude Code — or any MCP client — can call them. |
| **Skill / subagent** (`skills/`, `agents/`) | The domain-expert prompt. Translates a user's design brief into the right sequence of tool calls and interprets results in clinical-trial terms. |
| **Benchmark corpus** (`benchmarks/`) | Curated public trial designs (FDA guidances, ICH, published SAPs, clinicaltrials.gov entries) used as an evaluation suite. Each case has human-readable context + machine-readable inputs/expected outputs. |

## What v0.0.1 actually computes

| Family | Status in v0.0.1 |
|---|---|
| Fixed-sample binary | ✅ super / NI / equivalence |
| Fixed-sample continuous | ✅ super / NI / equivalence |
| Fixed-sample TTE — PH log-rank | ✅ super / NI (no equivalence) |
| Fixed-sample TTE — NPH MaxCombo, RMST, milestone | ✅ superiority only |
| Group-sequential binary / continuous | ✅ super / NI (no equivalence); efficacy + futility via `test.type` |
| Group-sequential TTE — PH | ✅ super / NI |
| Group-sequential TTE — NPH (MaxCombo / WLR / AHR) | ✅ superiority only |
| Adaptive — SSR, enrichment, treatment selection | 📚 corpus only — no wrapper |
| Multi-arm multi-stage (MAMS) | 📚 corpus only — no wrapper |
| Recurrent events | 📚 corpus only — no wrapper |
| Count / rate endpoints | 📚 corpus only — no wrapper |
| Bayesian designs | 📚 corpus only — no wrapper |
| Platform / basket / umbrella | 📚 corpus only — no wrapper |
| Crossover, factorial | 📚 corpus only — no wrapper |

The benchmark corpus has cases across all of the above (~176 cases / 21 family directories). v0.0.1's wrappers only compute the rows marked ✅. See [`benchmarks/README.md`](benchmarks/README.md) for the full corpus taxonomy.

## Status

| Component | Status |
|---|---|
| Repo scaffolding | ✅ |
| Benchmark schema | ✅ |
| Benchmark corpus | ✅ (176 cases across 21 family directories) |
| R package | ✅ (10 design wrappers + validator, R CMD check clean, 95 tests passing) |
| MCP server | ✅ (11 tools over stdio, TypeScript, 11/11 smoke pass) |
| Skill / subagent | ✅ (skill in `skills/designr`) |
| Plugin manifest | ✅ (`plugin.json` present; installation via `claude plugin install <path>` not yet end-to-end verified by maintainer) |

## MVP tool surface (v0.0.1)

Each of these is an MCP tool, each wrapping a validated function in `gsDesign` or `gsDesign2`. Hypothesis type (`comparison`), group-sequential `k`, spending function, and `test.type` are parameters, not separate tools — that keeps the surface small and predictable. Equivalence / TOST is supported by the binary and continuous fixed-sample wrappers only; survival wrappers do not currently support equivalence margins.

### Fixed-sample (6)

| Tool | R backend | Covers |
|---|---|---|
| `design_fixed_binary` | `gsDesign::nBinomial` | Two-arm binary, all 3 hypothesis types. |
| `design_fixed_continuous` | `gsDesign::nNormal` | Two-arm continuous, all 3 hypothesis types. |
| `design_fixed_survival_ph` | `gsDesign::nSurv` | TTE PH log-rank, superiority / NI. |
| `design_fixed_survival_maxcombo` | `gsDesign2::fixed_design_maxcombo` | TTE NPH MaxCombo (delayed effect). Superiority only. |
| `design_fixed_survival_rmst` | `gsDesign2::fixed_design_rmst` | TTE restricted mean survival time at τ. Superiority only. |
| `design_fixed_survival_milestone` | `gsDesign2::fixed_design_milestone` | TTE milestone survival probability S(τ). Superiority only. |

### Group-sequential (4)

| Tool | R backend |
|---|---|
| `design_gs_binary` | `gsDesign::gsDesign` + `nBinomial` (super / NI) |
| `design_gs_continuous` | `gsDesign::gsDesign` + `nNormal` (super / NI) |
| `design_gs_survival_ph` | `gsDesign::gsSurv` (super / NI) |
| `design_gs_survival_nph_combo` | `gsDesign2::gs_design_combo` / `gs_design_wlr` / `gs_design_ahr` (superiority only) |

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

See `mcp-server/SMOKE.md` for the full 11-prompt smoke matrix.

## Roadmap

Beyond v0.0.1, in priority order based on the corpus's family weights:

1. **Adaptive sample-size re-estimation** (corpus: `adaptive-ssr/`) — `rpact::getSampleSizeRates` + custom Promising-Zone rule.
2. **Group-sequential futility-only and binding-futility variants** — already exposed via `test.type` 3–6 in current GS wrappers; add explicit anchor tests.
3. **Adaptive treatment selection / population enrichment** (corpus: `adaptive-selection/`, `adaptive-enrichment/`) — `rpact::getDesignInverseNormal` + sub-population reweighting.
4. **MAMS** (corpus: `mams/`) — `rpact::getDesignMams` or `MAMS::mams`.
5. **Recurrent events** (corpus: `recurrent-events/`) — `WR::sample_size_LWYY` or analogues.
6. **Count / rate endpoints** (corpus: `count-rate/`) — Poisson and negative-binomial sample size.
7. **Bayesian designs** (corpus: `bayesian/`) — wrappers around predictive-probability and posterior-probability stopping rules.
8. **Platform / basket / umbrella** (corpus: `platform/`, `basket/`, `umbrella/`) — likely separate tools per master-protocol type.
9. **Simulation / OC tools** (`simulate_trial`, `compare_designs`).

Each row above already has ≥ 7 curated benchmark cases ready as regression anchors.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
