FROM ubuntu:update
MAINTAINER krystism "xuao@gmail.com"
# install packages
RUN set -x \
	&& apt-get -y install \
		swift \
		swift-proxy \
		python-swiftclient \
		python-keystoneclient \
		python-keystonemiddleware \
	&& apt-get -y clean \
	&& rm -f /var/lib/keystone/keystone.db
#VOLUME /etc/swift/

ADD admin-openrc.sh /root/admin-openrc.sh
#ADD etc/swift/proxy-server.conf /etc/swift/proxy-server.conf
#ADD etc/swift/swift.conf /etc/swift/swift.conf

EXPOSE 8080
#RUN /usr/bin/python /usr/bin/swift-proxy-server /etc/swift/proxy-server.conf
# copy sql script
# copy keystone config file

# add bootstrap script and make it executable
