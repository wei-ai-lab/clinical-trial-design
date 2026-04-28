#!/usr/bin/env python3
"""Score a single eval run against its scenario.

Reads:
  <run-dir>/scenario.yaml      (frozen at run time)
  <run-dir>/transcript.jsonl   (stream-json from claude -p or vendor adapter)
  <run-dir>/meta.json          (model, vendor, scenario id)

Writes:
  <run-dir>/score.json         (per-dimension scores + composite + metrics)

The six scoring dimensions are documented in eval/scoring.md. Dimensions
that the scenario does not specify are dropped from the composite mean
(not scored as 0).

Token / duration metrics are extracted from the transcript's `result`
event verbatim and reported alongside the score so MODEL_GUIDANCE.md
can show "model X scored 0.85 at $0.42 per scenario" tradeoffs.
"""

import argparse
import json
import re
import sys
from pathlib import Path

import yaml

# --- transcript parsing ----------------------------------------------------

def parse_transcript(jsonl_path: Path) -> dict:
    """Extract tool calls, narrative text, and usage metrics."""
    out = {
        "tool_calls": [],          # list of {name, input}
        "narrative": "",           # concatenated assistant text blocks
        "tokens_input": 0, "tokens_output": 0,
        "tokens_cache_creation": 0, "tokens_cache_read": 0,
        "duration_ms": None, "cost_usd": None, "is_error": False,
        "num_turns": 0,
        "raw_lines": 0,
    }
    if not jsonl_path.exists():
        out["is_error"] = True
        return out
    for line in jsonl_path.read_text().splitlines():
        if not line.strip():
            continue
        out["raw_lines"] += 1
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        et = ev.get("type")
        if et == "assistant":
            out["num_turns"] += 1
            for blk in ev.get("message", {}).get("content", []) or []:
                if not isinstance(blk, dict):
                    continue
                if blk.get("type") == "tool_use":
                    out["tool_calls"].append({
                        "name": blk.get("name"),
                        "input": blk.get("input", {}),
                    })
                elif blk.get("type") == "text":
                    out["narrative"] += blk.get("text", "") + "\n"
        elif et == "result":
            usage = ev.get("usage", {}) or {}
            out["tokens_input"]          = usage.get("input_tokens", 0)
            out["tokens_output"]         = usage.get("output_tokens", 0)
            out["tokens_cache_creation"] = usage.get("cache_creation_input_tokens", 0)
            out["tokens_cache_read"]     = usage.get("cache_read_input_tokens", 0)
            out["duration_ms"]           = ev.get("duration_ms")
            out["cost_usd"]              = ev.get("total_cost_usd", ev.get("cost_usd"))
            out["is_error"]              = bool(ev.get("is_error", False))
            # If the agent already emitted assistant turns, num_turns is set
            # from there; otherwise use the result's count
            if not out["num_turns"]:
                out["num_turns"] = ev.get("num_turns", 0)
    return out


# --- per-dimension scoring -------------------------------------------------

def score_tool_selection(parsed, expected):
    expected_tool = expected["expected"]["tool"]
    # Match against the basename of the MCP tool name.
    invoked = []
    for tc in parsed["tool_calls"]:
        n = tc["name"] or ""
        # e.g. mcp__plugin_clinical-trial-design_clinical-trial-design__design_survival
        m = re.match(r".*__([a-zA-Z_]+)$", n)
        invoked.append(m.group(1) if m else n)

    if not invoked:
        return 0.0, "no MCP design tool invoked"
    if expected_tool in invoked:
        return 1.0, f"invoked {expected_tool}"
    # Partial credit for related design tool
    related = {expected_tool} | _related_tools(expected_tool)
    if any(t in related for t in invoked):
        return 0.5, f"invoked related tool {invoked[0]} (expected {expected_tool})"
    return 0.0, f"invoked {invoked[0]}, expected {expected_tool}"


def _related_tools(tool: str) -> set:
    families = [
        {"design_binary", "design_continuous", "design_survival"},
        {"design_co_primary", "design_multi_population", "design_graphical_multiplicity"},
    ]
    for f in families:
        if tool in f:
            return f - {tool}
    return set()


