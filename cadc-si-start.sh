#!/bin/bash

set -e

# create a tempory set of variables from the (hopefully) existing vars.yaml
cat vars.yaml | sed 's/---/#/g' | sed 's/: /=/g' | sed 's/{{/${/g' | sed 's/}}/}/g' > /tmp/vars.sh
source /tmp/vars.sh


# create required directories
mkdir -p ${LOGS_FOLDER}
mkdir -p ${CACERTIFICATES_FOLDER}

docker pull ${POSTGRESQL_IMAGE}
docker pull ${HAPROXY_IMAGE}
docker pull ${SI_REPO_PATH}/minoc:${MINOC_VERSION}
docker pull ${SI_REPO_PATH}/tantar:${TANTAR_VERSION}
docker pull ${SI_REPO_PATH}/ratik:${RATIK_VERSION}
docker pull ${SI_REPO_PATH}/fenwick:${FENWICK_VERSION}
docker pull ${SI_REPO_PATH}/critwall:${CRITWALL_VERSION}
docker pull ${SI_REPO_PATH}/luskan:${LUSKAN_VERSION}

# create the network to be used by all
echo "starting the network"
docker network create si-network


# Instantiate postgresql
echo "starting postgresql server"
docker run -d \
       --volume=${CONFIG_FOLDER}/postgresql:/config:ro \
       --volume=${LOGS_FOLDER}:/logs:rw \
       -p 5432:5432 \
       --name pg12db \
       --network si-network \
       ${POSTGRESQL_IMAGE}
# Wait to populate
sleep ${WAIT_SECONDS_LONG}

# Launch minoc
echo "starting minoc"
docker run -d \
       --volume=${CONFIG_FOLDER}/minoc:/config:ro \
       --volume=${CONFIG_FOLDER}/cadc-registry.properties:/config/cadc-registry.properties:ro \
       --volume=${DATA_DIR}:/data:rw \
       --user tomcat:tomcat \
       --name minoc \
       --network si-network \
       ${SI_REPO_PATH}/minoc:${MINOC_VERSION} 
# Wait to start up
sleep ${WAIT_SECONDS}

# Launch luskan
echo "starting luskan"
docker run -d \
       --volume=${CONFIG_FOLDER}/luskan:/config:ro \
       --volume=${CONFIG_FOLDER}/cadc-registry.properties:/config/cadc-registry.properties:ro \
       --user tomcat:tomcat \
       --name luskan \
       --network si-network \
       ${SI_REPO_PATH}/luskan:${LUSKAN_VERSION}
# Wait to start up
sleep ${WAIT_SECONDS}

# Instantiate fenwick
echo "starting fenwick"
docker run -d \
       --volume=${CONFIG_FOLDER}/fenwick/:/config:ro \
       --volume=${CONFIG_FOLDER}/cadc-registry.properties:/config/cadc-registry.properties:ro \
       --user opencadc:opencadc \
       --name fenwick \
       --network si-network \
       ${SI_REPO_PATH}/fenwick:${FENWICK_VERSION}
# Wait to start up
sleep ${WAIT_SECONDS}

# Instantiate ratik
echo "starting ratik"
docker run -d \
       --volume=${CONFIG_FOLDER}/ratik/:/config:ro \
       --volume=${CONFIG_FOLDER}/cadc-registry.properties:/config/cadc-registry.properties:ro \
       --user opencadc:opencadc \
       --name ratik \
       --network si-network \
       ${SI_REPO_PATH}/ratik:${RATIK_VERSION}
# Wait to start up
sleep ${WAIT_SECONDS}

# Launch critwall
echo "starting critwall"
docker run -d \
       --volume=${CONFIG_FOLDER}/critwall:/config:ro \
       --volume=${CONFIG_FOLDER}/cadc-registry.properties:/config/cadc-registry.properties:ro \
       --volume=${DATA_DIR}:/data:rw \
       --user opencadc:opencadc \
       --name critwall \
       --network si-network \
       ${SI_REPO_PATH}/critwall:${CRITWALL_VERSION}
# Wait to start up
sleep ${WAIT_SECONDS}

# Launch tantar
echo "starting tantar"
docker run -d \
       --volume=${CONFIG_FOLDER}/tantar:/config:ro \
       --volume=${CONFIG_FOLDER}/cadc-registry.properties:/config/cadc-registry.properties:ro \
       --volume=${DATA_DIR}:/data:rw \
       --user opencadc:opencadc \
       --name tantar \
       --network si-network \
       ${SI_REPO_PATH}/tantar:${TANTAR_VERSION}
# Wait to start up
sleep ${WAIT_SECONDS}

# Instantiate haproxy
echo "starting haproxy"
docker run -d \
       --volume=${CERTIFICATES_FOLDER}/:/config:ro \
       --volume=${LOGS_FOLDER}:/logs:rw \
       --volume=${CONFIG_FOLDER}/haproxy:/usr/local/etc/haproxy/:rw \
       -p ${HAPROXY_EXPOSED_PORT}:443 \
       --name haproxy \
       --network si-network \
       ${HAPROXY_IMAGE}
# Wait to populate
sleep ${WAIT_SECONDS_LONG}

