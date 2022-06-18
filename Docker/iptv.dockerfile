FROM alpine:latest
LABEL maintainer="virus14m@gmail.com"
RUN apk add git make gcc libc-dev \
  && git clone https://github.com/pcherenkov/udpxy.git \
  && cd ./udpxy/chipmunk && make && make install \
  && apk del git make gcc libc-dev
CMD ["/usr/local/bin/udpxy", "-v", "-T", "-p", "4023"]
