FROM alpine:latest

ARG JTV2XMLTV_URL
ARG JTV2XMLTV_CRON
ARG JTV2XMLTV_VERSION

ENV JTV2XMLTVURL=${JTV2XMLTV_URL}

RUN apk add \
        --no-cache \
        --clean-protected \
        git \
        make \
        gcc \
        libc-dev \
        python3 \
        py3-setuptools \
        mini_httpd \
        libxml2-utils \
        gzip \
    && mkdir -p /opt/iptv-svc/src \
    && mkdir -p /www/jtv2xmltv \
    && chown -R minihttpd /www \
    && cd /opt/iptv-svc/src \
    && git clone --branch master https://github.com/pcherenkov/udpxy.git \
        && cd ./udpxy/chipmunk \
        && make \
        && make install \
        && cd ../.. \
    && git clone --branch ${JTV2XMLTV_URL} https://github.com/tataranovich/jtv2xmltv.git \
        && cd ./jtv2xmltv \
        && python3 setup.py install \
        && cd .. \
    && mv /etc/mini_httpd/mini_httpd.conf /etc/mini_httpd/mini_httpd.conf.orig \
    && printf "port=4023\nuser=minihttpd\ndir=/www\ndata_dir=/www/jtv2xmltv\nnochroot" > /etc/mini_httpd/mini_httpd.conf \
    && printf "%s /opt/iptv-svc/xmltv-build\n" "${JTV2XMLTV_CRON}" >> /var/spool/cron/crontabs/root \
    && cd /opt/iptv-svc \
    && wget "https://raw.githubusercontent.com/XMLTV/xmltv/master/xmltv.dtd" -O xmltv.dtd \
    && printf "#!/bin/sh\nwget $JTV2XMLTVURL -O /opt/iptv-svc/jtv.zip &&jtv2xmltv -i /opt/iptv-svc/jtv.zip -o /www/jtv2xmltv/tvguide.xml\ngzip -k /www/jtv2xmltv/tvguide.xml\n" > xmltv-build \
    && printf "#!/bin/sh\n" > entrypoint.sh \
    && printf "/opt/iptv-svc/xmltv-build\n" >> entrypoint.sh \
    && printf "crond\n" >> entrypoint.sh \
    && printf "nohup mini_httpd -C /etc/mini_httpd/mini_httpd.conf -D > /dev/null 2>&1&\n" >> entrypoint.sh \
    && printf "/usr/local/bin/udpxy -vTp 4022\n" >> entrypoint.sh \
    && chmod +x ./xmltv-build \
    && chmod +x ./entrypoint.sh

EXPOSE 4022/TCP 4023/TCP

WORKDIR /opt/iptv-svc

ENTRYPOINT ["./entrypoint.sh"]
