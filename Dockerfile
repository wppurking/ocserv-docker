FROM wppurking/ocserv
MAINTAINER Wyatt Pan <wppurking@gmail.com>

WORKDIR /etc/ocserv
CMD ["vpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*
