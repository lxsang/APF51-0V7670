
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


#define APF51_FPGA_MAP_SIZE 0x10000
#define MEM_OFFSET 0x8
#define POS_OFFSET 0xFFF0
#define R_QQVGA 2
#define R_Q_VGA 4
#define TRIGGER_CONFIG 4
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
	sleep(1);
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
	int w, h;
	int res = R_INT(rq,"res");
	if (res == 2) {
		w = 160; h = 120;
	} else if(res == 4)
	{
		w = 320; h = 240;
	}
	else
	{
		w = 640; h = 480;
		res = 0;
	}
	unsigned short buff_out[w*h/16];
	uchar img_data[w*h];
	int nword = w*h/16;
	unsigned short chunk[2];
	int npx, x, y, sum;
    if(! ptr_fpga)
	{
		html(client);
		__t(client,"Unable to comunicate with FPGA\n");
        	return;
	}
	// reset interrupt
	*(unsigned short*)(ptr_fpga+2) = 0xFFFF;
	// setting up the resolution
	*(unsigned short*)(ptr_fpga+MEM_OFFSET+res) = 0xFFFF;
	//printf("\nWait for data\n");
	uint32_t info;
	ssize_t nb = read(ffpga,&info,sizeof(info));
	//printf("IRQ: %d\n",nb);
	if(nb = sizeof(info))
	{
		// get the image
		obtr_memcpy(buff_out,ptr_fpga+MEM_OFFSET,nword);
		// get the sum
		obtr_memcpy(chunk,ptr_fpga+POS_OFFSET,2);
		memcpy(&x, (char*)chunk, 4);
		obtr_memcpy(chunk,ptr_fpga+POS_OFFSET+4,2);
		memcpy(&y, (char*)chunk, 4);
		obtr_memcpy(chunk,ptr_fpga+POS_OFFSET+8,2);
                memcpy(&npx, (char*)chunk, 4);
		printf("sum x: %d, sum y: %d, n: %d\n",x,y, npx);
		//obtr_memcpy(buff_out,ptr_fpga+MEM_OFFSET,nword);
		//sum = x = y = npx = 0;
		for (int i = 0; i < nword ; i++) {
                        unsigned short tmp = buff_out[i];
                        for (int j=0; j<16; j++) {
                                if(tmp & (1<<j))
                                { 
					img_data[i*16+j] = 255;
					/*npx++;
					sum = i*16+j;
					x+= sum/w;
					y+= sum%w;*/
				}
                                else
                                        img_data[i*16+j] = 0;
                        }

                }
		IplImage* gray_image  = cvCreateImage(cvSize(w,h),IPL_DEPTH_8U,1);
		//cvSetData(gray_image,img_data,gray_image->widthStep);
		gray_image->imageData = (uchar*)img_data;
		if(npx > 100)
                {
                       // int avg = y/npx;
			x = x/npx;
			y = y/npx;
			///y = y > w?(y%w):y;
			//y = (y - x*w)/npx;
			//x = x / npx;
			
                        printf("[x,y] = [%d,%d]\n", x,y);
			// draw the circle
			cvCircle(gray_image, cvPoint(y,x), 10, cvScalar(255,0,0,0), 1, 8, 0);
                }
		int params[3] = {0};
		params[0] = CV_IMWRITE_JPEG_QUALITY;
		params[1] = 90;
		CvMat* tmp = cvEncodeImage(".jpg", gray_image,params);
		jpeg(client);
		for(int i=0; i < tmp->rows; i++)
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
