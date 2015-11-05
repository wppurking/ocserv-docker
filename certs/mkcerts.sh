#!/bin/bash

# ca
certtool --generate-privkey --outfile /opt/certs/ca-key.pem && certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem --template /opt/certs/ca.tmpl --outfile /opt/certs/ca-cert.pem

# server
certtool --generate-privkey --outfile /opt/certs/server-key.pem && certtool --generate-certificate --load-privkey /opt/certs/server-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/server.tmpl --outfile /opt/certs/server-cert.pem

# user
# openssl pkcs12 -export -inkey user-key.pem -in user-cert.pem -certfile ca-cert.pem -out user.p12
certtool --generate-privkey --outfile /opt/certs/user-key.pem
certtool --generate-certificate --load-privkey /opt/certs/user-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/user.tmpl --outfile /opt/certs/user-cert.pem
certtool --to-p12 --load-privkey /opt/certs/user-key.pem --pkcs-cipher 3des-pkcs12 --load-certificate /opt/certs/user-cert.pem --outfile /opt/certs/user.p12 --outder
