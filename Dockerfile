FROM wppurking/ocserv-base-lib
MAINTAINER Wyatt Pan <wppurking@gmail.com>


RUN cd /root && wget ftp://ftp.infradead.org/pub/ocserv/ocserv-0.8.2.tar.xz && tar xvf /root/ocserv-0.8.2.tar.xz && cd ocserv-0.8.2 && ./configure --prefix=/usr --sysconfdir=/etc && make && make install;rm -rf /root/*
RUN apt-get -y install libpam0g-dev libpam-radius-auth
ADD pam_ocserv /etc/pam.d/ocserv

ADD ./certs /opt/certs
RUN certtool --generate-privkey --outfile /opt/certs/ca-key.pem
RUN certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem --template /opt/certs/ca-tmp --outfile /opt/certs/ca-cert.pem
RUN certtool --generate-privkey --outfile /opt/certs/server-key.pem
RUN certtool --generate-certificate --load-privkey /opt/certs/server-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/serv-tmp --outfile /opt/certs/server-cert.pem

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

WORKDIR /etc/ocserv
CMD ["vpn_run"]
