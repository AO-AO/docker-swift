#!/bin/bash

set -x
#get the host_ipaddress
docker kill mysql
docker rm -f mysql
docker kill keystone
docker rm -f keystone
docker kill swift-account
docker rm -f swift-account
docker kill swift-container
docker rm -f swift-container
docker kill swift-object
docker rm -f swift-object
docker kill swift-rsync
docker rm -f swift-rsync
docker kill swift
docker rm -f swift
rm config/*.ring.gz
rm -rf config/backups
rm config/*.builder
rm docker-keystone/bootstrap/created
umount data/vdb
umount data/vdc
rm -rf data/dev
rm -rf data/vdb
rm -rf data/vdc
sed -i "/docker/d" /etc/fstab
set +x
echo "OK"
