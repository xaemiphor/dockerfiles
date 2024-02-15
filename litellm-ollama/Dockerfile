#PLATFORMS=linux/amd64,linux/arm64/v8
FROM ollama/ollama as ollama

FROM python:3-buster as litellm

RUN \
    pip install --upgrade pip && \
    python3 -m pip install litellm[proxy] pyinstaller && \
    mkdir /app && cd /app && \
    pyinstaller --onefile `which litellm` --hidden-import=tiktoken_ext.openai_public --hidden-import=tiktoken_ext --hidden-import=gunicorn.glogging --hidden-import=gunicorn


FROM ubuntu:jammy

ARG S6_OVERLAY_VERSION=3.1.6.2

EXPOSE 11434
EXPOSE 8000

RUN \
    mkdir /config /data && \
    apt-get update && apt-get -y install curl xz-utils && \
    curl --silent -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar -C / -Jxp && \
    curl --silent -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-$(uname -m).tar.xz | tar -C / -Jxp && \
    apt-get clean

ENTRYPOINT ["/init"]

COPY --from=ollama /usr/bin/ollama /app/ollama
ENV OLLAMA_HOME=/config/ollama
ENV OLLAMA_MODELS=/data/ollama
COPY --from=litellm /app/dist/litellm /app/litellm
COPY root/ /
