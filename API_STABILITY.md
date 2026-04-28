# API stability commitments

This file documents what is **frozen** (cannot change without a major version bump per [SemVer](https://semver.org/)) and what is **flexible** (may change in any minor / patch release with a CHANGELOG entry). Effective from **v0.0.12 onward**.

The headline contract is: *"if your code (R or MCP-client) compiles against v0.0.12, it will continue to compile against every subsequent v0.x.y release until v1.0.0."*

> **Pre-1.0 caveat.** The project is below 1.0; if a frozen-field change becomes necessary before v1.0, we will bump the **minor** version (e.g., 0.0.x → 0.1.0) and document the break loudly in the CHANGELOG. The v0.0.7 schema break (10 → 3 tool collapse) is the canonical precedent for that path.

## Frozen — load-bearing across every release

### MCP tool names

The set of registered MCP tool names. Changing a tool name is an API break.

```
mcp__plugin_clinical-trial-design_clinical-trial-design__design_binary
                                                       __design_continuous
                                                       __design_survival
                                                       __design_co_primary
                                                       __design_multi_population
                                                       __design_graphical_multiplicity
                                                       __validate_against_benchmark
                                                       __verify_design
                                                       __design_report
```

### R package wire-format identifiers

These cross-version identifiers are part of the MCP-bridge contract and **must not change**:

- `ClinicalTrialDesign::designr_dispatch` (the JSON dispatcher entry point)
- `designr_input_error: <field>: <why>` error message prefix
- `DESIGNR_RSCRIPT` and `DESIGNR_LAUNCHER` env-var names

### Result JSON top-level shape

Every `design_*` result has these top-level fields (some `NULL` depending on family):

```
{
  sample_size_total,        # integer ≥ 1
  sample_size_per_arm,      # named int vector, same arm names across releases
  events_total,             # integer or null (null for non-survival)
  boundaries,               # null (fixed) | { upper_z, upper_p, … } (GS)
  timing,                   # null (fixed) | { information_fraction, events_per_analysis, … } (GS)
  operational,              # null | { given, derived, accrual_rate, accrual_duration, … }
  reasoning_chain,          # null | array of { decision, value, justification, source_type, source_ref? }
  inputs,                   # echoed parsed inputs
  method,                   # short label (e.g. "gsDesign::nSurv")
  package_version,          # backend version string
  raw                       # backend-specific extras
}
```

### Reasoning chain `source_type` enum

The six allowed values are frozen:

```
llm_precedent
fda_guidance
ich_guidance
user_supplied
package_default
sponsor_confidential
```

New values may be added in a minor release; existing values may **never** be removed or renamed.

### Schema enums

The schema enums in `benchmarks/schema/design.schema.json` are frozen — `design.comparison`, `design.endpoint.type`, `family`, multiplicity `strategy`. Additions allowed in minor releases; removals only at v1.0+.

### Error class names

The MCP error classes the bridge emits — `parse_error`, `bad_request`, `unknown_tool`, `input_error`, `r_error` — are part of the protocol and frozen.

## Flexible — may change in any release

- **Tool *descriptions*.** Optimized per release for LLM tool-routing accuracy; the prose is not part of the contract.
- **Result JSON `raw` sub-tree.** Captures backend-specific extras verbatim. No stability guarantee — its job is to surface whatever the underlying R package returned that didn't fit the canonical shape.
- **Default values** of optional parameters (e.g., `alpha = 0.025`, `power = 0.80`, `LDOF` spending). Tracked in the CHANGELOG; downstream callers should pass explicit values when stability matters.
- **Internal helpers** (any function prefixed `.` in R; any non-exported TypeScript symbol). Refactor-friendly.
- **CRAN dependency *floors*.** May rise in any release as long as the required version remains a public CRAN release. Floors are pinned in DESCRIPTION; the README's "tested against" table is informational.
- **Smoke matrix size and contents.** Number and choice of smoke prompts may change.
- **Benchmark corpus contents.** Cases may be added, refined, or moved between families. The schema is frozen; specific case YAMLs are not.

## Versioning policy through v1.0

| Change shape | Version step |
|---|---|
| Add a new MCP tool | minor (0.0.x → 0.1.0 if it changes shipped behavior, otherwise patch) |
| Add a new result top-level field | patch (existing readers ignore unknown fields) |
| Add a new optional parameter to an existing tool | patch |
| Change a default value | minor (downstream defaults shift; document loudly) |
| Remove or rename a frozen field | **v1.0+ only** — breaks every caller |
| Performance improvement or bug fix without API change | patch |

After v1.0, **frozen-field changes require a major version bump.** Pre-1.0, we reserve the right to consolidate (the v0.0.7 schema break is the precedent), but every break ships with a clear CHANGELOG entry plus a migration note.

## How to depend on this contract

- **R callers**: pin `ClinicalTrialDesign (>= 0.0.12, < 1.0.0)` in your DESCRIPTION. Treat any field outside the frozen list as best-effort.
- **MCP clients (Claude Code, custom agents)**: read tool *names* via the MCP capability negotiation. Read result fields via JSON path expressions that use the frozen names; ignore unknown fields.
- **Plugin manifest consumers**: the `mcpName` and the registered tool list are the parts you should index against.

If a future release needs to break this contract, we will document it in the CHANGELOG with a "Breaking changes" section, ship a migration guide, and bump the minor version (pre-1.0) or the major version (1.0+).
