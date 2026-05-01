# clinical-trial-design

**A Claude Code plugin and MCP server for end-to-end clinical trial design.**

`clinical-trial-design` helps biostatisticians and clinical trialists design Phase 2 and Phase 3 confirmatory studies through a conversational interface, backed by validated R packages (`gsDesign`, `gsDesign2`, `graphicalMCP`).

> **v0.0.13 — pre-beta.** Nine MCP tools across single-primary endpoint design (binary, continuous, time-to-event under PH and four NPH frameworks), multi-hypothesis design (co-primary, multi-population, graphical multiplicity / Maurer-Bretz), Monte-Carlo verification, and Word/PDF reporting. Reasoning-chain schema with sponsor-confidential redaction. Operational kernel solves accrual ↔ duration ↔ N, plus optional `max_n` / `max_duration` feasibility warnings. 288/288 R tests, 18/18 MCP smoke. Published to **npm** (`clinical-trial-design`) and the **official MCP registry** (`io.github.wei-ai-lab/clinical-trial-design`). Full change history in [CHANGELOG.md](CHANGELOG.md); API contract in [API_STABILITY.md](API_STABILITY.md).

## What it is

`clinical-trial-design` has four layers:

| Layer | Role |
|---|---|
| **R package** (`r-package/ClinicalTrialDesign`) | Pure R statistical computation engine. Wraps and extends established packages (`gsDesign`, `gsDesign2`, `graphicalMCP`, `simtrial`) behind a unified result schema. |
| **MCP server** (`mcp-server/`) | Exposes the R functions as typed tools over the Model Context Protocol so Claude Code — or any MCP client — can call them. |
| **Skill** (`skills/clinical-trial-design/`) | Domain-expert prompt. Translates a user's design brief into the right tool calls and interprets results in clinical-trial terms; includes a 9-step Phase 3 orchestration workflow with waypoints. |
| **Benchmark corpus** (`benchmarks/`) | 176 curated public-trial designs across 21 family directories. Each case is human-readable Markdown plus machine-readable YAML with expected outputs and tolerances. |

Plus an **eval harness** under `eval/` (11 reproducible scenarios × six scoring dimensions × multi-vendor Claude family) and an **examples gallery** under `examples/` (5 published trials reproduced end-to-end).

## What clinical-trial-design actually computes

| Family | Status |
|---|---|
| Fixed-sample binary | ✅ super / NI / equivalence |
| Fixed-sample continuous | ✅ super / NI / equivalence |
| Fixed-sample TTE — PH log-rank | ✅ super / NI |
| Fixed-sample TTE — NPH MaxCombo / RMST / milestone | ✅ superiority |
| Group-sequential binary / continuous | ✅ super / NI; futility via `test.type` |
| Group-sequential TTE — PH | ✅ super / NI; events via Schoenfeld + OBF inflation by default (regulatory-defensible; `events_calc` selector) |
| Group-sequential TTE — NPH (MaxCombo / WLR / AHR) | ✅ superiority |
| **Multi-hypothesis — co-primary endpoints** | ✅ fixed-sequence / alpha-split / Bonferroni |
| **Multi-hypothesis — multi-population (subgroup + ITT)** | ✅ nested or disjoint relations |
| **Multi-hypothesis — graphical (Maurer-Bretz)** | ✅ initial weights + transition matrix + Rule-3 validator |
| Adaptive (SSR, enrichment, selection) | ⏳ corpus has cases; wrappers are roadmap |
| MAMS / platform / basket / umbrella | ⏳ corpus has cases; wrappers are roadmap |

## Status

| Layer | State |
|---|---|
| R package | ✅ 288/288 testthat |
| MCP server | ✅ 9 tools over stdio, esbuild bundle, 18/18 smoke |
| Skill | ✅ 9-step Phase 3 orchestration workflow + waypoints |
| Benchmark corpus | ✅ 176 curated public-trial cases / 21 families |
| Plugin manifest | ✅ `.claude-plugin/plugin.json` + `marketplace.json` |
| npm package | ✅ `clinical-trial-design@0.0.13` published 2026-04-29 |
| Official MCP registry | ✅ `io.github.wei-ai-lab/clinical-trial-design` |
| CI release-gate | ✅ `.github/workflows/release-gate.yml` (R tests + R CMD check + MCP build/smoke + scenario validation) |
| LLM benchmark harness | ✅ 11 scenarios × 6-dimension rubric (`eval/`) |
| Pre-beta hand-off | ✅ items tracked in [BETA_HANDOFF.md](BETA_HANDOFF.md) |

