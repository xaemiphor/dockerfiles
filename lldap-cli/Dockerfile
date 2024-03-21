#PLATFORMS=linux/amd64,linux/arm64/v8,linux/arm/v7,linux/arm/v6
FROM bash:latest

RUN \
    apk --no-cache add jq curl && \
    wget https://raw.githubusercontent.com/Zepmann/lldap-cli/main/lldap-cli -O /usr/local/bin/lldap-cli && \
    chmod +x /usr/local/bin/lldap-cli
