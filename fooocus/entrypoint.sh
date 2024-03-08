#!/bin/bash
set -e
if [[ -n "${CONTAINER_DEBUG:-}" ]]; then
  set -x
fi
_ARGS=( '--port' "${PORT:-7865}" )

CONFIG_DIR=${CONFIG_DIR:-/config}

# Fix ownerships
for x in "${CONFIG_DIR}" '/app'; do
  chown -R 1000:1000 ${x}
done

if [[ "${AUTOUPDATE:-false}" == "false" ]]; then
  SCRIPT=launch.py
fi

# Restore files that may have gone missing due to docker mounts
if [[ $(cd /app ; git status -s | awk '$1 ~ /^D/{for (i=2; i<NF; i++) printf $i " "; print $NF}' | wc -l) -gt 0 ]]; then
  cd /app
  su user -c "git status -s | awk '\$1 ~ /^D/{for (i=2; i<NF; i++) printf \$i \" \"; print \$NF}' | xargs git restore"
fi

cd /app
echo "== $(date -u) Starting with args ${SCRIPT:-entry_with_update.py} ${_ARGS[@]} $@"
su user -c "/app/venv/bin/python ${SCRIPT:-entry_with_update.py} ${_ARGS[@]} $@"