## Tool surface

Nine MCP tools — three single-primary design tools, three multi-hypothesis design tools, three meta tools. Same unified result schema across families.

### Single-primary design tools (3)

| Tool | Endpoint | Selectors | R backend |
|---|---|---|---|
| `design_binary` | event / no-event | `design_class ∈ {"fixed", "group-sequential"}` | `gsDesign::nBinomial`, `gsDesign::gsDesign` |
| `design_continuous` | mean difference | `design_class ∈ {"fixed", "group-sequential"}` | `gsDesign::nNormal`, `gsDesign::gsDesign` |
| `design_survival` | time-to-event | `design_class` × `model ∈ {"ph", "maxcombo", "rmst", "milestone", "wlr", "ahr"}` | `gsDesign::nSurv`/`gsSurv` (PH); `gsDesign2::fixed_design_*` and `gs_design_*` (NPH) |

All three accept `comparison ∈ {"superiority", "non-inferiority", "equivalence"}` (equivalence on fixed-sample binary / continuous only), `alpha`, `power`, `sided`, `allocation_ratio`, GS parameters (`k`, `timing`, `sfu`, `sfl`, `test.type`), an optional `operational` block, and an optional `reasoning_chain` array (citation trail with `source_type` tags).

`design_survival` adds `events_calc ∈ {"schoenfeld" (default), "lachin-foulkes", "freedman"}` for PH GS designs and accepts `control_hazard_rate` (events per patient-year) as an alternative to `control_median`.

### Multi-hypothesis design tools (3)

| Tool | When to use | Strategies | R backend |
|---|---|---|---|
| `design_co_primary` | Two or more co-primary endpoints (PFS+OS, CV death+HHF, mixed binary+continuous) | `fixed-sequence` (hierarchical, default), `alpha-split` (weighted), `bonferroni` | Per-endpoint dispatch to single-primary tools at the appropriate effective alpha; total N = max across endpoints |
| `design_multi_population` | Same endpoint tested across multiple populations (biomarker subgroup + ITT, nested PD-L1 strata) | Same three strategies; `relation ∈ {"nested", "disjoint"}` | Same per-population dispatch; for `nested`, total N driven by largest implied-enrolled-N (events / prevalence); for `disjoint`, total N is the sum |
| `design_graphical_multiplicity` | Multi-hypothesis with alpha recycling (Maurer-Bretz) — mixed primary+secondary, dose-response | Graphical procedure with user-supplied initial weights and transition matrix; built-in Rule-3 validator | `graphicalMCP::graph_create`; per-hypothesis sample-size at worst-case alpha |

### Meta tools (3)

| Tool | Purpose |
|---|---|
| `validate_against_benchmark` | Replay a benchmark case through its matching design tool and diff against expected values within tolerance. |
| `verify_design` | Monte Carlo cross-check of any result. Closed-form simulation under H0 and H1; ±2 pp power / ±0.5 pp Type I tolerance gate. Supports fixed and GS designs on binary, continuous, and PH-survival endpoints. |
| `design_report` | Render a clinician-readable design summary in markdown (default), Word (`format="docx"` via `officer`), or PDF (`format="pdf"` via `rmarkdown` + Pandoc). Reasoning chain rendered as a Word table; sponsor-confidential entries surface a redaction warning at the top of the document. |

### Operational kernel

Every endpoint design tool accepts an `operational` block that solves the simple relations `accrual_rate × accrual_duration = sample_size_total` and `total_trial_duration = accrual_duration + follow_up_duration` (plus `target_events = sample_size_total × cumulative_event_rate(...)` for survival, via `uniroot` over the closed-form pooled exponential-PH event probability — same kernel `gsDesign::nSurv` uses internally).

