#!/bin/bash

set -x
#get the host_ipaddress
host_ip=192.168.139.201
# create database for keystone
sed -i "s/'` grep '^provider =' /etc/keystone/keystone.conf`'/provider = fernet/g" /etc/keystone/keystone.conf
mysql -uroot -pawcloud -hmysql << EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'awcloud';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'awcloud';
EOF

su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
service apache2 restart


export  OS_TOKEN=e04f697be8f675e20308
export OS_URL=http://keystone:35357/v3
export OS_IDENTITY_API_VERSION=3
if [ ! -f /root/bootstrap/created ];then
echo "created" > /root/bootstrap/created
openstack service create   --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://keystone:5000/v2.0
openstack endpoint create --region RegionOne   identity internal http://keystone:5000/v2.0
openstack endpoint create --region RegionOne   identity admin http://keystone:35357/v2.0
openstack domain create --description "Default Domain" default
openstack project create --domain default   --description "Admin Project" admin
openstack user create --domain default   --password awcloud admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --domain default   --description "Service Project" service
openstack project create --domain default   --description "Demo Project" demo
openstack user create --domain default   --password awcloud  demo
openstack role create user
openstack role add --project demo --user demo user

openstack user create --domain default --password awcloud swift
openstack role add --project service --user swift admin
openstack service create --name swift   --description "OpenStack Object Storage" object-store
openstack endpoint create --region RegionOne  object-store public http://${host_ip}:4040/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne   object-store internal http://${host_ip}:4040/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne   object-store admin http://${host_ip}:4040/v1
# it may take some time to start keystone service, waiting for it.
fi

# keystone init
service apache2 restart
# FIXME I need restart
set +x
echo "OK"
/bin/bash
