FROM python:3.10

WORKDIR /app

# TODO Rework this to not run as root
RUN \
    wget -q https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -O /usr/bin/jq && chmod +x /usr/bin/jq && \
    apt-get update && apt-get -y install wget git python3 python3-venv libgl1 libglib2.0-0 && apt-get clean && \
    pip install --upgrade pip && \
    git clone --depth 1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /app && \
    cd /app && pip install --no-cache-dir -r requirements_versions.txt && \
    pip install --no-cache-dir opencv-python-headless && \
    cd /app && COMMANDLINE_ARGS="--skip-torch-cuda-test" python -c 'from modules import launch_utils; launch_utils.prepare_environment()'

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=5m \
  CMD curl -f http://localhost:${PORT:-7860}/info || exit 1
