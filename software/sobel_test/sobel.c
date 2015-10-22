
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
int i = 0;

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
    	printf("Cannot load image\n");
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
	printf("Finish init\n");
}

void execute(int client,const char* method,dictionary rq)
{
	unsigned short buff_out[NDATAW];
	ffpga = open("/dev/uio0", O_RDWR|O_SYNC);
    if(ffpga <0)
    {
		html(client);
        __t(client,"Cannot open /dev/uio0\n");
        return -1;
    }

    ptr_fpga = mmap(0,APF51_FPGA_MAP_SIZE,PROT_READ|PROT_WRITE, MAP_SHARED, ffpga, 0);
    if(ptr_fpga == MAP_FAILED)
    {
		html(client);
        __t(client,"MMap faile\n");
        return -1;
    }
	// reset interrupt
	*(unsigned short*)(ptr_fpga+2) = 0xFFFF;
	//write the memory zoneOB
	writeimage();
	// write dummy bytes to trgger sobel
	*(unsigned short *)(ptr_fpga+TRIGGER_SOBEL) = 0xFFFF;
	
	printf("\nWait for data\n");
	uint32_t info;
	ssize_t nb = read(ffpga,&info,sizeof(info));
	if(nb = sizeof(info))
	{
	  
		obtr_memcpy(buff_out,ptr_fpga+MEM_OFFSET,NDATAW);

		// convert to grayscale
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

    munmap(ptr_fpga,APF51_FPGA_MAP_SIZE);
    close(ffpga);
	//__fb(client,htdocs("images/ex.jpg"));
	
}
