# CADC Storage Inventory

- [CADC Storage Inventory](#cadc-storage-inventory)
  * [Ansible deployment of CADC Storage Inventory](#ansible-deployment-of-cadc-storage-inventory)
    + [Use Ansible](#use-ansible)
    + [Configuring Inventory File](#configuring-inventory-file)
    + [Run Playbook](#run-playbook)
  * [Running from CLI](#running-from-cli)
    + [Start / Stop  Storage Inventory](#start---stop--storage-inventory)
  * [Building steps-by-step](#building-steps-by-step)
    + [Java Container](#java-container)
    + [PostGreSQL Container](#postgresql-container)
    + [TomCat Container](#tomcat-container)
    + [HAProxy Container](#haproxy-container)
  * [Instantiation](#instantiation)
    + [PostgreSQL](#postgresql)
    + [TomCat](#tomcat)
    + [HAproxy](#haproxy)
  * [Building Storage Inventory](#building-storage-inventory)
    + [Requirements](#requirements)
    + [Building `minoc`](#building--minoc-)
    + [Instantiate `minoc`](#instantiate--minoc-)
    + [Building `luskan`](#building--luskan-)
    + [Instantiate `luskan`](#instantiate--luskan-)
    + [Building `critwall`](#building--critwall-)
    + [Instantiate `critwall`](#instantiate--critwall-)
    + [Building `fenwich`](#building--fenwich-)
    + [Instantiate `fenwich`](#instantiate--fenwich-)
- [TechDebt](#techdebt)

# Storage inventory components diagram

![SI](https://github.com/opencadc/storage-inventory/raw/master/docs/storage-site.png)

## Ansible deployment of CADC Storage Inventory
### Use Ansible
You can install a released version of Ansible with pip or a package manager. See our installation guide for details on installing Ansible on a variety of platforms.

Power users and developers can run the devel branch, which has the latest features and fixes, directly. Although it is reasonably stable, you are more likely to encounter breaking changes when running the devel branch. We recommend getting involved in the Ansible community if you want to run the devel branch.


### Configuring Inventorie File
You need to add the target host in the inventorie
```
vi inventories/hosts
```
### Requeriments
Ansible version: latest.

Example: Ubuntu version
```
sudo apt update
sudo apt upgrade
sudo apt install software-properties-common
```
Next add ppa:ansible/ansible to your system’s Software Source:
```
sudo apt-add-repository ppa:ansible/ansible
```
You need install ansible-galaxy collection
```
ansible-galaxy collection install community.crypto
ansible-galaxy collection install community.docker
```
### Run Playbook
The first step is build the docker images
```
ansible-playbook -i inventories/hosts cadc-install.yml
```
If you get a error during the deployment, remember to remove all created containers
```
docker rm -f $(docker ps -a -q)
```

## Running from CLI

### Start / Stop  Storage Inventory

Clone this repository

```
git clone https://gitlab.com/jsancheziaa/cadc-storage-inventory
```

Run `cadc-si-start.sh`:

```
cd cadc-storage-inventory
bash cadc-si-start.sh
```

To stop all the services:

```
bash cadc-si-stop.sh
```

To delete all the services:

```
bash cadc-si-delete.sh
```

## Building steps-by-step

### Java Container

```
docker build -t cadc-java -f Dockerfile .
```

### PostGreSQL Container

Beforehand update file ´cadc-postgres-dev/src/init/init-content.sh´ and if you are going to deploy minoc, add the next:

```
...
DATABASES="minoc_inventory"
SCHEMAS="schema_minoc_inventory"
...
```

Then go to `cadc-postgres-dev` and build the container

```
docker build -t cadc-postgresql-dev -f Dockerfile.pg10 .
```

### TomCat Container

```
docker build -t cadc-tomcat -f Dockerfile .
```


### HAProxy Container

Pre-create a pair of keys autosigned:

```
openssl genrsa -out mydomain.key 2048
openssl req -new -key mydomain.key -out mydomain.csr
openssl x509 -req rsa:2048 -days 365  -in mydomain.csr -signkey mydomain.key -out mydomain.crt
cat mydomain.key mydomain.crt >> server-cert.pem
```

Build container:

```
docker build -t cadc-haproxy-dev -f Dockerfile .
```

## Instantiation

*Note the order.*

### PostgreSQL

Note: we used "--volume=/Users/manuparra/repos/docker-base/config/" remember to change it.

```
docker run -d --volume=/Users/manuparra/repos/docker-base/config/postgresql:/config:ro --volume=/Users/manuparra/repos/docker-base/config/postgresql-logs:/logs:rw -p 5432:5432 --name pg10db cadc-postgresql-dev:latest
```

### TomCat
```
docker run -d --user tomcat:tomcat --volume=/Users/manuparra/repos/docker-base/config/tomcat:/config:ro --name cadc-service cadc-tomcat:latest 
```

### HAproxy
```
docker run -d  --volume=/Users/manuparra/repos/docker-base/config/haproxy/logs:/logs:rw --volume=/Users/manuparra/repos/docker-base/certs/:/config:ro --link cadc-service:cadc-service -p 8443:443 --name haproxy cadc-haproxy-dev:latest
```


## Building Storage Inventory

### Requirements

Install `gradle` and `maven`.

Clone this repository:

```
git clone https://github.com/opencadc/storage-inventory.git
```

### Building `minoc`

```
cd minoc
gradle clean build
docker build -t minoc -f Dockerfile .
```

### Instantiate `minoc`

```
docker run -d --user tomcat:tomcat  --link pg10db:pg10db --volume=/Users/manuparra/repos/docker-base/config/minoc:/config:ro --name minoc cadc-minoc:latest
```

### Building `luskan`

```
cd luskan
gradle clean luskan
docker build -t luskan -f Dockerfile .
```

### Instantiate `luskan`

```
docker run -d --user tomcat:tomcat  --link pg10db:pg10db --volume=/Users/manuparra/repos/docker-base/config/luskan:/config:ro --name luskan cadc-luskan:latest
```

### Building `critwall`

```
cd luskan
gradle clean luskan
docker build -t luskan -f Dockerfile .
```

### Instantiate `critwall`

```
docker run -d --user tomcat:tomcat  --link pg10db:pg10db \
              --volume=/Users/manuparra/repos/docker-base/config/critwall:/config:ro 
              --name critwall 
              critwall:latest
```

### Building `fenwich`

```
cd fenwich
gradle clean fenwich
docker build -t fenwich -f Dockerfile .
```

### Instantiate `fenwich`

```
docker run -d --user tomcat:tomcat  --link pg10db:pg10db \
              --volume=/Users/manuparra/repos/docker-base/config/fenwick:/config:ro 
              --name fenwick 
              fenwick:latest
```



# TechDebt

- Export HAproxy configuration to solve the Warning: 
```
[WARNING] 348/090903 (19) : Setting tune.ssl.default-dh-param to 1024 by default, if your workload permits it you should set it to at least 2048. Please set a value >= 1024 to make this warning disappear.
```
- Check `/conf` and `/config` within HAProxy deployment and Documentation.
- Problem with underscores and middle dash for DBs and Scheme
- `OpaqueFileSystemStorageAdapter.org.opencadc.inventory.storage.fs.baseDir` ?
  - `#org.opencadc.inventory.storage.fs.baseDir = /tmp/`
  - `org.opencadc.inventory.storage.fs.OpaqueFileSystemStorageAdapter.baseDir = /tmp`
