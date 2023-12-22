#VERSION=0.0.3
#PLATFORMS=linux/amd64,linux/386,linux/arm/v6,linux/arm/v7,linux/arm64/v8
FROM alpine:3

RUN \
  apk --no-cache add bash git jq

COPY app.sh /bin/
COPY _ci.sh /bin/
ENTRYPOINT /bin/app.sh
