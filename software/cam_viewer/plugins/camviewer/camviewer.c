#include "../plugin.h"
//#include <opencv/cvaux.h>
#include <opencv/highgui.h>
//#include <opencv/cxcore.h>
#include <opencv/cv.h>

void init();
call __init__ = init;
//sqldb db;

void init()
{
	printf("Finish init\n");
}

void execute(int client,const char* method,dictionary rq)
{
	IplImage* img = cvLoadImage(htdocs("images/ex.jpg"),CV_LOAD_IMAGE_ANYDEPTH | CV_LOAD_IMAGE_ANYCOLOR);

  	if (!img)
  	{
    	html(client);
    	__t(client,"<p>Cannot load image</p>");
    	return;
  	}
  	//convert to jpeg memory
  	//CvMat* tmp(img);
  	int params[3] = {0};
  	params[0] = CV_IMWRITE_JPEG_QUALITY;
  	params[1] = 50;
  	CvMat* tmp = cvEncodeImage(".jpg", img,params);
	jpeg(client);
	for(int i = 0; i < tmp->rows; i++)
    {   
        	//int segment_start = image.data + i * image.step;

        	//uchar v = *(uchar*)(tmp->data + i*tmp->step + j);
            __b(client,tmp->data.ptr + i*(tmp->step),tmp->cols);
            //v_char.push_back();                       
    }
	//__f(client,htdocs("images/ex.jpg"));
	
}
