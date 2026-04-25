#!/usr/bin/env bash
# Publish + deprecate the 3 redirect aliases for clinical-trial-design.
# Run after publishing the canonical package from mcp-server/.
#
# Usage:
#   cd mcp-server/aliases && bash publish-aliases.sh
#
# Requires: npm login (npm whoami must succeed).

set -euo pipefail

cd "$(dirname "$0")"

ALIASES=(
  trial-design
  sample-size-calculator
  study-design
)
DEPRECATION_MSG="Renamed to clinical-trial-design — install that instead: npm install clinical-trial-design"

if ! npm whoami >/dev/null 2>&1; then
  echo "ERROR: not logged into npm. Run: npm login" >&2
  exit 1
fi

NPM_USER=$(npm whoami)
echo "Publishing 3 redirect aliases as ${NPM_USER}..."
echo

for a in "${ALIASES[@]}"; do
  if [ ! -f "$a/package.json" ]; then
    echo "ERROR: $a/package.json not found" >&2
    exit 1
  fi
  echo "==> Publishing $a@0.0.6"
  (cd "$a" && npm publish --access public) || {
    echo "  publish failed for '$a' — name may be taken on npm." >&2
    echo "  Edit ALIASES=(...) in this script to drop or replace it, then rerun." >&2
    exit 1
  }
done

echo
echo "Deprecating aliases (so 'npm install <alias>' shows a notice)..."
for a in "${ALIASES[@]}"; do
  echo "==> Deprecating $a@0.0.6"
  npm deprecate "$a@0.0.6" "$DEPRECATION_MSG"
done

echo
echo "Done. All 3 aliases published and deprecated."
echo "Spot-check with:"
echo "  npm view trial-design"
echo "  npm view sample-size-calculator"
