# designr MCP server

Thin Model Context Protocol server that exposes the `designr` R package as a set of tools for LLM clients (Claude Code, Claude Desktop, Cursor, …).

## Planned tool surface (preliminary)

| Tool | Purpose |
|---|---|
| `power_fixed` | Sample size / power for fixed-sample designs (super, NI, equiv). |
| `design_gs` | Group-sequential design (boundaries, spending, per-analysis N/events). |
| `design_gs_nph` | Group-sequential under non-proportional hazards (`gsDesign2`). |
| `design_ssr` | Sample-size re-estimation rules. |
| `design_mams` | Multi-arm multi-stage designs. |
| `design_platform` | Platform/basket/umbrella designs. |
| `simulate_trial` | Monte-Carlo operating characteristics for any of the above. |
| `compare_designs` | Side-by-side comparison under shared assumptions. |
| `validate_against_benchmark` | Run a benchmark case end-to-end and diff. |

Exact signatures and schemas TBD — will be locked once the R-side API stabilizes.

## Implementation (TBD)

Two options under consideration:
1. **Node/TypeScript MCP server** → spawns `Rscript` per call. Good MCP SDK support, slower per-call.
2. **Pure R MCP server** (e.g. via [`r-mcp`](https://github.com/posit-dev/mcptools) or a thin Plumber adapter). Lower overhead, smaller tool ecosystem.

Decision pending benchmark-corpus completion.
