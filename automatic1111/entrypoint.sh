#!/bin/bash
set -e
if [[ -n "${CONTAINER_DEBUG:-}" ]]; then
  set -x
fi
_ARGS=( '--port' "${PORT:-7860}" )

CONFIG_DIR=${CONFIG_DIR:-/config}

# Fix ownerships
for x in "${CONFIG_DIR}" '/app'; do
  chown -R 1000:1000 ${x}
done

# Create config file if not exists
#if [[ ! -e "${CONFIG_DIR}/config.json" ]]; then
#  cd /app
#  su user -c "/app/venv/bin/python3 -c 'from modules import shared, shared_init; shared_init.initialize(); shared.opts.save(shared.config_filename)'"
#  mv /app/config.json "${CONFIG_DIR}/config.json"
#fi
_ARGS+=( '--ui-settings-file' "${CONFIG_DIR}/config.json" )
_ARGS+=( '--ui-config-file' "${CONFIG_DIR}/ui-config.json" )
export SD_WEBUI_CACHE_FILE="${CONFIG_DIR}/cache.json"


# Restore files that may have gone missing due to docker mounts
if [[ $(cd /app ; git status -s | awk '$1 ~ /^D/{for (i=2; i<NF; i++) printf $i " "; print $NF}' | wc -l) -gt 0 ]]; then
  cd /app
  su user -c "git status -s | awk '\$1 ~ /^D/{for (i=2; i<NF; i++) printf \$i \" \"; print \$NF}' | xargs git restore"
fi

# Install any deps from extensions
#find /app/extensions/ -maxdepth 2 -type f -name 'requirements.txt' -exec pip install -r {} \;
#PYTHONPATH=/app find /app/extensions/ -maxdepth 2 -type f -name 'install.py' -exec python {} \;

cd /app
_ARGS+=( "$@" )
echo "== $(date -u) Starting with args ${SCRIPT:-webui.sh} ${_ARGS[@]}"
su user -c "bash ${SCRIPT:-webui.sh} ${_ARGS[@]}"
