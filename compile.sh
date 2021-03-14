#! /bin/bash

file=$(echo $1 | sed "s/.myc//g")

./myc $file.h $file.c < $1
gcc $file.h $file.c -o $file && ./$file