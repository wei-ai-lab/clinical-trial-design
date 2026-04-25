# AGENTS.md — codebase tour for AI agent contributors

If you are an AI agent (Claude, GPT, Gemini, an openclaw subagent, an
opencode workflow, etc.) reading this because a user has asked you to
contribute to `designr`, this is your entry point. It explains the
codebase the way a senior contributor would walk a new colleague
through it: what each layer does, where to add a new thing, which
tests gate a change, and what is in-scope for an agent contribution
versus what needs a human reviewer.

For human contributors, [`CONTRIBUTING.md`](./CONTRIBUTING.md) is the
shorter human-facing guide; it points back here for the technical
detail. The strategic *why* behind the project's direction is
described in the public [`README.md`](./README.md) and
[`CHANGELOG.md`](./CHANGELOG.md).

## What `designr` is

A Phase 3 clinical-trial-design assistant exposed as a Claude Code
plugin. It wraps the established R packages `gsDesign`, `gsDesign2`,
and (selectively) `rpact` and `simtrial` behind a stable JSON
schema, exposes those wrappers as MCP tools, and ships a skill
prompt that orients the host LLM. The project's value comes from
four properties:

1. **Coverage.** 13 design tools spanning fixed and group-sequential
   designs across binary / continuous / TTE-PH / TTE-NPH families,
   with superiority / non-inferiority / equivalence as a parameter
   (not a separate tool).
2. **Verification.** `verify_design()` Monte Carlo gate (±2 pp power,
   ±0.5 pp Type I) cross-checks every design before it is returned
   as final.
3. **Reproducibility.** A 176-case benchmark corpus with
   machine-readable YAML cases anchored to FDA / ICH / published
   trials.
4. **Statelessness.** No persistence, no telemetry, no outbound
   network calls (CI-enforced — see [`SECURITY.md`](./SECURITY.md)).

## Repo layout

```
designr/
├── .claude-plugin/        # Claude Code plugin manifest + marketplace.json
├── .github/
│   ├── ISSUE_TEMPLATE/    # Per-task templates an agent can fill programmatically
│   └── workflows/         # CI: testthat, smoke matrix, security-grep gate
├── AGENTS.md              # ← you are here
├── CONTRIBUTING.md        # human-facing contributor guide
├── SECURITY.md            # statelessness guarantees + reporting
├── HOSTING.md             # recommended host configurations
├── CHANGELOG.md           # release-by-release history
├── README.md              # quickstart + tool surface + tested versions
├── benchmarks/            # 176-case YAML corpus + JSON schema
│   ├── schema/design.schema.json
│   ├── README.md, GLOSSARY.md, ROADMAP.md
│   └── <family>/cases/<id>.yaml + <id>.md
├── docs/
├── mcp-server/            # TypeScript MCP server (stdio transport)
│   ├── src/
│   │   ├── index.ts       # registers all 13 tools, runs stdio
│   │   ├── r-bridge.ts    # spawns Rscript per call, JSON roundtrip
│   │   └── tools/<tool-name>.ts   # one zod schema + register() per tool
│   ├── dist/index.js      # bundled (esbuild) — committed; ships in plugin
│   ├── scripts/smoke.mjs  # 13-case smoke matrix
│   └── package.json
├── r-package/designr/     # R package
│   ├── DESCRIPTION, NAMESPACE
│   ├── R/                 # one file per design wrapper + utils + cli + dispatcher
│   ├── inst/launcher.R    # sources R/ in-place; invoked by mcp-server/r-bridge
│   └── tests/testthat/    # one test file per design family
└── skills/designr/SKILL.md  # skill prompt that orients the host LLM
```

## The four layers

A user prompt flows through four layers. When you change something,
identify which layer it belongs in — most changes are pure-layer
changes; cross-layer changes are rare and need extra care.

