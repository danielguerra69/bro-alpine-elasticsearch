![bro-logo](https://www.bro.org/images/bro-eyes.png)

### About

Bro-2.5 (git) on alpine linux with elasticsearch 2+ plugin.
It was build with danielguerra/alpine-bro-build.
The extracted size is 27M.

### Usage

Elasticsearch:
```bash
docker run -d --name elasticsearch elasticsearch
```

This image:
```bash
docker run -ti --rm -v /Users/PCAP:/data/pcap --link elasticsearch:elasticsearch  danielguerra/bro-alpine-elasticsearch
bro -r ../pcap/my.pcap
```

All logging goes to elasticsearch, there is no local log.

If you want a local log run the following from the bro-alpine-elasticsearch commandline

```bash
sed -i "s/default_writer = WRITER_NONE/default_writer = WRITER_ASCII/g" /usr/local/share/bro/base/frameworks/logging/main.bro
bro -r ../pcap/my.pcap
```
