#!/bin/bash
# clear-jinja-build.sh — remove jinja-build/ and jinja-templates/ for all projects in setup.yml
set -euo pipefail

SETUP_FILE="${1:-./setup.yml}"

if [[ ! -f "$SETUP_FILE" ]]; then
  echo "Error: setup file not found at '$SETUP_FILE'." >&2
  exit 1
fi

# --- helpers ---------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

to_abs() {
  local base="$1" p="$2"
  [[ "$p" == /* ]] && { printf '%s\n' "$p"; return; }
  (cd "$base" >/dev/null && cd "$(dirname "$p")" >/dev/null && printf '%s/%s\n' "$PWD" "$(basename "$p")")
}

# --- extract current env + project paths -----------------------------------
get_projects_with_yq() {
  local env
  env="$(yq -oy '.["current-setup"].env // "dev"' "$SETUP_FILE")"
  yq -oy ".environments[\"$env\"].projects | to_entries[].value.path" "$SETUP_FILE"
}

get_projects_with_python() {
python - "$SETUP_FILE" <<'PY'
import sys, os
try:
    import yaml
except Exception:
    sys.exit(2)

with open(sys.argv[1], 'r') as f:
    data = yaml.safe_load(f) or {}

env = (((data or {}).get('current-setup') or {}).get('env')) or 'dev'
projects = (((data or {}).get('environments') or {}).get(env) or {}).get('projects') or {}
for _, cfg in (projects or {}).items():
    p = (cfg or {}).get('path')
    if p:
        print(p)
PY
}

paths=""
if have yq; then
  paths="$(get_projects_with_yq || true)"
else
  out="$(get_projects_with_python || true)"
  rc=$?
  if [[ $rc -eq 2 ]]; then
    echo "Error: neither 'yq' is installed nor PyYAML available for Python fallback." >&2
    echo "Install yq (https://mikefarah.gitbook.io/yq/) or 'pip install pyyaml' and re-run." >&2
    exit 1
  fi
  paths="$out"
fi

if [[ -z "${paths// }" ]]; then
  echo "No project paths found in $SETUP_FILE"
  exit 0
fi

# --- delete per-project dirs safely ----------------------------------------
root_dir="$(cd "$(dirname "$SETUP_FILE")" && pwd)"

echo "Clearing jinja dirs for projects defined in $(realpath "$SETUP_FILE"):"
while IFS= read -r rel || [[ -n "$rel" ]]; do
  [[ -z "${rel// }" ]] && continue
  proj_abs="$(to_abs "$root_dir" "$rel")"
  # Safety: ensure path exists and is not /
  if [[ -d "$proj_abs" && "$proj_abs" != "/" ]]; then
    echo "  • $proj_abs"
    rm -rf -- "$proj_abs/jinja-build" "$proj_abs/jinja-templates"
  else
    echo "  • Skipping: $proj_abs (not a directory)"
  fi
done <<< "$paths"

echo "Done."