Supply any **0–4 of** `{accrual_rate, accrual_duration, follow_up_duration, total_trial_duration}` plus optional caps `{max_n, max_duration}`. The solver fills in the missing values with an audit trail (`given`, `derived`); cap violations surface as structured `feasibility_warnings` rather than silent over-cap designs.

## Quick start

Prerequisites: R ≥ 4.2, Node ≥ 18. No `npm install` step (the MCP server ships pre-bundled in `mcp-server/dist/index.js`) and no `remotes::install_local` step (the launcher sources `r-package/ClinicalTrialDesign/R/*.R` directly out of the plugin cache).

### 1. Install CRAN dependencies (one-time)

```bash
R -e 'install.packages(c("gsDesign","gsDesign2","graphicalMCP","jsonlite","officer","rmarkdown"))'
```

The first four are runtime imports; `officer` and `rmarkdown` are `Suggests:` and only needed for `design_report(format="docx")` / `format="pdf"`.

#### Tested dependency versions

`clinical-trial-design` v0.0.13 was developed and tested against the versions below. CRAN's latest is usually fine; pin to these floors only if you hit a version-skew issue.

| Layer | Dependency | Tested version |
|---|---|---|
| R runtime | R | 4.5.3 (works on R ≥ 4.2) |
| R imports | `gsDesign` | 3.9.0 |
|  | `gsDesign2` | 1.1.8 |
|  | `graphicalMCP` | 0.2.9 |
|  | `jsonlite` | 2.0.0 |
| R suggests | `officer` | 0.6.x (for `design_report(format="docx")`) |
|  | `rmarkdown` | 2.20+ (for `design_report(format="pdf")`; Pandoc system dep) |
|  | `simtrial` | 1.0.2 (for `verify_design` Monte Carlo) |
|  | `rpact` | 4.4.0 |
|  | `yaml` | 2.3.12 |
|  | `testthat` | 3.3.2 |
| Node runtime | Node | 22.22.1 (works on Node ≥ 18) |
| Node bundled | `@modelcontextprotocol/sdk` | ^1.0.0 (inlined in `dist/index.js`) |
|  | `zod` | ^3.23.0 (inlined) |

### 2. Install the plugin

**Method A — slash commands (recommended, inside Claude Code)**

```text
/plugin marketplace add wei-ai-lab/clinical-trial-design
/plugin install clinical-trial-design@wei-ai-lab
```

After install, restart Claude Code so it loads the bundled MCP server. Confirm with `/plugin` (clinical-trial-design should be listed and enabled at version 0.0.13).

**Method B — host shell (equivalent, scriptable)**

```bash
claude plugin marketplace add wei-ai-lab/clinical-trial-design
claude plugin install clinical-trial-design@wei-ai-lab
claude plugin list      # confirm: clinical-trial-design@wei-ai-lab, version 0.0.13, enabled
```

If anything goes wrong, `claude plugin validate /full/path/to/clinical-trial-design` will tell you whether the marketplace + plugin manifests parse cleanly.

**Quick local-dev alternative** — skip the marketplace step and load the plugin directly from a checkout:

```bash
git clone https://github.com/wei-ai-lab/clinical-trial-design ~/clinical-trial-design
claude --plugin-dir ~/clinical-trial-design
```

### Environment overrides

If `Rscript` isn't on your `PATH`, set `DESIGNR_RSCRIPT=/full/path/to/Rscript`. To override the R launcher path (rare), set `DESIGNR_LAUNCHER=/full/path/to/launcher.R`. The MCP server reads both env vars when spawning R. (The `DESIGNR_*` prefix is preserved as a wire-format contract; see [API_STABILITY.md](API_STABILITY.md).)

## Standalone MCP server (without Claude Code)

The MCP server is published to npm as `clinical-trial-design`. Any MCP-aware client (Claude Desktop, Cursor, Continue, custom MCP host) can launch it via `npx`:

```bash
npx clinical-trial-design@latest
```

The package bundles the R sources under `r/`; the launcher resolves them via `import.meta.url` so it works from a global install, a local install, or `npx`. CRAN dependencies (above) still need to be in your R user library.

## Updating

**Method A — slash command (inside Claude Code):**
```text
/plugin update clinical-trial-design@wei-ai-lab
```

