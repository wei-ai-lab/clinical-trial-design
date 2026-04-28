# Preprint draft outline — MCP-based agentic clinical trial design

**Working title:** *MCP-based agentic clinical trial design: a validated tool surface for biostatistical computation, with empirical LLM benchmarks*

**Target venue:** arXiv stat.ME → Statistics in Medicine or BMC Medical Research Methodology (methodology venue with biostat audience). Alternative: Journal of Open Source Software (different framing as a "tool paper").

**Lead author:** Wei Fu. **Affiliation:** wei.ai.lab.

---

## Abstract (target 250 words)

Confirmatory clinical trial design is mathematically narrow but operationally heavy: sample size and group-sequential boundary calculations are well-solved by R packages (`gsDesign`, `gsDesign2`), but translating a clinical question into the right tool, the right parameters, and a defensible deliverable still requires a senior biostatistician. Recent LLM agents are strong at the translation step but unreliable on the math: they hallucinate parameter values, mis-classify multiplicity strategies, and produce designs that do not survive simulation.

We present `clinical-trial-design`, a Claude Code plugin + Model Context Protocol (MCP) server that exposes the gsDesign / gsDesign2 / graphicalMCP design surface to LLM agents through validated, type-checked tools. The plugin ships nine tools spanning fixed-sample and group-sequential designs across binary, continuous, and time-to-event endpoints (PH and four NPH frameworks), three multi-hypothesis tools (co-primary, multi-population, graphical multiplicity), and three meta tools (Monte-Carlo verification, benchmark validator, structured Word/PDF reporting). A 176-case curated public-trial benchmark serves as the regression anchor; `R CMD check` and a 18-prompt MCP smoke matrix gate every release.

We further present an LLM-benchmarking harness that scores host LLMs across six dimensions — tool selection, parameter mapping, precedent synthesis, result interpretation, end-to-end design accuracy, and citation-trail quality — on 11 reproducible scenarios. Results indicate \[TODO once run\]. The plugin is open-source under the Apache-2.0 license.

## Sections

### 1. Introduction

- Why clinical trial design needs an MCP-shaped wrapper, not just a chat interface.
- The "validated math + LLM judgment" division of labor.
- Comparison frame: deep R packages, free-form chat, MCP-typed tools.

### 2. Related work

- `gsDesign` / `gsDesign2` (Anderson et al.) as the computational substrate.
- `RConsortium/pharma-skills` group-sequential-design skill — complementary, deep on survival GS multi-hypothesis.
- Anthropic's `clinical-trial-protocol-skill` — orchestrator for full FDA/NIH protocol drafting; sample size is one Python script. designr's MCP fits *under* their orchestrator.

### 3. Architecture

- Four-layer separation (skill, MCP server, R package, benchmark corpus).
- Stateless trust boundary: CI-gated against disk writes / network calls in the R package + MCP server.
- Operational kernel: any 0–4 of {accrual_rate, accrual_duration, follow_up_duration, total_trial_duration} solved via `accrual × duration = N`, `A + F = T`, and (for survival) uniroot over the closed-form pooled exponential-PH event probability.
- Reasoning chain schema: `{decision, value, justification, source_type, source_ref}` with a six-value enum tag.

### 4. Tool surface

- Three endpoint design tools (binary, continuous, survival) with `comparison ∈ {superiority, NI, equivalence}` and `design_class ∈ {fixed, group-sequential}` as parameters.
- Three multi-hypothesis tools (co-primary, multi-population, graphical multiplicity) with strategy enum and transition-matrix Rule-3 validator.
- Three meta tools (`validate_against_benchmark`, `verify_design`, `design_report`).

### 5. Validation

- 176-case curated public-trial benchmark corpus: schema, anchor selection, regression coverage.
- testthat assertions: 263/263 pass at v0.0.11.
- 18-prompt smoke matrix: full bundled-MCP integration test on every release.
- Same-input correctness vs `pharma-skills` on overlapping problems: boundary Z-values match to 3-4 decimals.

### 6. LLM benchmarking

- Six-dimension scoring rubric (eval/scoring.md).
- 11 curated scenarios spanning all 6 design tools and the operational kernel.
- Results across the Claude family + cross-vendor (when configured): \[TODO populate\]
- Cost/wall-time per scenario reported alongside score.

### 7. Discussion

- Where the plugin's MCP-typed boundary helps the agent vs raw R via Bash.
- Where it hurts (rare cases requiring raw gsDesign access).
- Roadmap: adaptive (SSR / enrichment / selection), MAMS, master protocols, Bayesian — corpus already covers, wrappers post-beta.

### 8. Reproducibility

- All code, scenarios, and benchmark cases in the public repo (Apache-2.0).
- Each release pinned by version; npm + MCP registry + Smithery distribution.
- Word/PDF report rendering does not require Pandoc (officer is R-native); only PDF requires Pandoc + a TeX engine.

### Acknowledgements

R Consortium, gsDesign / gsDesign2 / graphicalMCP authors, pharma-skills working group, Anthropic Claude Code team.

### References

- Anderson KM. gsDesign R package. CRAN.
- Bretz F, Maurer W, Brannath W, Posch M (2009). A graphical approach to sequentially rejective multiple test procedures. Stat Med 28:586-604.
- Schoenfeld DA (1983). Sample-size formula for the proportional-hazards regression model. Biometrics 39:499-503.
- Lan KKG, DeMets DL (1983). Discrete sequential boundaries for clinical trials. Biometrika 70:659-663.
- ICH E9 Statistical Principles for Clinical Trials (1998).
- (and the published trials cited in the curated benchmark cases — pulled per scenario)

---

## Submission notes

- ~6,000 words target, plus tables and one or two figures (architecture diagram, benchmark score chart).
- Single-author submission acceptable for a tool paper; consider co-author from the gsDesign or pharma-skills WG to broaden audience.
- arXiv pre-print first (free, indexed by Google Scholar), then journal submission.
- Upload the 176-case corpus as supplementary material (already public in the repo; cite by tag).

## To do before submission (post-tag work)

- [ ] Run the LLM benchmark suite to populate Section 6 with empirical scores.
- [ ] Generate the architecture diagram (already partially captured in `docs/architecture.md`).
- [ ] One end-to-end reproducibility example (e.g., reproduce a published CVOT design end-to-end through the agent).
- [ ] Co-author conversations: gsDesign team (Keaven Anderson), pharma-skills WG.
