#!/bin/bash -eux

# https://www.server-world.info/en/note?os=CentOS_7&p=openstack_pike&f=2

yum --enablerepo=centos-openstack-pike -y -q install mariadb-server
sed -i "s/\[mysqld\]/&\ncharacter-set-server=utf8/g" /etc/my.cnf
systemctl start mariadb
systemctl enable mariadb
echo -e "\ny\nroot\nroot\ny\ny\ny\n" | mysql_secure_installation

yum --enablerepo=epel -y -q install rabbitmq-server memcached 
systemctl start rabbitmq-server memcached
systemctl enable rabbitmq-server memcached
rabbitmqctl add_user openstack password
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
systemctl status firewalld >/dev/null 2>&1 && { firewall-cmd --add-port={11211/tcp,5672/tcp} --permanent; firewall-cmd --reload; }

# https://www.server-world.info/en/note?os=CentOS_7&p=openstack_pike&f=3
