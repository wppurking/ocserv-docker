#!/bin/bash

CA_CN="${CA_CN:-OCS CA}"
CA_ORG="${CA_ORG:-OCS ORG}"

SERVER_CN="${SERVER_CN:-www.example.com}"
SERVER_ORG="${SERVER_ORG:-server org}"

USER_CN="${USER_CN:-user}"
USER_UNIT="${USER_UNIT:-user unit}"

P12_NAME="${P12_NAME:-userp12}"
P12_PASS="${P12_PASS:-ocserv}"

# Generate certs

if [ ! -d /opt/ocserv ]; then
    echo "Error:"
    echo "    You must have the /opt/ocserv volum mounted!"
    exit 1
fi

if [ ! -f /opt/ocserv/server-key.pem ] || [ ! -f /etc/ocserv/server-cert.pem ]; then

    echo "Generating certs"

    cp /tmp/certs/* /opt/ocserv
    sed -i -e 's/{{CA_CN}}/'"${CA_CN}"'/g' /opt/certs/ca.tmpl
    sed -i -e 's/{{CA_ORG}}/'"${CA_ORG}"'/g' /opt/certs/ca.tmpl
    sed -i -e 's/{{SERVER_CN}}/'"${SERVER_CN}"'/g' /opt/certs/server.tmpl
    sed -i -e 's/{{SERVER_ORG}}/'"${SERVER_ORG}"'/g' /opt/certs/server.tmpl
    sed -i -e 's/{{USER_CN}}/'"${USER_CN}"'/g' /opt/certs/user.tmpl
    sed -i -e 's/{{USER_UNIT}}/'"${USER_UNIT}"'/g' /opt/certs/user.tmpl

    # ca
    certtool --generate-privkey --outfile /opt/certs/ca-key.pem
    certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem --template /opt/certs/ca.tmpl --outfile /opt/certs/ca-cert.pem

    # server
    certtool --generate-privkey --outfile /opt/certs/server-key.pem
    certtool --generate-certificate --load-privkey /opt/certs/server-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/server.tmpl --outfile /opt/certs/server-cert.pem

    # user
    certtool --generate-privkey --outfile /opt/certs/user-key.pem
    certtool --generate-certificate --load-privkey /opt/certs/user-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/user.tmpl --outfile /opt/certs/user-cert.pem
    certtool --to-p12 --load-privkey /opt/certs/user-key.pem --pkcs-cipher 3des-pkcs12 --load-certificate /opt/certs/user-cert.pem --outfile /opt/certs/user.p12 --outder  --template /dev/stdin <<EOF
pkcs12_key_name = ${P12_NAME}
password = ${P12_PASS}
EOF

    echo "Certs generated"
fi

#
# Run the OpenConnect server normally
#

# open ipv4 ip forward
sysctl -w net.ipv4.ip_forward=1

if [ ! -e /dev/net/tun ]; then
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

# open iptables nat
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 

exec "$@"
