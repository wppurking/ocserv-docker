FROM ubuntu:trusty
MAINTAINER Wyatt Pan <wppurking@gmail.com>

ADD ./certs /opt/certs
ADD ./bin /usr/local/bin
ADD dnsmasq.conf /dnsmasq.conf
RUN chmod a+x /usr/local/bin/*
WORKDIR /etc/ocserv

# china timezone
RUN echo "Asia/Shanghai" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

# install compiler, dependencies, tools , dnsmasq
RUN apt-get update && apt-get install -y \
    build-essential wget xz-utils libgnutls28-dev \
    libev-dev libwrap0-dev libpam0g-dev libseccomp-dev libreadline-dev \
    libnl-route-3-dev libkrb5-dev liboath-dev libprotobuf-c0-dev libtalloc-dev \
    libhttp-parser-dev libpcl1-dev libopts25-dev autogen pkg-config nettle-dev \
    protobuf-c-compiler gnutls-bin gperf liblockfile-bin nuttcp lcov iptables \
    unzip dnsmasq \
    && rm -rf /var/lib/apt/lists/*

# configuration dnsmasq
RUN mkdir -p /temp && cd /temp \
    && wget https://github.com/felixonmars/dnsmasq-china-list/archive/master.zip \
    && unzip master.zip \
    && cd dnsmasq-china-list-master \
    && cp *.conf /etc/dnsmasq.d/ \
    && bash dnsmasq-update-china-list cnnic \
    && cd / && rm -rf /temp

# configuration lz4
RUN mkdir -p /temp && cd /temp \
    && wget https://github.com/Cyan4973/lz4/releases/latest -O lz4.html \
    && export lz4_version=$(cat lz4.html | grep -m 1 -o 'r[0-9][0-9][0-9]') \
    && wget https://github.com/Cyan4973/lz4/archive/$lz4_version.tar.gz \
    && tar xvf $lz4_version.tar.gz \
    && cd lz4-$lz4_version \
    && make install \
    && ln -sf /usr/local/lib/liblz4.* /usr/lib/ \
    && cd / && rm -rf /temp

# configuration radcli
RUN mkdir -p /temp && cd /temp \
    && wget https://github.com/radcli/radcli/releases/latest -O radcli.html \
    && export radcli_version=$(cat radcli.html | grep -m 1 -o '[0-9]\.[0-9]\.[0-9]') \
    && wget https://github.com/radcli/radcli/releases/download/$radcli_version/radcli-$radcli_version.tar.gz \
    && tar xzf radcli-$radcli_version.tar.gz \
    && cd radcli-$radcli_version \
    && ./configure --prefix=/usr --sysconfdir=/etc --enable-legacy-compat \
    && make && make install \
    && cd / && rm -rf /temp

# configuration ocserv
RUN mkdir -p /temp && cd /temp \
    && wget http://www.infradead.org/ocserv/download.html \
    && export ocserv_version=$(cat download.html | grep -o '[0-9]*\.[0-9]*\.[0-9]*') \
    && wget ftp://ftp.infradead.org/pub/ocserv/ocserv-$ocserv_version.tar.xz \
    && tar xvf ocserv-$ocserv_version.tar.xz \
    && cd ocserv-$ocserv_version \
    && ./configure --prefix=/usr --sysconfdir=/etc --with-local-talloc \
    && make && make install \
    && cd / && rm -rf /temp


    # generate [ca-key.pem] -> ca-cert.pem [ca-key]
    && certtool --generate-privkey --outfile /opt/certs/ca-key.pem && certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem --template /opt/certs/ca-tmp --outfile /opt/certs/ca-cert.pem \
    # generate [server-key.pem] -> server-cert.pem [ca-key, server-key] 
    && certtool --generate-privkey --outfile /opt/certs/server-key.pem && certtool --generate-certificate --load-privkey /opt/certs/server-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/serv-tmp --outfile /opt/certs/server-cert.pem \
    # generate [user-key.pem] -> user-cert.pem [ca-key, user-key]
    && certtool --generate-privkey --outfile /opt/certs/user-key.pem && certtool --generate-certificate --load-privkey /opt/certs/user-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/user-tmp --outfile /opt/certs/user-cert.pem \
    # generate user.p12 [user-key, user-cert, ca-cert]
    && openssl pkcs12 -export -inkey /opt/certs/user-key.pem -in /opt/certs/user-cert.pem -certfile /opt/certs/ca-cert.pem -out /opt/certs/user.p12 -passout pass:616

CMD ["vpn_run"]
