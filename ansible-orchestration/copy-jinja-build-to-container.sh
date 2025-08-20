#!/bin/bash
# host location -> /embed-jinja/ansible-orchestration/copy-jinja-build-to-container.sh
# container location -> /working-directory/copy-jinja-build-to-container.sh

# Example usage:
# ./copy-jinja-build-to-container.sh /path/to/src /path/to/dst

# Copy rendered artifacts from /_jinja_build into /app (or a given target)
set -euo pipefail
SRC="${1:-/_jinja_build}"
DST="${2:-/.}" # container working directory.

# nothing to copy? exit quietly
[ -d "$SRC" ] || exit 0

# optional ownership (pass UID/GID via env)
UID_TGT="${TARGET_UID:-}"
GID_TGT="${TARGET_GID:-}"

# copy preserving modes/times; ignore sparse/devs; overwrite newer
cp -a "$SRC"/. "$DST"/

# optional fixup ownership
if [ -n "$UID_TGT" ] || [ -n "$GID_TGT" ]; then
  chown -R "${UID_TGT:-}-":"${GID_TGT:-}-" "$DST" 2>/dev/null || true
fi