| Layer | Where it lives | Contract |
|---|---|---|
| **Skill prompt** | `skills/designr/SKILL.md` | Tells the host LLM how to recognize trial-design intent and which MCP tool to invoke. |
| **MCP server** | `mcp-server/src/` | TypeScript + zod. One file per tool exposes a schema + `register(server)` that calls `runR(toolName, args)`. |
| **R package wrappers** | `r-package/designr/R/` | One `.R` file per design family. Each `design_*()` function validates inputs, calls the CRAN backend, and returns a normalized `designr` result list. |
| **CRAN backends** | `gsDesign`, `gsDesign2`, etc. | Established R packages we wrap. We do not modify them; we adapt their inputs and normalize their outputs. |

Stateless contract between layers: tool call args go MCP → R via JSON
on stdin; result goes back via one JSON line on stdout. One Rscript
subprocess per call. No state crosses calls.

## How to add a design wrapper

The most common agent contribution. Concrete walkthrough — adding a
hypothetical `design_fixed_count_rate` (Poisson rate-ratio fixed
design) as an example.

**1. R wrapper.** Create `r-package/designr/R/fixed_count_rate.R`.
Follow the shape of `R/fixed_binary.R`:

- Roxygen header explaining params (matches the MCP schema).
- Validate inputs using helpers in `R/utils_validate.R`
  (`check_prob`, `check_alpha`, `check_power`, etc.). Add new
  validators there if needed.
- Call the CRAN backend (`gsDesign`, `rpact`, etc.).
- Return a result list shaped by `R/utils_format.R::designr_result()`:
  `list(sample_size_total, sample_size_per_arm, events_total,
  boundaries, timing, inputs, method, package_version, raw)`.
  Fields not relevant to the family stay `NULL`.
- On bad input, call `designr_stop(field, why)` so the bridge can
  classify input errors cleanly.

**2. Register with the dispatcher.** In `R/cli.R`, add the new
function to `.tool_registry`. The dispatcher reads `{tool, args}`
from stdin and looks up the tool there.

**3. Roxygen → NAMESPACE.** Run `devtools::document()` from the
package root so the new `@export` lands in NAMESPACE.

**4. Test.** Create `tests/testthat/test-fixed-count-rate.R` with at
least one anchor test against a benchmark case (see next section).
Use `tests/testthat/helper-benchmark.R::load_case()` to load the
YAML.

**5. MCP tool.** Create `mcp-server/src/tools/fixed-count-rate.ts`.
Mirror `mcp-server/src/tools/fixed-binary.ts`:

- Zod schema for the args (use `common-schemas.ts` for shared
  fragments — `ComparisonEnum`, etc.).
- `register(server)` that registers the tool with name, description,
  schema, and a handler that calls `runR("design_fixed_count_rate",
  parsedArgs)`.

The **tool description string is critical for LLM-selection
accuracy** — write it as decision-aiding text the host LLM will read
to decide whether to invoke this tool. Bad description: "Calculates
sample size for Poisson rate ratio." Good description: "Use this
tool when the user wants Phase 3 sample size for a two-arm trial
with a count or rate primary endpoint analyzed by Poisson rate
ratio. Examples: exacerbation rate in COPD, hospitalization rate in
heart failure. Supports superiority and non-inferiority hypotheses."

**6. Register with the MCP server.** In `mcp-server/src/index.ts`,
import and call `register(server)`.

**7. Bundle.** `cd mcp-server && npm run build` regenerates
`dist/index.js`. Commit the bundled `dist/index.js` along with the
source — end users install the plugin without `npm install`.

**8. Smoke.** Add a smoke case to `mcp-server/scripts/smoke.mjs` and
`mcp-server/SMOKE.md`. Run `node mcp-server/scripts/smoke.mjs` to
confirm 14 / 14 pass.

**9. Skill prompt.** Update `skills/designr/SKILL.md` if the new
tool covers a class of clinical situations the existing tools do
not.

## How to add a benchmark anchor

