# syntax=docker/dockerfile:1.2
FROM alpine:latest AS builder
WORKDIR /src
RUN \
	apk --no-cache --no-progress upgrade \
	&& apk --no-cache --no-progress add ca-certificates curl tzdata jq

RUN \
	curl -sSL "$(curl -fsSL https://changelogs-live.fivem.net/api/changelog/versions/linux/server | jq -r .latest_download)" -o fx.tar.xz \
	&& tar -xf fx.tar.xz && rm -f fx.tar.xz

FROM scratch

COPY --from=builder /src/alpine/. /.

RUN \
	apk --no-cache --no-progress update \
	&& apk --no-cache --no-progress add ca-certificates openssl tini tzdata \
	&& rm -rf /var/cache/apk/*

COPY /entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /opt/cfx-server
RUN set -eux; \
	cp /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime && echo "Europe/Copenhagen" > /etc/timezone \
	&& addgroup -g 1000 -S fxserver; adduser -u 1000 -D -S -G fxserver fxserver \
	&& mkdir -p /opt/cfx-server/resources /opt/cfx-server/cache /opt/cfx-server/crashes \
	&& chown fxserver:fxserver /opt/cfx-server/resources /opt/cfx-server/cache /opt/cfx-server/crashes \
	&& touch /opt/cfx-server/server.cfg

USER fxserver:fxserver

VOLUME ["/opt/cfx-server/resources", "/opt/cfx-server/cache", "/opt/cfx-server/crashes"]

EXPOSE 30120/tcp 30120/udp

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["+exec", "server.cfg"]
