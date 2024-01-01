# fooocus

A simple docker wrapper on https://github.com/lllyasviel/Fooocus.   
Entrypoint updates config.txt to use /data instead of /app, but retains existing structures.   

Env Vars coded:
```
AUTOUPDATE | true/false - Uses either entry_with_update.py or launch.py
preset | string - Load a preset json file
theme | string - Set to dark to default to dark theme
CFG__* | string - Will replace the matching key with the value in config.txt prior to starting Fooocus
```

Useful to know:
```
/config/config.txt - Is copied to /app/config.txt on startup
/config/presets/* - Is copied to /app/presets/ on startup, can be used with PRESET env var
```

## docker-compose
```
version: '3.9'

services:
  fooocus:
    image: ghcr.io/xaemiphor/fooocus:main
    restart: unless-stopped
    environment:
      TZ: "UTC"
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
      - "81:8080"
    volumes:
      - "/srv/config/fooocus:/config" # Holds config files, etc
      - "/srv/data/fooocus:/data" # Hold models and output
    environment:
      THEME: dark
      PRESET: realistic
    labels:
      - homepage.group=ImageGeneration
      - homepage.name=Fooocus
      - homepage.href=http://<this-host>:81/

```
