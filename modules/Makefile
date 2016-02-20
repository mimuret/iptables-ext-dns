# -*- Makefile
obj-m := xt_dns.o
ccflags-y := -O3 -I${PWD}/../include
DEPMOD=/sbin/depmod
INSTALL=/usr/bin/install -c
KERNEL_RELEASE=$(shell uname -r)
all:
	$(MAKE) -C /lib/modules/$(KERNEL_RELEASE)/build M=$(PWD) modules
clean:
	$(MAKE) -C /lib/modules/$(KERNEL_RELEASE)/build M=$(PWD) clean
install:
	$(INSTALL) -m 0755 -o root -g root xt_dns.ko /lib/modules/$(KERNEL_RELEASE)/kernel/net/netfilter/xt_dns.ko
	$(DEPMOD) -A
	