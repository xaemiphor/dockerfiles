#!/bin/bash
set -e
_ARGS=( '--port' "${PORT:-7860}" )

if [[ "${AUTOUPDATE:-}" == "true" ]]; then
  cd /app && git pull
fi

if ! mountpoint -q /app/config.json; then
  if [[ ! -e "/config/config.json" ]]; then
    if [[ -L "/app/config.json" ]]; then
      rm /app/config.json
    fi
#    if [[ ! -e "/app/config.json" ]]; then
#      cd /app
#      python3 -c 'from modules import shared, shared_init; shared_init.initialize(); shared.opts.save(shared.config_filename)'
#      mv /app/config.json /config/config.json
#    fi
  fi
  if [[ -f "/config/config.json" ]]; then
    if [[ ! -L "/app/config.json" ]]; then
      if [[ -e "/app/config.json" ]]; then
        rm /app/config.json
      fi
      ln -s /config/config.json /app/config.json
    fi
  fi
fi

# Preconfigure config.json
if [[ -e "/app/config.json" && ! -d "/app/config.json" ]]; then
  # Load config arguments passed as CFG__ env vars
  for ENV_VAR in $(env | awk -F '=' '/^CFG__/{print $1}' | sort); do
    var=$(echo "${ENV_VAR,,}" | sed 's/^cfg__//g')
    value="${!ENV_VAR}"
    re='^[-]?[0-9]+([.][0-9]+)?$'
    if [[ "${value,,}" == "true" || "${value,,}" == "false" || ${value} =~ ${re} ]]; then
      jq --arg var "$var" --argjson val "${value}" '.[$var] = $val' /app/config.json > /tmp/config.json.modified
    else
      jq --arg var "$var" --arg val "${!ENV_VAR}" '.[$var] = $val' /app/config.json > /tmp/config.json.modified
    fi
    cat /tmp/config.json.modified > /app/config.json
    rm /tmp/config.json.modified
  done
fi

for _arg in $(env | awk -F '=' '/^ARG__/{print $1}' | sort); do
  var=$(echo "${_arg,,}" | sed -e 's/^arg__//g' -e 's/_/-/g')
  value="${!_arg}"
  if [[ -z "${value}" ]]; then
    _ARGS+=( "--${var}" )
  elif [[ "${value,,}" == "true" || "${value,,}" == "false" ]]; then
    _ARGS+=( "--${var}" "${value,,}" )
  elif [[ -n "${value}" ]]; then
    _ARGS+=( "--${var}" "${value}" )
  else
    echo "[ENTRYPOINT]: ERROR - ${_arg} / ${var} / ${value} - Not sure what these are"
  fi
done

# Restore files that may have gone missing due to docker mounts
if [[ $(cd /app ; git status -s | awk '$1 ~ /^D/{for (i=2; i<NF; i++) printf $i " "; print $NF}' | wc -l) -gt 0 ]]; then
  cd /app
  git status -s | awk '$1 ~ /^D/{for (i=2; i<NF; i++) printf $i " "; print $NF}' | xargs git restore
fi

# Install any deps from extensions
find /app/extensions/ -maxdepth 2 -type f -name 'requirements.txt' -exec pip install -r {} \;
PYTHONPATH=/app find /app/extensions/ -maxdepth 2 -type f -name 'install.py' -exec python {} \;

cd /app
echo "== $(date -u) Starting with args webui.sh ${_ARGS[@]}"
/app/webui.sh ${_ARGS[@]}
