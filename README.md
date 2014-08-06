## 用途

因为安装一个 Open Connect 的步骤实在太麻烦了, 特别对于新手, 所以特意参考了 jpetazzo 的 [dockvpn](https://github.com/jpetazzo/dockvpn) 弄了一个 ocserv 的.

不过现在比较简单, 基本上是纯手工制作的 Docker Box, 接下来会对 Box 进行一些调整, 例如将基础依赖库单独建立一个 Box 啥啥啥的.


## 使用
在安装好 Docker 1.0+ 并且正常启动 Docker 后:

* docker pull wppurking/ocserv : 从 Docker Hub 中拽下 ocserv box
* docker run --privileged -d -p 443:6379/tcp -p 443:6379/udp wppurking/ocserv  :  需要在 Docker 的 privileged 权限下, 打开 443 端口映射(box 内为 6379 端口是因为我构建这个的服务器上 443 端口被其他服务占用着, 历史遗留原因)