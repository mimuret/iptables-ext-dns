#!/bin/sh

KERNEL_RELEASE=`uname -r`
LDNS_DEVEL=''

if [ -e '/etc/centos-release' ] ; then
        if [ "$1" = "--debug" ] ; then
                yum install -y bind-utils ldns nc vim-common
        fi
        yum install -y gcc \
                make automake libtool \
                iptables-devel \
                kernel-headers-$KERNEL_RELEASE \
                kernel-devel-$KERNEL_RELEASE
        exit $?
fi
if [ -e '/etc/fedora-release' ] ; then
        if [ "$1" = "--debug" ] ; then
          yum install -y bind-utils ldns nmap-ncat vim-common
        fi
        dnf install -y gcc \
                make automake libtool \
                iptables-devel \
                kernel-headers-$KERNEL_RELEASE \
                kernel-devel-$KERNEL_RELEASE
        exit $?
fi
if [ -e '/etc/debian_version' ] ; then
        if [ "$1" = "--debug" ] ; then
                apt-get install -y dnsutils ldnsutils
        fi
        apt-get install -y gcc \
                make \
                automake \
                autoconf \
                libtool \
                linux-headers-$KERNEL_RELEASE \
                iptables-dev
        exit $?
fi

echo "not support os. please manual instal."
