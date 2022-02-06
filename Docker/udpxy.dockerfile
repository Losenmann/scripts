FROM alpine:latest
RUN apk add make gcc libc-dev git python3 py3-setuptools openrc nginx \
######## UDPXY ########
        && wget http://www.udpxy.com/download/udpxy/udpxy-src.tar.gz \
        && tar zxf udpxy-src.tar.gz \
        && cd udpxy-* && make && make install \
##### JVT-2-XMLTV #####
        && git clone https://github.com/tataranovich/jtv2xmltv.git \
        && cd jtv2xmltv && python3 setup.py install \
######## NGINX ########
        && adduser -D -g 'www' www \
        && mkdir /www \
        && chown -R www:www /var/lib/nginx \
        && chown -R www:www /www \
        && mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak \
        && echo -e 'user                            www;' > /etc/nginx/nginx.conf \
        && echo -e 'worker_processes                auto;' >> /etc/nginx/nginx.conf \
        && echo -e 'error_log                       /var/log/nginx/error.log warn;' >> /etc/nginx/nginx.conf \
        && echo -e 'events {worker_connections 1024;}' >> /etc/nginx/nginx.conf \
        && echo -e 'http {' >> /etc/nginx/nginx.conf \
        && echo -e '    include                     /etc/nginx/mime.types;' >> /etc/nginx/nginx.conf \
        && echo -e '    default_type                application/octet-stream;' >> /etc/nginx/nginx.conf \
        && echo -e '    sendfile                    on;' >> /etc/nginx/nginx.conf \
        && echo -e '    access_log                  /var/log/nginx/access.log;' >> /etc/nginx/nginx.conf \
        && echo -e '    keepalive_timeout           3000;' >> /etc/nginx/nginx.conf \
        && echo -e '    server {' >> /etc/nginx/nginx.conf \
        && echo -e '        listen                  4021;' >> /etc/nginx/nginx.conf \
        && echo -e '        root                    /www;' >> /etc/nginx/nginx.conf \
        && echo -e '        index                   index.html index.htm;' >> /etc/nginx/nginx.conf \
        && echo -e '        server_name             localhost;' >> /etc/nginx/nginx.conf \
        && echo -e '        client_max_body_size    32m;' >> /etc/nginx/nginx.conf \
        && echo -e '        error_page              500 502 503 504  /50x.html;' >> /etc/nginx/nginx.conf \
        && echo -e '        location = /50x.html {' >> /etc/nginx/nginx.conf \
        && echo -e '              root              /var/lib/nginx/html;' >> /etc/nginx/nginx.conf \
        && echo -e '        }' >> /etc/nginx/nginx.conf \
        && echo -e '    }' >> /etc/nginx/nginx.conf \
        && echo -e '}' >> /etc/nginx/nginx.conf \
        && echo -e '<!DOCTYPE html>' > /www/index.html \
        && echo -e '<html lang="en">' >> /www/index.html \
        && echo -e '<head>' >> /www/index.html \
        && echo -e '    <meta charset="utf-8" />' >> /www/index.html \
        && echo -e '    <title>HTML5</title>' >> /www/index.html \
        && echo -e '</head>' >> /www/index.html \
        && echo -e '<body>' >> /www/index.html \
        && echo -e '    Service is online' >> /www/index.html \
        && echo -e '</body>' >> /www/index.html \
        && echo -e '</html>' >> /www/index.html \
        && openrc && touch /run/openrc/softlevel \
        && cp -f /jtv2xmltv/ /www/tv.xml.zip
        && apk del make gcc libc-dev git
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
