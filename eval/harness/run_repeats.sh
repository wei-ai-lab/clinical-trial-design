#!/usr/bin/env bash
# Multi-run wrapper for distributional evidence.
#
# Single-shot agent runs have substantial variance from sampling
# temperature, system-prompt drift, and tool-routing nondeterminism.
# To turn the comparison from "anecdote" to "evidence", run each
# (scenario × model) pair N times and let aggregate_scores.py report
# distributional stats (mean ± SD ± min ± max) plus a reliability
# index (consistency across the N runs).
#
# Usage:
#   bash harness/run_repeats.sh \
#       --scenario scenarios/05_gs_survival_ph_obf.yaml \
#       --model claude-opus-4-7 \
#       [--n 10]                         # default: 10 repeats
#       [--vendor claude]                # default: claude
#
#   bash harness/run_repeats.sh --all [--n 10]
#       # Iterates every scenario × every Claude model with N repeats each.
#       # Total cost: N × scenarios × models × ~$0.50/run.
#       # 10 × 11 × 3 = 330 runs ≈ $150-250 of compute, ~6-10 hours wall.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCENARIO=""
MODEL=""
VENDOR="claude"
N=10
ALL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scenario) SCENARIO="$2"; shift 2 ;;
    --model)    MODEL="$2";    shift 2 ;;
    --vendor)   VENDOR="$2";   shift 2 ;;
    --n)        N="$2";        shift 2 ;;
    --all)      ALL=true;      shift 1 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if ! [[ "$N" =~ ^[0-9]+$ ]] || [[ "$N" -lt 1 ]]; then
  echo "--n must be a positive integer (got: $N)" >&2; exit 2
fi

run_one_with_repeats() {
  local scenario="$1"; local model="$2"
  local sid; sid="$(python3 -c 'import yaml,sys; print(yaml.safe_load(open(sys.argv[1]))["id"])' "$scenario")"
  echo "[run_repeats] $sid × $model — N=$N runs"
  for i in $(seq 1 "$N"); do
    printf "  [%d/%d] " "$i" "$N"
    bash "$REPO_ROOT/eval/harness/run_one.sh" \
         --scenario "$scenario" \
         --model "$model" \
         --vendor "$VENDOR" \
      | tail -1
  done
}

if [[ "$ALL" == "true" ]]; then
  CLAUDE_MODELS=( "claude-opus-4-7" "claude-sonnet-4-6" "claude-haiku-4-5" )
  SCENARIOS=( "$REPO_ROOT/eval/scenarios/"[0-9]*.yaml )
  echo "[run_repeats] FULL SUITE: ${#SCENARIOS[@]} scenarios × ${#CLAUDE_MODELS[@]} models × $N repeats = $((${#SCENARIOS[@]} * ${#CLAUDE_MODELS[@]} * N)) runs"
  for s in "${SCENARIOS[@]}"; do
    for m in "${CLAUDE_MODELS[@]}"; do
      run_one_with_repeats "$s" "$m"
    done
  done
else
  if [[ -z "$SCENARIO" || -z "$MODEL" ]]; then
    echo "usage: $0 --scenario <yaml> --model <name> [--n 10] [--vendor claude]" >&2
    echo "       $0 --all [--n 10]    # full suite" >&2
    exit 2
  fi
  run_one_with_repeats "$SCENARIO" "$MODEL"
fi

echo "[run_repeats] done — aggregate with: python3 harness/aggregate_scores.py"
