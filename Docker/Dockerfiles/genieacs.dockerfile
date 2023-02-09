FROM alpine:latest

RUN apk add \
    --update \
    nodejs \
    npm \
    mongodb \
    mongodb-tools \
  && mkdir -p /data/db/ \
  && chown root /data/db
  
  CMD ["/usr/bin/mongod", "-f", "/etc/mongod.conf"]
