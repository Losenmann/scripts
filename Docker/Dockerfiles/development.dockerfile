FROM alpine:latest

RUN mkdir -p /var/lib/arduino-cli \
  apk add \
    curl \
  && curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/var/lib/arduino-cli sh
