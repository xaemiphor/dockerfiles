#!/bin/bash
set -e
_ARGS=( '--listen' '--port' "${PORT:-8080}" )

if [[ "${AUTOUPDATE}" == "false" ]]; then
  SCRIPT=launch.py
fi

for _var in 'preset' 'theme'; do
  ENV_VAR=${_var^^}
  if [[ -n "${!ENV_VAR}" ]]; then
    _ARGS+=( "--${_var}" "${!ENV_VAR}" )
  fi
done

if [[ -n "${ALWAYS}" ]]; then
  _ARGS+=( "--always-${ALWAYS,,}" )
fi

if [[ ! -e "/config/config.txt" && ! -e "/app/config.txt" ]]; then
  # Create /config/config.txt, then move it to /app/config.txt
  cd /app
  python3 -c 'import modules.config'
  mv /app/config.txt /config/config.txt
fi
if [[ -f "/config/config.txt" ]]; then
  # Delete /app/config.txt if exists and create symlink
  if [[ -e "/app/config.txt" && ! -L "/app/config.txt" ]]; then
    rm /app/config.txt
  fi
  ln -s /config/config.txt /app/config.txt
fi

if [[ -d "/config/presets" && $(ls -1 /config/presets | wc -l) -gt 0 ]]; then
  cp /config/presets/* /app/presets/
fi

if [[ -e "/app/config.txt" ]]; then
  # Redirect all /app prefixes to /data
  jq '.[] |= sub("^/app/";"/data/")' /config/config.txt > /tmp/config.txt.modified
  mv /tmp/config.txt.modified /config/config.txt
  # Load config arguments passed as CFG__ env vars
  for ENV_VAR in $(env | awk -F '=' '/^CFG__/{print $1}'); do
    var=$(echo "${ENV_VAR,,}" | sed 's/^cfg__//g')
    jq --arg var "$var" --arg val "${!ENV_VAR}" '.[$var] = $val' /config/config.txt > /tmp/config.txt.modified
    mv /tmp/config.txt.modified /config/config.txt
  done
  for path_cfg in $(jq -c --raw-output 'to_entries[] | select(.key | startswith("path_")) | .value' /config/config.txt); do
    mkdir -p "${path_cfg}"
  done
fi

cd /app
python ${SCRIPT:-entry_with_update.py} ${_ARGS[@]}
