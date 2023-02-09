FROM alpine:latest

RUN printf "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main\n" >> /etc/apk/repositories \
    && printf "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community\n" >> /etc/apk/repositories \
    && apk update \
    && apk add \
        --update \
        nodejs \
        npm \
        mongodb \
        mongodb-tools \
    && mkdir -p /data/db/ \
    && chown root /data/db
  
  CMD ["/usr/bin/mongod", "-f", "/etc/mongod.conf"]
