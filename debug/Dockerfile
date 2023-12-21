FROM alpine:3

RUN \
  apk --no-cache add bash

COPY app.sh /bin/
ENTRYPOINT /bin/app.sh
