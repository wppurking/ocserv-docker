FROM ubuntu:trusty
MAINTAINER Wyatt Pan <wppurking@gmail.com>

ADD ./certs /opt/certs
ADD ./bin /usr/local/bin
ADD dnsmasq.conf /usr/local/etc/dnsmasq.conf
RUN chmod a+x /usr/local/bin/*
WORKDIR /etc/ocserv

# china timezone
RUN echo "Asia/Shanghai" > /etc/timezone

# install compiler, dependencies, tools , dnsmasq
RUN apt-get update && apt-get install -y \
    build-essential wget xz-utils libgnutls28-dev \
    libev-dev libwrap0-dev libpam0g-dev libseccomp-dev libreadline-dev \
    libnl-route-3-dev libkrb5-dev liboath-dev libtalloc-dev \
    libhttp-parser-dev libpcl1-dev libopts25-dev autogen pkg-config nettle-dev \
    gnutls-bin gperf liblockfile-bin nuttcp lcov iptables unzip dnsmasq \
    && rm -rf /var/lib/apt/lists/*

# configuration dnsmasq
RUN mkdir -p /temp && cd /temp \
    && wget https://github.com/felixonmars/dnsmasq-china-list/archive/master.zip \
    && unzip master.zip \
    && cd dnsmasq-china-list-master \
    && cp *.conf /etc/dnsmasq.d/ \
    && cd / && rm -rf /temp

# configuration lz4
RUN mkdir -p /temp && cd /temp \
    && wget https://github.com/lz4/lz4/releases/latest -O lz4.html \
    && export lz4_version=$(cat lz4.html | grep -m 1 -o 'v[0-9]\.[0-9]\.[0-9]') \
    && export lz4_suffix=$(cat lz4.html | grep -m 1 -o '[0-9]\.[0-9]\.[0-9]') \
    && wget https://github.com/lz4/lz4/archive/$lz4_version.tar.gz \
    && tar xvf $lz4_version.tar.gz \
    && cd lz4-$lz4_suffix \
    && make install \
    && ln -sf /usr/local/lib/liblz4.* /usr/lib/ \
    && cd / && rm -rf /temp

# configuration ocserv
RUN mkdir -p /temp && cd /temp \
    && wget https://ocserv.gitlab.io/www/download.html \
    && export ocserv_version=$(cat download.html | grep -o '[0-9]*\.[0-9]*\.[0-9]*') \
    && wget ftp://ftp.infradead.org/pub/ocserv/ocserv-$ocserv_version.tar.xz \
    && tar xvf ocserv-$ocserv_version.tar.xz \
    && cd ocserv-$ocserv_version \
    && ./configure --prefix=/usr --sysconfdir=/etc --with-local-talloc \
    && make && make install \
    && cd / && rm -rf /temp

# generate sll keys
RUN cd /opt/certs && ls \
    && ca_cn=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed -i 's/Your desired authority name/$ca_cn/g' /opt/certs/ca-tmp" \
    && ca_org=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed -i 's/Your desired orgnization name/$ca_org/g' /opt/certs/ca-tmp" \
    && serv_domain=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-12} | head -n 1) && bash -c -i "sed -i 's/yourdomainname/$serv_domain/g' /opt/certs/serv-tmp" \
    && serv_org=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1) && bash -c "sed -i 's/Your desired orgnization name/$serv_org/g' /opt/certs/serv-tmp" \
    && user_id=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-10} | head -n 1) && bash -c "sed -i 's/user/$user_id/g' /opt/certs/user-tmp"

# generate [ca-key.pem] -> ca-cert.pem [ca-key]
RUN certtool --generate-privkey --outfile /opt/certs/ca-key.pem && certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem --template /opt/certs/ca-tmp --outfile /opt/certs/ca-cert.pem
# generate [server-key.pem] -> server-cert.pem [ca-key, server-key] 
RUN certtool --generate-privkey --outfile /opt/certs/server-key.pem && certtool --generate-certificate --load-privkey /opt/certs/server-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/serv-tmp --outfile /opt/certs/server-cert.pem
# generate [user-key.pem] -> user-cert.pem [ca-key, user-key]
RUN certtool --generate-privkey --outfile /opt/certs/user-key.pem && certtool --generate-certificate --load-privkey /opt/certs/user-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/user-tmp --outfile /opt/certs/user-cert.pem
# generate user.p12 [user-key, user-cert, ca-cert]
RUN openssl pkcs12 -export -inkey /opt/certs/user-key.pem -in /opt/certs/user-cert.pem -certfile /opt/certs/ca-cert.pem -out /opt/certs/user.p12 -passout pass:616

CMD ["vpn_run"]
