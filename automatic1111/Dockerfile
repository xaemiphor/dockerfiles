FROM python:3.10.6

WORKDIR /app
RUN \
    wget -q https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -O /usr/bin/jq && chmod +x /usr/bin/jq && \
    apt-get update && apt-get -y install wget git python3-venv libgl1 libglib2.0-0 libgoogle-perftools4 libtcmalloc-minimal4 && apt-get clean && \
    pip install --upgrade pip && \
    pip install --no-cache-dir opencv-python-headless && \
    useradd -u 1000 --create-home user && \
    mkdir -p /app && chown user:user /app && \
    su user -c 'git clone --depth 1 --single-branch https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /app' && \
    su user -c 'sed "/start()/d" /app/launch.py > /app/prep_env.py' && \
    LAUNCH_SCRIPT=/app/prep_env.py su user -c '/app/webui.sh --skip-torch-cuda-test --reinstall-torch' && \
    rm /app/prep_env.py

USER user

#ENTRYPOINT ["/app/webui.sh"]
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=5m \
  CMD curl -f http://localhost:${PORT:-7860}/info || exit 1
