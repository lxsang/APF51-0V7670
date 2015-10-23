
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
#include "plugin.h"
#define NDATAW 9600
#define IMG "/root/workspace/APF51-0V7670/software/sobel_test/test.jpg"  
#define IMG_W 160
#define IMG_H 120
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
//unsigned short test_buff[NDATAW];
void writeimage()
{
	IplImage* img = cvLoadImage(IMG,CV_LOAD_IMAGE_ANYDEPTH |
								CV_LOAD_IMAGE_ANYCOLOR);
  	if (!img)
  	{
    	printf("%s","Cannot load image\n");
    	return;
  	}
	// convert to grayscale
	IplImage* gray_image  = cvCreateImage(cvGetSize(img),IPL_DEPTH_8U,1);
	cvCvtColor( img, gray_image, CV_BGR2GRAY );
	
	//obtr_memcpy(test_buff, gray_image->imageData,NDATAW);
	
	obtr_memcpy(ptr_fpga+MEM_OFFSET, gray_image->imageData,NDATAW);
}


void init();
call __init__ = init;
//sqldb db;

void init()
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
}
void pexit()
{
	printf("%s","Disconnect from FPGA\n");
	if(ptr_fpga)
	{
		munmap(ptr_fpga,APF51_FPGA_MAP_SIZE);
    		close(ffpga);
	}
	printf("%s","Done\n");
}
void origin(int client,const char* method,dictionary rq)
{
	jpeg(client);
	__fb(client,IMG);
}
void execute(int client,const char* method,dictionary rq)
{
	int i;
	unsigned short buff_out[NDATAW];
        if(! ptr_fpga)
	{
		html(client);
		__t(client,"Unable to comunicate with FPGA\n");
        	return;
	}
	// reset interrupt
	*(unsigned short*)(ptr_fpga+2) = 0xFFFF;
	//write the memory zoneOB
	writeimage();
	// write dummy bytes to trgger sobel
	// we don't need this any more
	*(unsigned short *)(ptr_fpga+TRIGGER_SOBEL) = 0xFFFF;

	LOG("\nWait for data\n");
	uint32_t info;
	ssize_t nb = read(ffpga,&info,sizeof(info));
	if(nb = sizeof(info))
	{

		obtr_memcpy(buff_out,ptr_fpga+MEM_OFFSET,NDATAW);

		IplImage* gray_image  = cvCreateImage(cvSize(IMG_W,IMG_H),IPL_DEPTH_8U,1);
		gray_image->imageData = (unsigned char*)buff_out;
		int params[3] = {0};
		params[0] = CV_IMWRITE_JPEG_QUALITY;
		params[1] = 80;
		CvMat* tmp = cvEncodeImage(".jpg", gray_image,params);
		jpeg(client);
		for(i=0; i < tmp->rows; i++)
		{
			__b(client,tmp->data.ptr + i*(tmp->step),tmp->cols);
		}
	}
	//printf("Done check \n");

	 //munmap(ptr_fpga,APF51_FPGA_MAP_SIZE);
	 //close(ffpga);
	//__fb(client,htdocs("images/ex.jpg"));

}
