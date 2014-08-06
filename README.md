## 用途

因为安装一个 Open Connect 的步骤实在太麻烦了, 特别对于新手, 所以特意参考了 jpetazzo 的 [dockvpn](https://github.com/jpetazzo/dockvpn) 弄了一个 ocserv 的.

不过现在比较简单, 基本上是纯手工制作的 Docker Box, 接下来会对 Box 进行一些调整, 例如将基础依赖库单独建立一个 Box 啥啥啥的.


## 使用
在安装好 Docker 1.0+ 并且正常启动 Docker 后:

* `cd ~;git clone https://github.com/wppurking/ocserv-docker.git` : 将当前 repo 下载, 拥有可调整的 ocserv.conf 配置文件以及 ocpasswd 用户密码文件
* `docker run -d --privileged -v ~/ocserv-docker/ocserv:/etc/ocserv -p 443:6379/udp -p 443:6379/tcp wppurking/ocserv`  :  Box 自动下载. 需要在 Docker 的 privileged 权限下, 打开 443 端口映射(box 内为 6379 端口是因为我构建这个的服务器上 443 端口被其他服务占用着, 历史遗留原因)
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


## 注意
* 如果主服务器上开启了 iptables, 一定要记得将 443 端口的 tcp 与 udp 都开放
* 如果需要修改 ocpasswd 中的密码, 因为我不知道他是使用的什么进行的加密, 所以需要自定自己处理 ocpasswd 文件内的内容.
* 初始化好的两个账户:  wyatt:616  holly:525