The benchmark corpus is a machine-readable schema you can scan
programmatically to find gaps and propose new anchors.

**Schema:** `benchmarks/schema/design.schema.json` (JSON Schema for
the YAML case files).

**Layout:** `benchmarks/<family>/cases/<id>.yaml` (machine-readable)
+ `benchmarks/<family>/cases/<id>.md` (human-readable rationale).

**Required YAML fields:**

```yaml
id: <year>_<TRIAL_ACRONYM>_<short_descriptor>
family: fixed-superiority | fixed-non-inferiority | ... (see schema)
source:
  kind: published-trial | fda-guidance | ich-guidance | textbook | sap
  citation: "<full citation>"
  doi: "<doi>"           # if available
  url: "<url>"           # if available
design:
  indication: "<text>"
  population: "<text>"
  arms: [{name, allocation}, ...]
  endpoint: {type, description, measurement_time}
  comparison: superiority | non-inferiority | equivalence
  sidedness: 1 | 2
  alpha: <number>
  power: <number>
  effect: { ... family-specific ... }
  accrual: { ... if applicable ... }
expected:
  sample_size_total: <int>     # or events_total for TTE
  tolerance:
    sample_size_pct: <int>     # e.g. 5 = ±5%
  notes: |
    <free text>
r_packages:
  - <package::function>
tags: [...]
caveats: |
  <free text — anything that makes this case unusual>
```

The `expected.*` and `tolerance.*` blocks are what testthat anchors
read. If those are missing, the case is documentary only.

**To find gaps mechanically:** scan `benchmarks/*/cases/*.yaml` for
cases that have `r_packages` referencing a CRAN function for which we
ship no wrapper, or that test a `comparison` type our wrapper does
not yet cover. These are the highest-leverage new wrapper targets.

## Test gates

A change is mergeable when all of these pass on CI:

| Gate | What it runs |
|---|---|
| **R tests** | `cd r-package/designr && R -e 'devtools::test()'` — testthat anchors against ~20 curated benchmark cases. |
| **R CMD check** | `R -e 'devtools::check(".")'` — package metadata, NAMESPACE, examples runnable. Status OK with 0 errors / 0 warnings. |
| **MCP build** | `cd mcp-server && npm run build` — esbuild bundles to `dist/index.js`. Zero TypeScript errors. |
| **Smoke matrix** | `node mcp-server/scripts/smoke.mjs` — all current tools (13 pre-v0.0.6) return a valid result through the JSON contract. |
| **security-grep** | `.github/workflows/security-grep.yml` — fails on disk-write or outbound-network patterns in `r-package/designr/R/` or `mcp-server/src/`. See [`SECURITY.md`](./SECURITY.md). |

Run them locally before opening a PR. If a CI gate fails, fix the
underlying issue rather than disabling the gate.

## Agent-contributor protocol

Rules for agent-submitted PRs (apply to humans too, but doubly so for
agents because we cannot reach across to clarify intent in real time):

1. **One purpose per PR.** A new wrapper, *or* a benchmark case, *or*
   a bug fix. Not all three. Reviewers (human or agent) should be
   able to read the diff in five minutes.

2. **Include a test.** A new wrapper needs at least one anchor test.
   A bug fix needs a regression test that fails on the unfixed code
   and passes after the fix. No test, no merge.

3. **Cite a source for every clinical assumption.** If your
   benchmark case says `power: 0.85`, the case's `source.citation`
   must show where that 0.85 came from (the published trial or the
   FDA guidance). If you cannot cite, the case is not yet ready.

4. **Match repo conventions.** Indentation, naming, file layout — if
   you're adding `fixed_count_rate.R`, look at `fixed_binary.R` and
   match its shape. Departures from the existing pattern need
   explicit justification in the PR description.

5. **Do not invent design methodology.** `designr` wraps established
   methods from established R packages. If the calculation you want
   to add is novel, it does not belong in `designr` — it belongs in
   a peer-reviewed R package upstream first.

