FROM ubuntu:trusty
MAINTAINER Wyatt Pan <wppurking@gmail.com>

ADD ./certs /opt/certs
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*
WORKDIR /etc/ocserv

RUN apt-get update && apt-get install build-essential libwrap0-dev libpam0g-dev libdbus-1-dev libreadline-dev libnl-route-3-dev  libpcl1-dev libopts25-dev autogen libgnutls28 libgnutls28-dev libseccomp-dev iptables wget gnutls-bin libprotobuf-c0-dev protobuf-c-compiler libprotobuf-dev protobuf-compiler libprotoc-dev libtalloc-dev libhttp-parser-dev libev4 libev-dev -y


RUN cd /root && wget http://www.infradead.org/ocserv/download.html && export ocserv_version=$(cat download.html | grep -o '[0-9]*\.[0-9]*\.[0-9]*') \
	&& wget ftp://ftp.infradead.org/pub/ocserv/ocserv-$ocserv_version.tar.xz && tar xvf ocserv-$ocserv_version.tar.xz \
	&& cd ocserv-$ocserv_version && sed -i 's/define DEFAULT_CONFIG_ENTRIES 96/define DEFAULT_CONFIG_ENTRIES 200/g' src/vpn.h  \
    && ./configure --prefix=/usr --sysconfdir=/etc --with-local-talloc && make && make install \
	&& rm -rf /root/download.html && rm -rf ocserv-* \

    && ca_cn=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed 's/Your desired authority name/$ca_cn/g' /opt/certs/ca-tmp" \
    && ca_org=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed 's/Your desired orgnization name/$ca_org/g' /opt/certs/ca-tmp" \
    && serv_domain=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed 's/yourdomainname/$serv_domain/g' /opt/certs/serv-tmp" \
    && serv_org=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed 's/Your desired orgnization name/$serv_org/g' /opt/certs/serv-tmp" \

    && certtool --generate-privkey --outfile /opt/certs/ca-key.pem && certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem --template /opt/certs/ca-tmp --outfile /opt/certs/ca-cert.pem && certtool --generate-privkey --outfile /opt/certs/server-key.pem && certtool --generate-certificate --load-privkey /opt/certs/server-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/serv-tmp --outfile /opt/certs/server-cert.pem

CMD ["vpn_run"]
