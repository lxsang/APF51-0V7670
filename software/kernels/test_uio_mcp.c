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
#define ACCESS_NO (2000*100)
#define MBYTE       (1000000)
#  ifndef CLK_TCK
#   define CLK_TCK      CLOCKS_PER_SEC
#  endif 
int ffpga ;
void * ptr_fpga;

/*
  Our function to copy a 16bit data region
  using specially to communicate with 
  the fpga
  Note that the len here is number of 16 bit words
*/
void* obtr_memcpy(void* dst, void* src, size_t len)
{
	unsigned short* pDst = (unsigned short*) dst;
	unsigned short* pSrc = (unsigned short*) src;
	while(len--)
		*pDst++ = *pSrc++;
	return dst;
}

unsigned short buffer[128];
int i = 0;

void init_buffer(){
	for(i = 0; i<128; i++)
		buffer[i] = i+1;
}

void dump_mem_acess_time(clock_t tick1, clock_t tick2)
{
	int tick = tick2 - tick1;
	float duration = ((float) tick)/((float) CLK_TCK);
	printf("Wrote 128x16 bits words %d time in %g sec\n",ACCESS_NO,duration);
	printf("Speed: %g Mbyte/s \n",
		(float)((ACCESS_NO*128*2)/duration)/MBYTE);
} 

int main(int argc, char *argv[])
{
    unsigned short buff_out[128];
	clock_t tick1, tick2;
	init_buffer();
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

	//write the memory zone
	// testing the access time
	tick1 = clock();
	for (i = 0; i < ACCESS_NO; i++) {
		obtr_memcpy(ptr_fpga+MEM_OFFSET, buffer,128);
	}
	tick2 = clock();
	dump_mem_acess_time(tick1, tick2);

	//obtr_memcpy(buff_out,ptr_fpga+MEM_OFFSET,128);
	// test read speed
	printf("Test read speed\n");
	tick1 = clock();
	for (i = 0; i < ACCESS_NO; i++) {
		obtr_memcpy(buff_out,ptr_fpga+MEM_OFFSET,128);
	}
	tick2 = clock();
	dump_mem_acess_time(tick1,tick2);
	
	for ( i = 0; i < 128; i++) {
		printf(" [%d] ", buff_out[i]);
	}

	/*printf("Write by loop\n");
	tick1 = clock();
	int j;
	for(j = 0; j < ACCESS_NO;j++)
		for (i = 0; i < 128; i++) {
		*(unsigned short*)(ptr_fpga+MEM_OFFSET+i*2) = buffer[i];
		}
		tick2 = clock()
	dump_mem_acess_time(tick1,tick2);
	printf("Read by loop\n");
	for (i = 0; i < 128; i++) {
		printf(" [%d] ",
			   ( *(unsigned short*)(ptr_fpga+MEM_OFFSET+i*2)) 
			);
	}
	*/
    munmap(ptr_fpga,APF51_FPGA_MAP_SIZE);
    close(ffpga);
    return 0;
}
