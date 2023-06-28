# CADC Storage Inventory -- local site deployment
This repository contains a script for deployment and installation of a local site storage inventory, along with the required configuration files.
## Pre-requisites
- SSL certificates for the host on the host (check out `make-self-signed-ssl-certs.sh` or create them via letsencrypt.org)

In addition, you need to have docker installed and running.
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce
#Check status
sudo systemctl status docker
# Executing docker command without sudo
sudo usermod -aG docker ${USER}
```
--

## Storage inventory components diagram

![SI](https://github.com/opencadc/storage-inventory/raw/master/docs/storage-site.png)

## Components required for a local storage site
The below components can either be build from scratch as docker images using the description from the [CADC-Storage Inventory github](https://github.com/opencadc/storage-inventory) or they can be pulled from the [CADC docker image repository](https://images.opencadc.org/)(requires login). Descriptions of how to query what resources are available can be found [here](https://www.opencadc.org/storage-inventory/ops/). Pulling the images requires no login.

### Must have
 - minoc (handles data upload/download/removal)
 - luskan (handles the metadata)
 - postgres database server (e.g. [postgresql from CADC](https://github.com/opencadc/docker-base/tree/master/cadc-postgresql-dev))
 - proxy server (e.g. [haproxy from CADC](https://github.com/opencadc/docker-base/tree/master/cadc-haproxy-dev))

### Should have (must for multi-site/global functionality)
 - tantar (ensures that content of database and actual data in storage agree)
 - ratik (validates all metadata between local site and a remote site, e.g. global site)
 - fenwick (synchronises metadata between local site and remote site in an incremental fashion)
 - critwall (Process to retrieve files from remote storage sites)

The SPsrc local site is a multi-site deployment

### Run script

If you get a error during the deployment, remember to remove all created containers
```
docker rm -f $(docker ps -a -q)
```
Assuming you have all the required images on your system, you can also start/stop/delete them via the below bash scripts.

### Start / Stop  Storage Inventory

You can also start/stop the different containers via runing `spsrc-si-start.sh`, `spsrc-si-stop.sh`. To also delete them or stop and delete in one go you run `spsrc-si-delete.sh` or `spsrc-si-stop-and-delete.sh`. Make sure you adjust the scripts to your local deployment.

## Testing deployment
 - test if services are online and available via the availability hooks described [here](https://www.opencadc.org/storage-inventory/ops/#deployment) (e.g. for minoc: `curl https://www.example.org/minoc/availability`)
 - there is also a demo video and some example test commands with curl on [this site](https://www.canfar.net/storage/vault/list/pdowler/SRCnet/SI-demo)

- Check `/conf` and `/config` within deployment and Documentation, in order to configure your site

