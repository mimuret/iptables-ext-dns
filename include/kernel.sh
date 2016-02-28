#!/bin/sh

KERNEL_VERSION=`uname -r | awk -F '.' '{ print $1 }'`
KERNEL_PATCHLEVEL=`uname -r | awk -F '.' '{ print $2 }'`
KERNEL_SUBLEVEL=`uname -r | awk -F '.' '{ print $3 }'`

echo "#define KERNEL_VERSION $KERNEL_VERSION"
echo "#define KERNEL_PATCHLEVEL $KERNEL_PATCHLEVEL"
echo "#define KERNEL_SUBLEVEL \"$KERNEL_SUBLEVEL\""
