# designr

**A Claude Code plugin for end-to-end Phase 3 clinical trial design.**

`designr` helps biostatisticians and clinical trialists design Phase 3 studies through a conversational interface in Claude Code, backed by validated R statistical packages.

> **v0.0.4 alpha.** Public repo, installable as a Claude Code plugin via a local marketplace. v0.0.4 makes the plugin self-contained at runtime: the compiled MCP server ships pre-bundled (`mcp-server/dist/index.js`, all Node deps inlined) and the R launcher sources `r-package/designr/R/*.R` directly out of the plugin cache, so plugin updates pick up R changes automatically with no `remotes::install_local` re-run. Plugin / MCP server / R package versions are now aligned as a single source of truth. v0.0.3 introduced the marketplace-based install flow (`/plugin install <path>` is no longer supported by Claude Code). v0.0.2 added Monte Carlo verification (`verify_design`) and markdown reporting (`design_report`). The current release covers fixed-sample and group-sequential designs (see [MVP tool surface](#mvp-tool-surface)). Adaptive / MAMS / platform / Bayesian / recurrent-events / count-rate wrappers are roadmap, not shipped — see [Roadmap](#roadmap). Full change history in [CHANGELOG.md](CHANGELOG.md).

## What it is

`designr` has four layers:

| Layer | Role |
|---|---|
| **R package** (`r-package/designr`) | Pure R statistical computation engine. Wraps and extends established packages (`gsDesign`, `gsDesign2`, `rpact`, `simtrial`, …) behind a consistent API. |
| **MCP server** (`mcp-server/`) | Exposes R functions as tools over the Model Context Protocol so Claude Code — or any MCP client — can call them. |
| **Skill / subagent** (`skills/`, `agents/`) | The domain-expert prompt. Translates a user's design brief into the right sequence of tool calls and interprets results in clinical-trial terms. |
| **Benchmark corpus** (`benchmarks/`) | Curated public trial designs (FDA guidances, ICH, published SAPs, clinicaltrials.gov entries) used as an evaluation suite. Each case has human-readable context + machine-readable inputs/expected outputs. |

## What designr actually computes

| Family | Status |
|---|---|
| Fixed-sample binary | ✅ super / NI / equivalence |
| Fixed-sample continuous | ✅ super / NI / equivalence |
| Fixed-sample TTE — PH log-rank | ✅ super / NI (no equivalence) |
| Fixed-sample TTE — NPH MaxCombo, RMST, milestone | ✅ superiority only |
| Group-sequential binary / continuous | ✅ super / NI (no equivalence); efficacy + futility via `test.type` |
| Group-sequential TTE — PH | ✅ super / NI |
| Group-sequential TTE — NPH (MaxCombo / WLR / AHR) | ✅ superiority only |
| Monte Carlo verification (`verify_design`) | ✅ fixed binary / continuous / PH-survival; GS binary / continuous / PH-survival |
| Markdown reporting (`design_report`) | ✅ all families |
| Adaptive — SSR, enrichment, treatment selection | 📚 corpus only — no wrapper |
| Multi-arm multi-stage (MAMS) | 📚 corpus only — no wrapper |
| Recurrent events | 📚 corpus only — no wrapper |
| Count / rate endpoints | 📚 corpus only — no wrapper |
| Bayesian designs | 📚 corpus only — no wrapper |
| Platform / basket / umbrella | 📚 corpus only — no wrapper |
| Crossover, factorial | 📚 corpus only — no wrapper |

The benchmark corpus has cases across all of the above (~176 cases / 21 family directories). The current wrappers only compute the rows marked ✅. See [`benchmarks/README.md`](benchmarks/README.md) for the full corpus taxonomy.

## Status

| Component | Status |
|---|---|
| Repo scaffolding | ✅ |
| Benchmark schema | ✅ |
| Benchmark corpus | ✅ (176 cases across 21 family directories) |
| R package | ✅ (10 design wrappers + validator + `verify_design` + `design_report`, 137 tests passing; sourced in-place by launcher — no `install_local` step) |
| MCP server | ✅ (13 tools over stdio, TypeScript bundled with esbuild, 13/13 smoke pass) |
| Skill / subagent | ✅ (skill in `skills/designr`) |
| Plugin manifest | ✅ (`.claude-plugin/plugin.json` + `marketplace.json`; full install round-trip verified) |

## MVP tool surface

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

### Meta (3)

| Tool | Purpose |
|---|---|
| `validate_against_benchmark` | Replay a benchmark case through its matching design tool and diff against expected values within tolerance. |
| `verify_design` | Monte Carlo cross-check of a `designr` result. Closed-form simulation under H0 and H1; tolerance gate ±2 pp power / ±0.5 pp Type I, modeled on `pharma-skills`'s `lrsim()` convention. Supports fixed and GS designs on binary, continuous, and PH survival endpoints. |
| `design_report` | Render a clinician-readable markdown summary of any `designr` result (Design overview, Key inputs, Headline output, Analysis plan for GS, Method & version). Suitable to paste into a SAP-style document or render to HTML / PDF / Word downstream. |

## Quick start

Prerequisites: R ≥ 4.2, Node ≥ 18. No `npm install` step (the MCP server ships pre-bundled in `mcp-server/dist/index.js`, Node deps inlined) and no `remotes::install_local` step (the MCP server sources `r-package/designr/R/*.R` directly out of the plugin cache).

### 1. Clone and install CRAN dependencies (one-time)

```bash
git clone https://github.com/wei-ai-lab/designr
cd designr
R -e 'install.packages(c("gsDesign","gsDesign2","jsonlite"))'
```

`gsDesign`, `gsDesign2`, and `jsonlite` are CRAN packages the R launcher imports at runtime. Install them once into your R user library; they don't need to be reinstalled on plugin updates.

### 2. Install the plugin

**Method A — slash commands (recommended, inside Claude Code)**

```text
/plugin marketplace add /full/path/to/designr
/plugin install designr@wei-ai-lab
```

`/plugin marketplace add` accepts the repo root because `.claude-plugin/marketplace.json` lives there. After install, restart Claude Code so it loads the bundled MCP server. Confirm with `/plugin` (designr should be listed and enabled).

**Method B — host shell (equivalent, scriptable)**

```bash
claude plugin marketplace add /full/path/to/designr
claude plugin install designr@wei-ai-lab
claude plugin list   # confirm: designr@wei-ai-lab, version 0.0.4, enabled
```

Both methods do the same thing. Pick one. If anything goes wrong, `claude plugin validate /full/path/to/designr` will tell you whether the marketplace + plugin manifests parse cleanly.

**Quick local-dev alternative** — skip the marketplace step entirely and launch Claude Code with the plugin loaded directly:

```bash
claude --plugin-dir /full/path/to/designr
```

This is for iterating on the plugin itself, not for end-user installs.

### Environment overrides

If `Rscript` isn't on your `PATH`, set `DESIGNR_RSCRIPT=/full/path/to/Rscript` in your shell. To override the R launcher path (rare), set `DESIGNR_LAUNCHER=/full/path/to/launcher.R`. The MCP server reads both env vars when spawning R.

## Updating

When a new version of `designr` is released, the update flow is:

```bash
cd /full/path/to/designr
git pull
```

…then **either** of these (use the same method you used to install):

**Method A — slash command (inside Claude Code)**

```text
/plugin update designr@wei-ai-lab
```

**Method B — host shell**

```bash
claude plugin update designr@wei-ai-lab
```

Restart Claude Code afterwards so it picks up the refreshed MCP server. CRAN dependencies (`gsDesign`, `gsDesign2`, `jsonlite`) **do not** need to be reinstalled on every update — only re-run `install.packages(...)` if the release notes say a new dependency was added.

## Uninstalling

**Method A — slash commands (inside Claude Code)**

```text
/plugin uninstall designr@wei-ai-lab
/plugin marketplace remove wei-ai-lab
```

**Method B — host shell**

```bash
claude plugin uninstall designr@wei-ai-lab
claude plugin marketplace remove wei-ai-lab
```

Both methods are equivalent. The first command removes the installed plugin; the second removes the local marketplace pointer (skip it if you plan to reinstall later from the same checkout). Neither method touches your R library — to fully clean up, also run `R -e 'remove.packages(c("gsDesign","gsDesign2"))'` if you no longer need those CRAN packages for other work.

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

See `mcp-server/SMOKE.md` for the full 13-prompt smoke matrix.

## Roadmap

In priority order based on the corpus's family weights:

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

## Related work

[`RConsortium/pharma-skills`](https://github.com/RConsortium/pharma-skills) is a complementary R Consortium working group skill collection. It goes deeper than `designr` on a single vertical — survival group-sequential designs with co-primary endpoints, multi-population (biomarker + ITT), Maurer–Bretz graphical multiplicity, and a Word-report deliverable backed by a Python template. Where `designr` is broad and MCP-native (one plugin, validated tools across the gsDesign / gsDesign2 surface, no local R session needed), `pharma-skills` is a single deep skill that runs in the user's local R session and requires `lrsim()` simulation pass before declaring a design done. The two solve adjacent problems with different shapes.

`designr`'s `verify_design` tool adopts the same simulation-verification convention (±2 pp power / ±0.5 pp Type I tolerance) so a design produced here can be subjected to the same credibility floor.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
