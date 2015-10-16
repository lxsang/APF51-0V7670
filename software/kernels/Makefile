obj-m+=uio.o
obj-m+=obtrkn.o
all:
	make -C /lib/modules/$(shell uname -r)/build/ M=$(PWD) modules
test:
	gcc -mcpu=cortex-a8 test_uio.c -o test_uio
	gcc -mcpu=cortex-a8 test_uio_mcp.c -o test_uio_mcp
	gcc -mcpu=cortex-a8 test_mem_mcp.c -o test_mem_mcp
clean: 
	make -C /lib/modules/$(shell uname -r)/build/ M=$(PWD) clean
