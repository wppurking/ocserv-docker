## Super Quick Start

```
wget https://raw.githubusercontent.com/njuaplusplus/docker-ocserv/master/docker-compose.yml
```

根据需求修改 `docker-compose.yml`, 尤其是 `SERVER_CN` 要对应你的域名.
`P12_PASS` 为你导出证书的密码, 下次导入要使用.

选择挂载目录, 如果目录里已有证书和配置文件 `ocserv.con`, 则不会重复生成或者下载. 否则会自动生成证书, 下载配置文件.

然后使用 [docker-compose](https://github.com/docker/compose/releases)
启动:

```
docker-compose up -d
```

## 参数说明

有空再补全.....
