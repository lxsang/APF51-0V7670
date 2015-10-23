#include<stdio.h>
#include<stdlib.h>

int main(int argc, char *argv[])
{
	char test[2];
	test[0] = 1;
	test[1] = 5;

	unsigned short* ptr;
	ptr = (unsigned short*) test;


	printf("Ptr value %d\n",*ptr );
	
    return 0;
}
