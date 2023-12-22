#VERSION=0.0.2
#PLATFORMS=linux/amd64,linux/arm/v7,linux/arm64/v8
FROM node:alpine

RUN \
  apk --no-cache add bash && \
  npm install -g leasot

COPY app.sh /bin/
COPY _ci.sh /bin/
ENTRYPOINT /bin/app.sh
