#VERSION=0.0.1
#PLATFORMS=linux/amd64,linux/386,linux/arm/v6,linux/arm/v7,linux/arm64/v8
FROM alpine:3

RUN \
  apk --no-cache add bash git

COPY app.sh /bin/
ENTRYPOINT /bin/app.sh
