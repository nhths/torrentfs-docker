FROM golang:1.23.5-alpine3.21 AS downloader

ARG TORRENTFS_VERSION=latest

RUN go install github.com/anacrolix/torrent/...@${TORRENTFS_VERSION}


FROM debian:stable-slim

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
    fuse \
    bindfs \
    procps \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/log/supervisord /var/run/supervisord

WORKDIR /

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY start.sh /
RUN chmod +x /start.sh

COPY --from=downloader /go/bin/torrentfs ./torrentfs

ENTRYPOINT [ "/start.sh" ]
