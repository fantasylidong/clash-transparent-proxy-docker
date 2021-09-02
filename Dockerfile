# build clash dashboard
FROM ubuntu:latest as node_builder
# fix https://github.com/conda-forge/pygridgen-feedstock/issues/10#issuecomment-365914605
RUN apt-get update && apt-get install -y libgl1-mesa-glx
WORKDIR /clash-dashboard-src
RUN git clone https://github.com/Dreamacro/clash-dashboard.git --depth=1 /clash-dashboard-src
RUN npm install
RUN npm run build
RUN mv ./dist /clash_ui

# build clash
FROM golang:alpine as builder

RUN apk add --no-cache make git && \
    wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb && \
    git clone https://github.com/Dreamacro/clash.git /clash-src

WORKDIR /clash-src
RUN git checkout v1.4.1 && \
    go mod download

COPY Makefile /clash-src/Makefile
RUN make current

FROM alpine:latest
ENV TZ=Asia/Shanghai
# RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.11/main/" > /etc/apk/repositories
COPY --from=builder /clash-src/bin/clash /usr/local/bin/
COPY --from=builder /Country.mmdb /root/.config/clash/
COPY --from=node_builder /clash_ui /root/.config/clash/ui
COPY entrypoint.sh /usr/local/bin/
COPY config.yaml /root/.config/clash/

RUN apk add --no-cache \
    ca-certificates  \
    bash  \
    curl \
    iptables  \
    bash-doc  \
    bash-completion  \
    rm -rf /var/cache/apk/* && \
    chmod a+x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["clash"]
