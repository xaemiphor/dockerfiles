FROM python:3.10

WORKDIR /app

# TODO Rework this to not run as root
RUN \
    wget -q https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -O /usr/bin/jq && chmod +x /usr/bin/jq && \
    pip install --upgrade pip && \
    bash -c "pip install --no-cache-dir -r <(curl --silent 'https://raw.githubusercontent.com/lllyasviel/Fooocus/main/requirements_versions.txt')" && \
    pip install --no-cache-dir torch==2.1.0 torchvision==0.16.0 --extra-index-url https://download.pytorch.org/whl/cu121 && \
    pip install --no-cache-dir opencv-python-headless && \
    git clone --depth 1 https://github.com/lllyasviel/Fooocus.git /app

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=5m \
  CMD curl -f http://localhost:${PORT:-7865}/info || exit 1
