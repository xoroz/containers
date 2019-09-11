#!/bin/bash
# 
# migrate a pagekit site into a precreated container
# Requires a zip of the /public folder and the .gz of the database
# by Felipe Ferreira 08/16/2019

# as first step could  check if
#1 both containers are running (OK)
#2 .env file exists (OK)
#3 import files are present (OK)

############ CHECKS AND PRE-START
C=$(docker-compose ps |grep -c "Up")
if [ "$C" -ne "2" ]; then
 echo "ERROR - Could not get the 2 containers, are they Up and running?"
 exit 2
fi
if [ ! -f ".env" ]; then
 echo "ERROR - Could not find the .env file!"
 exit 2
fi

source .env

D="/opt/data/imports/"
WI="${D}${SITE_NAME}.zip"
DI="${D}${DB_NAME}"
if [ ! -f  $WI ]; then
 echo "ERROR - $WI not found!"
 exit 2
fi
if [ ! -f ${DI}.gz ]; then
 echo "ERROR - $DI not found!"
 exit 2
fi
######################## MAIN
P=$(pwd)
WV=$(docker volume inspect PK_WEB_$SITE_PORT |grep Mountpoint |awk -F":" '{print $NF}' | sed 's/,//g' | sed 's/ //g' |sed 's/"//g' )

if [ ! -d  $WV ]; then
 echo "ERROR - $WV not found!"
 exit 2
fi
echo "WEB_VOLUME: $WV"

echo "$SITE_NAME is being inserted into container volume $SITE_VOLUME"
cp -fv $WI $WV
cd $WV ; unzip -q -o ${SITE_NAME}.zip ;  cd $P
WV="${WV}/public/"

# FIX DB HOST NAME, DB PASSWORD, using pre configured SKEL file
sed -e "s/DB_NAME/$DB_NAME/g" -e "s/DB_PASSWORD/$DB_ROOT_PASSWORD/g"  ${D}config.php > ${WV}config.php
cp -fv ${D}htaccess ${WV}.htaccess
# Set www-data for public
chown 33:33 -R ${WV} 
find $WV -type d -exec chmod 755 '{}' \;
echo "OK - $SITE_NAME has been inserted into container and has $(du -sh $WV)"

echo -e "\n................................................\n"
sleep 5
#get container dynamicly
PK_DB=$(docker-compose ps |grep db |awk '{ print $1 }')

DI=${D}${DB_NAME}
if [ ! -f ${DI} ]; then 
 cd $D ; gunzip -k -d ${DB_NAME}.gz ; cd $P
fi
if [ ! -f ${DI} ]; then
 echo "ERROR - Could not find $DI"
 exit 2
fi

echo "$DB_NAME is being imported to db container w pass $DB_ROOT_PASSWORD"
echo "Checking connection using root and $DB_ROOT_PASSWORD"
docker exec -i $PK_DB  mysql -u root -p${DB_ROOT_PASSWORD} -e "show databases;"|grep $DB_NAME

cat $DI | docker exec -i $PK_DB mysql -u root -p${DB_ROOT_PASSWORD}
if [ "$?" -ne "0" ]; then
 echo "ERROR $DI could not be inserted into $PK_DB"
 docker-compose logs $PK_DB |tail -n 10
# docker-compose down
 exit 2
fi
rm -f $DI
C=$(docker exec -i $PK_DB  mysql -u root -p${DB_ROOT_PASSWORD} -e "show databases;"|grep -c  $DB_NAME)
if [ "$C" -ne "1" ]; then
 echo "ERROR - DB could not be imported to $PK_DB"
fi

sleep 2

#TEST
C=$(curl -s -I "http://localhost:$SITE_PORT" |head -n1  |grep -c " 200 ")
if [ "$C" -ne "1" ]; then
 echo "ERROR - Site http://localhost:$SITE_PORT did not open"
# docker-compose logs |tail -n 10
 docker-compose down 
 exit 2
else
 echo "Site is up at http://192.168.7.67:$SITE_PORT"
fi

echo -e "\n\n\n-------------------------------------------------------------------\n\n"

exit 0
