#!/bin/bash

filepath=$(cd "$(dirname "$0")"; pwd)
echo $filepath

set -x
Nic=eth0
if [ ! -d ${filepath}/data/dev ]; then
mkdir -p ${filepath}/data/dev/
mkdir -p ${filepath}/data/vdb/
mkdir -p ${filepath}/data/vdc/
echo "${filepath}/data/dev/vdb ${filepath}/data/vdb xfs noatime,nodiratime,nobarrier,logbufs=8 0 2" >> /etc/fstab
echo "${filepath}/data/dev/vdc ${filepath}/data/vdc xfs noatime,nodiratime,nobarrier,logbufs=8 0 2" >> /etc/fstab
fi

if [ ! -f ${filepath}/data/dev/vdb ]; then
dd if=/dev/zero of=${filepath}/data/dev/vdb count=5 bs=2G
mkfs.xfs ${filepath}/data/dev/vdb
fi

if [ ! -f ${filepath}/data/dev/vdc ]; then
dd if=/dev/zero of=${filepath}/data/dev/vdc count=5 bs=2G
mkfs.xfs ${filepath}/data/dev/vdc
mount ${filepath}/data/vdb/
mount ${filepath}/data/vdc/
fi





#get the host_ipaddress
host_ip=`ifconfig ${Nic} | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'`
sed -i "s/`cat docker-keystone/bootstrap/bootstrap.sh | grep 'host_ip='`/host_ip=${host_ip}/g" docker-keystone/bootstrap/bootstrap.sh

sed -i "s/'`cat docker-swift/bootstrap/bootstrap.sh | grep 'host_ip='`'/host_ip=${host_ip}/g" docker-swift/bootstrap/bootstrap.sh

sed -i "s/`cat docker-keystone/etc/openstack-dashboard/local_settings.py | grep 'OPENSTACK_HOST ='`/OPENSTACK_HOST = \"${host_ip}\"/g" docker-keystone/etc/openstack-dashboard/local_settings.py

#sed -i "s/`grep OS_AUTH_URL docker-keystone/admin-openrc.sh | awk -F '[:/]' '{print $4}'`/${host_ip}/" docker-keystone/admin-openrc.sh

#sed -i "s/`grep auth_uri config/proxy-server.conf | awk -F '[:/]' '{print $4}'`/${host_ip}/" config/proxy-server.conf

#sed -i "s/`grep auth_url config/proxy-server.conf | awk -F '[:/]' '{print $4}'`/${host_ip}/" config/proxy-server.conf
# create database for keystone

#sed -i "s/`grep address= swift-rsync/etc/rsyncd.conf`/adress=${host_ip}/" swift-rsync/etc/rsyncd.conf 
# keystone init
# FIXME I need restart
docker run -d -e MYSQL_ROOT_PASSWORD=awcloud -h mysql --name mysql -d mariadb:10.1.12
while [ $(docker logs mysql 2>&1 | grep -c "ready for connections.") -lt 2 ]; do
    sleep 1
done

docker run -itd  -p  5000:5000 -p 35357:35357 -p 80:80 --link mysql:mysql -v ${filepath}/docker-keystone/openstack-dashboard:/usr/share/openstack-dashboard/ -v ${filepath}/docker-keystone/bootstrap/:/root/bootstrap/ -v ${filepath}/docker-keystone/etc/openstack-dashboard/:/etc/openstack-dashboard/ --name keystone -h keystone keystone-horizon

docker run -itd --name swift -h swift -p 4040:4040   -v ${filepath}/config/:/etc/swift/ -v ${filepath}/docker-swift/bootstrap/:/root/bootstrap/ --link keystone:keystone swift-proxy

while [ $(docker logs swift 2>&1 | grep -c "^OK") -lt 1 ]; do
    sleep 1
done

docker run --privileged=true -itd  --name swift-rsync -h swift-rsync -p  873:873 -v ${filepath}/data/vdb:/swift/vdb -v ${filepath}/data/vdc:/swift/vdc -v ${filepath}/swift-rsync/bootstrap/:/root/bootstrap/  swift-rsync

docker run --privileged=true  -p 6000:6000 -itd --name swift-object -h swift-object -v ${filepath}/config/:/etc/swift/ -v ${filepath}/data/vdb:/swift/vdb -v ${filepath}/data/vdc:/swift/vdc -v ${filepath}/swift-object/bootstrap/:/root/bootstrap/ swift-object 

docker run --privileged=true -p 6001:6001 -itd --name swift-container -h swift-container -v ${filepath}/config/:/etc/swift/ -v ${filepath}/data/vdb:/swift/vdb -v ${filepath}/data/vdc:/swift/vdc -v ${filepath}/swift-container/bootstrap/:/root/bootstrap/ swift-container 

docker run --privileged=true  -p 6002:6002 -itd --name swift-account -h swift-acount -v ${filepath}/config/:/etc/swift/ -v ${filepath}/data/vdb:/swift/vdb -v ${filepath}/data/vdc:/swift/vdc -v ${filepath}/swift-account/bootstrap/:/root/bootstrap/ swift-account 

while [ $(docker logs keystone 2>&1 | grep -c "^OK") -lt 1 ]; do
    sleep 1
done
set +x
echo "OK"