**Method B — host shell:**
```bash
claude plugin update clinical-trial-design@wei-ai-lab
```

Restart Claude Code after updating.

## Try it

Five conversational prompts you can paste into Claude Code once the plugin is installed. Each demonstrates a v0.0.13 capability:

1. **Fixed binary superiority with reasoning chain (CAPTURE-style)**
   > *"Design a Phase 3 trial for refractory unstable angina. Control 30-day event rate ≈ 15%, hoped-for treatment rate ≈ 9%, two-sided α = 0.05, power 80%, 1:1. Cite the precedent for the assumed effect size."*

   Expect `design_binary` (`design_class = "fixed"`) with N ≈ 1,000 and a populated `reasoning_chain` (the agent should tag the alpha as `fda_guidance`, the precedent-derived effect as `llm_precedent`).

2. **Group-sequential survival under PH, regulatory-default events**
   > *"Phase 3 oncology, single-primary OS, 1L metastatic. Median 11 vs 17 mo (HR ≈ 0.65), 2:1 randomization, 5% two-sided, 80% power, three analyses at 50%, 75%, 100% information time, OBF spending. 25 patients/month accrual, 12-month minimum follow-up, 5%/year dropout."*

   Expect `design_survival` (`model="ph"`, `design_class="group-sequential"`) with events ≈ 190 (Schoenfeld + OBF inflation), boundaries (2.96, 2.36, 2.01), and a Word/PDF report on follow-up if you ask for one. Pass `events_calc="lachin-foulkes"` if you want the v0.0.7 default behavior; `"schoenfeld"` is the new default and matches regulatory convention.

