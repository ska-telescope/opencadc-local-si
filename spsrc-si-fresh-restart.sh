#!/bin/bash

# Pull all the containers precreated

# Default config files locate in ${CONFIG_FOLDER}
CONFIG_FOLDER="/home/cloud-user/si/config"
LOGS_FOLDER="/home/cloud-user/si/logs"
# Define where the data will live, directory need XXX permissons
DATA_DIR="/data"
SI_REPO_PATH="images.opencadc.org/storage-inventory"
MINOC_VERSION=0.9.1
TANTAR_VERSION=0.4.0
RATIK_VERSION=0.1.4
FENWICK_VERSION=0.5.5
CRITWALL_VERSION=0.4.3
LUSKAN_VERSION=0.6.0
POSTGRESQL_IMAGE="swsrc/cadc-postgresql-12-dev"
HAPROXY_IMAGE="amigahub/cadc-haproxy"
WAIT_SECONDS=8
WAIT_SECONDS_LONG=7
HAPROXY_EXPOSED_PORT=443

docker pull ${POSTGRESQL_IMAGE}
docker pull ${HAPROXY_IMAGE}
docker pull ${SI_REPO_PATH}/minoc:${MINOC_VERSION}
docker pull ${SI_REPO_PATH}/tantar:${TANTAR_VERSION}
docker pull ${SI_REPO_PATH}/ratik:${RATIK_VERSION}
docker pull ${SI_REPO_PATH}/fenwick:${FENWICK_VERSION}
docker pull ${SI_REPO_PATH}/critwall:${CRITWALL_VERSION}
docker pull ${SI_REPO_PATH}/luskan:${LUSKAN_VERSION}

# Instantiate cadc-postgresql
docker run -d --volume=${CONFIG_FOLDER}/config/postgresql:/config:ro \
              --volume=${LOGS_FOLDER}/:/logs:rw \
              -p 5432:5432 
              --name pg12db 
              ${POSTGRESQL_IMAGE}:latest

# Wait to populate
sleep ${WAIT_SECONDS_LONG}

# Instantiate minoc
docker run -d --user tomcat:tomcat  --link pg12db:pg12db \
       --volume=${CONFIG_FOLDER}/config/minoc:/config:ro \
       --volume=${DATA_DIR}:/data:rw \
       --name minoc \
       ${SI_REPO_PATH}/minoc:${MINOC_VERSION}

#Wait
sleep ${WAIT_SECONDS}

# Instantiate luskan
docker run -d --user tomcat:tomcat  --link pg12db:pg12db \
       --volume=${CONFIG_FOLDER}/config/luskan:/config:ro \
       --name luskan \
       ${SI_REPO_PATH}/luskan:${LUSKAN_VERSION}
      # optionally add the below if baseStorageDir in cadc-tap-tmp.properties is not /tmp
      #--volume=/dir/on/host:/data:rw

#Wait 
sleep ${WAIT_SECONDS}
# Instantiate fenwick
docker run -d --user opencadc:opencadc  --link pg10db:pg10db \
              --volume=${CONFIG_FOLDER}/config/fenwick:/config:ro 
              --name fenwick 
              ${SI_REPO_PATH}/fenwick:${FENWICK_VERSION}
#Wait 
sleep ${WAIT_SECONDS}
# Instantiate critwall
docker run -d --user opencadc:opencadc  --link pg10db:pg10db \
              --volume=${CONFIG_FOLDER}/config/critwall:/config:ro 
              --name critwall 
              ${SI_REPO_PATH}/critwall:${CRITWALL_VERSION}

sleep ${WAIT_SECONDS}	      

# Instantiate tantar
docker run -d --user opencadc:opencadc  --link pg12db:pg12db \
       --volume=${CONFIG_FOLDER}/config/tantar:/config:ro \
       --volume=${DATA_DIR}:/data:rw \
       --name tantar \
       ${SI_REPO_PATH}/tantar:${TANTAR_VERSION}

#Wait
sleep ${WAIT_SECONDS}

# Instantiate ratik
docker run -d --user opencadc:opencadc  --link pg12db:pg12db \
       --volume=${CONFIG_FOLDER}/config/ratik:/config:ro \
       --name ratik \
       ${SI_REPO_PATH}/ratik:${RATIK_VERSION}

#Wait
sleep ${WAIT_SECONDS}


# Instantiate cadc-haproxy
docker run -d --volume=${LOGS_FOLDER}:/logs:rw \
              --volume=${CERTIFICATES_FOLDER}:/config:ro \
	      --volume=${CONFIG_FOLDER}/config/haproxy:/usr/local/etc/haproxy/:rw \
              --link minoc:minoc \
              --link luskan:luskan \
              -p ${HAPROXY_EXPOSED_PORT}:443 \
              --name haproxy \
              ${HAPROXY_IMAGE}:latest

