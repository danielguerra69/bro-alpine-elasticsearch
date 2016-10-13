FROM alpine:3.4

MAINTAINER Daniel Guerra <daniel.guerra69@gmail.com>

ENV PLUGINS "/usr/local/lib/bro/plugins"
ENV SCRIPTS "/usr/local/share/bro/base"

RUN echo "===> Adding dependencies..." && \
    apk add --update zlib openssl libstdc++ libpcap geoip libgcc libcurl curl && \
    rm -rf /var/cache/apk/*
# add precompiled bro
ADD bro.tar.gz /
# add logs to elasticsearch filte
ADD logs-to-elasticsearch.bro $PLUGINS/Bro_ElasticSearch/scripts/Bro/ElasticSearch/logs-to-elasticsearch.bro
# set volume
VOLUME ["/data/logs", "/data/config","/data/pcap"]
# set workdir
WORKDIR /data/logs
# set elasticsearch server for link
RUN sed -i "s/127.0.0.1/elasticsearch/g" $PLUGINS/Bro_ElasticSearch/scripts/init.bro
# increase transfer timeout to 60s
RUN sed -i "s/const transfer_timeout = 2secs/const transfer_timeout = 60secs/" $PLUGINS/Bro_ElasticSearch/scripts/init.bro
# enable elasticsearch
RUN echo "@load Bro/ElasticSearch/logs-to-elasticsearch" >> $SCRIPTS/init-default.bro
# enable tcprs
RUN echo "@load Bro/TCPRS" >> $SCRIPTS/init-default.bro
# stop local logging
RUN sed -i "s/default_writer = WRITER_ASCII/default_writer = WRITER_NONE/g" $SCRIPTS/frameworks/logging/main.bro
# Do some elasticsearch tweaks (couldnt solve it with mapping :`( )
# elastic is not happy about version, type change count/string
RUN sed -i "s/version:     count           \&log/socks_version:     count           \&log/g" $SCRIPTS/protocols/socks/main.bro
RUN sed -i "s/\$version=/\$socks_version=/g" $SCRIPTS/protocols/socks/main.bro
RUN sed -i "s/version:          string \&log/ssl_version:     string \&log/g" $SCRIPTS/protocols/ssl/main.bro
RUN sed -i "s/\$version=/\$ssl_version=/g" $SCRIPTS/protocols/ssl/main.bro
RUN sed -i "s/version:         count        \&log/ssh_version:         count        \&log/g" $SCRIPTS/protocols/ssh/main.bro
RUN sed -i "s/\$version =/\$ssh_version =/g" $SCRIPTS/protocols/ssh/main.bro
RUN sed -i "s/version: string \&log/snmp_version: string \&log/g" $SCRIPTS/protocols/snmp/main.bro
RUN sed -i "s/\$version=/\$snmp_version=/g" $SCRIPTS/protocols/snmp/main.bro
# set the path
ENV BROPATH .:/data/config:/usr/local/share/bro:/usr/local/share/bro/policy:/usr/local/share/bro/site
# add entrypoint to set bro mapping
ADD docker-entrypoint.sh /usr/sbin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "/bin/sh" ]
