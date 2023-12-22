FROM alpine:3

RUN \
  apk --no-cache add bash git

COPY app.sh /bin/
ENTRYPOINT /bin/app.sh
