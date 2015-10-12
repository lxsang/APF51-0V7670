#!/bin/bash

for f in `ls patches/`
do
	#echo $f
	if [ -f "patches/$f" ]; then
		echo "Patching:  $f \n"
		patch -p1 < patches/$f
	fi
done
