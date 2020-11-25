#!/bin/bash
#go though all files stored in /etc directory. The for loop will be abandon when /etc/resolv.conf file found
for file in /etc/*
do
	if [ "${file}" == "/etc/resolv.conf" ]
	then
		countNameservers=$(grep -c nameserver /etc/resolv.conf)
		echo "Total  ${countNameservers} nameservers defined in ${file}"
		break
	fi
done