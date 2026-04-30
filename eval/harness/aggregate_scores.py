#!/usr/bin/env python3
"""Aggregate per-run scores into MODEL_GUIDANCE.md.

Scans all completed runs (each has a score.json), groups by (model,
scenario), and writes a markdown table with composite scores,
per-dimension means + standard deviations across repeats, cost +
duration distributional stats, and a reliability index measuring how
consistently the agent reaches the same sample-size answer across
repeats on the same scenario.

When N > 1 repeats per (scenario × model) are present, the aggregator
treats them as a distribution and reports mean ± SD ± [min, max]. With
N = 1 the SD is shown as "—" and the metric reduces to v0.0.10's
single-shot view.

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
    # First pass: bucket scores by (model, scenario) so we can compute
    # within-(model, scenario) reliability before rolling up to model.
    by_model_scenario = {}
    for sf in score_files:
        s = json.loads((sf / "score.json").read_text())
        model = s["model"]
        scen  = s["scenario"]
        key = (model, scen)
        bucket = by_model_scenario.setdefault(key, {
            "vendor": s["vendor"],
            "scores": [],     # list of full score.json payloads, one per repeat
        })
        bucket["scores"].append(s)

    # Second pass: collapse per (model, scenario), then roll up to per-model.
    for (model, scen), bucket in by_model_scenario.items():
        m = by_model.setdefault(model, {
            "vendor": bucket["vendor"],
            "n_scenarios": 0,            # distinct scenarios this model touched
            "n_repeats_total": 0,        # total runs (sum of repeats per scenario)
            "composites": [],            # one composite per (scenario × repeat)
            "dim_scores": {},            # dim_name -> list of scores across all runs
            "duration_ms": [],
            "cost_usd": [],
            "billed_units": [],
            "errors": 0,
            "reliability_per_scenario": {},  # scen -> reliability_index in [0, 1]
        })
        m["n_scenarios"] += 1
        m["n_repeats_total"] += len(bucket["scores"])

        # Within-scenario reliability index: across N repeats, what
        # fraction of pairs of sample-size totals fall within ±10%
        # of each other? (1.0 = perfectly consistent; 0.0 = wildly
        # different across runs.) Fallback to None if we don't have
        # a sample-size to compare on.
        sample_sizes = []
        for s in bucket["scores"]:
            # Walk the run-dir to find the tool result we already
            # parsed; the score JSON doesn't carry the result, so we
            # rely on the metric `sample_size` if present, else skip.
            ss = s.get("metrics", {}).get("sample_size_total")
            if ss is None:
                # Look for it under dimensions if scoring code exposed it
                dims = s.get("dimensions", {})
                e2e_note = dims.get("end_to_end_design", {}).get("note", "")
                # extract first integer from the note
                import re as _re
                mtch = _re.search(r"sample_size_total\s*=\s*(\d+)", e2e_note)
                if mtch:
                    ss = int(mtch.group(1))
            if ss is not None:
                sample_sizes.append(ss)

        rel = None
        if len(sample_sizes) >= 2:
            # Pairwise: how many (i, j) pairs have |s_i - s_j| / max(...) <= 0.10?
            n = len(sample_sizes)
            agree = 0; total = 0
            for i in range(n):
                for j in range(i + 1, n):
                    total += 1
                    a, b = sample_sizes[i], sample_sizes[j]
                    if max(a, b) > 0 and abs(a - b) / max(a, b) <= 0.10:
                        agree += 1
            rel = agree / total if total else None
        elif len(sample_sizes) == 1:
            rel = 1.0   # trivially consistent with itself
        m["reliability_per_scenario"][scen] = rel

        # Roll repeats into the model-wide pools.
        for s in bucket["scores"]:
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


def _fmt_dist(xs: list[float], unit: str = "", precision: int = 3) -> str:
    """Render a small distribution as 'mean ± SD [min, max]' or '—' if empty."""
    if not xs:
        return "—"
    if len(xs) == 1:
        return f"{xs[0]:.{precision}f}{unit}"
    mean = statistics.mean(xs)
    sd   = statistics.stdev(xs)
    return f"{mean:.{precision}f}{unit} ± {sd:.{precision}f} [{min(xs):.{precision}f}, {max(xs):.{precision}f}]"


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
        lines.append("> ⏳ **No runs yet.** Run `bash eval/harness/run_all.sh` (single-shot) or `bash eval/harness/run_repeats.sh --all --n 10` (distributional) first.")
        lines.append("")
        return "\n".join(lines)
    lines.append("## Composite scores")
    lines.append("")
    lines.append(
        "| Model | Vendor | Scenarios | Repeats / scenario | Composite (mean ± SD) | Errors | $/scenario | Wall time/scenario |"
    )
    lines.append("|---|---|---|---|---|---|---|---|")
    by_model_sorted = sorted(
        by_model.items(),
        key=lambda kv: -(statistics.mean(kv[1]["composites"]) if kv[1]["composites"] else 0),
    )
    for model, m in by_model_sorted:
        avg_repeats = m["n_repeats_total"] / max(m["n_scenarios"], 1)
        cost_str = _fmt_dist(m["cost_usd"], unit="$", precision=2) if m["cost_usd"] else "—"
        dur_secs = [d / 1000 for d in m["duration_ms"]] if m["duration_ms"] else []
        dur_str  = _fmt_dist(dur_secs, unit="s", precision=0) if dur_secs else "—"
        comp_str = _fmt_dist(m["composites"], precision=3)
        lines.append(
            f"| `{model}` | {m['vendor']} | {m['n_scenarios']}/{n_scenarios_total} | "
            f"{avg_repeats:.0f} | {comp_str} | {m['errors']} | "
            f"{cost_str} | {dur_str} |"
        )
    lines.append("")
    lines.append("## Per-dimension breakdown (mean across all runs)")
    lines.append("")
    lines.append(
        "| Model | Tool sel. | Param. map | Precedent | Interpret. | End-to-end | Reasoning chain |"
    )
    lines.append("|---|---|---|---|---|---|---|")
    for model, m in by_model_sorted:
        cells = []
        for dim in ("tool_selection", "parameter_mapping", "precedent_synthesis",
                    "result_interpretation", "end_to_end_design", "reasoning_chain"):
            scores = m["dim_scores"].get(dim, [])
            if scores:
                if len(scores) > 1:
                    cells.append(f"{statistics.mean(scores):.2f} ± {statistics.stdev(scores):.2f}")
                else:
                    cells.append(f"{scores[0]:.2f}")
            else:
                cells.append("—")
        lines.append(f"| `{model}` | " + " | ".join(cells) + " |")
    lines.append("")
    lines.append("## Reliability index (sample-size consistency across repeats)")
    lines.append("")
    lines.append(
        "Within each (model, scenario) cell with N > 1 repeats, the reliability "
        "index is the fraction of pairs of sample-size results within ±10% of "
        "each other. 1.00 = perfectly consistent across repeats; 0.00 = the "
        "agent rolls dice. Useful for detecting model snapshots that produce "
        "correct designs only some of the time."
    )
    lines.append("")
    lines.append("| Model | Scenarios with reliability ≥ 0.9 | Mean reliability across scenarios |")
    lines.append("|---|---|---|")
    for model, m in by_model_sorted:
        rels = [v for v in m["reliability_per_scenario"].values() if v is not None]
        n_high = sum(1 for v in rels if v >= 0.9)
        mean_rel = statistics.mean(rels) if rels else None
        lines.append(
            f"| `{model}` | {n_high}/{len(rels)} | "
            f"{(f'{mean_rel:.2f}' if mean_rel is not None else '—')} |"
        )
    lines.append("")
    lines.append("## Methodology + caveats")
    lines.append("")
    lines.append(
        "Each composite cell is `mean ± SD [min, max]` across all (scenario × "
        "repeat) runs the model completed. Per-dimension cells use "
        "`mean ± SD` across the same pool when N > 1; with N = 1 only the "
        "mean is shown. Cost and wall time are reported verbatim from the "
        "transcript's `result` event — they're not factored into the "
        "composite score (a faster model that scores worse still scores "
        "worse). Reliability index is computed within (model, scenario) and "
        "then averaged across scenarios."
    )
    lines.append("")
    lines.append(
        "Single-shot mode (N=1) approximates v0.0.10 behavior; distributional "
        "mode (N≥10) is recommended for the pharma-skills comparison so cost "
        "and score variance are visible."
    )
    lines.append("")
    lines.append(
        "See `eval/scoring.md` for the full rubric and `eval/README.md` for "
        "how to extend the scenario set."
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
