## Quick Start

```
cd /root/
wget https://github.com/njuaplusplus/docker-ocserv/archive/master.zip
unzip master.zip
mv docker-ocserv-master docker-ocserv
cd docker-ocserv
```

根据需求修改 `docker-compose.yml`, 尤其是 `SERVER_CN` 要对应你的域名.
`P12_PASS` 为你导出证书的密码, 下次导入要使用.

然后使用 [docker-compose](https://github.com/docker/compose/releases)
启动:

```
docker-compose up -d
```

## 参数说明

有空再补全.....