def score_parameter_mapping(parsed, expected):
    if "parameters" not in expected.get("expected", {}):
        return None, "no parameters expected"
    expected_tool = expected["expected"]["tool"]
    matching = [tc for tc in parsed["tool_calls"]
                if (tc["name"] or "").endswith("__" + expected_tool)]
    if not matching:
        return 0.0, f"no call to {expected_tool} to inspect"
    invoked = matching[0]["input"]
    expected_params = expected["expected"]["parameters"]
    scores = []
    notes = []
    for k, v in expected_params.items():
        actual = invoked.get(k)
        if isinstance(v, dict) and "range" in v:
            lo, hi = v["range"]
            if actual is not None and lo <= actual <= hi:
                scores.append(1.0)
            elif actual is not None and lo * 0.8 <= actual <= hi * 1.2:
                scores.append(0.5)
                notes.append(f"{k}={actual} outside [{lo},{hi}]")
            else:
                scores.append(0.0)
                notes.append(f"{k}={actual} far from [{lo},{hi}]")
        elif isinstance(v, (int, float)):
            if actual == v:
                scores.append(1.0)
            elif actual is not None and abs(actual - v) / max(abs(v), 1e-9) < 0.20:
                scores.append(0.5)
                notes.append(f"{k}={actual} ~{v}")
            else:
                scores.append(0.0)
                notes.append(f"{k}={actual} (expected {v})")
        else:
            if actual == v:
                scores.append(1.0)
            else:
                scores.append(0.0)
                notes.append(f"{k}={actual} (expected {v})")
    avg = sum(scores) / len(scores) if scores else None
    return avg, "; ".join(notes) if notes else "all parameters matched"


def score_precedent_synthesis(parsed, expected):
    precedents = expected.get("expected", {}).get("precedents") or []
    if not precedents:
        return None, "no precedents listed"
    # Substring match on narrative — LLM-judge would be richer but this is
    # a deterministic floor-score that doesn't require an extra API call.
    narr = parsed["narrative"].lower()
    hits = [p for p in precedents if p.lower() in narr]
    if not hits:
        return 0.0, "no precedent cited"
    return 1.0 if len(hits) >= 1 else 0.5, f"cited: {','.join(hits)}"


def score_result_interpretation(parsed, expected):
    keys = expected.get("expected", {}).get("interpretation_keys") or []
    if not keys:
        return None, "no interpretation_keys listed"
    narr = parsed["narrative"].lower()
    hits = sum(1 for k in keys if k.lower() in narr)
    return hits / len(keys), f"{hits}/{len(keys)} keys present"


def score_end_to_end(parsed, expected):
    rc = expected.get("expected", {}).get("result_check")
    if not rc:
        return None, "no result_check"
    expected_tool = expected["expected"]["tool"]
    # Heuristic: scan tool_results for a JSON object containing the
    # expected_tool's typical output shape. If the agent didn't run the
    # tool, this dimension scores 0.
    tr_text = ""
    for line in (parsed.get("_raw_jsonl") or []):
        pass  # handled at top-level; see below
    # We look for the tool_result content blocks in the transcript,
    # which aren't captured by parse_transcript above. Re-parse here.
    # (To keep score.py self-contained we re-read the transcript file.)
    return None, "result_check parsing requires the run-dir; see score.py.score_end_to_end_v2"


def score_end_to_end_v2(run_dir: Path, expected):
    """Read the transcript and inspect tool_result blocks for the expected_tool.
    Score against expected.result_check (range / abs_tol)."""
    rc = expected.get("expected", {}).get("result_check")
    if not rc:
        return None, "no result_check"
    expected_tool = expected["expected"]["tool"]
    transcript_path = run_dir / "transcript.jsonl"
    if not transcript_path.exists():
        return 0.0, "no transcript"
    last_result = None
    for line in transcript_path.read_text().splitlines():
        if not line.strip():
            continue
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        if ev.get("type") != "user":
            continue
        msg = ev.get("message", {})
        for blk in msg.get("content", []) or []:
            if not isinstance(blk, dict):
                continue
            if blk.get("type") == "tool_result":
                # The MCP server returns its result as a text content block
                # of JSON.
                contents = blk.get("content", [])
                if isinstance(contents, list):
                    for c in contents:
                        if isinstance(c, dict) and c.get("type") == "text":
                            txt = c.get("text", "")
                            try:
                                parsed = json.loads(txt)
                                last_result = parsed
                            except json.JSONDecodeError:
                                pass
    if last_result is None:
        return 0.0, "no tool_result with parseable JSON"
    scores = []
    notes = []
    for k, spec in rc.items():
        actual = last_result.get(k)
        if k == "boundaries":
            # Special: spec may contain abs_tol checks
            for sub_k, sub_spec in (spec or {}).items():
                if sub_k == "upper_z_first":
                    boundaries = (last_result.get("boundaries") or {})
                    z = boundaries.get("upper_z")
                    if isinstance(z, list) and z:
                        diff = abs(z[0] - sub_spec["expected"])
                        scores.append(1.0 if diff <= sub_spec["abs_tol"] else 0.0)
                        notes.append(f"boundary_z[0]={z[0]:.3f} (expected {sub_spec['expected']})")
                    else:
                        scores.append(0.0)
                        notes.append("boundaries missing")
            continue
        if isinstance(spec, dict) and "range" in spec:
            lo, hi = spec["range"]
            if isinstance(actual, (int, float)) and lo <= actual <= hi:
                scores.append(1.0)
            elif isinstance(actual, (int, float)) and lo * 0.5 <= actual <= hi * 1.5:
                scores.append(0.5)
                notes.append(f"{k}={actual} outside [{lo},{hi}]")
            else:
                scores.append(0.0)
                notes.append(f"{k}={actual} (expected [{lo},{hi}])")
        elif isinstance(spec, str):
            # e.g. driver: "OS"
            actual_driver = (last_result.get("raw") or {}).get("driver") or actual
            scores.append(1.0 if actual_driver == spec else 0.0)
            if actual_driver != spec:
                notes.append(f"{k}={actual_driver} (expected {spec})")
    avg = sum(scores) / len(scores) if scores else None
    return avg, "; ".join(notes) if notes else "all result checks matched"


