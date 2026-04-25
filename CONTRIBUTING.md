# Contributing to `designr`

Thanks for considering a contribution. `designr` is built to be
contributed to by both human and AI-agent contributors; the technical
codebase tour lives in [`AGENTS.md`](./AGENTS.md), and this document
focuses on the human-facing process.

## What contributions are welcome

Highest-value, in priority order:

1. **A new benchmark anchor case** for a design family `designr`
   already covers. The corpus today is 176 cases, but only ~20 of
   them are wired into testthat anchors; expanding that gates more
   regression coverage.
2. **A new design wrapper** for a family on the roadmap. See the
   "Phase 1 → Phase 2" split in the README; Phase 1 deepens the
   current 13-tool surface, Phase 2 adds new families.
3. **A bug fix with a regression test.** The CRAN backends
   (`gsDesign`, `gsDesign2`) are well-tested upstream; bugs in
   `designr` are usually input-validation issues, normalization
   issues in `utils_format.R`, or contract drift between the R
   package and MCP server.
4. **Improving a tool's MCP description** for LLM-selection
   accuracy. See the "tool description string is critical" note in
   [`AGENTS.md`](./AGENTS.md).
5. **Documentation polish** — README, AGENTS.md, SECURITY.md,
   HOSTING.md, benchmark glossary.

If your idea does not fit one of those, open an issue first to
discuss before writing code.

## How to contribute

1. **Open an issue** describing the change you want to make. We use
   issue templates in `.github/ISSUE_TEMPLATE/` to keep proposals
   structured. If you are an AI agent, the templates are
   machine-readable so you can fill them programmatically.
2. **Fork and branch off `dev`.** `main` is always-shippable; `dev`
   is where iteration happens. Branch off `dev`, name your branch
   for the issue (e.g., `add-fixed-count-rate`).
3. **Make the change small and focused.** One purpose per PR.
4. **Write a test.** New wrapper → at least one benchmark anchor
   test. Bug fix → regression test that fails on the unfixed code.
5. **Run the local gates** before opening the PR:

   ```bash
   # R side
   cd r-package/designr
   R -e 'devtools::test()'
   R -e 'devtools::check(".")'

   # MCP side
   cd ../../mcp-server
   npm run build
   node scripts/smoke.mjs
   ```

6. **Open a PR against `dev`.** Reference the issue. Describe what
   changed, why, and how you tested it.
7. **Address review feedback.** Reviewers may be human or AI agents
   acting on the maintainer's behalf — the standards are the same
   either way.

## What needs maintainer-only review

Some changes need a human maintainer's sign-off before merging,
regardless of who proposed them:

- New CRAN dependencies (see dependency-review policy in
  [`SECURITY.md`](./SECURITY.md)).
- Changes to the JSON contract between MCP and R.
- Changes to the `verify_design()` Monte Carlo tolerance defaults.
- Changes to the `security-grep` CI workflow.
- Plugin manifest changes (`.claude-plugin/`).
- Releases (version bumps, tags, marketplace updates).

The full list with rationale is in
[`AGENTS.md`](./AGENTS.md#what-needs-human-review-agents-do-not-auto-merge).

## Code of conduct

Be civil. Disagreement is fine; personal attacks are not.

If a contribution conflict cannot be resolved through PR discussion,
the maintainer's decision stands. The project is open source under
Apache 2.0; you are welcome to fork.

## Reporting a bug

For a bug that is not a security vulnerability: open a regular issue
using the "bug" template.

For a security-relevant bug (e.g., the package writes to disk under
some condition, or a dependency leaks data over the network): see
[`SECURITY.md`](./SECURITY.md) — open a private security advisory
or email `wei.ai.lab@outlook.com`. Do not file a public issue for
security reports.

## License

By contributing, you agree that your contribution is licensed under
the project's Apache 2.0 license. See [`LICENSE`](./LICENSE).
