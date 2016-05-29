#!/bin/bash

set -x
#get the host_ipaddress
chown -R swift:swift /swift/
chown -R root:swift /etc/swift
# create database for keystone

# keystone init
swift-init all restart

# FIXME I need restart
set +x
echo "OK"
/bin/bash
/bin/bash
