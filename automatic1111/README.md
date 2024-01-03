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
      - "/srv/config/automatic1111:/config" # Holds config files, etc
      - "/srv/data/automatic1111:/data" # Hold models and output
    environment:
      TZ: "UTC"
      ARG__THEME: "dark"
    labels:
      - homepage.group=ImageGeneration
      - homepage.name=AUTOMATIC1111
      - homepage.href=http://<this-host>:81/

```
