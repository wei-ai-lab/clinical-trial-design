# 2-minute demo video — script + shot list

A walkthrough that takes a viewer from clean state to a SAP-ready Phase 3 design in under 2 minutes. Suitable for the README header, plugin marketplace listing, and conference talks.

## Before recording

- Clean Claude Code window (no plugins active besides this one).
- Plugin installed and visible in `claude plugin list`.
- Terminal at the project root.
- Screen resolution 1920×1080 or higher.
- One pre-recorded prompt copied to clipboard (see "Prompt 1" below).

## Shot list (target ~120 sec)

### 0:00 — 0:10 — Title card

> **clinical-trial-design**
> **A Claude Code plugin and MCP server for end-to-end clinical trial design.**
> *Phase 2 / Phase 3 confirmatory trials. Sample size, group-sequential boundaries, NPH evaluation, multi-hypothesis multiplicity, Word/PDF reporting.*

(Static title slide; voice-over reads the title and the elevator pitch.)

### 0:10 — 0:25 — Install + verify

```bash
$ claude plugin install clinical-trial-design@wei-ai-lab
$ claude plugin list | grep clinical
clinical-trial-design  0.0.11  enabled
```

Voice-over: "One install. The plugin ships with the MCP server pre-bundled and the R sources staged into the plugin cache — no `npm install`, no `install_local`."

### 0:25 — 1:00 — End-to-end design (the headline shot)

Prompt 1 (paste into Claude Code):

> *"Phase 3 oncology trial. Single primary OS endpoint, 1L metastatic disease. Median OS 11 months in control, 17 months in treatment. 2:1 randomization. Two interim analyses at 50% and 75% information time, plus the final. O'Brien-Fleming alpha-spending. 5% two-sided, 80% power. 25 patients/month accrual, 12-month minimum follow-up, 5%/year dropout. Build the design, verify it, and give me a Word report."*

Watch the agent:
1. Pick `design_survival(model="ph", design_class="group-sequential")`.
2. Print the design — events, boundaries, calendar timing.
3. Call `verify_design` — empirical power within ±2 pp.
4. Call `design_report(format="docx")` — Word file path returned.

Voice-over: "The agent picks the right tool, computes the design under the proportional-hazards log-rank model, simulates to verify, and delivers a sponsor-quality Word report. End-to-end in one conversation."

### 1:00 — 1:30 — Multi-hypothesis depth

Prompt 2 (paste):

> *"Now redesign as co-primary PFS + OS, hierarchical (PFS first, then OS). Same effect sizes; OS HR 0.65."*

Watch the agent:
1. Switch to `design_co_primary(strategy="fixed-sequence")`.
2. Both endpoints sized at full alpha=0.025. OS drives the total N.
3. The reasoning chain shows the multiplicity decision tagged `ich_guidance`.

Voice-over: "Co-primary endpoints, hierarchical alpha control. The plugin correctly preserves the full alpha on each test in the fixed-sequence — the most common multiplicity mistake an LLM would otherwise make."

### 1:30 — 1:50 — Trust boundary

Show the SECURITY.md page briefly:

> "Stateless. CI-gated. The R package and MCP server cannot write to disk or call the network — every change goes through a grep-based CI gate. Confidential trial inputs you give the agent never leave your conversation through the plugin."

### 1:50 — 2:00 — Closing

> *Try it: `claude plugin install clinical-trial-design@wei-ai-lab`*
> *github.com/wei-ai-lab/clinical-trial-design*

## Post-production notes

- Cut any pause longer than 2 seconds.
- Add a watermark in the lower-right with the version (e.g., `v0.0.11`).
- 1080p, h264, mp4, ≤ 50 MB so it embeds cleanly in GitHub READMEs.
- Upload to YouTube *and* Loom; embed both in README so users can pick.
