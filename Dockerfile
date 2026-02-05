FROM debian:trixie AS builder
RUN <<EOF
sed -Ei 's/deb\.debian\.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources
apt update
apt -y install wget
EOF

ARG CORPLINK_VERSION=5.4
ARG GOST_VERSION=3.2.6
WORKDIR /app
RUN <<EOF
wget -O- https://github.com/PinkD/corplink-rs/releases/download/$CORPLINK_VERSION/corplink-rs-${CORPLINK_VERSION}-linux-x86_64.tar.gz |
  tar zxf - corplink-rs
wget -O- https://github.com/go-gost/gost/releases/download/v$GOST_VERSION/gost_${GOST_VERSION}_linux_amd64v3.tar.gz |
  tar zxf - gost
EOF

FROM debian:trixie
RUN <<EOF
sed -Ei 's/deb\.debian\.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources
apt update
apt -y install bind9-dnsutils curl iproute2 iputils-ping less procps s6 vim wget
EOF

COPY --from=builder /app/ /app/

WORKDIR /tmp
COPY s6/ /etc/s6/
CMD ["/usr/bin/s6-svscan", "/etc/s6"]
