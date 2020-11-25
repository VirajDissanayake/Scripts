#!/bin/bash

#find the files greater than 300mb in temp folder

fileName = find /etc/tmp -size 300
echo "Enter filename"
read filename

if [[ -f "$filename" ]]
then
    echo "Enter your values to append to the file"
    read txt
    echo "$txt" >> $filename
else
    echo "file not found"
fi