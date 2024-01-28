# litellm-ollama

Loosely based on  https://github.com/BerriAI/litellm/tree/main/cookbook/litellm-ollama-docker-image   
Upstream does not seem to be building amd64 at the moment, and I'd prefer not to pre-bundle any models


```
version: '3.9'

x-nvidia: &nvidia
  runtime: nvidia
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities:
              - gpu

services:
  litellm-ollama1:
    <<: *nvidia
    image: ghcr.io/xaemiphor/litellm-ollama:main
    restart: unless-stopped
    ports:
      - "8000:8000"
      - "11434:11434"
    volumes:
      - "/srv/config/litellm-ollama:/config"
      - "/srv/data/litellm-ollama:/data"
    environment:
      OLLAMA_PULL: tinydolphin,tinyllama
      LITELLM_PORT: 8000
      LITELLM_HOST: 0.0.0.0

```
