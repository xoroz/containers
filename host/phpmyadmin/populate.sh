#!/bin/bash
#
# by Felipe Ferreira 08/20/2019
# setup phpmyadmin to have a dropdown with all Databases Running in this host
DIR="/var/www/app/phpmyadmin/"
CONFIG="${DIR}config.inc.php"
if [ ! -f $CONFIG ]; then
 echo "ERROR - please first configure phpmyadmin at $DIR"
 exit 2
fi 

cp $CONFIG ${CONFIG}.bkp
echo "" > config.inc.php
echo "<?php" >> config.inc.php
echo '$i=0;' >> config.inc.php

for N in $(docker ps |grep db |awk '{ print $NF }'); do 
 IP=$(docker inspect $N |grep IPAddress |tail -n1 |sed -e 's/"//g' -e 's/,//g' |awk '{ print $NF }')
 echo "$N $IP"
 sed -e "s/SKEL_NAME/${N}/g" -e "s/SKEL_IP/${IP}/g"  skel.inc.php >> config.inc.php
done
cp -fv config.inc.php $CONFIG
echo "DB config file updated"

#docker cp config.inc.php ${P}:/var/www/html/config.inc.php 
#docker exec -ti $P /etc/init.d/apache2 reload
