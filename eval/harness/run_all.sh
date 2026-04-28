#!/usr/bin/env bash
# Run every scenario × every available model. Skips vendors whose
# environment is not configured (no API key, no Ollama endpoint).
# Writes per-run dirs under ${EVAL_RUN_ROOT:-${TMPDIR}/clinical-trial-design-eval/}.
#
# Usage:
#   bash harness/run_all.sh
#
# Each (scenario × model) combination becomes one (~3-5 min) claude -p
# session, so the full Claude-only suite (3 models × 11 scenarios) is
# ~2 hours of wall time and ~$10-30 of compute. Plan accordingly.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCENARIOS=( "$REPO_ROOT/eval/scenarios/"[0-9]*.yaml )

# Models to test, organized by vendor.
CLAUDE_MODELS=( "claude-opus-4-7" "claude-sonnet-4-6" "claude-haiku-4-5" )
OPENAI_MODELS=( "gpt-5" )
GEMINI_MODELS=( "gemini-2-pro" )
OLLAMA_MODELS=( "llama-3.1-8b" )

run_pair() {
  local scenario="$1"
  local model="$2"
  local vendor="$3"
  echo "  ▶ ${scenario##*/} × $vendor:$model"
  bash "$REPO_ROOT/eval/harness/run_one.sh" \
       --scenario "$scenario" \
       --model "$model" \
       --vendor "$vendor" || true
}

echo "[run_all] ${#SCENARIOS[@]} scenarios"

# Claude — uses the user's existing creds via the claude CLI.
echo "[run_all] === Claude family ==="
for s in "${SCENARIOS[@]}"; do
  for m in "${CLAUDE_MODELS[@]}"; do
    run_pair "$s" "$m" claude
  done
done

# OpenAI — gated on OPENAI_API_KEY.
if [[ -n "${OPENAI_API_KEY:-}" ]]; then
  echo "[run_all] === OpenAI family ==="
  for s in "${SCENARIOS[@]}"; do
    for m in "${OPENAI_MODELS[@]}"; do
      run_pair "$s" "$m" openai
    done
  done
else
  echo "[run_all] (OPENAI_API_KEY not set — skipping OpenAI models)"
fi

if [[ -n "${GEMINI_API_KEY:-}" ]]; then
  echo "[run_all] === Gemini family ==="
  for s in "${SCENARIOS[@]}"; do
    for m in "${GEMINI_MODELS[@]}"; do
      run_pair "$s" "$m" gemini
    done
  done
else
  echo "[run_all] (GEMINI_API_KEY not set — skipping Gemini models)"
fi

if [[ -n "${OLLAMA_BASE_URL:-}" ]]; then
  echo "[run_all] === Ollama (open-weight) ==="
  for s in "${SCENARIOS[@]}"; do
    for m in "${OLLAMA_MODELS[@]}"; do
      run_pair "$s" "$m" ollama
    done
  done
else
  echo "[run_all] (OLLAMA_BASE_URL not set — skipping Ollama models)"
fi

echo "[run_all] done — score with: python3 harness/aggregate_scores.py"
