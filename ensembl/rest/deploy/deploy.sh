#!/bin/sh
# Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ENSEMBL_VERSION=$1
TEST_ENV=$2
if [ -z "$ENSEMBL_VERSION" ]; then
  echo 'Cannot find the API version. Make sure this has been given to the script' >2
  exit
fi

# Install APT dependencies
apt-get clean
echo 'deb http://ca.archive.ubuntu.com/ubuntu/ precise-updates main restricted' >> /etc/apt/sources.list
echo 'deb http://ca.archive.ubuntu.com/ubuntu/ precise-updates universe' >> /etc/apt/sources.list
echo 'deb http://ca.archive.ubuntu.com/ubuntu/ precise-updates multiverse' >> /etc/apt/sources.list
apt-get update
apt-get install -y git vim
apt-get install -y cpanminus libxml-libxml-perl libxml-simple-perl libxml-writer-perl
apt-get install -y libdbi-perl libdbd-mysql-perl
apt-get install -y build-essential
apt-get install -y libtest-differences-perl libtest-json-perl libtest-xml-simple-perl

# Clean up
apt-get clean

# Installing MySQL for development purposes. Also putting in an ro & rw user
if [ -n "$TEST_ENV" ]; then

  apt-get install -y python-software-properties
  apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
  add-apt-repository 'deb http://mirrors.coreix.net/mariadb/repo/10.0/ubuntu precise main'

  apt-get update

  echo "mysql-server mysql-server/root_password select vagrant" | debconf-set-selections
  echo "mysql-server mysql-server/root_password_again select vagrant" | debconf-set-selections
  apt-get install -y mariadb-server

  service mysql stop
  cp /vagrant/settings/my.cnf /etc/mysql/my.cnf
  service mysql start

  /usr/bin/mysql -uroot -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION; FLUSH PRIVILEGES"
  /usr/bin/mysql -uroot -pvagrant -e "CREATE USER 'ro'@'%'; GRANT SELECT ON *.* TO 'ro'@'%'; FLUSH PRIVILEGES"
  /usr/bin/mysql -uroot -pvagrant -e "CREATE USER 'rw'@'%'; GRANT ALL PRIVILEGES ON *.* TO 'rw'@'%'; FLUSH PRIVILEGES"

  apt-get clean
fi

# Go for catalyst & main dependencies from CPAN
cpanm Module::Install
cpanm Catalyst Catalyst::Devel
cpanm Hash::Merge

# Going for the other CPANM dependencies
cpanm Catalyst::Plugin::ConfigLoader Catalyst::Plugin::Static::Simple Catalyst::Action::RenderView Catalyst::Component::InstancePerContext Catalyst::View::JSON Log::Log4perl::Catalyst Catalyst::Plugin::Cache Parse::RecDescent Catalyst::Controller::REST Catalyst::View::TT

# Only odd dependency is on 0.19 of subrequest
cpanm EDENC/Catalyst-Plugin-SubRequest-0.19.tar.gz

# CHI dependencies
cpanm CHI CHI::Driver::Memcached::Fast

# Test case dependencies
cpanm Test::XPath Test::XML::Simple

# ensembl-test dependencies
cpanm Devel::Peek Devel::Cycle Error IO::String PadWalker Test::Builder::Module

# User settings
home=/home/vagrant
user=vagrant

# Install Ensembl Git Tools
if [ -d $home/programs ]; then
  rm -rf $home/programs
fi
mkdir $home/programs
cd $home/programs
git clone https://github.com/Ensembl/ensembl-git-tools.git
cd $home

# Install BioPerl
mkdir -p $home/src
cd $home/src
wget https://github.com/bioperl/bioperl-live/archive/bioperl-release-1-2-3.tar.gz
tar zxf bioperl-release-1-2-3.tar.gz
mv bioperl-live-bioperl-release-1-2-3 bioperl-1.2.3

# Install Ensembl APIs using shallow clone & move onto the release branch
cd $home/src
$home/programs/ensembl-git-tools/bin/git-ensembl --clone rest ensembl-test
$home/programs/ensembl-git-tools/bin/git-ensembl --checkout --branch "release/$ENSEMBL_VERSION" rest ensembl-test

# Copy settings into place
cp /vagrant/settings/profile $home/.profile

# Chown all these files to vagrant
chown -R $user:$user $home/.profile $home/src $home/programs

# DONE!