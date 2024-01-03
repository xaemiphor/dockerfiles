FROM python:3.10

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh

RUN \
    wget -q https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -O /usr/bin/jq && chmod +x /usr/bin/jq && \
    pip install --upgrade pip && \
    git clone --depth 1 https://github.com/lllyasviel/Fooocus.git /app && \
    cd /app && pip install --no-cache-dir -r requirements_versions.txt && \
    cd /app && python -c 'import launch; prepare_environment()' && \
    cd /app && git clean -dfx && git clean -dfX && \
    pip install --no-cache-dir opencv-python-headless

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=5m \
  CMD curl -f http://localhost:${PORT:-7865}/info || exit 1
