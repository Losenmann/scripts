FROM alpine:latest
RUN apk add git make gcc libc-dev \
# python3 py3-setuptools openrc nginx
  && git clone https://github.com/pcherenkov/udpxy.git \
#  && git clone https://github.com/tataranovich/jtv2xmltv.git \
#  && cd jtv2xmltv && python3 setup.py install \
  && cd ./udpxy/chipmunk && make && make install \
  && apk del git make gcc libc-dev \
  && rm -Rvf ./udpxy
CMD ["/usr/local/bin/udpxy", "-v", "-T", "-p", "4022"]