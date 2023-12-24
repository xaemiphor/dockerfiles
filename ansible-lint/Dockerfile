#VERSION=0.0.1
FROM python:3-alpine

RUN \
  apk --no-cache add bash git && \
  pip3 install "ansible-lint" -q

COPY app.sh /bin/
COPY _ci.sh /bin/
ENTRYPOINT /bin/app.sh
