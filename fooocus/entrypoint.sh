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

# TODO Figure out how to force generate the config.txt file without starting Fooocus, put it at /app/config.txt
if [[ -e "/config/config.txt" ]]; then
  cp /config/config.txt /app/config.txt
fi

if [[ -d "/config/presets" && $(ls -1 /config/presets | wc -l) -gt 0 ]]; then
  cp /config/presets/* /app/presets/
fi

if [[ -e "/app/config.txt" ]]; then
  # Redirect all /app prefixes to /data
  jq '.[] |= sub("^/app/";"/data/")' /app/config.txt > /tmp/config.txt.modified
  mv /tmp/config.txt.modified /app/config.txt
  # Load config arguments passed as CFG__ env vars
  for ENV_VAR in $(env | awk -F '=' '/^CFG__/{print $1}'); do
    var=$(echo "${ENV_VAR,,}" | sed 's/^cfg__//g')
    jq --arg var "$var" --arg val "${!ENV_VAR}" '.[$var] = $val' /app/config.txt > /tmp/config.txt.modified
    mv /tmp/config.txt.modified /app/config.txt
  done
  for path_cfg in $(jq -c --raw-output 'to_entries[] | select(.key | startswith("path_")) | .value' /app/config.txt); do
    mkdir -p "${path_cfg}"
  done
  if [[ ! -e "/config/config.txt" ]]; then
    cp /app/config.txt /config/config.txt
  fi
fi

cd /app
python ${SCRIPT:-entry_with_update.py} ${_ARGS[@]}
