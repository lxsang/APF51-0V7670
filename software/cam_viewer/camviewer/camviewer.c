
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
#define IMG_W 160
#define IMG_H 120
#define NDATAW IMG_W*IMG_H //


#define APF51_FPGA_MAP_SIZE 0x10000
#define MEM_OFFSET 0x8
#define RW_COUNTER_BASE 0xFFF8
#define R_COUNTER 0
#define W_COUNTER 2
#define ID_COUNTER 4
#define TRIGGER_CONFIG 4
#define RED_MASK 0xF800
#define GREEN_MASK 0x07E0
#define BLUE_MASK 0x001F
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



void init();
call __init__ = init;
//sqldb db;
void cv565_888(unsigned short* src, IplImage* dst)
{
	float factor5Bit = 255.0 / 31.0;
	float factor6Bit = 255.0 / 63.0;

	for(int i = 0; i < IMG_H; i++)
	{
		for(int j = 0; j < IMG_W; j++)
		{
			unsigned short rgb565 = src[i + j];
			uchar r5 = (rgb565 & RED_MASK)   >> 11;
			uchar g6 = (rgb565 & GREEN_MASK) >> 5;
			uchar b5 = (rgb565 & BLUE_MASK);

			// round answer to closest intensity in 8-bit space...
			uchar r8 = floor((r5 * factor5Bit) + 0.5);
			uchar g8 = floor((g6 * factor6Bit) + 0.5);
			uchar b8 = floor((b5 * factor5Bit) + 0.5);

			dst->imageData[i*dst->widthStep + j]       = r8;
			dst->imageData[i*dst->widthStep + (j + 1)] = g8;
			dst->imageData[i*dst->widthStep + (j + 2)] = b8;
		}
	}
	
}
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
		// trigger config
		*(unsigned short *)(ptr_fpga+TRIGGER_CONFIG) = 0xFFFF;
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

void execute(int client,const char* method,dictionary rq)
{
	int i;
	unsigned short buff_out[NDATAW];
	uchar img888[NDATAW*3];
        if(! ptr_fpga)
	{
		html(client);
		__t(client,"Unable to comunicate with FPGA\n");
        	return;
	}
	// reset interrupt
	*(unsigned short*)(ptr_fpga+2) = 0xFFFF;
	
	//printf("\nWait for data\n");
	uint32_t info;
	ssize_t nb = read(ffpga,&info,sizeof(info));
	if(nb = sizeof(info))
	{

		obtr_memcpy(buff_out,ptr_fpga+MEM_OFFSET,NDATAW);
		IplImage* gray_image  = cvCreateImage(cvSize(IMG_W,IMG_H),IPL_DEPTH_8U,3);	
		float factor5Bit = 255.0 / 31.0;
		float factor6Bit = 255.0 / 63.0;
		uchar r5,g6,b5,r8,g8,b8;
		unsigned short rgb565;
		for (int i = 0; i < NDATAW; i++) {
			rgb565 = buff_out[i];//*((unsigned short*) ptr_fpga+MEM_OFFSET+ (i*2));
			r5 = (rgb565 & RED_MASK)   >> 11;
			g6 = (rgb565 & GREEN_MASK) >> 5;
			b5 = (rgb565 & BLUE_MASK);

			// round answer to closest intensity in 8-bit space...
			r8 = floor((r5 * factor5Bit) + 0.5);
			g8 = floor((g6 * factor6Bit) + 0.5);
		    b8 = floor((b5 * factor5Bit) + 0.5);
			img888[i*3]       = r8;
			img888[i*3 + 1]   = g8;
			img888[i*3+ 2]    = b8;
		  }
		
		//cv565_888(buff_out,gray_image);
		gray_image->imageData = (uchar*)img888;
		int params[3] = {0};
		params[0] = CV_IMWRITE_JPEG_QUALITY;
		params[1] = 90;
		CvMat* tmp = cvEncodeImage(".jpg", gray_image,params);
		jpeg(client);
		for(i=0; i < tmp->rows; i++)
		{
			__b(client,tmp->data.ptr + i*(tmp->step),tmp->cols);
		}
		cvReleaseImage(&gray_image);
		cvReleaseMat(&tmp);
	 }
	
	
	//printf("Done check \n");

	 //munmap(ptr_fpga,APF51_FPGA_MAP_SIZE);
	 //close(ffpga);
	//__fb(client,htdocs("images/ex.jpg"));

}
