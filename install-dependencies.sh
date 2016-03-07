#!/bin/sh

KERNEL_RELEASE=`uname -r`

if [ -e '/etc/redhat-release' ] ; then
        IPT_VERSION=$(rpm -qi iptables  | grep Version| awk '{print $3}')

        PACKAGES="gcc make automake libtool"
        PACKAGES="$PACKAGES kernel-headers-$KERNEL_RELEASE kernel-devel-$KERNEL_RELEASE"
        PACKAGES="$PACKAGES iptables-devel-$IPT_VERSION"

        exit $?
fi
if [ -e '/etc/fedora-release' ] ; then
        IPT_VERSION=$(rpm -qi iptables  | grep Version| awk '{print $3}')
        
        PACKAGES="gcc make automake libtool"
        PACKAGES="$PACKAGES kernel-headers-$KERNEL_RELEASE kernel-devel-$KERNEL_RELEASE"
        PACKAGES="$PACKAGES iptables-devel-$IPT_VERSION"
        
        if [ "$1" = "--debug" ] ; then
          PACKAGES="$PACKAGES bind-utils ldns-utils nc vim-common"
        fi

        dnf install $PACKAGES
        exit $?
fi
if [ -e '/etc/debian_version' ] ; then
        IPT_VERSION=$(aptitude show iptables | grep 'Version' | awk '{print $2}')

        PACKAGES="gcc make automake libtool"
        PACKAGES="$PACKAGES linux-headers-$KERNEL_RELEASE"
        PACKAGES="$PACKAGES iptables-dev=$IPT_VERSION"

        if [ "$1" = "--debug" ] ; then
          PACKAGES="$PACKAGES dnsutils ldnsutils"
        fi
        apt-get install -y $PACKAGES
        exit $?
fi

echo "not support os. please manual instal."
