#!/bin/bash
for pid in $(pidof avconv); do
	#kill -9 $pid
	echo "$pid"
done
