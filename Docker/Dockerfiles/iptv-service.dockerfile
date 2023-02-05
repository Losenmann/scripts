FROM alpine:latest

ARG JTV2XMLTV_URL
ARG JTV2XMLTV_CRON

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
    && mkdir -p /opt/iptv-svc/src \
    && mkdir -p /opt/iptv-svc/jtv2xmltv \
    && mkdir -p /www/jtv2xmltv \
    && chown -R minihttpd /www \
    && /opt/iptv-svc/src \
    && git clone https://github.com/pcherenkov/udpxy.git \
        && cd "$(basename "$_" .git)" \
        && make \
        && make install \
        && cd .. \
    && git clone https://github.com/tataranovich/jtv2xmltv.git \
        && cd "$(basename "$_" .git)" \
        && python3 setup.py install \
        && cd .. \
    && wget https://raw.githubusercontent.com/XMLTV/xmltv/master/xmltv.dtd -O /opt/iptv-svc/jtv2xmltv/xmltv.dtd \
    && mv /etc/mini_httpd/mini_httpd.conf /etc/mini_httpd/mini_httpd.conf.orig \
    && printf "port=4023\nuser=minihttpd\ndir=/www\ndata_dir=/www/jtv2xmltv\nnochroot" > /etc/mini_httpd/mini_httpd.conf \
    && printf "xmltv () { wget $JTV2XMLTVURL -O /opt/iptv-svc/jtv2xmltv/jtv.zip &&jtv2xmltv -i /opt/iptv-svc/jtv2xmltv/jtv.zip -o /www/jtv2xmltv/tvguide.xml; }" >> /root/.bashrc \
    && printf "xmltv" > /opt/iptv-svc/jtv2xmltv/xmltv_build.sh \
    && printf "%s /opt/iptv-svc/jtv2xmltv/xmltv_build.sh" ${JTV2XMLTV_CRON} >> /etc/crontabs/root \
    && printf "nohup mini_httpd -C /etc/mini_httpd/mini_httpd.conf -D > /dev/null 2>&1&" > /opt/iptv-svc/entrypoint.sh \
    && printf "\n/usr/local/bin/udpxy -vTp 4022" >> /opt/iptv-svc/entrypoint.sh \
    && chmod +x /opt/iptv-svc/jtv2xmltv/xmltv_build.sh \
    && chmod +x /opt/iptv-svc/entrypoint.sh \
    && source /root/.bashrc

EXPOSE 4022/TCP 4023/TCP

WORKDIR /opt/iptv

ENTRYPOINT ["entrypoint.sh"]
#ENTRYPOINT ["/usr/local/bin/udpxy", "-vTp", "4022"]
#CMD ["/usr/local/bin/udpxy", "-v", "-T", "-p", "4022"]
