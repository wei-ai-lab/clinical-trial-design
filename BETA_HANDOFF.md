# Beta handoff — actions you need to take

`clinical-trial-design` is at **pre-beta** as of v0.0.12 (2026-04-28). Engineering deliverables for v0.0.8 → v0.0.12 are shipped; what's left to reach the v0.5.0 beta tag is human-only work tracked here.

## Per-release: npm publish + registry resubmissions

After each tagged release, run:

```bash
cd ~/clinical-trial-design/mcp-server
npm publish --access public                       # needs your npm 2FA
mcp-publisher publish                             # MCP official registry, gated on npm-publish
npx @smithery/cli publish                          # Smithery, gated on npm-publish
```

Status of pending publishes:

| Release | Tagged | npm published | MCP registry | Smithery |
|---|---|---|---|---|
| v0.0.7 | ✅ 2026-04-26 | ⏳ pending | ⏳ pending | ⏳ pending |
| v0.0.8 | ✅ 2026-04-28 | ⏳ pending | ⏳ pending | ⏳ pending |
| v0.0.9 | ✅ 2026-04-28 | ⏳ pending | ⏳ pending | ⏳ pending |
| v0.0.10 | ✅ 2026-04-28 | ⏳ pending | ⏳ pending | ⏳ pending |
| v0.0.11 | ✅ 2026-04-28 | ⏳ pending | ⏳ pending | ⏳ pending |
| v0.0.12 | ✅ 2026-04-29 | ✅ 2026-04-29 | ✅ 2026-04-29 | deferred (see below) |

The 7 redirect-package aliases (`designr`, `phase3-trial`, `trial-design`, `sample-size-calculator`, `gsdesign-mcp`, `mcp-clinical-trial`, `study-design`) were a one-time publish at v0.0.6 and don't republish per release.

**Smithery is deferred.** Their `mcp publish` accepts HTTP-served servers or `.mcpb` bundles, not stdio-over-npm. The official MCP registry already covers our discovery surface, so Smithery is duplicative for v0.5.x. Three paths if a user asks for Smithery later: (a) web-form manual submission at smithery.ai/new, (b) build a `.mcpb` bundle, (c) add an HTTP transport shim. None are blocking the pharma-skills comparison or beta.

## v0.0.10 — LLM benchmark suite (Claude-only scope; runs deferred)

The `eval/` harness is shipped (11 scenarios, six-dimension scoring rubric, run scripts, aggregator with distributional + reliability-index reporting). Cross-vendor coverage (GPT, Gemini, open-weight) is intentionally **out of scope** — the harness preserves vendor adapter hooks but Claude is the only target for v0.0.10 so the planned pharma-skills comparison runs apples-to-apples on one model lineup.

### Recommended: distributional run (multi-run, for the pharma-skills comparison)

```bash
cd ~/clinical-trial-design
claude plugin list | grep clinical-trial-design     # confirm plugin active

# Full suite, 10 repeats per (scenario × model)
# 3 Claude models × 11 scenarios × 10 repeats = 330 runs ≈ 6-10h wall, ~$150-250
bash eval/harness/run_repeats.sh --all --n 10
python3 eval/harness/aggregate_scores.py            # writes MODEL_GUIDANCE.md
```

Output table includes:
- Composite mean ± SD ± [min, max] per model
- Per-dimension mean ± SD (across all repeats)
- **Reliability index** — within each (model × scenario), fraction of pairs of sample-size answers within ±10% of each other. 1.00 = perfectly consistent; < 0.5 = the model rolls dice on this design.

### Lower-cost alternative: single-shot

```bash
bash eval/harness/run_all.sh                        # 3 × 11 = 33 runs, ~2h, ~$15-30
python3 eval/harness/aggregate_scores.py
```

Same aggregator, same MODEL_GUIDANCE.md shape — but no SD or reliability index. Useful for a smoke pass before committing to the longer run.

### One scenario, one model (smoke check)

```bash
bash eval/harness/run_one.sh \
    --scenario eval/scenarios/01_fixed_binary_superiority.yaml \
    --model claude-opus-4-7
python3 eval/harness/score.py --run-dir <RUN_DIR_FROM_ABOVE>
```

### Cross-vendor (deferred)

Out of v0.0.10 scope. Adapter scripts for OpenAI / Gemini / Ollama are stubbed at `eval/harness/adapters/*.py`. Adding a real adapter is 1–2 hours per vendor; document as a v0.5.x or v1.0 work item if cross-vendor scores are wanted later.

## v0.0.11 — discoverability + reporting deliverables (scripts shipped)

Word + PDF reporting are SHIPPED in v0.0.11 (`design_report(format="docx")` via officer, `format="pdf"` via rmarkdown). Three downstream artifacts need a human:

