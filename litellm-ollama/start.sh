#!/bin/bash
ollama serve &
(sleep 2s && if [[ -n "${OLLAMA_PULL:-}" ]]; then echo -n "${OLLAMA_PULL:-}" | xargs -n1 -P1 -d ',' ollama pull ; fi ) &
litellm --port ${LITELLM_PORT:-8000} --host "${LITELLM_HOST:-0.0.0.0}"
