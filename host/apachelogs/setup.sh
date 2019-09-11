#!/bin/bash
#
# create bind mountpoint for SFTP log access
# by Felipe Ferreira 09/2019
#

for F in $(find /var/lib/docker/volumes/JOOMLA_WEB_*/_data/logs/ -maxdepth 1 -type d); do
 FD=$(echo "$F" |awk -F"/" '{ print $(NF-3) }')
 C=$(mount -l |grep -c "$FD")
 if [ $C -eq 1 ]; then 
  echo "Mountpoint $FD already found"
  continue;
 fi

 if [ ! -d "/home/sftproot/alogs/home/$FD" ]; then
  mkdir -p /home/sftproot/alogs/home/$FD
 fi

  echo "Bind Mapping $F to /home/sftproot/alogs/home/$FD"
  bindfs -r --map=www-data/alogs:@www-data/@sftponly $F /home/sftproot/alogs/home/$FD

done 
