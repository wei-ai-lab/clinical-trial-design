# Publishing the npm package

The MCP server is published to npm as `clinical-trial-design`. This doc covers the canonical publish, the 7 redirect aliases, and the post-publish MCP-registry / Smithery steps.

## 1. Canonical package — `clinical-trial-design`

The canonical package is published from `mcp-server/`. The `prepublishOnly` script automatically runs `npm run build` (esbuild bundle → `dist/index.js`) and `npm run stage-r` (copies R sources from `r-package/ClinicalTrialDesign/` to `r/`), so no manual prep is needed.

```bash
npm whoami                    # confirm logged in (else: npm login)
cd mcp-server
npm publish --access public
# If your account has 2FA enforced, npm returns E403 on the bare
# command. Pass a fresh OTP from your authenticator app:
#   npm publish --access public --otp=123456
```

Verify:

```bash
npm view clinical-trial-design version
# → 0.0.13

npx clinical-trial-design     # spawns the MCP server on stdio
```

Web: https://www.npmjs.com/package/clinical-trial-design

## 2. Discoverability aliases — 3 redirect packages

Three redirect aliases get published so users searching for related terms (`trial-design`, `sample-size-calculator`, `study-design`) find the canonical name. Each is a 1-file deprecation stub: `package.json` + `README.md`, no code, no bundle. After publish, each is `npm deprecate`-d so `npm install <alias>` shows a notice pointing at the canonical name.

```bash
cd mcp-server/aliases
bash publish-aliases.sh                   # 2FA off
bash publish-aliases.sh --otp 123456      # 2FA on — pass a fresh OTP
```

The script publishes all three (`trial-design`, `sample-size-calculator`, `study-design`) and then deprecates them. It fails fast on the first conflict — if a name is already taken on npm, edit the `ALIASES=(...)` list in the script, drop the conflict, and rerun. A single OTP usually covers the full run (3 publishes + 3 deprecates ≈ a few seconds total, well under the 30-second OTP window).

## 3. MCP registry submission

The canonical package's `mcpName` field (`io.github.wei-ai-lab/clinical-trial-design`) ties it to this GitHub org for registry verification. Submit:

```bash
npx @modelcontextprotocol/publisher publish
```

This uses npm package ownership of `clinical-trial-design` to verify your authority over the `io.github.wei-ai-lab/...` namespace, then registers the server at https://registry.modelcontextprotocol.io.

## 4. Smithery

Smithery (https://smithery.ai) auto-discovers MCP servers from npm. After step 1 lands, the package should show up within a few hours under the canonical name. If it doesn't, submit manually at https://smithery.ai/server/new with the npm name `clinical-trial-design`.

## 5. After publish — release tag

Once steps 1–4 are confirmed (npm view returns 0.0.13, registry shows the package), the v0.0.13 release tag goes onto `main`:

```bash
git checkout main
git merge --ff-only dev
git tag -a v0.0.13 -m "v0.0.13: events_calc + control_hazard_rate + feasibility_warnings"
git push origin main --follow-tags
```
