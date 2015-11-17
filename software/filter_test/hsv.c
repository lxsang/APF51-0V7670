
/*
  This program use to test memcpy on the uio device
*/

#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>

#define APF51_FPGA_MAP_SIZE 0x10000
#define MEM_OFFSET 0x8
#define TRIGGER_SOBEL 4
#include <unistd.h>
int ffpga ;
void * ptr_fpga;

void* obtr_memcpy(void* dst, void* src, size_t len)
{
	unsigned short* pDst = (unsigned short*) dst;
	unsigned short* pSrc = (unsigned short*) src;
	while(len--)
	{

		//printf(" %2X ", *pSrc);
		*pDst++ = *pSrc++;
		
	}
	return dst;
}


int main(int argc, char *argv[])
{
	printf("%s","Connect to the fpga\n");
	ffpga = open("/dev/uio0", O_RDWR|O_SYNC);
    	if(ffpga <0)
    	{
        	printf("%s","Cannot open /dev/uio0\n");
        	return;
    	}
    	ptr_fpga = mmap(0,APF51_FPGA_MAP_SIZE,PROT_READ|PROT_WRITE, MAP_SHARED, ffpga, 0);
    	if(ptr_fpga == MAP_FAILED)
    	{
		ptr_fpga = NULL;
        	printf("%s","MMap faile\n");
        	return;
    	}
		*(unsigned short*)(ptr_fpga+2) = 0xFFFF;
		if(argc == 4)
		{
			unsigned short r,g,b;

			r = (unsigned short) atoi(argv[1]);
			g = (unsigned short) atoi(argv[2]);
			b = (unsigned short) atoi(argv[3]);
			printf("R:%d G:%d B:%d\n",r,g,b);
			*(unsigned short*)(ptr_fpga+MEM_OFFSET) = r;
			*(unsigned short*)(ptr_fpga+MEM_OFFSET+2) = g;
			*(unsigned short*)(ptr_fpga+MEM_OFFSET+4) = b;
			*(unsigned short *)(ptr_fpga+TRIGGER_SOBEL) = 0xFFFF;
			//uint32_t info;
			//ssize_t nb = read(ffpga,&info,sizeof(info));
			//if(nb = sizeof(info))
			//{
				// get back data
				printf("Data %d\n",*(unsigned short*)(ptr_fpga+MEM_OFFSET));
				printf("Data %d\n",*(unsigned short*)(ptr_fpga+MEM_OFFSET+2));
				printf("Data %d\n",*(unsigned short*)(ptr_fpga+MEM_OFFSET+4));
				printf("Data %d\n",*(unsigned short*)(ptr_fpga+MEM_OFFSET+6));
			//}
		}
	if(ptr_fpga)
	{
		munmap(ptr_fpga,APF51_FPGA_MAP_SIZE);
    		close(ffpga);
	}
	printf("%s","Done\n");
}


