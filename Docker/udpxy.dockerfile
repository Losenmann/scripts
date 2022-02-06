FROM alpine:latest
RUN apk add make gcc libc-dev git python3 py3-setuptools \
######## UDPXY ########
        && wget http://www.udpxy.com/download/udpxy/udpxy-src.tar.gz \
        && tar zxf udpxy-src.tar.gz \
        && cd udpxy-* && make && make install \
##### JVT-2-XMLTV #####
        && git clone https://github.com/tataranovich/jtv2xmltv.git \
        && cd jtv2xmltv && python3 setup.py install \
        && apk del make gcc libc-dev git python3 py3-setuptools
CMD ["/usr/local/bin/udpxy", "-v", "-T", "-p", "4022"]

######## DEFAULT ########
# FROM alpine:latest as builder
# RUN apk add make gcc libc-dev
# WORKDIR /tmp
# RUN wget http://www.udpxy.com/download/udpxy/udpxy-src.tar.gz \
#       && tar zxf udpxy-src.tar.gz \
#       && cd udpxy-* && make && make install
# FROM alpine:latest
# COPY --from=builder /usr/local/bin/udpxy /usr/local/bin/udpxy
# COPY --from=builder /usr/local/bin/udpxrec /usr/local/bin/udpxrec
# ENTRYPOINT ["/usr/local/bin/udpxy"]
# CMD ["-v", "-T", "-p", "4022"]
