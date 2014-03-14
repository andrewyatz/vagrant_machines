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
mkdir $home/src
cd $home/src
wget https://github.com/bioperl/bioperl-live/archive/bioperl-release-1-2-3.tar.gz
tar zxf bioperl-release-1-2-3.tar.gz
mv bioperl-live-bioperl-release-1-2-3 bioperl-1.2.3

# Install Ensembl APIs using shallow clone & move onto the release branch
cd $home/src
$home/programs/ensembl-git-tools/bin/git-ensembl --clone rest
$home/programs/ensembl-git-tools/bin/git-ensembl --checkout --branch "release/$ENSEMBL_VERSION" rest

# Copy settings into place
cp /vagrant/settings/profile $home/.profile

# Chown all these files to vagrant
chown -R $user:$user $home/.profile $home/src $home/programs

# DONE!