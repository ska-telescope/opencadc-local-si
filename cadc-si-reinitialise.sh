#!/bin/bash

containers='pg12db minoc luskan haproxy fenwick critwall ratik tantar'

sudo docker rm -f ${containers}
sudo docker network rm si-network
sleep 5
./cadc-si-start.sh
