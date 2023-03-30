#!/bin/bash

containers='haproxy critwall fenwick luskan minoc pg12db tantar ratik'

for cont in ${containers}; do
    sudo docker stop ${cont}
done
