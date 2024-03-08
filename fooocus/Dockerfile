#VERSION=2.2.1
FROM python:3.10.6

WORKDIR /app
ARG VERSION
RUN \
    wget -q https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -O /usr/bin/jq && chmod +x /usr/bin/jq && \
    apt-get update && apt-get -y install wget git python3-venv libgl1 libglib2.0-0 libgoogle-perftools4 libtcmalloc-minimal4 && apt-get clean && \
    pip install --upgrade pip && \
    pip install --no-cache-dir torch==2.1.0 torchvision==0.16.0 --extra-index-url https://download.pytorch.org/whl/cu121 && \
    pip install --no-cache-dir opencv-python-headless && \
    useradd -u 1000 --create-home user && \
    mkdir -p /app && chown user:user /app && \
    su user -c 'git clone --depth 1 --branch ${VERSION} https://github.com/lllyasviel/Fooocus.git /app' && \
    su user -c 'python3 -m venv venv' && \
    su user -c 'export PATH="/app/venv/bin:${PATH}" ; pip install -r requirements_versions.txt'

USER user

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=5m \
  CMD curl -f http://localhost:${PORT:-7860}/info || exit 1
