FROM ubuntu:update
MAINTAINER krystism "xuao@gmail.com"
# install packages
RUN set -x \
	&& apt-get -y install \
		swift-object \
	&& apt-get -y clean \
	&& rm -f /var/lib/keystone/keystone.db
#VOLUME /etc/swift/

#ADD etc/swift/object-server.conf /etc/swift/
#ADD etc/swift/swift.conf /etc/swift/

EXPOSE	6000
# copy sql script
# copy keystone config file
ENTRYPOINT ["./root/bootstrap/bootstrap.sh"]
# add bootstrap script and make it executable
