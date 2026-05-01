# Architecture

## Layers

```
┌──────────────────────────────────────────────────────────────┐
│                        Claude Code                            │
│  (or any MCP-capable client: Claude Desktop, Cursor, …)       │
└───────┬────────────────────────┬─────────────────────────────┘
        │ user prompt            │ tool calls (MCP)
        ▼                        ▼
┌─────────────────┐      ┌──────────────────────┐
│  CTD skill      │─────▶│  CTD MCP server      │
│  (prompt layer) │      │  (tool surface)      │
└─────────────────┘      └──────────┬───────────┘
                                    │ R calls
                                    ▼
                         ┌────────────────────────────┐
                         │  ClinicalTrialDesign R pkg │
                         │  (compute engine)          │
                         └──────────┬─────────────────┘
                                    │ depends on
                                    ▼
                  gsDesign · gsDesign2 · graphicalMCP · simtrial · officer
```

## Responsibilities

### R package (`r-package/ClinicalTrialDesign`)
- Single source of truth for statistical correctness; 288/288 testthat at v0.0.13.
- Wraps `gsDesign` (binary / continuous / PH survival), `gsDesign2` (NPH MaxCombo / RMST / milestone / WLR / AHR), and `graphicalMCP` (Maurer-Bretz alpha recycling) behind a unified result schema.
- `Suggests:` `simtrial` (for `verify_design` Monte Carlo) and `officer` / `rmarkdown` (for `design_report(format="docx"|"pdf")`).
- Fully unit-tested against the 176-case benchmark corpus.
- Installable as a standalone R package (independent of Claude Code).

### MCP server (`mcp-server`)
- Thin translation layer: MCP tool calls ↔ R function calls.
- Each MCP tool has a zod-typed schema at the boundary that rejects invalid input before R even runs (returns `designr_input_error: <field>: <why>`).
- Spawns one stateless `Rscript` subprocess per tool call (≈ 300 ms launcher overhead + R compute).
- 9 tools total: `design_binary`, `design_continuous`, `design_survival`, `design_co_primary`, `design_multi_population`, `design_graphical_multiplicity`, `validate_against_benchmark`, `verify_design`, `design_report`.
- Built with `esbuild` to a single `dist/index.js` bundle for the npm publish; the bundle is also the shape the Claude Code plugin loads.

### Skill (`skills/clinical-trial-design`)
- Domain knowledge encoded as a SKILL.md system prompt.
- 9-step Phase 3 orchestration workflow (clinical context → endpoint → effect size → error rates → design class → compute → operational → sensitivity + simulation → deliverable) with per-step LLM / user / package responsibility tags.
- Waypoints pattern: agents save intermediate JSON to `waypoints/{01..09}*.json` so a multi-day cross-functional design conversation can pause and resume.
- Reasoning-chain conventions documented (which `source_type` to use when, the redaction warning shape).

### Benchmark corpus (`benchmarks/`)
- 176 curated cases across 21 family directories.
- Dual format: human-readable Markdown + machine-readable YAML with `expected.*` and `tolerance.*` fields.
- Drives `validate_against_benchmark` MCP tool: agent runs a benchmark id, the result is diff'd against the case's expected values within tolerance, and the discrepancy is reported.

### Eval harness (`eval/`)
- 11 scenarios spanning every MCP tool, each scoring along six dimensions (tool selection, parameter mapping, precedent synthesis, result interpretation, end-to-end design accuracy, reasoning-chain quality).
- Single-shot mode (`run_all.sh`) and distributional mode (`run_repeats.sh --n N`); the latter computes a reliability index across N repeats per (model × scenario).
- Output: `MODEL_GUIDANCE.md` at repo root — populated empirically once the user runs the suite.

### Examples gallery (`examples/`)
- 5 published trials reproduced end-to-end: CAPTURE (binary fixed superiority), PARADIGM-HF (TTE PH fixed), KEYNOTE-024 (TTE NPH MaxCombo), KEYNOTE-189 (co-primary hierarchical), KEYNOTE-042 (nested PD-L1 strata).
- Each: runnable `run.R` plus narrative `README.md` plus a populated `reasoning_chain` demonstrating the citation pattern.

## Why this split

- **R package standalone-usable.** Biostatisticians can `install_github("wei-ai-lab/clinical-trial-design", subdir = "r-package/ClinicalTrialDesign")` and call functions from the console without Claude Code. Keeps the math inspectable and CI-testable independent of any LLM.
- **MCP server = generic tool surface.** Not tied to Claude Code; works with any MCP client.
- **Skill = opinion.** When and how to use each tool, what to ask the user, how to explain results. This is where pharma-specific judgment lives and where we iterate fastest.
- **Benchmarks = ground truth.** Any statistical or prompt change can be regression-tested against known-correct designs from the literature.
