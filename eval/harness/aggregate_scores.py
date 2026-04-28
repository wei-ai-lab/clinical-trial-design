#!/usr/bin/env python3
"""Aggregate per-run scores into MODEL_GUIDANCE.md.

Scans all completed runs (each has a score.json), groups by model,
and writes a markdown table with composite scores, per-dimension means,
and per-scenario cost averages.

Usage:
  python3 harness/aggregate_scores.py [--run-root <path>] [--output MODEL_GUIDANCE.md]
"""

import argparse
import json
import os
import statistics
from pathlib import Path


def find_runs(run_root: Path) -> list[Path]:
    if not run_root.exists():
        return []
    return [p for p in run_root.iterdir() if p.is_dir() and (p / "score.json").exists()]


def aggregate(score_files: list[Path]) -> dict:
    by_model = {}
    for sf in score_files:
        s = json.loads((sf / "score.json").read_text())
        model = s["model"]
        by_model.setdefault(model, {
            "vendor": s["vendor"],
            "n_scenarios": 0,
            "composites": [],
            "dim_scores": {k: [] for k in s["dimensions"].keys()},
            "duration_ms": [],
            "cost_usd": [],
            "billed_units": [],
            "errors": 0,
        })
        m = by_model[model]
        m["n_scenarios"] += 1
        if s["composite"] is not None:
            m["composites"].append(s["composite"])
        for k, d in s["dimensions"].items():
            if d.get("score") is not None:
                m["dim_scores"].setdefault(k, []).append(d["score"])
        if s["metrics"].get("duration_ms"):
            m["duration_ms"].append(s["metrics"]["duration_ms"])
        if s["metrics"].get("cost_usd"):
            m["cost_usd"].append(s["metrics"]["cost_usd"])
        m["billed_units"].append(s["metrics"]["billed_units"])
        if s["metrics"].get("is_error"):
            m["errors"] += 1
    return by_model


def render(by_model: dict, n_scenarios_total: int) -> str:
    lines = []
    lines.append("# MODEL_GUIDANCE.md")
    lines.append("")
    lines.append(
        "Empirical scores for the host LLM's ability to use the "
        "`clinical-trial-design` plugin. Scenarios live under "
        "`eval/scenarios/`; rubric in `eval/scoring.md`. Scores recompute "
        "deterministically from the transcripts saved at run time — re-run "
        "`harness/aggregate_scores.py` to refresh."
    )
    lines.append("")
    if not by_model:
        lines.append("> ⏳ **No runs yet.** Run `bash eval/harness/run_all.sh` first.")
        lines.append("")
        return "\n".join(lines)
    lines.append("## Composite scores")
    lines.append("")
    lines.append(
        "| Model | Vendor | Scenarios | Composite (mean) | Errors | Mean $/scenario | Mean wall time/scenario |"
    )
    lines.append("|---|---|---|---|---|---|---|")
    for model, m in sorted(by_model.items(), key=lambda kv: -statistics.mean(kv[1]["composites"]) if kv[1]["composites"] else 0):
        comp = statistics.mean(m["composites"]) if m["composites"] else None
        cost = statistics.mean(m["cost_usd"]) if m["cost_usd"] else None
        dur = statistics.mean(m["duration_ms"]) if m["duration_ms"] else None
        lines.append(
            f"| `{model}` | {m['vendor']} | {m['n_scenarios']}/{n_scenarios_total} | "
            f"{comp:.3f if comp is not None else '—'} | {m['errors']} | "
            f"{('$%.2f' % cost) if cost is not None else '—'} | "
            f"{('%.0fs' % (dur/1000)) if dur else '—'} |"
        )
    lines.append("")
    lines.append("## Per-dimension breakdown")
    lines.append("")
    lines.append(
        "| Model | Tool sel. | Param. map | Precedent | Interpret. | End-to-end | Reasoning chain |"
    )
    lines.append("|---|---|---|---|---|---|---|")
    for model, m in sorted(by_model.items(), key=lambda kv: -statistics.mean(kv[1]["composites"]) if kv[1]["composites"] else 0):
        cells = []
        for dim in ("tool_selection", "parameter_mapping", "precedent_synthesis",
                    "result_interpretation", "end_to_end_design", "reasoning_chain"):
            scores = m["dim_scores"].get(dim, [])
            cells.append(f"{statistics.mean(scores):.2f}" if scores else "—")
        lines.append(f"| `{model}` | " + " | ".join(cells) + " |")
    lines.append("")
    lines.append("## Methodology + caveats")
    lines.append("")
    lines.append(
        "Each cell is the mean across all scenarios that scored that dimension; "
        "missing dimensions are not penalized. Composite is the mean across "
        "the per-dimension means in a row. Cost and wall time are reported "
        "verbatim from the transcript's `result` event — they're not "
        "factored into the composite score (a faster model that scores worse "
        "still scores worse)."
    )
    lines.append("")
    lines.append(
        "See `eval/scoring.md` for the full rubric and `eval/README.md` for "
        "how to extend the scenario set or add a new model adapter."
    )
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--run-root", type=Path,
                    default=Path(os.environ.get("EVAL_RUN_ROOT", "/tmp/clinical-trial-design-eval")))
    ap.add_argument("--output", type=Path, default=Path("MODEL_GUIDANCE.md"))
    ap.add_argument("--n-scenarios", type=int, default=11)
    args = ap.parse_args()

    runs = find_runs(args.run_root)
    by_model = aggregate(runs)
    md = render(by_model, args.n_scenarios)
    args.output.write_text(md)
    print(f"wrote {args.output} ({len(runs)} runs aggregated across {len(by_model)} models)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
