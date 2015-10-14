#!/bin/sh

if [ "$1" == "" ]; then
	echo "Usage: `basename $0` ip name"
	exit 1
fi
if [ "$2" == "" ]; then
	echo "Usage: `basename $0` ip name"
	exit 1
fi
./fclean
hdlmake
make
if [ $? -eq 0 ]; then
    bitgen  -w -g Binary:Yes -intstyle ise  top_level.ncd
    #scp "./top_level.bin" "root@$1:/root/$2.bin"
else
    echo "FAIL TO MAKE"
fi
