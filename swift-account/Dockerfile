FROM ubuntu:update
MAINTAINER "xuao@gmail.com"
# install packages
RUN set -x \
	&& apt-get -y install \
		swift-account \
	&& apt-get -y clean \
	&& rm -f /var/lib/keystone/keystone.db
#VOLUME /etc/swift/

#ADD etc/swift/account-server.conf /etc/swift/
#ADD etc/swift/swift.conf /etc/swift/

EXPOSE	6002
# copy sql script
# copy keystone config file
ENTRYPOINT ["./root/bootstrap/bootstrap.sh"]
# add bootstrap script and make it executable
