# Publishing the npm package

The MCP server is published to npm as `clinical-trial-design`. This doc covers the canonical publish, the 7 redirect aliases, and the post-publish MCP-registry / Smithery steps.

## 1. Canonical package — `clinical-trial-design`

The canonical package is published from `mcp-server/`. The `prepublishOnly` script automatically runs `npm run build` (esbuild bundle → `dist/index.js`) and `npm run stage-r` (copies R sources from `r-package/ClinicalTrialDesign/` to `r/`), so no manual prep is needed.

```bash
npm whoami                    # confirm logged in (else: npm login)
cd mcp-server
npm publish --access public
```

Verify:

```bash
npm view clinical-trial-design version
# → 0.0.6

npx clinical-trial-design     # spawns the MCP server on stdio
```

Web: https://www.npmjs.com/package/clinical-trial-design

## 2. Discoverability aliases — 4 redirect packages

Four redirect aliases get published so users searching for related terms (`designr`, `trial-design`, `sample-size-calculator`, `study-design`) find the canonical name. Each is a 1-file deprecation stub: `package.json` + `README.md`, no code, no bundle. After publish, each is `npm deprecate`-d so `npm install <alias>` shows a notice pointing at the canonical name.

```bash
cd mcp-server/aliases
bash publish-aliases.sh
```

The script publishes all four (`designr`, `trial-design`, `sample-size-calculator`, `study-design`) and then deprecates them. It fails fast on the first conflict — if a name is already taken on npm, edit the `ALIASES=(...)` list in the script, drop the conflict, and rerun.

## 3. MCP registry submission

The canonical package's `mcpName` field (`io.github.wei-ai-lab/clinical-trial-design`) ties it to this GitHub org for registry verification. Submit:

```bash
npx @modelcontextprotocol/publisher publish
```

This uses npm package ownership of `clinical-trial-design` to verify your authority over the `io.github.wei-ai-lab/...` namespace, then registers the server at https://registry.modelcontextprotocol.io.

## 4. Smithery

Smithery (https://smithery.ai) auto-discovers MCP servers from npm. After step 1 lands, the package should show up within a few hours under the canonical name. If it doesn't, submit manually at https://smithery.ai/server/new with the npm name `clinical-trial-design`.

## 5. After publish — release tag

Once steps 1–4 are confirmed (npm view returns 0.0.6, registry shows the package), the v0.0.6 release tag goes onto `main`:

```bash
git checkout main
git merge --ff-only dev
git tag -a v0.0.6 -m "v0.0.6: rebrand to clinical-trial-design"
git push origin main --follow-tags
```
