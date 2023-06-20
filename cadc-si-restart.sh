#!/bin/bash

containers='pg12db minoc luskan haproxy fenwick critwall ratik tantar'

for cont in ${containers}; do
    sudo docker restart ${cont}
    sleep 5
done

