#!/bin/bash
set -e
_ARGS=( '--listen' '--port' "${PORT:-7860}" )

cd /app
python ${SCRIPT:-webui.py} ${_ARGS[@]}
