# Changelog

All notable changes to `designr` are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/wei-ai-lab/designr/compare/v0.0.2...HEAD
[0.0.2]: https://github.com/wei-ai-lab/designr/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/wei-ai-lab/designr/releases/tag/v0.0.1
