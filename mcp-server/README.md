# designr MCP server

TypeScript MCP server that exposes the [`designr`](../r-package/designr) R package as 11 Phase 3 trial-design tools over stdio. One Rscript subprocess per tool call, JSON roundtrip, ~300 ms per call + R compute.

## Tools

See the top-level [README](../README.md) and [SMOKE.md](./SMOKE.md) for the full tool surface and working prompts.

## Build

```bash
npm install
npm run build   # -> dist/index.js
```

The server is wired from the top-level `plugin.json`:

```json
"mcpServers": { "designr": { "command": "node", "args": ["mcp-server/dist/index.js"] } }
```

## Smoke pass

```bash
npm run build
node scripts/smoke.mjs
```

Expected: `11 pass / 0 fail / 11 total`. Requires the R `designr` package installed (`R -e 'remotes::install_local("../r-package/designr")'`).

## Environment

- `DESIGNR_RSCRIPT` — full path to `Rscript` if not on `PATH`.

## Layout

```
src/
  index.ts              # McpServer + stdio transport; registers 11 tools
  r-bridge.ts           # spawns Rscript, JSON roundtrip, 60s timeout
  tools/
    common-schemas.ts   # shared zod fragments
    fixed-*.ts          # 6 fixed-sample tools
    gs-*.ts             # 4 group-sequential tools
    validate-benchmark.ts
scripts/
  smoke.mjs             # programmatic 11-tool smoke pass
```
