FROM ubuntu
MAINTAINER Wyatt Pan <wppurking@gmail.com>

RUN apt-get update
RUN apt-get install build-essential libwrap0-dev libpam0g-dev libdbus-1-dev libreadline-dev libnl-route-3-dev libprotobuf-c0-dev libpcl1-dev libopts25-dev autogen libgnutls28 libgnutls28-dev libseccomp-dev iptables wget gnutls-bin -y

RUN cd /root && wget http://www.infradead.org/ocserv/download.html && export ocserv_version=$(cat download.html | grep -o '[0-9]\.[0-9]\.[0-9]') \
	&& wget ftp://ftp.infradead.org/pub/ocserv/ocserv-$ocserv_version.tar.xz && tar xvf ocserv-$ocserv_version.tar.xz \
	&& cd ocserv-$ocserv_version && ./configure --prefix=/usr --sysconfdir=/etc && make && make install \
	&& rm -rf /root/*

ADD ./certs /opt/certs
RUN certtool --generate-privkey --outfile /opt/certs/ca-key.pem
RUN certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem --template /opt/certs/ca-tmp --outfile /opt/certs/ca-cert.pem
RUN certtool --generate-privkey --outfile /opt/certs/server-key.pem
RUN certtool --generate-certificate --load-privkey /opt/certs/server-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/serv-tmp --outfile /opt/certs/server-cert.pem

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

WORKDIR /etc/ocserv
CMD ["vpn_run"]
