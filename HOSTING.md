# Hosting `clinical-trial-design`

`clinical-trial-design` is a stateless plugin (see [`SECURITY.md`](./SECURITY.md)),
which means **the host you run it inside determines your overall
data-handling posture**, not the plugin itself.

This document gives recommended host configurations for two common
user profiles. The same `clinical-trial-design` build serves both — no
plugin-side configuration changes between them.

## Profile A — individual researcher / small company

**Typical use case:** exploring trial design options with public
information, drafting designs against published precedents, learning
the tooling.

**Recommended host:** Claude Code (public, default install) on a
managed laptop.

**Configuration notes:**

- Default Claude Code transcript retention is local
  (`~/.claude/projects/<workspace>/...`). Inputs and outputs of MCP
  tool calls land there. This is a feature for individual users
  (you can review your own design history); be aware of it if you
  share the laptop or sync that directory.
- Anthropic's API processes your prompts under their standard
  data-handling terms. If your inputs include any sponsor-confidential
  information, switch to Profile B before doing the work.
- Web search (used by the LLM to find precedent trials and FDA
  guidance) goes out over the public internet. This is normal and
  desirable for public-information work.

**What `clinical-trial-design` does in this profile:** receives JSON tool calls,
spawns Rscript, returns JSON. No local writes, no network calls
from the plugin itself.

## Profile B — large enterprise (pharma sponsor, hospital system, CRO)

**Typical use case:** designing a real confirmatory trial (Phase 2 or
Phase 3) that involves sponsor-confidential inputs (internal Phase 2
readouts, pipeline assumptions, prior-compound effect estimates,
business deadlines) and requires a cross-functional decision audit
trail.

**Recommended host:** Claude Code Enterprise on AWS Bedrock (or
equivalent on Azure with Anthropic-on-Azure, or on Google Cloud)
with the following posture:

- **Private endpoint.** Bedrock private endpoint or VPC peering — no
  prompt data leaves your network boundary.
- **Zero-data-retention agreement** with the LLM provider, if
  available under your contract.
- **Corporate transcript retention enabled.** This becomes your
  trial-design audit log: every tool call's inputs (the assumptions
  the agent made, the precedents the LLM cited, the user overrides
  applied) and outputs (the resulting design + reasoning chain) are
  persisted in a corporate-owned location with your normal IAM /
  RBAC controls.
- **Standard enterprise IAM.** Restrict who can invoke the plugin
  to the trial-design working group.
- **Network egress controls.** Block outbound traffic from the
  workstation running Claude Code except to the corporate Bedrock
  endpoint and the corporate code repository. The plugin itself
  makes no outbound calls; this lock-down protects against
  whatever else the host might attempt.

**What `clinical-trial-design` does in this profile:** identical to Profile A —
receives JSON tool calls, spawns Rscript, returns JSON. The
plugin's stateless behavior is the property that lets the host
control the rest cleanly.

**Why persistence is a feature here, not a leak:** confirmatory trial
design is a months-long cross-functional process. Statistician,
clinical lead, regulatory affairs, operations, and leadership each
review and revise the design over multiple sessions. The persisted
transcript — including every tool call's inputs and outputs — is
the audit log of *why* the design landed where it did. The
v0.0.9 reasoning-chain schema makes that audit log structured
rather than free-text: each assumption carries a `source_type` tag
(LLM-precedent, FDA-guidance, user-supplied, sponsor-confidential,
package-default) and a `source_ref` (paper, guidance doc, or
internal reference).

## Profile C (forthcoming) — air-gapped deployment

For sponsors who require fully offline operation:

- Local LLM (Llama-3.x, Qwen, or DeepSeek deployed on-prem).
- Claude Code or an alternative MCP-capable host pointed at the local
  LLM.
- `clinical-trial-design` plugin installed from a local mirror.
- All R / Node dependencies pre-cached in an internal repository.

This profile is technically supported today (the plugin is fully
stateless and makes no outbound calls), but is not yet documented
end-to-end. We expect to ship a worked example by v0.0.11.
Contributions welcome — see [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Multi-host support

`clinical-trial-design` is currently shipped as a Claude Code plugin.
The R package and MCP server are host-agnostic; the plugin manifest,
skill prompt, and install / update flow are host-specific. Per-host
adapters (openclaw, opencode, Cursor) are scheduled for v0.6.0.

Until then, advanced users can invoke the MCP server directly from
any MCP-capable host by pointing at
`r-package/ClinicalTrialDesign/inst/launcher.R` (see the bridge code in
`mcp-server/src/r-bridge.ts` for the JSON contract).
