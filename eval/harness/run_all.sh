#!/usr/bin/env bash
# Run every scenario × every Claude model. The Claude family is the
# canonical comparator for v0.0.10 — we measure how `clinical-trial-design`
# performs against pharma-skills with the host model held constant
# across the Claude generation lineup. Cross-vendor (GPT, Gemini,
# open-weight) is documented as future work but intentionally out of
# scope here so the pharma-skills comparison runs apples-to-apples.
#
# Usage:
#   bash harness/run_all.sh
#
# Each (scenario × model) combination becomes one (~3-5 min) claude -p
# session, so the full Claude-only suite (3 models × 11 scenarios) is
# ~2 hours of wall time and ~$10-30 of compute. To get distributional
# evidence, use harness/run_repeats.sh which wraps this with N runs
# per (scenario × model).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCENARIOS=( "$REPO_ROOT/eval/scenarios/"[0-9]*.yaml )

# Models to test — Claude family only.
CLAUDE_MODELS=( "claude-opus-4-7" "claude-sonnet-4-6" "claude-haiku-4-5" )

run_pair() {
  local scenario="$1"
  local model="$2"
  echo "  ▶ ${scenario##*/} × $model"
  bash "$REPO_ROOT/eval/harness/run_one.sh" \
       --scenario "$scenario" \
       --model "$model" \
       --vendor claude || true
}

echo "[run_all] ${#SCENARIOS[@]} scenarios × ${#CLAUDE_MODELS[@]} Claude models"

for s in "${SCENARIOS[@]}"; do
  for m in "${CLAUDE_MODELS[@]}"; do
    run_pair "$s" "$m"
  done
done

echo "[run_all] done — aggregate with: python3 harness/aggregate_scores.py"
echo
echo "Cross-vendor coverage (GPT, Gemini, open-weight) is intentionally out"
echo "of v0.0.10 scope. The harness shape is preserved in run_one.sh; the"
echo "vendor adapters under harness/adapters/ are stubs. Add an adapter to"
echo "extend coverage in a future release."
