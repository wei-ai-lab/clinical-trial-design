#!/usr/bin/env bash
# Publish + deprecate the 3 redirect aliases for clinical-trial-design.
# Run after publishing the canonical package from mcp-server/.
#
# Usage:
#   cd mcp-server/aliases && bash publish-aliases.sh           # 2FA off
#   cd mcp-server/aliases && bash publish-aliases.sh --otp 123456
#   OTP=123456 bash publish-aliases.sh                          # env var form
#
# Requires: npm login (npm whoami must succeed).
#
# 2FA notes: a single OTP is valid for ~30 seconds. The script does up
# to 6 npm operations (3 publishes + 3 deprecates), all fast, so one
# fresh code usually covers the whole run. If you see a 401/403 mid-run,
# rerun with a new OTP — already-published aliases will fail the second
# 'npm publish' (versions are immutable) but `--ignore-scripts` is not
# needed; you can remove the published name from ALIASES=(...) and rerun
# only the remaining ones + the full deprecate loop.

set -euo pipefail

cd "$(dirname "$0")"

ALIASES=(
  trial-design
  sample-size-calculator
  study-design
)
DEPRECATION_MSG="Renamed to clinical-trial-design — install that instead: npm install clinical-trial-design"

# Parse --otp <code> or fall back to OTP env var.
OTP="${OTP:-}"
if [ "${1:-}" = "--otp" ] && [ -n "${2:-}" ]; then
  OTP="$2"
fi

OTP_ARGS=()
if [ -n "$OTP" ]; then
  OTP_ARGS=(--otp="$OTP")
fi

if ! npm whoami >/dev/null 2>&1; then
  echo "ERROR: not logged into npm. Run: npm login" >&2
  exit 1
fi

NPM_USER=$(npm whoami)
echo "Publishing 3 redirect aliases as ${NPM_USER}..."
if [ -n "$OTP" ]; then
  echo "(using OTP — make sure your authenticator code is fresh)"
fi
echo

for a in "${ALIASES[@]}"; do
  if [ ! -f "$a/package.json" ]; then
    echo "ERROR: $a/package.json not found" >&2
    exit 1
  fi
  echo "==> Publishing $a@0.0.6"
  (cd "$a" && npm publish --access public "${OTP_ARGS[@]}") || {
    echo "  publish failed for '$a' — name may be taken on npm, OTP may be stale, or 2FA may be required." >&2
    echo "  Edit ALIASES=(...) and/or rerun with a fresh --otp <code>." >&2
    exit 1
  }
done

echo
echo "Deprecating aliases (so 'npm install <alias>' shows a notice)..."
for a in "${ALIASES[@]}"; do
  echo "==> Deprecating $a@0.0.6"
  npm deprecate "$a@0.0.6" "$DEPRECATION_MSG" "${OTP_ARGS[@]}"
done

echo
echo "Done. All 3 aliases published and deprecated."
echo "Spot-check with:"
echo "  npm view trial-design"
echo "  npm view sample-size-calculator"
