# fooocus

A simple docker wrapper on https://github.com/lllyasviel/Fooocus.   
Attempts to restructure application paths to consolodate into /config and /data had some annoying side-effects, so this has been simplified at the cost of just adding more volume mounts.   
ARG__ and CFG__ prefixes still manipulate the CLI arguments and configuration variables, but you can also directly edit config.txt and restart the container.

Env Vars coded:
```
AUTOUPDATE | true/false - Uses either entry_with_update.py or launch.py
CFG__* | string - Will replace the matching key with the value in config.txt prior to starting Fooocus
ARG__* | string - Direct passthrough of arguments to the launch command
```

Useful to know:
```
/config/config.txt - Is symlinked to where fooocus expects it, and will be modified by CFG_ env vars directly
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
      - "/srv/config/fooocus:/config" # Config.txt will be stored here
      - "/srv/config/fooocus/presets:/app/presets"
      - "/srv/data/fooocus/models:/app/models"
      - "/srv/data/fooocus/outputs:/app/outputs"
      # ETC
    environment:
      TZ: "UTC"
      ARG__LISTEN: ""
      ARG__THEME: dark
      ARG__PRESET: realistic
    labels:
      - homepage.group=ImageGeneration
      - homepage.name=Fooocus
      - homepage.href=http://<this-host>:81/

```
