FROM alpine:3.4

MAINTAINER Daniel Guerra <daniel.guerra69@gmail.com>

RUN echo "===> Adding dependencies..." && \
    apk add --update zlib openssl libstdc++ libpcap geoip libgcc libcurl && \
    rm -rf /var/cache/apk/*
# add precompiled bro
ADD bro.tar.gz /

RUN mv /usr/local/lib/bro/plugins /usr/local/share/bro
# set volume
VOLUME ["/data/logs", "/data/config","/data/pcap"]
# set workdir
WORKDIR /data/logs
# set elasticsearch server
RUN sed -i "s/127.0.0.1/elasticsearch/g" /usr/local/lib/bro/plugins/Bro_ElasticSearch/scripts/init.bro
# enable elasticsearch
RUN echo "@load plugins/Bro_ElasticSearch/scripts/init" >> /usr/local/share/bro/base/init-default.bro
# stop local logging
RUN sed -i "s/default_writer = WRITER_ASCII/default_writer = WRITER_NONE/g" /usr/local/share/bro/base/frameworks/logging/main.bro
# set the json separator to _
RUN sed -i "s/default_scope_sep = \"\.\"/default_scope_sep = \"_\"/g" /usr/local/share/bro/base/frameworks/logging/main.bro
# set the path
ENV BROPATH .:/data/config:/usr/local/share/bro:/usr/local/share/bro/policy:/usr/local/share/bro/site

CMD [ "/bin/sh" ]
