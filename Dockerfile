FROM alpine:3.4

MAINTAINER Daniel Guerra <daniel.guerra69@gmail.com>

RUN echo "===> Adding dependencies..." && \
    apk add --update zlib openssl libstdc++ libpcap geoip libgcc libcurl curl && \
    rm -rf /var/cache/apk/*
# add precompiled bro
ADD bro.tar.gz /
# add logs to elasticsearch filte
ADD logs-to-elasticsearch.bro /usr/local/lib/bro/plugins/Bro_ElasticSearch/scripts/Bro/ElasticSearch/logs-to-elasticsearch.bro
# set volume
VOLUME ["/data/logs", "/data/config","/data/pcap"]
# set workdir
WORKDIR /data/logs
# set elasticsearch server for link
RUN sed -i "s/127.0.0.1/elasticsearch/g" /usr/local/lib/bro/plugins/Bro_ElasticSearch/scripts/init.bro
# increase transfer timeout to 60s
RUN sed -i "s/const transfer_timeout = 2secs/const transfer_timeout = 60secs/" /usr/local/lib/bro/plugins/Bro_ElasticSearch/scripts/init.bro
# enable elasticsearch
RUN echo "@load Bro/ElasticSearch/logs-to-elasticsearch" >> /usr/local/share/bro/base/init-default.bro
# stop local logging
RUN sed -i "s/default_writer = WRITER_ASCII/default_writer = WRITER_NONE/g" /usr/local/share/bro/base/frameworks/logging/main.bro
# set the path
ENV BROPATH .:/data/config:/usr/local/share/bro:/usr/local/share/bro/policy:/usr/local/share/bro/site
# add entrypoint to set bro mapping
ADD docker-entrypoint.sh /usr/sbin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "/bin/sh" ]
