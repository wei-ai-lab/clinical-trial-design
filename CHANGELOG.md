# Changelog

All notable changes to `designr` are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.5] — 2026-04-25

Agent-friendliness + trust-boundary release. No new design wrappers, no
new MCP tools — the focus is making `designr` a project that AI agents
(and humans) can contribute to confidently, and making its statelessness
a checked property rather than an assertion.

### Added

- `AGENTS.md` — codebase tour and contributor protocol written for
  AI-agent contributors. Covers the four-layer architecture (skill →
  MCP server → R wrappers → CRAN backends), a worked example of adding
  a new design wrapper end-to-end (R function → benchmark anchor →
  testthat anchor → MCP tool registration → smoke prompt → CHANGELOG),
  the in-scope vs. needs-human-review lists, and multi-host notes
  covering Claude Code, GPT, Gemini, openclaw, and opencode.
- `CONTRIBUTING.md` — human-facing process. References `AGENTS.md` for
  technical detail. Priority list: benchmark anchors > new wrappers >
  bug fixes > tool-description improvements > docs.
- `SECURITY.md` — documents `designr`'s stateless trust boundary as a
  design property: CI-gated against disk writes and network calls
  inside the R package and MCP server. Confidential trial inputs given
  to the agent never leave the conversation *through the plugin*.
  Persistence and audit are framed as *host* concerns (small-co. wants
  none; large-enterprise wants corporate transcript retention as audit
  log). Forbidden patterns are enumerated.
- `HOSTING.md` — three deployment profiles. Profile A: small-co. on
  public Claude Code with managed laptops (no persistence). Profile B:
  large-enterprise on Claude Code Enterprise + Amazon Bedrock private
  endpoint (corporate transcript retention as audit log of
  cross-functional trial-design decisions). Profile C: air-gapped
  on-prem (forthcoming v0.0.11).
- `.github/ISSUE_TEMPLATE/add-benchmark-case.yml` — machine-fillable
  GitHub issue form that mirrors `benchmarks/schema/design.schema.json`.
  Required fields use regex pattern validation. Auto-labels
  `good first issue` because adding a benchmark anchor is the
  highest-impact, lowest-friction contribution.
- `.github/ISSUE_TEMPLATE/add-design-wrapper.yml` — issue form for
  proposing a new design family wrapper. Requires roadmap-phase
  declaration (Phase 1 depth vs. Phase 2 expand) and a paired
  benchmark anchor case.
- `.github/ISSUE_TEMPLATE/bug-report.yml` — separates bug reports from
  security advisories (security routes to private GitHub advisories
  via `config.yml`). Requires environment details (R version, Node
  version, plugin version, OS).
- `.github/ISSUE_TEMPLATE/improve-tool-description.yml` — dedicated
  path for LLM-tool-selection improvements. The MCP tool descriptions
  are how the agent picks the right wrapper; small wording fixes
  there are disproportionately valuable.
- `.github/ISSUE_TEMPLATE/config.yml` — disables blank issues; routes
  security reports to private GitHub advisories.
- `.github/workflows/security-grep.yml` — two-job CI grep gate that
  fails any PR introducing disk writes or network calls. R-side
  forbids `writeLines`, `write.csv`, `write.table`, `saveRDS`,
  `save(`, `cat(..., file=)`, `download.file`, `socketConnection`,
  `httr::`, `curl::`, `RCurl::`, `url(`. MCP-side forbids
  `fs.writeFile*`, `fs.appendFile*`, `writeFileSync`,
  `appendFileSync`, `fetch(`, `http.request`, `https.request`,
  `net.connect`, `net.createConnection`, `dgram`. Triggers on push
  and PR to `main` and `dev`. Locally simulated all patterns —
  current codebase passes both jobs cleanly.
- README "Contributing" and "Trust boundary and hosting" sections
  linking the four new docs above.

### Changed

- Versions aligned across the stack to `0.0.5`. `plugin.json`,
  `marketplace.json` (both `metadata.version` and `plugins[0].version`),
  `mcp-server/package.json`, the MCP server's reported `version` in
  `mcp-server/src/index.ts`, and `r-package/designr/DESCRIPTION` all
  read `0.0.5`. `mcp-server/dist/index.js` rebuilt with esbuild
  (730.8 KB, all Node deps inlined, the `"0.0.5"` literal verified
  present in the bundle). `node scripts/smoke.mjs` returns 13 / 13.

