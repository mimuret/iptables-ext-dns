#!/bin/sh

KERNEL_RELEASE=`uname -r`
LDNS_DEVEL=''

if [ -e '/etc/centos-release' ] ; then
        if [ $1 == '--test'] ; then
                LDNS_DEVEL='ldns-devel openssl-devel'
        fi
        sudo yum -y install gcc \
                make automake libtool \
                iptables-devel \
                kernel-headers-$KERNEL_RELEASE \
                kernel-devel-$KERNEL_RELEASE \
                $LDNS_DEVEL
        exit $?
fi
if [ -e '/etc/fedora-release' ] ; then
        if [ $1 == '--test'] ; then
                LDNS_DEVEL='ldns-devel'
        fi
        sudo dnf -y install gcc \
                make automake libtool \
                iptables-devel \
                kernel-headers-$KERNEL_RELEASE \
                kernel-devel-$KERNEL_RELEASE \
                $LDNS_DEVEL
        exit $?
fi
if [ -e '/etc/debian_version' ] ; then
        if [ $1 == '--test'] ; then
                LDNS_DEVEL='libldns-dev'
        fi
        sudo apt-get install gcc \
                make \
                automake \
                autoconf \
                libtool \
                linux-headers-$KERNEL_RELEASE \
                iptables-dev \
                $LDNS_DEVEL
        exit $?
fi

echo "not support os. please manual instal."
