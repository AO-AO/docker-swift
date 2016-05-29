#!/bin/bash
filepath=$(cd "$(dirname "$0")"; pwd)
set -x
#get the host_ipaddress
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
#rm config/*.ring.gz
#rm -rf config/backups
#rm config/*.builder
# keystone init
# FIXME I need restart
docker run -itd  -p  5000:5000 -p 35357:35357 -p 80:80 --link mysql:mysql -v ${filepath}/docker-keystone/openstack-dashboard:/usr/share/openstack-dashboard/ -v ${filepath}/docker-keystone/bootstrap/:/root/bootstrap/ -v ${filepath}/docker-keystone/etc/openstack-dashboard/:/etc/openstack-dashboard/ --name keystone -h keystone keystone-horizon

docker run -itd --name swift -h swift -p 4040:4040   -v ${filepath}/config/:/etc/swift/ -v ${filepath}/docker-swift/bootstrap/:/root/bootstrap/ --link keystone:keystone swift-proxy

docker run --privileged=true -itd  --name swift-rsync -h swift-rsync -p  873:873 -v ${filepath}/data/vdb:/swift/vdb -v ${filepath}/data/vdc:/swift/vdc -v ${filepath}/swift-rsync/bootstrap/:/root/bootstrap/  swift-rsync

docker run --privileged=true  -p 6000:6000 -itd --name swift-object -h swift-object -v ${filepath}/config/:/etc/swift/ -v ${filepath}/data/vdb:/swift/vdb -v ${filepath}/data/vdc:/swift/vdc -v ${filepath}/swift-object/bootstrap/:/root/bootstrap/ swift-object 

docker run --privileged=true -p 6001:6001 -itd --name swift-container -h swift-container -v ${filepath}/config/:/etc/swift/ -v ${filepath}/data/vdb:/swift/vdb -v ${filepath}/data/vdc:/swift/vdc -v ${filepath}/swift-container/bootstrap/:/root/bootstrap/ swift-container 

docker run --privileged=true  -p 6002:6002 -itd --name swift-account -h swift-acount -v ${filepath}/config/:/etc/swift/ -v ${filepath}/data/vdb:/swift/vdb -v ${filepath}/data/vdc:/swift/vdc -v ${filepath}/swift-account/bootstrap/:/root/bootstrap/ swift-account 

set +x
echo "OK"
