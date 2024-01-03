#!/bin/bash
set -e
_ARGS=( '--listen' '--port' "${PORT:-7865}" )

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

# Adjust the config.txt file and it's relative paths
if [[ -f "/config/config.txt" ]]; then
  # Redirect all /app prefixes to /data
  jq '.[] |= sub("^/app/";"/data/")' /config/config.txt > /tmp/config.txt.modified
  mv /tmp/config.txt.modified /config/config.txt
  # Load config arguments passed as CFG__ env vars
  for ENV_VAR in $(env | awk -F '=' '/^CFG__/{print $1}'); do
    var=$(echo "${ENV_VAR,,}" | sed 's/^cfg__//g')
    jq --arg var "$var" --arg val "${!ENV_VAR}" '.[$var] = $val' /config/config.txt > /tmp/config.txt.modified
    mv /tmp/config.txt.modified /config/config.txt
  done
  # Hardcode path_outputs back to /app, as gradio blocks providing this
  jq --arg var "path_outputs" --arg val "/app/outputs" '.[$var] = $val' /config/config.txt > /tmp/config.txt.modified
  mv /tmp/config.txt.modified /config/config.txt
  for path_cfg in $(jq -c --raw-output 'to_entries[] | select(.key | startswith("path_")) | .value' /config/config.txt); do
    mkdir -p "${path_cfg}"
  done
fi

# https://github.com/lllyasviel/Fooocus/issues/907
# https://github.com/lllyasviel/Fooocus/issues/1485
# Too lazy to invent a secondary configuration file and map symlinks more than this.
if [[ ! -L "/app/outputs" ]]; then
  if [[ -d "/app/outputs" ]]; then
    rmdir /app/outputs
  fi
  ln -s /data/outputs /app/outputs
fi

# Move presets to /config
if [[ -d "/app/presets" ]]; then
  if [[ ! -d "/config/presets" ]]; then
    mv /app/presets /config/presets
  elif [[ -d "/config/presets" ]]; then
    # TODO Check for new preset files and consider copying over
    rm -r /app/presets
  fi
fi
if [[ ! -L "/app/presets" ]]; then
  ln -s /config/presets /app/presets
fi

# Copy fooocus_expansion to /data
path_fooocus_expansion=$(jq -c --raw-output '.path_fooocus_expansion' /app/config.txt )
for object in $(find /app/models/prompt_expansion/fooocus_expansion -type f -printf '%P\n'); do
  if [[ ! -e "${path_fooocus_expansion}/${object}" ]]; then
    cp "/app/models/prompt_expansion/fooocus_expansion/${object}" "${path_fooocus_expansion}/${object}"
  fi
done

cd /app
python ${SCRIPT:-entry_with_update.py} ${_ARGS[@]}
