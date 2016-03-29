#!/bin/bash

WWW_ROOT=$1

echo $WWW_ROOT

mkdir -p ${WWW_ROOT} && cd ${WWW_ROOT} || exit 1

# get the key
/usr/local/bin/get-key.sh ${WWW_ROOT}

# get the rpms
touch /etc/yum.conf
reposync -r yum -p ${WWW_ROOT}
createrepo ${WWW_ROOT}/yum

# get the debs
apt-mirror
