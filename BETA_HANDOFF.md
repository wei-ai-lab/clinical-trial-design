# Beta handoff — actions you need to take

This file tracks the human-only actions accumulating across v0.0.8 → v0.0.12. The autonomous loop ships engineering deliverables; everything below requires your credentials, your judgment, or external counterparties. Updated continuously as releases ship.

## Per-release: npm publish + registry resubmissions

Each minor release needs two manual steps after the git tag is pushed:

```bash
cd ~/clinical-trial-design/mcp-server
npm publish --access public                       # needs your npm 2FA
mcp-publisher publish                             # MCP official registry, gated on npm-publish
npx @smithery/cli publish                          # Smithery, gated on npm-publish
```

Status of pending publishes (oldest first — release ceremony was paused at v0.0.7 for the M3+M4 evaluation work; resumes at v0.0.8 ship):

| Release | Tagged | npm published | MCP registry | Smithery |
|---|---|---|---|---|
| v0.0.7 | ✅ 2026-04-26 | ⏳ pending | ⏳ pending | ⏳ pending |
| v0.0.8 | ✅ 2026-04-28 | ⏳ pending | ⏳ pending | ⏳ pending |
| v0.0.9 | ✅ 2026-04-28 | ⏳ pending | ⏳ pending | ⏳ pending |
| v0.0.10 | ⏳ in-flight | ⏳ pending | ⏳ pending | ⏳ pending |
| v0.0.11 | not tagged | — | — | — |
| v0.0.12 | not tagged | — | — | — |

The 7 redirect-package aliases (`designr`, `phase3-trial`, `trial-design`, `sample-size-calculator`, `gsdesign-mcp`, `mcp-clinical-trial`, `study-design`) were a one-time publish at v0.0.6 and don't need re-publishing.

## v0.0.10 — LLM benchmark suite (eval/ shipped, runs deferred)

The `eval/` harness is shipped (scenarios, scoring rubric, run scripts, aggregator). The first end-to-end run requires you to drive the harness — I cannot exercise `claude -p` non-interactively from inside another Claude session. To populate `MODEL_GUIDANCE.md`:

```bash
cd ~/clinical-trial-design

# Confirm the plugin is in your default Claude profile
claude plugin list | grep clinical-trial-design

# Optional: cross-vendor coverage (Claude is the default)
export OPENAI_API_KEY="..."             # GPT-5 / o-series
export GEMINI_API_KEY="..."             # Gemini 2.x or 3.x
export OLLAMA_BASE_URL="http://localhost:11434"  # local Llama-3.x or Qwen

# Full suite (3 Claude models × 11 scenarios = ~2 hours, ~$10-30)
bash eval/harness/run_all.sh
python3 eval/harness/aggregate_scores.py    # rewrites MODEL_GUIDANCE.md

# Or one scenario × one model (~3-5 min, ~$0.50)
bash eval/harness/run_one.sh \
    --scenario eval/scenarios/01_fixed_binary_superiority.yaml \
    --model claude-opus-4-7
python3 eval/harness/score.py --run-dir <RUN_DIR_FROM_ABOVE>
```

Adapter scripts for OpenAI / Gemini / Ollama are stubbed at `eval/harness/adapters/*.py` (per-vendor, not yet implemented). Without them the suite skips those vendors gracefully and writes a note in `MODEL_GUIDANCE.md`. If you want cross-vendor coverage before beta, the adapters are a 1-2 hour lift each.

## v0.0.11 — discoverability + reporting deliverables

Three artifacts that need a human:

1. **2-minute demo video** — I'll prepare a script + recording shot list (`docs/demo-video-script.md`). You record + upload to YouTube/Loom and paste the link into README + plugin marketplace listing.
2. **Preprint draft** — I'll draft `docs/preprint/preprint-draft.md` using the benchmark corpus + LLM benchmark scores. You review → submit to arXiv stat.ME or a stat methodology venue.
3. **`awesome-claude-code` listing** — Per their CONTRIBUTING.md, web-form-only, human-only. Submit at https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml when v0.0.11 ships.

## v0.0.12 — conference outreach

I'll draft talk abstracts for R/Pharma, JSM, useR! covering the MCP-as-trial-design-interface + benchmark methodology. You review and submit per each conference's CFP deadline (these are real-world dates — flag if any are about to expire).

Cross-plugin recommendation outreach (regulatory affairs, biomarker analysis adjacent skills) — I'll write a list of candidate skills/plugins to reach out to. You DM their maintainers.

## v0.5.0 beta gate (your call)

When pre-beta is ready, the four gate items are explicitly your judgment:

1. **Three external biostatisticians sign-off** on real-trial output. I cannot recruit reviewers. Suggested approach: the agents-as-reviewers protocol from AGENTS.md plus targeted outreach to colleagues in the R Consortium WG / pharma biostat networks.
2. **At least one external agent-contributor PR merged.** AGENTS.md and the 5 issue templates make this discoverable; you decide when one lands cleanly enough to count.
3. **Final review of pre-beta deliverables.** I stop at v0.0.12 tagged + this file complete; you do the end-to-end review before promoting to v0.5.0.
4. **Zero open `priority:beta-blocker` issues** at the time of the v0.5.0 tag.

## Open architectural decisions parked from M3+M4 eval

These came out of the comparison vs `RConsortium/pharma-skills` (documented in private `clinical-trial-design-eval` repo). They are NOT v0.0.8 scope — they're parked for a future release window:

- **Events anti-conservatism (~1 pp under nominal power) on `design_survival(model="ph", design_class="group-sequential")`.** Two valid event-computation paths (Schoenfeld+OBF inflation vs gsSurv internal) differ by ~3% on canonical eval issue-27. Fix: add `events_calc = c("schoenfeld","gssurv")` parameter; default to `"schoenfeld"` to match regulatory expectation.
- **`feasibility_warnings` field** on results when user-supplied operational constraints (`max_n`, `max_duration`) are violated.
- **Median ↔ hazard rate input** for survival (accept `control_hazard_rate` or `control_event_rate_py` as alternative to `control_median`).
- **Word reporter `design_report(format="docx")`** via `officer`. Already scheduled v0.0.11.
- **NPH evaluation step** (design under PH, evaluate under NPH, report both power values).
- **Piecewise control hazard** for `design_survival` (currently scalar exponential only).
- **`verify_design` for NPH GS** (currently fixed binary/continuous/PH-survival and GS binary/continuous/PH-survival).

These could be bundled into a v0.0.8.1 patch or pulled into v0.0.9 — your call.

## How to use this file

This file is **not in the master plan** (master plan stays at `~/.openclaw/workspace-office-claw-1/projects/designr/MASTER_PLAN.md`, private). It's a public-facing handoff document that ships in the repo. Each release adds an entry; nothing here gets deleted — completed items get a check mark and a date.
