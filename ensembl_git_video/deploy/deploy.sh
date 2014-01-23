#!/bin/sh

apt-get clean
apt-get update
 
apt-get install -y git
apt-get install -y libdbi-perl libdbd-mysql-perl unzip tcsh
apt-get clean