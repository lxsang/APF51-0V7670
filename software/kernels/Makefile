obj-m+=uio.o
obj-m+=obtrkn.o
all:
	make -C /lib/modules/$(shell uname -r)/build/ M=$(PWD) modules

test:
	gcc test_uio.c -o uio_test
clean:
	make -C /lib/modules/$(shell uname -r)/build/ M=$(PWD) clean
