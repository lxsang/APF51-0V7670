/*
  This program is used to test the uio device
*/
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>

#define LED 0x8
#define APF51_FPGA_MAP_SIZE 0x10000

int ffpga ;
void * ptr_fpga;


int main(int argc, char *argv[])
{
    unsigned short led;
    ffpga = open("/dev/uio0", O_RDWR|O_SYNC);
    if(ffpga <0)
    {
        printf("Cannot open /dev/uio0\n");
        return -1;
    }

    ptr_fpga = mmap(0,APF51_FPGA_MAP_SIZE,PROT_READ|PROT_WRITE, MAP_SHARED, ffpga, 0);
    if(ptr_fpga == MAP_FAILED)
    {
        printf("MMap faile\n");
        return -1;
    }
    uint32_t info;
    ssize_t nb = read(ffpga,&info,sizeof(info));
    if(nb == sizeof(info))
    {
        printf("Interrupt %d\n", info);
        // read the led status
        led = *(unsigned short*)(ptr_fpga + LED);
        printf("The led value is %d\n",led );
        // toggle the led
        *(unsigned short*)(ptr_fpga+LED) = (unsigned short)(led ^ 1);
    }
    munmap(ptr_fpga,APF51_FPGA_MAP_SIZE);
    close(ffpga);
    return 0;
}
