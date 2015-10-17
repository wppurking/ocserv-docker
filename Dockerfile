FROM ubuntu:14.04
MAINTAINER Wyatt Pan <wppurking@gmail.com> Aplusplus <njuaplusplus at googlemail>

RUN apt-get update \
 && apt-get install -y build-essential libwrap0-dev libpam0g-dev \
      libdbus-1-dev libreadline-dev libnl-route-3-dev libpcl1-dev \
      libopts25-dev autogen libgnutls28 libgnutls28-dev libseccomp-dev \
      iptables wget gnutls-bin libprotobuf-c0-dev protobuf-c-compiler \
      libprotobuf-dev protobuf-compiler libprotoc-dev libtalloc-dev libhttp-parser-dev \
 && cd /root && wget http://pkgs.fedoraproject.org/repo/pkgs/ocserv/ -O index.html \
 && export ocserv_version=$(grep -o '[0-9]*\.[0-9]*\.[0-9]*' index.html | tail -1) \
 && wget http://pkgs.fedoraproject.org/repo/pkgs/ocserv/ocserv-$ocserv_version.tar.xz/ -O index.html \
 && export ocserv_hash=$(grep -o -E '<td><a href=.*</a></td>' index.html | grep -o -E '[0-9a-z]+/') \
 && wget http://pkgs.fedoraproject.org/repo/pkgs/ocserv/ocserv-$ocserv_version.tar.xz/${ocserv_hash}ocserv-$ocserv_version.tar.xz \
 && tar xvf ocserv-$ocserv_version.tar.xz \
 && cd ocserv-$ocserv_version \
 && ./configure --prefix=/usr --sysconfdir=/etc --with-local-talloc \
 && make && make install \
 && rm -rf /root/index.html && rm -rf ocserv-* \
 && rm -rf /var/lib/apt/lists/*

ADD ./certs /opt/certs
RUN certtool --generate-privkey --outfile /opt/certs/ca-key.pem \
 && certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem \
      --template /opt/certs/ca-tmp --outfile /opt/certs/ca-cert.pem \
 && certtool --generate-privkey --outfile /opt/certs/server-key.pem \
 && certtool --generate-certificate --load-privkey /opt/certs/server-key.pem \
      --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem \
      --template /opt/certs/serv-tmp --outfile /opt/certs/server-cert.pem

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

WORKDIR /etc/ocserv
CMD ["vpn_run"]
