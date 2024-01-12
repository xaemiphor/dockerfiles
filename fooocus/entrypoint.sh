#!/bin/bash
set -e
_ARGS=( '--port' "${PORT:-7865}" )

if [[ "${AUTOUPDATE:-}" == "false" ]]; then
  SCRIPT=launch.py
fi

# If the path is already mounted, don't bother generating or symlinking it
if ! mountpoint -q /app/config.txt; then
  if [[ ! -f "/config/config.txt" ]]; then
    if [[ -e "/app/config.txt" ]]; then
      rm /app/config.txt
    fi
    # Setup config file to be symlink in config
    if [[ ! -e "/app/config.txt" ]]; then
      # Create /config/config.txt, then move it to /app/config.txt
      cd /app
      python3 -c 'import modules.config'
      mv /app/config.txt /config/config.txt
    fi
  fi
  if [[ ! -L "/app/config.txt" ]]; then
    if [[ -e "/app/config.txt" ]]; then
      rm /app/config.txt
    fi
    ln -s /config/config.txt /app/config.txt
  fi
fi

# Adjust the config.txt file and it's relative paths
if [[ -e "/app/config.txt" && ! -d "/app/config.txt" ]]; then
  # Load config arguments passed as CFG__ env vars
  for ENV_VAR in $(env | awk -F '=' '/^CFG__/{print $1}' | sort); do
    var=$(echo "${ENV_VAR,,}" | sed 's/^cfg__//g')
    jq --arg var "$var" --arg val "${!ENV_VAR}" '.[$var] = $val' /app/config.txt > /tmp/config.txt.modified
    cat /tmp/config.txt.modified > /app/config.txt
    rm /tmp/config.txt.modified
  done
fi

# Direct ARG passthrough
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

cd /app
python ${SCRIPT:-entry_with_update.py} ${_ARGS[@]}