3. **CVOT with annualized event rate (v0.0.13's `control_hazard_rate`)**
   > *"Cardiovascular outcomes trial. Control event rate is 2.5% per patient-year, target HR 0.80, 1:1, 2.5% one-sided, 90% power, fixed-sample. We'll enroll 200 patients/month and need at least 12 months of follow-up after the last enrollment."*

   Expect `design_survival` to accept `control_hazard_rate = 0.025` directly (no need to translate to a median first), use the `operational` block to solve duration, and report an events count in the high hundreds.

4. **Co-primary PFS + OS, hierarchical (KEYNOTE-189-style)**
   > *"Phase 3 1L NSCLC. Co-primary PFS and OS, hierarchical (PFS first, then OS). 2:1 randomization. PFS HR 0.50, control median 4.7 mo. OS HR 0.70, control median 17 mo. 80% power per endpoint, α = 0.025 one-sided. Plan a 20-month accrual, 12-month minimum follow-up for PFS / 24 months for OS. Report a Word document at the end."*

   Expect `design_co_primary` with `strategy = "fixed-sequence"`. OS will drive the total N. Both endpoints sized at full alpha = 0.025 (NOT alpha-split). Final tool call to `design_report(format = "docx")`.

5. **Operational kernel + feasibility warning**
   > *"For prompt 1 above, we can enroll 80 patients/month with at least 3 months follow-up — and we can't go above 1,000 patients total."*

   Expect the operational block to derive `accrual_duration ≈ 12.5` months, total study duration ≈ 15.5 months, plus a `feasibility_warnings` entry on the result if N exceeds the 1,000 cap (it doesn't quite — should land ~960). For a violation case, ask for power 90% with the same constraints and watch the warning surface.

For an end-to-end reproducible example, see `examples/`:
- [`01_capture_binary`](examples/01_capture_binary/) — binary fixed superiority
- [`02_paradigm_hf_survival`](examples/02_paradigm_hf_survival/) — TTE PH fixed
- [`03_keynote024_maxcombo`](examples/03_keynote024_maxcombo/) — TTE NPH MaxCombo
- [`04_keynote189_co_primary`](examples/04_keynote189_co_primary/) — co-primary hierarchical
- [`05_keynote042_multi_population`](examples/05_keynote042_multi_population/) — nested PD-L1 strata

Each is a runnable `run.R` plus a narrative `README.md`. The full 18-prompt smoke matrix is in `mcp-server/SMOKE.md`.

## Roadmap

In priority order based on the corpus's family weights and current LLM-benchmark gaps:

1. **NPH evaluation step** — pharma-skills' workflow gate where a PH design is followed by an NPH-evaluation pass that reports power under both PH and NPH assumptions. Currently NPH is a model selector, not an eval step.
2. **Piecewise control hazard** for `design_survival` (currently scalar exponential only).
3. **`verify_design` for NPH GS** designs (`maxcombo` / `wlr` / `ahr` group-sequential).
4. **Adaptive sample-size re-estimation** (corpus: `adaptive-ssr/`) — `rpact::getSampleSizeRates` + Promising-Zone rule.
5. **Adaptive treatment selection / population enrichment** (corpus: `adaptive-selection/`, `adaptive-enrichment/`).
6. **MAMS** (corpus: `mams/`) — `MAMS::mams` or `rpact::getDesignMams`.
7. **Recurrent events** (corpus: `recurrent-events/`).
8. **Count / rate endpoints** (corpus: `count-rate/`).
9. **Bayesian designs** (corpus: `bayesian/`).
10. **Platform / basket / umbrella** (corpus: `platform/`, `basket/`, `umbrella/`).

Each row above already has ≥ 7 curated benchmark cases ready as regression anchors. See [BETA_HANDOFF.md](BETA_HANDOFF.md) for items pending before the v0.5.0 beta tag.

## Related work

[`RConsortium/pharma-skills`](https://github.com/RConsortium/pharma-skills) is a complementary R Consortium working group skill collection focused on survival group-sequential designs with deep multi-hypothesis support and a Word-report deliverable backed by a Python template. As of v0.0.8, `clinical-trial-design` ships its own multi-hypothesis tools (`design_co_primary`, `design_multi_population`, `design_graphical_multiplicity`) covering hierarchical alpha control, biomarker subgroup + ITT patterns, and Maurer-Bretz alpha recycling.

The two projects still solve adjacent problems with different shapes: `clinical-trial-design` is broad and MCP-native (validated tools across the gsDesign / gsDesign2 / graphicalMCP surface, no local R session needed; cost-cheap because the agent doesn't reload skill content per turn), while `pharma-skills` runs in the user's local R session and requires `lrsim()` simulation pass before declaring a design done.

`clinical-trial-design`'s `verify_design` adopts the same simulation-verification convention (±2 pp power / ±0.5 pp Type I tolerance) so a design produced here can be subjected to the same credibility floor.

## Contributing

`clinical-trial-design` welcomes contributions from both human biostatisticians and AI agents. Two entry points:

- **[AGENTS.md](AGENTS.md)** — codebase tour and conventions written for AI-agent contributors. Covers the four-layer architecture, a concrete walkthrough of adding a new design wrapper, the benchmark anchor schema, the agent-contributor protocol, and the reasoning-chain conventions.
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — human-facing process: priority list, PR checklist, review expectations.

The highest-impact contribution is a **new benchmark anchor** — see [`.github/ISSUE_TEMPLATE/add-benchmark-case.yml`](.github/ISSUE_TEMPLATE) for the machine-fillable template that mirrors `benchmarks/schema/design.schema.json`.

## Trust boundary and hosting

- **[SECURITY.md](SECURITY.md)** — `clinical-trial-design`'s statelessness as a *design property*: the R package and MCP server are CI-gated against disk writes and network calls (`.github/workflows/security-grep.yml`). Any PR introducing forbidden patterns (`writeLines`, `saveRDS`, `download.file`, `httr::`, `fs.writeFile`, `fetch`, `http.request`, …) fails before merge. Confidential trial inputs you give the agent never leave your conversation through the plugin.
- **[HOSTING.md](HOSTING.md)** — three deployment profiles: small-co. on public Claude Code (no persistence wanted), large-enterprise on Claude Code Enterprise + Bedrock private endpoint (corporate transcript retention as audit log), and air-gapped (forthcoming). Persistence and audit are *host* concerns; the plugin stays the same.
- **[API_STABILITY.md](API_STABILITY.md)** — what's frozen (MCP tool names, result-JSON top-level shape, `source_type` enum, error-class names) vs flexible (tool descriptions, defaults, internal helpers).

## License

[Apache License 2.0](LICENSE). All R code, MCP server, skill content, and benchmark corpus.
