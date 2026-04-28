# Conference talk abstracts — drafts for v0.0.12 / pre-beta

Three talks targeting the biostatistics, R, and ML/agents communities. All three describe the same underlying work; the framing differs by audience. Submit when each conference's CFP opens (deadlines vary).

---

## R/Pharma 2026 — biostatistics audience

**Title:** *MCP-based clinical trial design: validated R wrappers for LLM agents that an FDA reviewer can read*

**Format:** 20-min regular talk; alternative 5-min lightning talk.

**Submitter:** Wei Fu — wei.ai.lab.

**Abstract** (~200 words):

R-based trial-design packages — `gsDesign`, `gsDesign2`, `graphicalMCP` — solve the math that biostatisticians need for confirmatory Phase 3 trials. Surfacing those packages to LLM agents has been done by skill collections (`RConsortium/pharma-skills`) and chat workflows, but agents still hallucinate parameters, mis-classify multiplicity strategies, and produce designs that fail simulation.

`clinical-trial-design` is a Claude Code plugin and Model Context Protocol (MCP) server that exposes a small, validated tool surface across the gsDesign / gsDesign2 / graphicalMCP backends. It ships nine MCP tools: three endpoint-design tools (binary, continuous, survival with PH and four NPH frameworks), three multi-hypothesis tools (co-primary, multi-population, graphical multiplicity with Maurer-Bretz alpha recycling), and three meta tools (Monte-Carlo verification, benchmark validator, structured Word/PDF reporting).

Every tool call returns a unified result shape, validates inputs at the boundary, and supports a structured `reasoning_chain` field so each design assumption carries a `source_type` tag (LLM precedent, FDA / ICH guidance, user-supplied, sponsor-confidential). A 176-case curated benchmark corpus + testthat regression gate + 18-prompt MCP smoke matrix gate every release.

I'll demo end-to-end design of a published Phase 3 trial in five minutes, walk through the multi-hypothesis tool surface, and show the Word output that lands in the sponsor's review packet — produced from the same conversation, no extra tooling.

**Take-home:** the validated-tools-vs-free-form-chat split is the next maturity step for agentic trial design.

---

## JSM 2026 — Statistical Computing / Statistics in Healthcare audience

**Title:** *Validated tool boundaries for LLM agents in confirmatory clinical trial design: an empirical evaluation*

**Format:** Contributed paper, 15 min + Q&A. Section: Statistical Computing or Health Policy Statistics.

**Abstract** (~200 words):

LLM agents are being deployed for biostatistical computation, but published evaluations of their accuracy on confirmatory trial design are rare. We present an empirical eval framework that scores LLM agents on six dimensions — tool selection, parameter mapping, precedent synthesis, result interpretation, end-to-end design accuracy, and citation-trail quality — across 11 reproducible scenarios spanning fixed-sample and group-sequential designs in binary, continuous, and time-to-event endpoints (PH and four NPH frameworks), plus three multi-hypothesis patterns (co-primary, multi-population, graphical multiplicity).

The framework targets a Model Context Protocol (MCP) plugin we developed, `clinical-trial-design`, which wraps gsDesign / gsDesign2 / graphicalMCP under typed tool boundaries. We report scores across the Claude family (Opus, Sonnet, Haiku) and \[other vendors when configured\]. We compare against two baselines: (a) raw R via Bash with no skill, (b) a comparably-positioned skill collection (`RConsortium/pharma-skills`).

Headline empirical findings (issue-27 anchor): boundary Z-values match published expected to 3-4 decimals across all arms; the MCP-typed wrapper is ~18× cheaper in billed tokens than skill-only on the same task while producing the same statistical answer; deliverable shape (Word + multiplicity diagram + simulation log) is the workflow gap, not statistical correctness.

We'll discuss methodological caveats (LLM-judge dimensions, prompt under-specification) and the implications for sponsor adoption.

**Keywords:** clinical trials, group sequential, MCP, LLM, benchmark.

---

## useR! 2026 — R community audience

**Title:** *clinical-trial-design: a Claude Code plugin for end-to-end Phase 3 trial design from a conversational interface*

**Format:** Regular talk, 20 min. Alternative: tutorial, 90 min.

**Abstract** (~150 words):

`clinical-trial-design` is a Claude Code plugin + MCP server that lets a biostatistician design a Phase 2/3 confirmatory trial through a conversation, backed by validated R packages (`gsDesign`, `gsDesign2`, `graphicalMCP`). The plugin ships nine MCP tools spanning fixed-sample / group-sequential designs across binary, continuous, and time-to-event endpoints (proportional and non-proportional hazards), three multi-hypothesis tools (co-primary, multi-population, graphical multiplicity with Maurer-Bretz alpha recycling), and three meta tools (Monte-Carlo verification, benchmark validator, structured Word/PDF reporting via `officer` / `rmarkdown`).

The talk will cover: the R package architecture and stateless trust boundary; the operational solver for `accrual × duration = N` and survival event-tied uniroot; the unified result schema and reasoning-chain citation trail; the curated 176-case public-trial benchmark corpus; and a live demo of designing a published trial end-to-end, including a Word deliverable for the sponsor.

Open-source on GitHub: github.com/wei-ai-lab/clinical-trial-design (Apache-2.0).

---

## How and when to submit

| Conference | Typical CFP deadline | Submit at |
|---|---|---|
| R/Pharma | mid-summer (May–July) | https://rinpharma.com |
| JSM | early February for August conference | https://ww2.amstat.org/meetings/jsm/ |
| useR! | February–March for July | https://user2026.r-project.org/ (TBD) |

Add to BETA_HANDOFF.md once each is submitted; remove from "to do" once accepted or declined.
