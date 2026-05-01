# clinical-trial-design MCP server

TypeScript MCP server that exposes the [`ClinicalTrialDesign`](../r-package/ClinicalTrialDesign) R package as **9 trial-design tools** over stdio (3 endpoint + 3 multi-hypothesis + 3 meta). One `Rscript` subprocess per tool call, JSON roundtrip, ~300 ms per call + R compute. Covers Phase 2 and Phase 3 confirmatory designs.

Published to npm as `clinical-trial-design` and to the official MCP registry as `io.github.wei-ai-lab/clinical-trial-design`.

## Tools

See the top-level [README](../README.md) for the full tool surface, [SMOKE.md](./SMOKE.md) for the 18-prompt smoke matrix, and [PUBLISH.md](./PUBLISH.md) for the npm + registry publish steps.

## Build

```bash
npm install                  # pulls dev dependencies (esbuild, typescript)
npm run build                # esbuild bundle → dist/index.js (the publish artifact)
npm run build:dev            # tsc → build/*.js per-file (used by the smoke script)
```

The server is wired from the top-level `.claude-plugin/plugin.json`:

```json
"mcpServers": { "clinical-trial-design": { "command": "node", "args": ["mcp-server/dist/index.js"] } }
```

## Smoke pass

```bash
npm run build:dev            # required: smoke imports from build/r-bridge.js
node scripts/smoke.mjs
```

Expected: `18 pass / 0 fail / 18 total`. The R sources are loaded directly by `r/inst/launcher.R` (or `../r-package/ClinicalTrialDesign/inst/launcher.R` in dev); no `remotes::install_local` step required.

## Environment

- `DESIGNR_RSCRIPT` — full path to `Rscript` if not on `PATH`.
- `DESIGNR_LAUNCHER` — full path to `launcher.R` if you need to override the default. Wire-format identifier preserved as a stability commitment (see [API_STABILITY.md](../API_STABILITY.md)).

## Layout

```
src/
  index.ts                         # McpServer + stdio transport; registers 9 tools
  r-bridge.ts                      # spawns Rscript, JSON roundtrip, 60s timeout
  tools/
    common-schemas.ts              # shared zod fragments + ReasoningChainSchema
    design-binary.ts               # endpoint design (3 tools)
    design-continuous.ts
    design-survival.ts
    design-co-primary.ts           # multi-hypothesis (3 tools)
    design-multi-population.ts
    design-graphical-multiplicity.ts
    validate-benchmark.ts          # meta (3 tools)
    verify-design.ts
    design-report.ts
scripts/
  smoke.mjs                        # programmatic 18-prompt smoke pass
r/                                 # R sources staged for the npm tarball
  R/*.R
  inst/launcher.R
  DESCRIPTION
  NAMESPACE
```
