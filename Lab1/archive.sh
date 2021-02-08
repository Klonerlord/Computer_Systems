#!/bin/bash

path=$(pwd)
tar -czf $path/$1.tar $path/$1
gzip -k $path/$1
bzip2 -k $path/$1
zip $1.zip $path/$1
xz -k $path/$1