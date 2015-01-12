#!/bin/sh

# "globals"
home=/home/vagrant
user=vagrant
group=vagrant

echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

# Java

add-apt-repository -y ppa:webupd8team/java 
apt-get -y update 
apt-get -y install oracle-java7-installer git 

# Elasticsearch & Logstash work
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
echo 'deb http://packages.elasticsearch.org/elasticsearch/1.1/debian stable main' | sudo tee /etc/apt/sources.list.d/elasticsearch.list
echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list

apt-get update
apt-get -y install elasticsearch=1.1.1
apt-get -y install logstash=1.4.2-1-2c0f5a1
service elasticsearch restart
update-rc.d elasticsearch defaults 95 10

# KIBANA
apt-get -y install nginx apache2-utils
cd $home
wget https://download.elasticsearch.org/kibana/kibana/kibana-3.0.1.tar.gz
tar xvf kibana-3.0.1.tar.gz
cp /vagrant/deploy/config.js $home/kibana-3.0.1/config.js
mkdir -p /var/www/kibana3
cp -R $home/kibana-3.0.1/* /var/www/kibana3/
cd $home
# Originally gotten from here but now it's in the deploy dir
# wget https://gist.githubusercontent.com/thisismitch/2205786838a6a5d61f55/raw/f91e06198a7c455925f6e3099e3ea7c186d0b263/nginx.conf
cp /vagrant/deploy/nginx.conf /etc/nginx/sites-available/default
service nginx restart

# Cleanup
chown -R $user:$group $home/.profile $home/kibana* $home/*.conf
apt-get clean
