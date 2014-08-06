## 用途

因为安装一个 Open Connect 的步骤实在太麻烦了, 特别对于新手, 所以特意参考了 jpetazzo 的 [dockvpn](https://github.com/jpetazzo/dockvpn) 弄了一个 ocserv 的.

不过现在比较简单, 基本上是纯手工制作的 Docker Box, 接下来会对 Box 进行一些调整, 例如将基础依赖库单独建立一个 Box 啥啥啥的.


## 简单部署
在安装好 Docker 1.0+ 并且正常启动 Docker 后:

* `cd ~;git clone https://github.com/wppurking/ocserv-docker.git` : 将当前 repo 下载, 拥有可调整的 ocserv.conf 配置文件以及 ocpasswd 用户密码文件
* `docker run -d --privileged -v ~/ocserv-docker/ocserv:/etc/ocserv -p 443:443/udp -p 443:443/tcp wppurking/ocserv`  :  Box 自动下载. ocserv 的一些功能需要 Docker 在 privileged 权限下处理
* `docker ps -aq | xargs docker logs` : 检查是否正常运行. 

```
listening (TCP) on 0.0.0.0:443...
listening (TCP) on [::]:443...
listening (UDP) on 0.0.0.0:443...
listening (UDP) on [::]:443...
ocserv[12]: main: initializing control unix socket: /var/run/occtl.socket
ocserv[12]: main: initialized ocserv 0.8.2
ocserv[13]: sec-mod: sec-mod initialized (socket: /var/run/ocserv-socket.12)
```

## 使用
* 初始化好的两个账户:  wyatt:616  holly:525
* 如果主服务器上开启了 iptables, 一定要记得将 443 端口的 tcp 与 udp 都开放
* 已经做了其能够处理的下发路由数量 (ocserv.conf 中, 感谢: kevinzhow 的 [route.sh](https://gist.github.com/kevinzhow/9661732) 和 [ip_cook.rb](https://gist.github.com/kevinzhow/9661753) )


## 自定义证书, 密钥, 用户名
因为是构建一个独立的 box 进行分发, 方便快速部署一个 ocserv, 所以将证书, 密钥, 用户都集成在里面了, 此刻方便使用. 如果对于有担心的, 可以 `docker run -t -i wppurking/ocserv bash` 进入到 box 中适用 ocpasswd 和 certtool 重新进行处理, 具体操作步骤参考 [[原创]linode vps debian7.5安装配置ocserv(OpenConnect server)](http://luoqkk.com/linode-vps-debian-installation-and-configuration-ocserv-openconnect-server.html)


## 信息
* Box Size: 421.5 MB
* 基础 Box: ubuntu:latest   (278.6 MB)
* 测试过的环境:  Linode 1G Ubuntu 12.04 LTS, Vultr 768MB Ubuntu 14.04 LTS