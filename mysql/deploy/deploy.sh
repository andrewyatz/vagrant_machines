#!/bin/sh
echo "mysql-server mysql-server/root_password select vagrant" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again select vagrant" | debconf-set-selections
apt-get clean
apt-get update
apt-get install -y mysql-server htop

# Bring in the custom MySQL Config
service mysql stop
cp /vagrant/conf/my.cnf /etc/mysql/my.cnf
service mysql start

/usr/bin/mysql -uroot -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION; FLUSH PRIVILEGES"
apt-get clean