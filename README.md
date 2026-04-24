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
| Benchmark corpus | 🚧 in progress |
| R package | 🔲 not started |
| MCP server | 🔲 not started |
| Skill / subagent | 🔲 not started |
| Plugin packaging | 🔲 not started |

## License

Apache License 2.0 — see [LICENSE](LICENSE).
