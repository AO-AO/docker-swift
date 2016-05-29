#!/bin/bash

set -x
#get the host_ipaddress
host_ip=192.168.139.201
chown -R root:swift /etc/swift
# create database for keystone
cd /etc/swift

if [ ! -f /etc/swift/object.ring.gz ];then
swift-ring-builder account.builder create 10 3 1
swift-ring-builder account.builder   add --region 1 --zone 1 --ip ${host_ip}  --port 6002   --device vdb --weight 100
swift-ring-builder account.builder   add --region 1 --zone 2 --ip ${host_ip}  --port 6002   --device vdc --weight 100
swift-ring-builder account.builder rebalance

swift-ring-builder container.builder create 10 3 1
swift-ring-builder container.builder  add --region 1 --zone 1 --ip ${host_ip}  --port 6001   --device vdb --weight 100
swift-ring-builder container.builder   add --region 1 --zone 2 --ip ${host_ip}  --port 6001   --device vdc --weight 100
swift-ring-builder container.builder rebalance

swift-ring-builder object.builder create 10 3 1
swift-ring-builder object.builder   add --region 1 --zone 1 --ip ${host_ip}  --port 6000   --device vdb --weight 100
swift-ring-builder object.builder   add --region 1 --zone 2 --ip ${host_ip}  --port 6000   --device vdc --weight 100
swift-ring-builder object.builder rebalance
fi

chown -R root:swift /etc/swift
# keystone init
service swift-proxy restart
sleep 5
swift-init all restart

# FIXME I need restart
set +x
echo "OK"
/bin/bash
