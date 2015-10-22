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
//#include <opencv/cvaux.h>
#include <opencv/highgui.h>
//#include <opencv/cxcore.h>
#include <opencv/cv.h>

#define NDATAW 9600
#define IMG "/root/workspace/APF51-0V7670/software/cam_viewer/htdocs/images/tartine.jpg"  

#define APF51_FPGA_MAP_SIZE 0x10000
#define MEM_OFFSET 0x8
#define RW_COUNTER_BASE 0xFFF8
#define R_COUNTER 0
#define W_COUNTER 2
#define ID_COUNTER 4
#define TRIGGER_SOBEL 4
#include <unistd.h>
int ffpga ;
void * ptr_fpga;
int i = 0;

void rw_counter_log()
{
	printf("component id is %d \n",
		   *(unsigned short*)(ptr_fpga+RW_COUNTER_BASE+ID_COUNTER));
	printf("Read times : %d\n",
		   *(unsigned short*)(ptr_fpga+RW_COUNTER_BASE+R_COUNTER));
	printf("Write times: %d\n",
		   *(unsigned short*)(ptr_fpga+RW_COUNTER_BASE+W_COUNTER));
}
void reset_counter()
{
	// write a dummy word to reset conter
	*(unsigned short*)(ptr_fpga+RW_COUNTER_BASE) = 0xFFFF;
}
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
	{

		//printf(" %2X ", *pSrc);
		*pDst++ = *pSrc++;
		
	}
	return dst;
}
void writeimage()
{
	IplImage* img = cvLoadImage(IMG,CV_LOAD_IMAGE_ANYDEPTH |
								CV_LOAD_IMAGE_ANYCOLOR);
  	if (!img)
  	{
    	printf("Cannot load image\n");
    	return;
  	}
	// convert to grayscale
	IplImage* gray_image  = cvCreateImage(cvGetSize(img),IPL_DEPTH_8U,1);
	cvCvtColor( img, gray_image, CV_BGR2GRAY );
	// write image to fpga
	obtr_memcpy(ptr_fpga+MEM_OFFSET, img->imageData,NDATAW);
}

int main(int argc, char *argv[])
{
	unsigned short buff_out[NDATAW];
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
	// reset interrupt
	*(unsigned short*)(ptr_fpga+2) = 0xFFFF;
	reset_counter();
	rw_counter_log();
	//write the memory zoneOB
	writeimage();
	//obtr_memcpy(ptr_fpga+MEM_OFFSET, buffer,8);
	// write dummy bytes to trgger sobel
	*(unsigned short *)(ptr_fpga+TRIGGER_SOBEL) = 0xFFFF;
	rw_counter_log();

	// wait for data
	reset_counter();
	printf("\nWait for data\n");
	uint32_t info;
	ssize_t nb = read(ffpga,&info,sizeof(info));
	if(nb = sizeof(info))
	{
	   //sleep(3);
		obtr_memcpy(buff_out,ptr_fpga+MEM_OFFSET,NDATAW);
		rw_counter_log();
		
		for ( i = 0; i < NDATAW; i++) {
			printf(" [%2X] ",buff_out[i] );
		}
	}
	printf("Done check \n");


    munmap(ptr_fpga,APF51_FPGA_MAP_SIZE);
    close(ffpga);
    return 0;
}
