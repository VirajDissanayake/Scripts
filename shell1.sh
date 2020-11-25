#!/bin/bash
for i in `cat /tmp/users`
do
echo $i
echo "'Password@123'" | passwd --stdin "$i"
done