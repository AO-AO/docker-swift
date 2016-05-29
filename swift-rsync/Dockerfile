FROM ubuntu:update
MAINTAINER krystism "xuao@gmail.com"
# install packages
RUN set -x \
	&& apt-get -y install \
		rsync \
	&& apt-get -y clean 
ADD etc/default/rsync /etc/default/rsync
ADD etc/rsyncd.conf /etc/
EXPOSE 873
#RUN /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf
# copy sql script
# copy keystone config file
# add bootstrap script and make it executable
ENTRYPOINT ["./root/bootstrap/bootstrap.sh"]
