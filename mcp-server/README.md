# clinical-trial-design MCP server

TypeScript MCP server that exposes the [`ClinicalTrialDesign`](../r-package/ClinicalTrialDesign) R package as 13 trial-design tools over stdio. One Rscript subprocess per tool call, JSON roundtrip, ~300 ms per call + R compute. Covers Phase 2 and Phase 3 confirmatory designs.

## Tools

See the top-level [README](../README.md) and [SMOKE.md](./SMOKE.md) for the full tool surface and working prompts.

## Build

```bash
npm install
npm run build   # -> dist/index.js
```

The server is wired from the top-level `plugin.json`:

```json
"mcpServers": { "clinical-trial-design": { "command": "node", "args": ["mcp-server/dist/index.js"] } }
```

## Smoke pass

```bash
npm run build
node scripts/smoke.mjs
```

Expected: `13 pass / 0 fail / 13 total`. The R sources are loaded directly by `inst/launcher.R`; no `remotes::install_local` step is required.

## Environment

- `DESIGNR_RSCRIPT` — full path to `Rscript` if not on `PATH`.
- `DESIGNR_LAUNCHER` — full path to `launcher.R` if you need to override the default.

## Layout

```
src/
  index.ts              # McpServer + stdio transport; registers 13 tools
  r-bridge.ts           # spawns Rscript, JSON roundtrip, 60s timeout
  tools/
    common-schemas.ts   # shared zod fragments
    fixed-*.ts          # 6 fixed-sample tools
    gs-*.ts             # 4 group-sequential tools
    validate-benchmark.ts
    verify-design.ts
    design-report.ts
scripts/
  smoke.mjs             # programmatic 13-tool smoke pass
```
