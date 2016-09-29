FROM alpine:3.4

MAINTAINER Daniel Guerra <daniel.guerra69@gmail.com>

RUN echo "===> Adding dependency..." && \
    apk add --update zlib openssl libstdc++ libpcap geoip libgcc libcurl && \
    rm -rf /var/cache/apk/*

ADD bro.tar.gz /

VOLUME ["/data/logs", "/data/config"]
WORKDIR /data/logs

ENV BROPATH .:/data/config:/usr/local/share/bro:/usr/local/share/bro/policy:/usr/local/share/bro/site

CMD [ "/bin/sh" ]
