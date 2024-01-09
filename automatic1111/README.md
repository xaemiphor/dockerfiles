# AUTOMATIC1111

A simple docker wrapper on https://github.com/AUTOMATIC1111/stable-diffusion-webui.   

Env Vars coded:
```
```

Useful to know:
```
```

## docker-compose
```
version: '3.9'

services:
  automatic1111:
    image: ghcr.io/xaemiphor/automatic1111:main
    restart: unless-stopped
    runtime: nvidia
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities:
                - gpu
    ports:
      - "81:7860"
    volumes:
      - "/srv/config/automatic1111:/config" # Holds config.json file
      - "/srv/data/automatic1111/models:/app/models"
      - "/srv/data/automatic1111/outputs:/app/outputs"
      - "/srv/data/automatic1111/extensions:/app/extensions"
      - "/srv/data/automatic1111/embeddings:/app/embeddings"
      - "/srv/data/automatic1111/log:/app/log"
    environment:
      TZ: "UTC"
      ARG__THEME: "dark"
      ARG__API: ""
      ARG__API_LOG: ""
      ARG__listen: ""
      ARG__enable_insecure_extension_access: ""
    labels:
      - homepage.group=ImageGeneration
      - homepage.name=AUTOMATIC1111
      - homepage.href=http://<this-host>:81/

```
