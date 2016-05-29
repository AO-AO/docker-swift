#!/bin/bash

set -x
#get the host_ipaddress
host_ip=192.168.139.201
rsync_ip=`ifconfig ${eth0} | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'`
chown -R swift:swift /swift/
chown -R root:swift /etc/swift
# create database for keystone

sed -i "s/`grep 'address =' /etc/rsyncd.conf`/adress = ${rsync_ip}/" /etc/rsyncd.conf
# keystone init
service rsync restart
sleep 5
swift-init all restart

# FIXME I need restart
set +x
echo "OK"
/bin/bash
