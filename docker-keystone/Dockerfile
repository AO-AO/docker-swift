FROM ubuntu:update
MAINTAINER xuao "xuao@awcloud.com"
# install packages
RUN set -x \
	&& apt-get -y update \
	&& apt-get -y install \
		python-openstackclient \
		python-pymysql \
		mysql-client \
		keystone \
		apache2 \
		libapache2-mod-wsgi \
		openstack-dashboard \
	&& apt-get remove -y --purge openstack-dashboard-ubuntu-theme
	&& apt-get -y clean \
	&& rm -f /var/lib/keystone/keystone.db
EXPOSE 5000 35357
# copy sql script
# copy keystone config file
ADD admin-openrc.sh /root/
ADD etc/keystone/keystone.conf /etc/keystone/keystone.conf
ADD etc/apache2/apache2.conf /etc/apache2/apache2.conf
ADD etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py
ADD etc/keystone/keystone-paste.ini /etc/keystone/keystone-paste.ini
ADD etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-available/wsgi-keystone.conf
RUN ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
RUN echo "manual" > /etc/init/keystone.override

ENTRYPOINT ['./root/bootstrap/bootstrap.sh']
