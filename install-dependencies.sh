#!/bin/sh

KERNEL_RELEASE=`uname -r`
LANG=C

export LANG

if [ -e '/etc/redhat-release' ] ; then
        which dnf > /dev/null
        if [ "$?" = "0" ] ; then
          PKG='dnf'
        else
          PKG='yum'
        fi
        IPT_VERSION=$(rpm -qi iptables  | grep Version| awk '{print $3}')
        
        PACKAGES="gcc make automake libtool"
        PACKAGES="$PACKAGES kernel-headers-$KERNEL_RELEASE kernel-devel-$KERNEL_RELEASE"
        PACKAGES="$PACKAGES iptables-devel-$IPT_VERSION"
        
        if [ "$1" = "--debug" ] ; then
          PACKAGES="$PACKAGES bind-utils ldns-utils nc vim-common"
        fi

        $PKG install -y $PACKAGES
        exit $?
fi
if [ -e '/etc/debian_version' ] ; then
        which apt > /dev/null
        if [ "$?" = "0" ] ; then
          IPT_VERSION=$(apt show iptables | grep 'Version' | awk '{print $2}')
        else
          IPT_VERSION=$(aptitude show iptables | grep 'Version' | awk '{print $2}')
        fi
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