def score_reasoning_chain(parsed, expected):
    rc_spec = expected.get("expected", {}).get("reasoning_chain")
    if not rc_spec:
        return None, "no reasoning_chain expectation"
    # Find the agent's invocation params for the expected tool
    expected_tool = expected["expected"]["tool"]
    matching = [tc for tc in parsed["tool_calls"]
                if (tc["name"] or "").endswith("__" + expected_tool)]
    rc = []
    if matching:
        rc = matching[0]["input"].get("reasoning_chain") or []
    must_have = rc_spec.get("must_have_source_types", [])
    # Hard-zero if reasoning_chain is required by the scenario's
    # parameters_required list and is empty.
    required = expected.get("expected", {}).get("parameters_required") or []
    if "reasoning_chain" in required and not rc:
        return 0.0, "reasoning_chain required but absent"
    if not must_have:
        # No required source_types; skip if chain absent, otherwise full credit
        return (1.0 if rc else None), \
               (f"chain has {len(rc)} entries" if rc else "no chain")
    present = {e.get("source_type") for e in rc if isinstance(e, dict)}
    hits = sum(1 for s in must_have if s in present)
    return hits / len(must_have), \
           f"{hits}/{len(must_have)} required source_types present"


# --- composite + I/O -------------------------------------------------------

def score_run(run_dir: Path) -> dict:
    scenario = yaml.safe_load((run_dir / "scenario.yaml").read_text())
    parsed   = parse_transcript(run_dir / "transcript.jsonl")
    meta     = json.loads((run_dir / "meta.json").read_text())

    dims = {}
    dims["tool_selection"]        = score_tool_selection(parsed, scenario)
    dims["parameter_mapping"]     = score_parameter_mapping(parsed, scenario)
    dims["precedent_synthesis"]   = score_precedent_synthesis(parsed, scenario)
    dims["result_interpretation"] = score_result_interpretation(parsed, scenario)
    dims["end_to_end_design"]     = score_end_to_end_v2(run_dir, scenario)
    dims["reasoning_chain"]       = score_reasoning_chain(parsed, scenario)

    scored = [(k, v[0]) for k, v in dims.items() if v[0] is not None]
    composite = (sum(s for _, s in scored) / len(scored)) if scored else None

    out = {
        "scenario": scenario["id"],
        "model":    meta.get("model"),
        "vendor":   meta.get("vendor"),
        "dimensions": {
            k: {"score": v[0], "note": v[1]} for k, v in dims.items()
        },
        "composite": composite,
        "metrics": {
            "duration_ms":           parsed["duration_ms"],
            "tokens_input":          parsed["tokens_input"],
            "tokens_output":         parsed["tokens_output"],
            "tokens_cache_creation": parsed["tokens_cache_creation"],
            "tokens_cache_read":     parsed["tokens_cache_read"],
            "billed_units":
                parsed["tokens_input"]
                + 5.0  * parsed["tokens_output"]
                + 1.25 * parsed["tokens_cache_creation"]
                + 0.10 * parsed["tokens_cache_read"],
            "cost_usd":   parsed["cost_usd"],
            "num_turns":  parsed["num_turns"],
            "is_error":   parsed["is_error"],
        },
    }
    (run_dir / "score.json").write_text(json.dumps(out, indent=2))
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--run-dir", required=True, type=Path)
    args = ap.parse_args()
    out = score_run(args.run_dir)
    print(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
