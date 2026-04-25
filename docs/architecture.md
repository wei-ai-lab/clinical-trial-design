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
                  gsDesign · gsDesign2 · rpact · simtrial · …
```

## Responsibilities

### R package (`r-package/ClinicalTrialDesign`)
- Single source of truth for statistical correctness.
- Wraps established R packages behind a consistent, documented API.
- Fully unit-tested against the benchmark corpus.
- Installable as a standalone R package (independent of Claude Code).

### MCP server (`mcp-server`)
- Thin translation layer: MCP tool calls ↔ R function calls.
- Handles JSON ↔ R data-frame marshaling.
- Returns structured results (numbers, tables, plot artifacts).
- Runs R via `Rscript` subprocess or [`r-mcp`](#) bindings (TBD).

### Skill / subagent (`skills/clinical-trial-design`, `agents/`)
- Domain knowledge encoded as a system prompt.
- Elicits design intent from the user (endpoint type, margin, hazard assumptions, etc.).
- Maps intent to correct MCP tool sequence.
- Interprets numerical output in clinical terms (e.g. "at this rate you need 412 events").

### Benchmarks (`benchmarks/`)
- Curated from public sources (see `benchmarks/README.md` for methodology).
- Dual format: human-readable markdown + machine-readable YAML.
- Drives the evaluation harness: agent produces a design given the brief; we compare to the published design.

## Why this split

- **R package standalone-usable.** Biostatisticians can `install_github("wei-ai-lab/clinical-trial-design", subdir = "r-package/ClinicalTrialDesign")` and call functions from the console without Claude Code. Keeps the math inspectable and CI-testable independent of any LLM.
- **MCP server = generic tool surface.** Not tied to Claude Code; works with any MCP client.
- **Skill = opinion.** When and how to use each tool, what to ask the user, how to explain results. This is where pharma-specific judgment lives and where we iterate fastest.
- **Benchmarks = ground truth.** Any statistical or prompt change can be regression-tested against known-correct designs from the literature.
