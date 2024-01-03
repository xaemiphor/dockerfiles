#!/bin/bash
set -e
_ARGS=( '--listen' '--port' "${PORT:-7860}" )

if [[ ! -e "/config/config.json" ]]; then
  if [[ -L "/app/config.json" ]]; then
    rm /app/config.json
  fi
  if [[ ! -e "/app/config.json" ]]; then
    cd /app
    python3 -c 'from modules import shared, shared_init; shared_init.initialize(); shared.opts.save(shared.config_filename)'
    mv /app/config.json /config/config.json
  fi
fi
if [[ -f "/config/config.json" ]]; then
  if [[ ! -L "/app/config.json" ]]; then
    if [[ -e "/app/config.json" ]]; then
      rm /app/config.json
    fi
    ln -s /config/config.json /app/config.json
  fi
fi

# Move some paths to /data
for entry in 'models' 'outputs' 'log' 'extensions' 'embeddings'; do
  if [[ ! -d "/data/${entry}" ]]; then
    if [[ -d "/app/${entry}" ]]; then
      mv "/app/${entry}" "/data/${entry}"
    fi
  fi
  if [[ ! -L "/app/${entry}" ]]; then
    if [[ -e "/app/${entry}" ]]; then
      rm -R "/app/${entry}"
    fi
    ln -s "/data/${entry}" "/app/${entry}"
  fi
done

# Preconfigure config.json
if [[ -f "/config/config.json" ]]; then
  # Load config arguments passed as CFG__ env vars
  for ENV_VAR in $(env | awk -F '=' '/^CFG__/{print $1}'); do
    var=$(echo "${ENV_VAR,,}" | sed 's/^cfg__//g')
    value="${!ENV_VAR}"
    re='^[-]?[0-9]+([.][0-9]+)?$'
    if [[ "${value,,}" == "true" || "${value,,}" == "false" || ${value} =~ ${re} ]]; then
      jq --arg var "$var" --argjson val "${value}" '.[$var] = $val' /config/config.json > /tmp/config.json.modified
      mv /tmp/config.json.modified /config/config.json
    else
      jq --arg var "$var" --arg val "${!ENV_VAR}" '.[$var] = $val' /config/config.json > /tmp/config.json.modified
      mv /tmp/config.json.modified /config/config.json
    fi
  done
fi

for _var in 'theme'; do
  ENV_VAR=${_var^^}
  if [[ -n "${!ENV_VAR}" ]]; then
    _ARGS+=( "--${_var}" "${!ENV_VAR}" )
  fi
don

cd /app
python ${SCRIPT:-webui.py} ${_ARGS[@]}
