# clash-transparent-proxy-docker

使用 Docker 和 clash 容器进行透明代理

## 3个docker的特点
- morzlee/clash-premium-transparent-proxy-docker:latest 使用最新premium内核，支持tun模式，使用tproxy处理，支持udp和tcp，但是只支持x86架构
- morzlee/clash-transparent-proxy-docker:latest 使用最新clash内核，不支持tun模式，使用tproxy处理，支持udp和tcp，支持linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64架构
- morzlee/clash-transparent-redir-proxy-docker:latest 使用最新clash内核，不支持tun模式，使用redir处理，只支持tcp，支持linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64架构

## 特点

- [x] IPv4 TCP 透明代理
- [x] IPv4 UDP 透明代理
- [x] FULL CONE NAT


## 使用方法

### docker

1. 开启混杂模式

    ```bash
    ip a # 查看你的网卡名字，Openwrt一般是br-lan
    ip link set <你的网卡名> promisc on
    ```

2. Docker 创建 macvlan 网络

    ```bash
    docker network create -d macvlan --subnet=<局域网的CIDR地址块> --gateway=<局域网的网关> -o parent=<网卡名> <macvlan网络名>
    ```

3. 编写好 clash 的配置文件，必须将 Tproxy 端口设置为 7893, DNS端口设置为 53

4. 运行容器

    ```bash
    docker run -m 512m --net=op --ip=10.0.0.30<容器ip> -d -v /root/clash/config.yaml:/root/.config/clash/config.yaml --name clash --restart=always --privileged morzlee/clash-transparent-proxy-docker:latest
    ```

5. 把客户端网关改为<容器ip>


