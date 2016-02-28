# -*- Makefile
obj-m := xt_dns.o
ccflags-y := -O3 -I$(src)/../include
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
	$(MAKE) INSTALL_MOD_DIR=kernel/net/netfilter -C $(BUILD_DIR) M=$(PWD) modules_install
	$(DEPMOD) -A
check:
