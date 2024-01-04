# fooocus

A simple docker wrapper on https://github.com/lllyasviel/Fooocus.   
Entrypoint updates config.txt to use /data instead of /app, but retains existing structures.   
Other than attempting to restructure content between /config and /data folders, no other changes are made.

Env Vars coded:
```
AUTOUPDATE | true/false - Uses either entry_with_update.py or launch.py
CFG__* | string - Will replace the matching key with the value in config.txt prior to starting Fooocus
ARG__* | string - Direct passthrough of arguments to the launch command
```

Useful to know:
```
/config/config.txt - Is symlinked to where fooocus expects it, and will be modified by CFG_ env vars directly
/config/presets/* - Is populated by foocus defaults, then directly symlinked
/data/outputs/ - Is hardcoded due to gradio/fooocus not passing files outside the project directory
```

## docker-compose
```
version: '3.9'

services:
  fooocus:
    image: ghcr.io/xaemiphor/fooocus:main
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
      - "81:7865"
    volumes:
      - "/srv/config/fooocus:/config" # Holds config files, etc
      - "/srv/data/fooocus:/data" # Hold models and output
    environment:
      TZ: "UTC"
      ARG__THEME: dark
      ARG__PRESET: realistic
      ARG__ALWAYS_GPU: true
    labels:
      - homepage.group=ImageGeneration
      - homepage.name=Fooocus
      - homepage.href=http://<this-host>:81/

```
