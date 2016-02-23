# -*- Makefile
obj-m := xt_dns.o
ccflags-y := -O3 -I${PWD}/../include
DEPMOD=/sbin/depmod
INSTALL=/usr/bin/install -c
KERNEL_RELEASE=`uname -r`
BUILD_DIR=/lib/modules/$(KERNEL_RELEASE)/build
all: kernel.h
	$(MAKE) -C $(BUILD_DIR) M=$(PWD) modules
kernel.h: kernel.sh
	$(SHELL) kernel.sh > kernel.h
clean:
	$(MAKE) -C $(BUILD_DIR) M=$(PWD) clean
install:
	$(INSTALL) -m 0755 -o root -g root xt_dns.ko /lib/modules/$(KERNEL_RELEASE)/kernel/net/netfilter/xt_dns.ko
	$(DEPMOD) -A
