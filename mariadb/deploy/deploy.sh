#!/bin/sh

apt-get clean
apt-get update
 
apt-get install -y python-software-properties
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb http://mirrors.coreix.net/mariadb/repo/10.0/ubuntu precise main'

apt-get update

echo "mysql-server mysql-server/root_password select vagrant" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again select vagrant" | debconf-set-selections
apt-get install -y mariadb-server

service mysql stop
cp /vagrant/conf/my.cnf /etc/mysql/my.cnf
service mysql start

/usr/bin/mysql -uroot -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION; FLUSH PRIVILEGES"

apt-get clean