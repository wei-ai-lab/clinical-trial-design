# Security and data handling

## Scope of this document

`designr` is invoked with clinical trial design inputs that may include
sponsor-confidential information (internal Phase 2 readouts, pipeline
assumptions, business deadlines). This document explains, layer by
layer, what the plugin guarantees about that data and what is the
responsibility of the host environment you run it in.

The short version: **`designr` is a stateless computation layer.**
Persistence, history, audit logging, access control, and data residency
are properties of your *host* (Claude Code, Claude Code Enterprise,
openclaw, opencode, Cursor) and your organization's deployment of it,
not of the plugin.

For recommended host configurations per user profile, see
[`HOSTING.md`](./HOSTING.md).

## What `designr` guarantees (CI-enforced)

Each MCP tool call follows this lifecycle:

1. JSON arguments arrive on the MCP server's stdin.
2. The MCP server spawns a fresh `Rscript` subprocess and pipes the
   JSON to its stdin.
3. The subprocess sources `r-package/designr/R/*.R`, dispatches to the
   matching wrapper, computes, writes a single JSON line to stdout,
   and exits.
4. The MCP server forwards that JSON back to the host.

That is the whole lifecycle. Specifically:

- **No state carries across calls.** Each tool invocation is a fresh
  R subprocess. There is no in-memory or on-disk session that
  remembers prior calls.
- **No telemetry.** No analytics, no usage logging, no phone-home from
  either the R package or the MCP server.
- **No persistence by the plugin.** The R subprocess does not write to
  disk except via output the user explicitly requests
  (e.g., a markdown report the user redirects to a file).
  `Rscript`'s default flags (`--no-save --no-restore`) prevent
  `.RData` / `.Rhistory` writes.
- **No outbound network calls from the R package code paths.**
  `gsDesign`, `gsDesign2`, and `jsonlite` are pure-math/parse
  packages; nothing in the wrappers we ship invokes HTTP, sockets,
  or downloads.
- **No outbound network calls from the MCP server code paths.** The
  MCP server only pipes stdio to the R subprocess; it does not open
  connections.

These guarantees are CI-enforced. The
[`security-grep`](.github/workflows/security-grep.yml) workflow runs
on every push and pull request and fails the build if a grep gate
finds any of the following in non-test code paths:

- In `r-package/designr/R/*.R`: `write*()`, `save*()`, `cat(..., file=)`,
  `download.file`, `url(`, `socketConnection`, `httr::`, `curl::`,
  `RCurl::`.
- In `mcp-server/src/**/*.ts`: `fs.writeFile*`, `fs.appendFile*`,
  `writeFileSync`, `appendFileSync`, `fetch(`, `http.request`,
  `https.request`, `net.connect`, `net.createConnection`.

If you are adding a wrapper or a new MCP tool that legitimately needs
to write a file (e.g., `design_report(format = "docx")` in v0.0.10),
the design pattern is to **return** the bytes / string to the caller
and let the host decide whether to save them — not to write inside
the package. That keeps the CI gate intact.

## What `designr` does *not* do (host responsibility)

- **Persistence of conversation history.** Including tool-call inputs
  and outputs.
- **Audit logging** for cross-functional review.
- **Access control** and multi-user collaboration.
- **Data residency** — where the host's LLM runs, where its
  transcripts are stored.
- **Data-handling contracts with LLM providers.**

These are determined by the host. `designr` fits *into* the bigger
trial-design process; it does not try to *cover* the bigger process.
Cross-functional review (statistician, clinician, regulatory affairs,
operations, leadership) happens against the host's persisted
transcript, not against a plugin-internal log.

## Two user profiles, same plugin

`designr` is designed so the *same build* serves both ends of the
spectrum, with no plugin-side configuration:

### Individual researcher / small company

- Likely host: **public Claude Code** on a managed laptop.
- Data-handling question is "do I trust Anthropic's API with this
  prompt?" That is about the host, not the plugin.
- Recommended posture: explore designs with public-precedent
  effect-size assumptions; if you must work with sponsor-confidential
  data, switch the host to a private endpoint or run an air-gapped
  setup. See [`HOSTING.md`](./HOSTING.md).

### Large enterprise (e.g., pharma sponsor)

- Likely host: **Claude Code Enterprise on AWS Bedrock** (or
  equivalent on Azure / GCP) with a private endpoint and corporate
  transcript retention.
- Persistence is *wanted* — trial design is a months-long
  cross-functional effort and the persisted transcript is the
  decision audit log.
- `designr`'s structured output (the `reasoning_chain` schema landing
  in v0.0.8) is designed to make that retained transcript a
  high-quality audit record automatically: every assumption tagged
  with its `source_type` (LLM-precedent, FDA-guidance, user-supplied,
  sponsor-confidential, package-default) and its `source_ref`.

## Reporting a vulnerability

If you find a way that `designr` can leak inputs — either through a
wrapper that writes to disk, a dependency that opens a socket, or a
new code path that bypasses the CI grep gate — please open a private
security advisory on the GitHub repo, or email
`wei.ai.lab@outlook.com`. Do not file a public issue for security
reports.

We aim to triage within 5 business days and ship a fix in the next
patch release.

## Dependency review policy

Any new dependency introduced into `r-package/designr/Imports:` or
`mcp-server/package.json` must include in the PR description:

1. Whether the dependency makes outbound network calls in any code
   path the plugin uses.
2. Whether it writes to disk in any code path the plugin uses.
3. The license.

If (1) or (2) is "yes," the PR must explain why that surface is
unavoidable and how it will be sandboxed. The CI grep gate covers
the package's own code; it does not transitively scan dependencies.
This human review step covers the gap.

The current dependency surface is intentionally narrow:

- R `Imports:` — `gsDesign`, `gsDesign2`, `jsonlite`. All pure math
  / parse.
- R `Suggests:` (loaded only when explicitly invoked) — `rpact`,
  `simtrial`, `testthat`, `yaml`. None known to make outbound calls
  in our usage.
- MCP server runtime — `@modelcontextprotocol/sdk`, `zod`. Both
  inlined into the bundled `mcp-server/dist/index.js`.
