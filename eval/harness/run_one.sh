#!/usr/bin/env bash
# Run a single eval scenario through one model and capture the
# stream-json transcript for scoring.
#
# Usage:
#   bash harness/run_one.sh \
#       --scenario scenarios/05_gs_survival_ph_obf.yaml \
#       --model claude-opus-4-7 \
#       [--vendor claude]                    # claude (default); other vendors are stub adapters
#       [--run-dir /tmp/eval-runs/<auto>]    # default: auto under ${TMPDIR}/clinical-trial-design-eval/
#
# Output:
#   <run-dir>/transcript.jsonl       (stream-json)
#   <run-dir>/scenario.yaml          (frozen copy of the input)
#   <run-dir>/meta.json              (model, vendor, scenario id, run timestamp)
#
# Vendor scope: Claude only for v0.0.10. The MCP plugin must be installed
# in the user's Claude profile (claude plugin list | grep clinical-trial-design).
# OpenAI / Gemini / Ollama adapters are stubbed at harness/adapters/* and
# documented as future work — they were intentionally left out of v0.0.10
# scope so the pharma-skills comparison runs apples-to-apples on the
# Claude generation lineup.

set -euo pipefail

SCENARIO=""
MODEL=""
VENDOR="claude"
RUN_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scenario) SCENARIO="$2"; shift 2 ;;
    --model)    MODEL="$2";    shift 2 ;;
    --vendor)   VENDOR="$2";   shift 2 ;;
    --run-dir)  RUN_DIR="$2";  shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$SCENARIO" || -z "$MODEL" ]]; then
  echo "usage: $0 --scenario <yaml> --model <name> [--vendor claude|openai|gemini|ollama]" >&2
  exit 2
fi
if [[ ! -f "$SCENARIO" ]]; then
  echo "scenario not found: $SCENARIO" >&2; exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCENARIO_ID="$(python3 -c 'import yaml,sys; print(yaml.safe_load(open(sys.argv[1]))["id"])' "$SCENARIO")"

if [[ -z "$RUN_DIR" ]]; then
  RUN_ROOT="${EVAL_RUN_ROOT:-${TMPDIR:-/tmp}/clinical-trial-design-eval}"
  mkdir -p "$RUN_ROOT"
  RUN_DIR="$RUN_ROOT/${SCENARIO_ID}-${MODEL}-$(date -u +%Y%m%dT%H%M%SZ)"
fi
mkdir -p "$RUN_DIR"
cp "$SCENARIO" "$RUN_DIR/scenario.yaml"

# Extract the prompt — pass to the agent verbatim.
PROMPT="$(python3 -c '
import yaml, sys
print(yaml.safe_load(open(sys.argv[1]))["prompt"])
' "$SCENARIO")"

# Capture run metadata up front so the scorer can read it without parsing
# the transcript header.
python3 - "$RUN_DIR/meta.json" <<EOF
import json, sys, datetime
json.dump({
    "scenario": "$SCENARIO_ID",
    "scenario_path": "$SCENARIO",
    "model": "$MODEL",
    "vendor": "$VENDOR",
    "started_at": datetime.datetime.utcnow().isoformat() + "Z",
}, open(sys.argv[1], "w"), indent=2)
EOF

ALLOWED_TOOLS="Bash,Read,Write,Edit,Glob,mcp__plugin_clinical-trial-design_clinical-trial-design__*"

case "$VENDOR" in
  claude)
    echo "[run_one] claude -p --model $MODEL  (scenario: $SCENARIO_ID)"
    echo "$PROMPT" | claude -p --model "$MODEL" --allowedTools "$ALLOWED_TOOLS" \
      --verbose --output-format stream-json \
    > "$RUN_DIR/transcript.jsonl"
    ;;
  openai|gemini|ollama)
    ADAPTER="$REPO_ROOT/eval/harness/adapters/${VENDOR}.py"
    if [[ ! -f "$ADAPTER" ]]; then
      echo "[run_one] $VENDOR adapter not yet implemented at $ADAPTER" >&2
      echo "[run_one] writing a stub transcript so the scorer can mark this run as 'not yet executable'" >&2
      python3 - "$RUN_DIR/transcript.jsonl" "$VENDOR" "$MODEL" <<'EOF'
import json, sys
out = sys.argv[1]
vendor = sys.argv[2]
model = sys.argv[3]
with open(out, "w") as f:
    f.write(json.dumps({"type":"system","subtype":"adapter_missing",
                        "vendor": vendor, "model": model}) + "\n")
    f.write(json.dumps({"type":"result","subtype":"not_run",
                        "is_error": True,
                        "result":"adapter not implemented"}) + "\n")
EOF
    else
      python3 "$ADAPTER" --model "$MODEL" --prompt-file <(echo "$PROMPT") \
        > "$RUN_DIR/transcript.jsonl"
    fi
    ;;
  *)
    echo "unknown vendor: $VENDOR" >&2; exit 2 ;;
esac

echo "[run_one] transcript at $RUN_DIR/transcript.jsonl"
echo "[run_one] next: python3 harness/score.py --run-dir $RUN_DIR"