6. **Do not modify CRAN backends.** We wrap them; we do not patch
   them. If a CRAN backend has a bug, file the bug upstream.

7. **No telemetry, no persistence, no network calls.** The CI gate
   blocks this, but read [`SECURITY.md`](./SECURITY.md) before adding
   anything that touches I/O.

8. **No `Co-Authored-By` trailer crediting an agent or assistant on
   the commit message.** This is a project standing rule. If you are
   acting on behalf of a human contributor, the commit attribution
   is theirs.

### What is in scope for an agent contribution

- Adding a new design wrapper for a family the project plans to
  cover (check the [`MASTER_PLAN.md`](./README.md#roadmap) section in
  README's roadmap reference and the open issues).
- Adding a benchmark case for an existing family.
- Fixing a wrapper bug with a regression test.
- Improving a wrapper's input validation.
- Improving a tool's MCP description (see "tool description string
  is critical" above).
- Documentation tightening.

### What needs human review (agents: do not auto-merge)

- New CRAN dependencies (must pass dependency-review policy in
  [`SECURITY.md`](./SECURITY.md)).
- Any change to the JSON contract between MCP and R (`R/cli.R`,
  `R/utils_format.R`, `mcp-server/src/r-bridge.ts`).
- Any change to the `verify_design()` Monte Carlo tolerance
  defaults.
- Any change to the security-grep workflow or the patterns it
  enforces.
- Anything that affects the plugin manifest (`.claude-plugin/`).
- Releases (version bumps, tags, marketplace updates).

## Multi-agent notes

This project is built to be contributed to by multiple AI agents
across multiple host platforms. A few host-specific notes:

- **Claude Code (Claude Opus / Sonnet / Haiku):** the project's
  primary development host. Tool descriptions are tuned for Claude's
  selection behavior; submit improvements that broaden compatibility
  to other hosts without sacrificing Claude-side accuracy.
- **GPT / Codex agents:** read `mcp-server/src/r-bridge.ts` first to
  understand the JSON contract — many changes that look like R bugs
  are actually contract violations.
- **Gemini agents:** the `benchmarks/*/cases/*.yaml` corpus is your
  highest-leverage starting point; YAML scanning + adding anchor
  cases is well-suited to Gemini's long-context strengths.
- **openclaw / opencode subagents:** the `r-package/designr/inst/launcher.R`
  + `mcp-server/src/r-bridge.ts` pair is host-agnostic and works
  outside Claude Code today; if you find host-specific friction,
  open an issue tagged `multi-host`.

If you are reviewing another agent's PR, the bar is "would I want
this in production at a Phase 3 sponsor on the day someone has to
defend it in a regulatory meeting?" If you cannot answer yes,
request changes.

## Where to look first if you are stuck

| Symptom | First place to look |
|---|---|
| "What does the JSON contract look like?" | `r-package/designr/R/cli.R` + `mcp-server/src/r-bridge.ts` |
| "What shape should my wrapper return?" | `r-package/designr/R/utils_format.R` + an existing wrapper as template |
| "How does input validation work?" | `r-package/designr/R/utils_validate.R` |
| "How is a tool registered with MCP?" | `mcp-server/src/index.ts` + any `mcp-server/src/tools/*.ts` |
| "What does a benchmark case look like?" | `benchmarks/fixed-superiority/cases/1997_CAPTURE_abciximab.yaml` |
| "Where do I run the smoke matrix?" | `mcp-server/scripts/smoke.mjs` |
| "What guarantees does the package make about my data?" | [`SECURITY.md`](./SECURITY.md) |
| "Is my change in scope for an agent PR?" | "Agent-contributor protocol" above |

If after reading this you still are not sure where a change belongs,
open a draft PR or an issue describing what you are trying to do —
that is a faster way to get the maintainer to point at the right
file than guessing.
