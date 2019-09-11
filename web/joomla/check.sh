#!/bin/bash
IP_HOST=$(ip addr  |grep ens160 |tail -n1  |awk '{ print $2 }' |awk -F"/" '{ print $1}')
I=$(netstat -ntlp |grep ":16" |awk '{ print $4 }' |sed "s/0.0.0.0/ ${IP_HOST}/g")

 for P in $I;  do
  echo -e "$P"
  curl -s -I $P |head -n1 
 done

