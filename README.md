# clinical-trial-design

**A Claude Code plugin and MCP server for end-to-end clinical trial design.**

`clinical-trial-design` helps biostatisticians and clinical trialists design Phase 2 and Phase 3 confirmatory studies through a conversational interface, backed by validated R statistical packages (`gsDesign`, `gsDesign2`).

> **v0.0.8 alpha.** Pre-1.0 schema break. The ten endpoint-shaped design tools collapse into three endpoint-typed tools (`design_binary`, `design_continuous`, `design_survival`) with `design_class ∈ {"fixed", "group-sequential"}` and (for survival) `model ∈ {"ph", "maxcombo", "rmst", "milestone", "wlr", "ahr"}` as parameters — total tool count drops 13 → 6. Same release lifts the operational kernel into the public surface: any design tool can take an `operational` block that solves `accrual_rate × accrual_duration = N` and `total_trial_duration = accrual_duration + follow_up_duration` (plus a `uniroot`-based event-probability tie for survival). Survival accrual API standardized on `accrual_duration` + `followup_duration` for every model. 184/184 R tests pass; 14/14 smoke. Slash commands and the wire-format identifiers (`designr_dispatch`, `DESIGNR_RSCRIPT`/`DESIGNR_LAUNCHER`) are preserved. v0.0.6 was the rebrand from `designr` → `clinical-trial-design`; v0.0.5 was an agent-friendliness + trust-boundary release; v0.0.4 made the plugin self-contained at runtime; v0.0.3 introduced the marketplace-based install flow; v0.0.2 added Monte Carlo verification (`verify_design`) and markdown reporting (`design_report`). The current release covers fixed-sample and group-sequential designs (see [MVP tool surface](#mvp-tool-surface)). Adaptive / MAMS / platform / Bayesian / recurrent-events / count-rate wrappers are roadmap, not shipped — see [Roadmap](#roadmap). Full change history in [CHANGELOG.md](CHANGELOG.md).

## What it is

`clinical-trial-design` has four layers:

| Layer | Role |
|---|---|
| **R package** (`r-package/ClinicalTrialDesign`) | Pure R statistical computation engine. Wraps and extends established packages (`gsDesign`, `gsDesign2`, `rpact`, `simtrial`, …) behind a consistent API. |
| **MCP server** (`mcp-server/`) | Exposes R functions as tools over the Model Context Protocol so Claude Code — or any MCP client — can call them. |
| **Skill / subagent** (`skills/clinical-trial-design/`) | The domain-expert prompt. Translates a user's design brief into the right sequence of tool calls and interprets results in clinical-trial terms. |
| **Benchmark corpus** (`benchmarks/`) | Curated public trial designs (FDA guidances, ICH, published SAPs, clinicaltrials.gov entries) used as an evaluation suite. Each case has human-readable context + machine-readable inputs/expected outputs. |

## What clinical-trial-design actually computes

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
| R package | ✅ `ClinicalTrialDesign` (3 design functions + `solve_operational` + validator + `verify_design` + `design_report`, 184 tests passing; sourced in-place by launcher — no `install_local` step) |
| MCP server | ✅ (6 tools over stdio, TypeScript bundled with esbuild, 14/14 smoke pass) |
| Skill / subagent | ✅ (skill in `skills/clinical-trial-design`) |
| Plugin manifest | ✅ (`.claude-plugin/plugin.json` + `marketplace.json`; full install round-trip verified) |
| npm package | ✅ `clinical-trial-design` (publishable; `npx clinical-trial-design` runs the MCP server standalone) |

## MVP tool surface

Nine MCP tools — three endpoint-typed design tools, three multi-hypothesis design tools, and three meta tools. Single-primary tools are organized by endpoint axis (binary / continuous / survival); multi-hypothesis tools are organized by *which* multiplicity pattern they encode (co-primary, multi-population, graphical). Everything else — hypothesis type, fixed vs group-sequential, survival statistical model, multiplicity strategy, accrual / follow-up timing — is a *parameter*.

### Single-primary design tools (3)

| Tool | Endpoint | Selectors | R backends |
|---|---|---|---|
| `design_binary` | event / no-event | `design_class ∈ {"fixed", "group-sequential"}` | `gsDesign::nBinomial`, `gsDesign::gsDesign(endpoint="binomial")` |
| `design_continuous` | mean difference | `design_class ∈ {"fixed", "group-sequential"}` | `gsDesign::nNormal`, `gsDesign::gsDesign(endpoint="normal")` |
| `design_survival` | time-to-event | `design_class` × `model ∈ {"ph", "maxcombo", "rmst", "milestone", "wlr", "ahr"}` | `gsDesign::nSurv`/`gsSurv` (PH); `gsDesign2::fixed_design_*` and `gs_design_combo`/`gs_design_wlr`/`gs_design_ahr` (NPH) |

All three accept `comparison ∈ {"superiority", "non-inferiority", "equivalence"}` (equivalence on binary / continuous fixed-sample only — survival wrappers don't support equivalence margins), `alpha`, `power`, `sided`, `allocation_ratio`, GS parameters (`k`, `timing`, `sfu`, `sfl`, `test.type`), and an optional `operational` block (see below).

### Multi-hypothesis design tools (3) — added v0.0.8

| Tool | When to use | Strategies | R backends |
|---|---|---|---|
| `design_co_primary` | Two or more primary endpoints sharing alpha (PFS+OS, CV death+HHF, mixed binary+continuous) | `fixed-sequence` (hierarchical, default — full alpha per test, gating preserves family-wise alpha by closed testing), `alpha-split` (weighted), `bonferroni` | Dispatches per-endpoint to `design_binary` / `design_continuous` / `design_survival` at the appropriate effective alpha; total N = max across endpoints |
| `design_multi_population` | Same endpoint tested across multiple populations (biomarker subgroup + ITT, nested PD-L1 strata) | Same three strategies; `relation ∈ {"nested", "disjoint"}` | Same per-population dispatch; for `nested`, total N driven by largest implied-enrolled-N (events / prevalence); for `disjoint`, total N is the sum |
| `design_graphical_multiplicity` | Multi-hypothesis with alpha recycling (Maurer-Bretz) — mixed primary+secondary, dose-response | Graphical procedure with user-supplied initial weights and transition matrix; built-in Rule-3 validator for transition matrix + gate prerequisites | `graphicalMCP::graph_create`; per-hypothesis sample-size at worst-case alpha (`max(initial_weight_i, fallback)` × family alpha) |

### Operational kernel

Any design tool accepts an `operational` block that solves the simple relations `accrual_rate × accrual_duration = sample_size_total` and `total_trial_duration = accrual_duration + follow_up_duration` (plus `target_events = sample_size_total × cumulative_event_rate(...)` for survival, via `uniroot` over the closed-form pooled exponential-PH event probability — same kernel `gsDesign::nSurv` uses internally).

Supply any **0–4 of** `{accrual_rate, accrual_duration, follow_up_duration, total_trial_duration}` inside the block. The solver fills in the missing values and returns an audit trail (`given`, `derived`). This collapses what was previously a back-and-forth — call the design tool, then translate the answer into accrual feasibility — into a single round trip.

### Meta tools (3)

| Tool | Purpose |
|---|---|
| `validate_against_benchmark` | Replay a benchmark case through its matching design tool and diff against expected values within tolerance. |
| `verify_design` | Monte Carlo cross-check of a `clinical-trial-design` result. Closed-form simulation under H0 and H1; tolerance gate ±2 pp power / ±0.5 pp Type I, modeled on `pharma-skills`'s `lrsim()` convention. Supports fixed and GS designs on binary, continuous, and PH survival endpoints. |
| `design_report` | Render a clinician-readable markdown summary of any `clinical-trial-design` result (Design overview, Key inputs, Headline output, Analysis plan for GS, Method & version). Suitable to paste into a SAP-style document or render to HTML / PDF / Word downstream. |

## Quick start

Prerequisites: R ≥ 4.2, Node ≥ 18. No `npm install` step (the MCP server ships pre-bundled in `mcp-server/dist/index.js`, Node deps inlined) and no `remotes::install_local` step (the MCP server sources `r-package/ClinicalTrialDesign/R/*.R` directly out of the plugin cache).

### 1. Clone and install CRAN dependencies (one-time)

```bash
git clone https://github.com/wei-ai-lab/clinical-trial-design
cd clinical-trial-design
R -e 'install.packages(c("gsDesign","gsDesign2","graphicalMCP","jsonlite"))'
```

`gsDesign`, `gsDesign2`, and `jsonlite` are CRAN packages the R launcher imports at runtime. Install them once into your R user library; they don't need to be reinstalled on plugin updates.

#### Tested dependency versions

`clinical-trial-design` v0.0.8 was developed and tested against the versions below. The R package's `DESCRIPTION` file pins minimum versions matching this set — older versions are not supported. CRAN's latest is usually fine; pin to these floors only if you hit a version-skew issue.

| Layer | Dependency | Tested version |
|---|---|---|
| R runtime | R | 4.5.3 (works on R ≥ 4.2) |
| R imports | `gsDesign` | 3.9.0 |
|  | `gsDesign2` | 1.1.8 |
|  | `graphicalMCP` | 0.2.9 |
|  | `jsonlite` | 2.0.0 |
| R suggests | `simtrial` | 1.0.2 |
|  | `rpact` | 4.4.0 |
|  | `yaml` | 2.3.12 |
|  | `testthat` | 3.3.2 |
|  | `remotes` | 2.5.0 |
| Node runtime | Node | 22.22.1 (works on Node ≥ 18) |
| Node bundled | `@modelcontextprotocol/sdk` | ^1.0.0 (inlined in `dist/index.js`) |
|  | `zod` | ^3.23.0 (inlined) |
| Node devDeps | `esbuild` | ^0.20.0 |
|  | `typescript` | ^5.5.0 |

### 2. Install the plugin

**Method A — slash commands (recommended, inside Claude Code)**

```text
/plugin marketplace add /full/path/to/clinical-trial-design
/plugin install clinical-trial-design@wei-ai-lab
```

`/plugin marketplace add` accepts the repo root because `.claude-plugin/marketplace.json` lives there. After install, restart Claude Code so it loads the bundled MCP server. Confirm with `/plugin` (clinical-trial-design should be listed and enabled).

**Method B — host shell (equivalent, scriptable)**

```bash
claude plugin marketplace add /full/path/to/clinical-trial-design
claude plugin install clinical-trial-design@wei-ai-lab
claude plugin list   # confirm: clinical-trial-design@wei-ai-lab, version 0.0.7, enabled
```

Both methods do the same thing. Pick one. If anything goes wrong, `claude plugin validate /full/path/to/clinical-trial-design` will tell you whether the marketplace + plugin manifests parse cleanly.

**Quick local-dev alternative** — skip the marketplace step entirely and launch Claude Code with the plugin loaded directly:

```bash
claude --plugin-dir /full/path/to/clinical-trial-design
```

This is for iterating on the plugin itself, not for end-user installs.

### Environment overrides

If `Rscript` isn't on your `PATH`, set `DESIGNR_RSCRIPT=/full/path/to/Rscript` in your shell. To override the R launcher path (rare), set `DESIGNR_LAUNCHER=/full/path/to/launcher.R`. The MCP server reads both env vars when spawning R. (The `DESIGNR_*` prefix is preserved as the wire-format contract across the v0.0.6 rebrand and the v0.0.8 schema break — see [CHANGELOG](CHANGELOG.md).)

## Standalone MCP server (without Claude Code)

The MCP server is also published to npm as `clinical-trial-design`. Any MCP-aware client (Claude Desktop, Cursor, Continue, custom MCP host) can launch it via `npx`:

```bash
npx clinical-trial-design
```

This downloads the bundle on first run, then spawns the server on stdio. The bundle ships the staged R sources at `<install>/r/inst/launcher.R` — same `Rscript` requirement (R ≥ 4.2 + `gsDesign`, `gsDesign2`, `jsonlite` in your R user library), but no Claude Code plugin install needed.

Example Claude Desktop config:

```json
{
  "mcpServers": {
    "clinical-trial-design": {
      "command": "npx",
      "args": ["-y", "clinical-trial-design"]
    }
  }
}
```

The plugin install path (above) is preferred for Claude Code users — it bundles the skill alongside the tools, so the agent knows *how* to design a trial, not just *what* tools exist.

## Updating

When a new version is released, the update flow is:

```bash
cd /full/path/to/clinical-trial-design
git pull
```

…then **either** of these (use the same method you used to install):

**Method A — slash command (inside Claude Code)**

```text
/plugin update clinical-trial-design@wei-ai-lab
```

**Method B — host shell**

```bash
claude plugin update clinical-trial-design@wei-ai-lab
```

Restart Claude Code afterwards so it picks up the refreshed MCP server. CRAN dependencies (`gsDesign`, `gsDesign2`, `jsonlite`) **do not** need to be reinstalled on every update — only re-run `install.packages(...)` if the release notes say a new dependency was added.

## Uninstalling

**Method A — slash commands (inside Claude Code)**

```text
/plugin uninstall clinical-trial-design@wei-ai-lab
/plugin marketplace remove wei-ai-lab
```

**Method B — host shell**

```bash
claude plugin uninstall clinical-trial-design@wei-ai-lab
claude plugin marketplace remove wei-ai-lab
```

Both methods are equivalent. The first command removes the installed plugin; the second removes the local marketplace pointer (skip it if you plan to reinstall later from the same checkout). Neither method touches your R library — to fully clean up, also run `R -e 'remove.packages(c("gsDesign","gsDesign2"))'` if you no longer need those CRAN packages for other work.

## Try it

Three conversational prompts you can paste into Claude Code once the plugin is installed. Each one should invoke a specific MCP tool and return a design:

1. **Fixed binary superiority (CAPTURE-style)**
   > *"Design a trial for refractory unstable angina. Control 30-day event rate ≈ 15%, hoped-for treatment rate ≈ 9%, two-sided α = 0.05, power 80%, 1:1 allocation."*
   Expect `design_binary` (`design_class = "fixed"`) with N ≈ 1,100.

2. **TTE PH group-sequential (PARADIGM-HF-style)**
   > *"I need a 2-analysis GS design for a CV outcome trial. Control median OS ≈ 30 months, target HR = 0.75, accrual 100/month over 30 months, 24 months minimum follow-up, OBF spending, α = 0.025 one-sided, power 90%."*
   Expect `design_survival` (`model = "ph"`, `design_class = "group-sequential"`) with events ≈ 380 at final analysis.

3. **TTE NPH MaxCombo (KEYNOTE-024-style)**
   > *"Design an immunotherapy trial with delayed effect: 4-month delay, post-delay HR 0.60, control median 10 months, accrual 20/month for 18 months, 12 months follow-up, α = 0.025, power 90%."*
   Expect `design_survival` (`model = "maxcombo"`, `design_class = "fixed"`) with a MaxCombo design summary.

For an end-to-end example that exercises the operational kernel: append *"and we can enroll 80 patients/month with at least 3 months of post-accrual follow-up — size the accrual window for me too"* to prompt 1. The agent should pass an `operational` block containing `{accrual_rate: 80, follow_up_duration: 3}`, and the response will include a derived accrual duration and total trial duration alongside the headline N.

See `mcp-server/SMOKE.md` for the full 14-prompt smoke matrix.

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

[`RConsortium/pharma-skills`](https://github.com/RConsortium/pharma-skills) is a complementary R Consortium working group skill collection focused on survival group-sequential designs with deep multi-hypothesis support and a Word-report deliverable backed by a Python template. As of v0.0.8, `clinical-trial-design` ships its own multi-hypothesis tools — `design_co_primary`, `design_multi_population`, and `design_graphical_multiplicity` — covering hierarchical alpha-control, biomarker subgroup + ITT patterns, and Maurer–Bretz alpha recycling. The two projects still solve adjacent problems with different shapes: `clinical-trial-design` is broad and MCP-native (validated tools across the gsDesign / gsDesign2 / graphicalMCP surface, no local R session needed), while `pharma-skills` runs in the user's local R session and requires `lrsim()` simulation pass before declaring a design done.

`clinical-trial-design`'s `verify_design` tool adopts the same simulation-verification convention (±2 pp power / ±0.5 pp Type I tolerance) so a design produced here can be subjected to the same credibility floor.

## Contributing

`clinical-trial-design` welcomes contributions from both human biostatisticians and AI agents. Two entry points:

- **[AGENTS.md](AGENTS.md)** — codebase tour and conventions written for AI-agent contributors (Claude, GPT, Gemini, openclaw, opencode, …). Covers the four-layer architecture, a concrete walkthrough of adding a new design wrapper, the benchmark anchor schema, and the agent-contributor protocol (one purpose per PR, paired benchmark anchor required for new wrappers, no novel methodology, no telemetry, no `Co-Authored-By` trailer).
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — human-facing process: priority list (benchmark anchors > new wrappers > bug fixes > tool-description improvements > docs), PR checklist, and review expectations.

The highest-impact contribution is a **new benchmark anchor** — see [`.github/ISSUE_TEMPLATE/add-benchmark-case.yml`](.github/ISSUE_TEMPLATE) for the machine-fillable template that mirrors `benchmarks/schema/design.schema.json`.

## Trust boundary and hosting

- **[SECURITY.md](SECURITY.md)** — `clinical-trial-design`'s statelessness as a *design property*: the R package and MCP server are CI-gated against disk writes and network calls (`.github/workflows/security-grep.yml`). Any PR introducing forbidden patterns (`writeLines`, `saveRDS`, `download.file`, `httr::`, `fs.writeFile`, `fetch`, `http.request`, …) fails before merge. Confidential trial inputs you give the agent never leave your conversation through the plugin.
- **[HOSTING.md](HOSTING.md)** — three deployment profiles: small-co. on public Claude Code (no persistence wanted), large-enterprise on Claude Code Enterprise + Bedrock private endpoint (corporate transcript retention as audit log), and air-gapped (forthcoming). Persistence and audit are *host* concerns; the plugin stays the same.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