## [0.0.4] — 2026-04-25

### Fixed

- Plugin install now ships a working MCP server out of the box. Two
  problems were stacked: `mcp-server/dist/` was gitignored (so a fresh
  `git clone` produced a plugin whose `mcpServers.designr.args` pointed
  at a non-existent `dist/index.js`), and even if `dist/` had shipped,
  it would have failed at runtime because TypeScript-compiled output
  still imports `@modelcontextprotocol/sdk` from `node_modules/`, which
  is not present after a plain clone. v0.0.4 fixes both: the build now
  uses esbuild to produce a single self-contained
  `mcp-server/dist/index.js` (~730 KB) with all Node deps inlined, and
  that file is committed to the repo. End users no longer need
  `npm install` or `npm run build` — `/plugin install` yields an MCP
  server that starts immediately with all 13 tools registered. This was
  particularly broken on Claude Code-on-Windows reaching across to a
  WSL plugin path, where `cmd.exe` could not even `cd` into the
  `\\wsl.localhost\…` UNC path to run `npm install`.
- Plugin updates now propagate R-side changes automatically. Previously
  the MCP server invoked `Rscript -e 'designr::designr_dispatch(...)'`,
  which required the `designr` R package to be installed in the user's
  R library — meaning every plugin update that touched R code also
  required re-running `remotes::install_local("r-package/designr")`
  for the changes to take effect. v0.0.4 ships an
  `r-package/designr/inst/launcher.R` that sources every file under
  `R/` in-place, and the MCP server invokes that launcher instead of
  the installed package. CRAN dependencies (`gsDesign`, `gsDesign2`,
  `jsonlite`) are still installed once into the user's library;
  `designr` itself never is. Verified with the package physically
  removed from the user's library: 13/13 smoke pass and a real
  `tools/call` over stdio through the installed bundled server returns
  a correct design.

### Added

- `esbuild` is now a `devDependency` of `mcp-server`. `npm run build`
  invokes it to produce the bundled `dist/index.js`. `npm run build:dev`
  is preserved as an escape hatch for `tsc`-based debugging (used by
  `scripts/smoke.mjs`, which imports `runR` directly from
  `mcp-server/build/r-bridge.js`).
- `r-package/designr/inst/launcher.R` — bootstrap script that locates
  its own path via `commandArgs(--file=)`, sources every sibling
  `R/*.R`, and hands stdin to `designr_dispatch()`.
- `DESIGNR_LAUNCHER` env var override on the MCP bridge for cases where
  the launcher needs to live somewhere other than the default
  `${CLAUDE_PLUGIN_ROOT}/r-package/designr/inst/launcher.R`.
- README sections: "Updating" and "Uninstalling", each with both the
  slash-command (Method A) and host-shell (Method B) flows clearly
  labeled to avoid ambiguity.
- Pinned dependency floors in `r-package/designr/DESCRIPTION`
  (`gsDesign >= 3.9.0`, `gsDesign2 >= 1.1.8`, `jsonlite >= 1.8.0`,
  `rpact >= 4.0.0`, `simtrial >= 1.0.0`, `yaml >= 2.3.0`,
  `testthat >= 3.0.0`) and a "Tested dependency versions" table in the
  README enumerating the exact R / Node / CRAN / npm versions used in
  development. Bundled Node deps (`@modelcontextprotocol/sdk`, `zod`)
  are inlined in `dist/index.js`; devDeps (`esbuild`, `typescript`)
  matter only for maintainers.

### Changed

- Versions aligned across the stack. `plugin.json`,
  `marketplace.json`, `mcp-server/package.json`, the MCP server's
  reported `version`, and `r-package/designr/DESCRIPTION` all now read
  `0.0.4`. Going forward, the plugin version is the single source of
  truth — git tag, plugin manifest, MCP server, and R package move
  together.
- Branching model: `main` is now treated as always-shippable. Iteration
  happens on `dev` (or feature branches); `main` only advances when a
  release is fully tested end-to-end. Tags are immutable once
  published — fix-forward to the next patch instead of force-moving.

## [0.0.3] — 2026-04-25

### Fixed

- Plugin install path: `claude plugin install <path>` is no longer supported
  by Claude Code, which requires plugins to be installed through a
  marketplace. v0.0.3 ships the `.claude-plugin/marketplace.json` and
  `.claude-plugin/plugin.json` files the current Claude Code plugin spec
  requires, and the README quickstart now uses
  `/plugin marketplace add <path>` + `/plugin install designr@wei-ai-lab`
  instead. A `claude --plugin-dir <path>` quick-dev alternative is also
  documented.
