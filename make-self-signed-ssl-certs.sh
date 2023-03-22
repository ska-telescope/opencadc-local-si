#!/bin/bash

# create certs for the server? If not 'true' will skip the last step
# where the certs are copied to the haproxy's config dir
FOR_SERVER='true'
#FOR_SERVER='false'

# output directory for the certificates
DIR=/home/ubuntu/ssl/client

# config directory from which haproxy loads the certificates
CONF_DIR=/home/ubuntu//software/src/cadc-storage-inventory/certs/

# site name; can be anything for the client; should be localhost/an IP address/a domain name for the server
SITE=130.238.29.214
#SITE=random

mkdir -p ${DIR} && cd ${DIR}

# create CA-authority's private key and certificate
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "/CN=${SITE}"

# create server's private key
openssl genrsa -out server.key 4096

# create the server's certificate based on a signature request and the CA-authority from above
openssl req -new -key server.key -out server.csr -subj "/CN=${SITE}"
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

if [[ ${FOR_SERVER} == 'true' ]];then
    cat ca.crt server.crt ca.key server.key > ${CONF_DIR}/server-cert.pem
    echo -e "\n Concatenated ca.crt server.crt ca.key server.key into ${CONF_DIR}/server-cert.pem \n"
    echo -e " Remember to copy ${DIR}/ca.crt to the client. \n"
    echo -e " Also remember to put the client's CA-certificates into ${CONF_DIR}/cacerts/ \n"
else
    # rename the server* files to client* files for clarity
    suffs='csr crt key'
    for suff in ${suffs};do 
	mv server.${suff} client.${suff}
    done
    cat ca.crt client.crt ca.key client.key > all-certs-and-keys.crt
    echo -e "\n Concatenated ca.crt client.crt ca.key client.key into ${DIR}/all-certs-and-keys.crt \n"
    echo -e " That file should live on the client. \n"
    echo -e " Remeber to copy ${DIR}/ca.crt to ${CONF_DIR}/cacerts/ on the server.\n"
fi
cd -