1. **2-minute demo video** — Script + shot list at `docs/demo-video-script.md`. You record + upload to YouTube/Loom and paste the link into README + plugin marketplace listing.
2. **Preprint draft** — Outlined at `docs/preprint-draft.md` (~6,000 words across 8 sections). You populate Section 6 (LLM benchmark scores) once the eval suite has been run, then submit to arXiv stat.ME and consider a stat methodology venue.
3. **`awesome-claude-code` listing** — Per their CONTRIBUTING.md, web-form-only, human-only. Submit at https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml when ready.

## v0.0.12 — conference outreach (abstracts drafted)

Three talk abstracts at `docs/talk-abstracts.md` — R/Pharma (biostat audience), JSM (Statistical Computing), useR! (R community). Each frames the same work for the venue. Submit per each conference's CFP timing:

| Conference | Typical CFP deadline |
|---|---|
| R/Pharma | mid-summer (May–July) |
| JSM | early February for August conference |
| useR! | February–March for July |

Cross-plugin recommendation outreach (regulatory affairs, biomarker analysis adjacent skills) — DM-based, you decide which to reach out to. Suggested first set: any clinical-protocol skill that wraps gsDesign, the Anthropic `clinical-trial-protocol-skill` (their orchestrator could call our MCP at the sample-size step).

## v0.5.0 beta gate (your call)

When pre-beta is ready, the four gate items are explicitly your judgment:

1. **Three external biostatisticians sign-off** on real-trial output. I cannot recruit reviewers. Suggested approach: the agents-as-reviewers protocol from AGENTS.md plus targeted outreach to colleagues in the R Consortium WG / pharma biostat networks.
2. **At least one external agent-contributor PR merged.** AGENTS.md and the 5 issue templates make this discoverable; you decide when one lands cleanly enough to count.
3. **Final review of pre-beta deliverables.** I stop at v0.0.12 tagged + this file complete; you do the end-to-end review before promoting to v0.5.0.
4. **Zero open `priority:beta-blocker` issues** at the time of the v0.5.0 tag.

## Pre-beta release inventory

What shipped in v0.0.8 → v0.0.12 across the engineering surface:

| Release | Headline |
|---|---|
| v0.0.8 | 3 multi-hypothesis tools (co_primary, multi_population, graphical) + 3 benchmark families |
| v0.0.9 | reasoning_chain schema + sponsor_confidential redaction in design_report |
| v0.0.10 | eval/ benchmark harness — 11 scenarios, six-dimension scoring, MODEL_GUIDANCE.md |
| v0.0.11 | design_report(docx/pdf) + tool-description rewrite + 9-step skill orchestration + waypoints + demo-video script + preprint outline |
| v0.0.12 | release-gate CI + API_STABILITY.md + 5-trial examples gallery + talk abstracts |

Test totals as of v0.0.12: **263/263 testthat, 18/18 MCP smoke, 11 eval scenarios validate, 5 examples run end-to-end clean.**

## Open architectural decisions parked from M3+M4 eval

These came out of the comparison vs `RConsortium/pharma-skills` (documented in private `clinical-trial-design-eval` repo). Parked for v0.0.12+ — could be a v0.0.12.1 patch or roll into v0.5.0 beta polish:

- **Events anti-conservatism (~1 pp under nominal power) on `design_survival(model="ph", design_class="group-sequential")`.** Two valid event-computation paths (Schoenfeld+OBF inflation vs gsSurv internal) differ by ~3% on canonical eval issue-27. Fix: add `events_calc = c("schoenfeld","gssurv")` parameter; default to `"schoenfeld"` to match regulatory expectation.
- **`feasibility_warnings` field** on results when user-supplied operational constraints (`max_n`, `max_duration`) are violated.
- **Median ↔ hazard rate input** for survival (accept `control_hazard_rate` or `control_event_rate_py` as alternative to `control_median`).
- **NPH evaluation step** (design under PH, evaluate under NPH, report both power values) — pharma-skills' workflow gate.
- **Piecewise control hazard** for `design_survival` (currently scalar exponential only).
- **`verify_design` for NPH GS** (currently fixed binary/continuous/PH-survival and GS binary/continuous/PH-survival).

## How to use this file

This file is **not in the master plan** (master plan stays at `~/.openclaw/workspace-office-claw-1/projects/designr/MASTER_PLAN.md`, private). It's a public-facing handoff document that ships in the repo. Each release adds an entry; nothing here gets deleted — completed items get a check mark and a date.

When the user is satisfied that all four beta-gate items are met, tag v0.5.0 directly on `main` with a beta-acceptance message, push the tag, and announce on the project's discoverability surfaces (README, plugin marketplace, awesome-claude-code, MCP registry, npm).