- Plugin manifest validation: `plugin.json` no longer declares an explicit
  `skills` path or empty `agents` / `commands` arrays. The first triggered
  the Claude Code installer's `skills: Invalid input` validation error
  (the field expects a path to a *parent* directory containing
  `<name>/SKILL.md`, not the skill directory itself); the latter two were
  schema-invalid empties. With those fields omitted, Claude Code
  auto-discovers the skill at the default `skills/designr/SKILL.md`
  location. Verified with `claude plugin validate` and a full
  install round-trip.

### Changed

- `mcpServers.designr.args` in `plugin.json` now uses the spec-recommended
  `${CLAUDE_PLUGIN_ROOT}` placeholder so the bundled MCP server resolves
  correctly regardless of the plugin's installed location.
- Author email in `plugin.json` updated to `wei.ai.lab@outlook.com`.

### Removed

- Legacy root-level `plugin.json`. The current Claude Code plugin spec
  expects `.claude-plugin/plugin.json`; the old location was unused.

## [0.0.2] — 2026-04-24

### Added

- `verify_design()` — Monte Carlo simulation cross-check for a `designr`
  result. Closed-form simulation (`rbinom` / `rnorm` / `rexp`) drives
  empirical power and Type I error estimates against the design's target
  α and 1−β. Supports fixed and group-sequential designs on binary,
  continuous, and PH survival endpoints. Default tolerance gate ±2 pp
  power / ±0.5 pp Type I, modeled on `RConsortium/pharma-skills`'s
  `lrsim()` convention. Equivalence (TOST) and NPH families (MaxCombo,
  RMST, milestone, GS NPH combo) raise a clean deferred-feature error.
- `design_report()` — Renders a markdown summary of any `designr` result
  with sections: Design overview, Key inputs, Headline output, Analysis
  plan (when GS boundaries / timing are present), Method & version.
  Suitable to paste into a SAP-style document or render to HTML / PDF /
  Word downstream.
- MCP tools `verify_design` and `design_report` registered on the bridge;
  smoke matrix expanded to 13 cases (`mcp-server/scripts/smoke.mjs`,
  `mcp-server/SMOKE.md`).
- `.mailmap` aliasing v0.0.1 commits under the new `wei.ai.lab@outlook.com`
  identity (cosmetic only — history is not rewritten).
- `CHANGELOG.md` (this file). v0.0.1 backfilled below.

### Changed

- Git author identity on this repo is now
  `Wei Fu <wei.ai.lab@outlook.com>`. Past commits keep their original
  author email but resolve to the new identity through `.mailmap` for
  `git log --use-mailmap` and GitHub display.
- `cli.R` JSON emission now preserves names on multi-element atomic
  vectors (e.g. `sample_size_per_arm`) by coercing to a named list right
  before serialization, so MCP clients that round-trip a result back into
  `verify_design` / `design_report` can index by arm name.

## [0.0.1] — 2026-04-24

### Added

- Initial alpha release.
- 10 design wrappers: `design_fixed_binary`, `design_fixed_continuous`,
  `design_fixed_survival_ph`, `design_fixed_survival_maxcombo`,
  `design_fixed_survival_rmst`, `design_fixed_survival_milestone`,
  `design_gs_binary`, `design_gs_continuous`, `design_gs_survival_ph`,
  `design_gs_survival_nph_combo`.
- `validate_against_benchmark` — replays a benchmark case through its
  matching design tool and diffs against expected values within
  tolerance.
- MCP server (TypeScript, stdio transport) exposing 11 tools — 10
  design wrappers + the validator.
- Skill / subagent prompt under `skills/designr/`.
- Benchmark corpus: 176 curated cases across 21 family directories
  (FDA guidances, ICH, published SAPs, clinicaltrials.gov entries).
- testthat anchors (~20 canonical cases) covering each design family.
- README with quick-start, MVP tool surface, three "Try it" prompts,
  and roadmap.

[Unreleased]: https://github.com/wei-ai-lab/designr/compare/v0.0.5...HEAD
[0.0.5]: https://github.com/wei-ai-lab/designr/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/wei-ai-lab/designr/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/wei-ai-lab/designr/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/wei-ai-lab/designr/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/wei-ai-lab/designr/releases/tag/v0.0.1
