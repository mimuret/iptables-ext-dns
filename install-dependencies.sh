#!/bin/sh

KERNEL_RELEASE=`uname -r`
LDNS_DEVEL=''

if [ -e '/etc/centos-release' ] ; then
        yum -y install gcc \
                make automake libtool \
                iptables-devel \
                kernel-headers-$KERNEL_RELEASE \
                kernel-devel-$KERNEL_RELEASE 
        exit $?
fi
if [ -e '/etc/fedora-release' ] ; then
        dnf -y install gcc \
                make automake libtool \
                iptables-devel \
                kernel-headers-$KERNEL_RELEASE \
                kernel-devel-$KERNEL_RELEASE 
        exit $?
fi
if [ -e '/etc/debian_version' ] ; then
        apt-get install gcc \
                make \
                automake \
                autoconf \
                libtool \
                linux-headers-$KERNEL_RELEASE \
                iptables-dev 
        exit $?
fi

echo "not support os. please manual instal."
