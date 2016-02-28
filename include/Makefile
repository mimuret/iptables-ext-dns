all: kernel.h
	
kernel.h: kernel.sh
	$(SHELL) kernel.sh > kernel.h
clean:
	rm kernel.h
	$(MAKE) -C $(BUILD_DIR) M=$(PWD) clean
install:
check:
