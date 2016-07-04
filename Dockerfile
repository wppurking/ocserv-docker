FROM ubuntu:trusty
MAINTAINER Wyatt Pan <wppurking@gmail.com>

ADD ./certs /opt/certs
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*
WORKDIR /etc/ocserv

RUN apt-get update && apt-get install build-essential wget xz-utils libgnutls28-dev gnutls-bin libev-dev libwrap0-dev libpam0g-dev libseccomp-dev libreadline-dev libnl-route-3-dev libkrb5-dev liboath-dev libprotobuf-c0-dev libtalloc-dev libhttp-parser-dev libpcl1-dev libopts25-dev autogen pkg-config nettle-dev protobuf-c-compiler gperf liblockfile-bin nuttcp lcov iptables -y


RUN cd /root && wget https://github.com/Cyan4973/lz4/releases/latest -o lz4.html && export lz4_version=$(cat lz4.html | grep -m 1 -o 'r[0-9][0-9][0-9]') \
	&& wget https://github.com/Cyan4973/lz4/archive/$lz4_version.tar.gz && tar xvf $lz4_version.tar.gz && cd lz4-$lz4_version && make install && ln -sf /usr/local/lib/liblz4.* /usr/lib/ \
	&& wget http://www.infradead.org/ocserv/download.html && export ocserv_version=$(cat download.html | grep -o '[0-9]*\.[0-9]*\.[0-9]*') \
	&& cd /root && wget ftp://ftp.infradead.org/pub/ocserv/ocserv-$ocserv_version.tar.xz && tar xvf ocserv-$ocserv_version.tar.xz \
	&& cd ocserv-$ocserv_version && sed -i 's/define DEFAULT_CONFIG_ENTRIES 96/define DEFAULT_CONFIG_ENTRIES 200/g' src/vpn.h  \
    && ./configure --prefix=/usr --sysconfdir=/etc --with-local-talloc && make && make install \
	&& rm -rf /root/* \

    && ca_cn=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed 's/Your desired authority name/$ca_cn/g' /opt/certs/ca-tmp" \
    && ca_org=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed 's/Your desired orgnization name/$ca_org/g' /opt/certs/ca-tmp" \
    && serv_domain=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed 's/yourdomainname/$serv_domain/g' /opt/certs/serv-tmp" \
    && serv_org=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed 's/Your desired orgnization name/$serv_org/g' /opt/certs/serv-tmp" \

    && certtool --generate-privkey --outfile /opt/certs/ca-key.pem && certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem --template /opt/certs/ca-tmp --outfile /opt/certs/ca-cert.pem && certtool --generate-privkey --outfile /opt/certs/server-key.pem && certtool --generate-certificate --load-privkey /opt/certs/server-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/serv-tmp --outfile /opt/certs/server-cert.pem

CMD ["vpn_run"]
