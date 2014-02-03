#!/bin/sh

ENSEMBL_VERSION=$1
GUI=$2

if [ -z "$ENSEMBL_VERSION" ]; then
  echo 'Cannot find the API version. Make sure this has been given to the script' >2
  exit
fi

# Global user settings
user=ensembl
home=/home/$user

# Add the ensembl user & make it able to sudo 
useradd -d $home -s /bin/bash -U -m $user
usermod -a -G sudo $user

# Install APT dependencies
apt-get clean
echo 'deb http://ca.archive.ubuntu.com/ubuntu/ precise-updates main restricted' >> /etc/apt/sources.list
echo 'deb http://ca.archive.ubuntu.com/ubuntu/ precise-updates universe' >> /etc/apt/sources.list
echo 'deb http://ca.archive.ubuntu.com/ubuntu/ precise-updates multiverse' >> /etc/apt/sources.list
apt-get update
apt-get install -y git
apt-get install -y cpanminus libmodule-install-perl libxml-libxml-perl libtest-xml-simple-perl
apt-get install -y libdbi-perl libdbd-mysql-perl

if [ -n "$GUI" ]; then
  apt-get update
  add-apt-repository ppa:gnome3-team/gnome3
  apt-get install -y  --no-install-recommends gnome-shell
  apt-get install -y --no-install-recommends ubuntu-desktop
  apt-get install -y --no-install-recommends gdm
  # dpkg-reconfigure gdm
fi

apt-get clean

# Run the post installation script
# /home/vagrant/postinstall.sh

: <<'END'
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
$home/programs/ensembl-git-tools/bin/git-ensembl --clone --depth 1 --branch "release/$ENSEMBL_VERSION" api tools

# Copy settings into place
cp /vagrant/settings/profile $home/.profile

# Chown and chgrp all files to vagrant user 
chown -R $user:$user $home/.profile $home/src $home/programs
END
