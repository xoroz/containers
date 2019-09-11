#!/bin/bash
# 
# migrate a joomla site into a precreated container
# Requires a zip of the /public folder and the .gz of the database and port in a list like "site.it;db_it;1601"

# by Felipe Ferreira 08/16/2019

# as first step could  check if
#1 both containers are running (OK)
#2 .env file exists (OK)
#3 import files are present (OK)

############ CHECKS AND PRE-START
C=$(docker-compose ps |grep -c "Up")
echo -e "----------------------------------------------------------------\n"
if [ "$C" -ne "2" ]; then
 echo "ERROR - Could not get the 2 containers, are they Up and running?"
 exit 2
fi
if [ ! -f ".env" ]; then
 echo "ERROR - Could not find the .env file!"
 exit 2
fi

IP_HOST=$(ip addr  |grep ens160 |tail -n1  |awk '{ print $2 }' |awk -F"/" '{ print $1}') 
echo "IP_HOST=$IP_HOST" >> .env
source .env
D="/var/imports/"
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
WV=$(docker volume inspect JOOMLA_WEB_$SITE_PORT |grep Mountpoint |awk -F":" '{print $NF}' | sed 's/,//g' | sed 's/ //g' |sed 's/"//g' )

if [ ! -d  $WV ]; then
 echo "ERROR - $WV not found!"
 exit 2
fi

#echo "WEB - $SITE_NAME is being inserted into container volume $SITE_VOLUME"
cp -f $WI $WV
#could have been done with "docker cp" 
cd $WV ; rm -rf public/installation/* ; unzip -q -o ${SITE_NAME}.zip ;  rm -f ${SITE_NAME}.zip ; rm -rf public/installation/* ; cd $P

WV="${WV}/public/"

# FIX DB HOST NAME, GET DB PASSWORD, GET DB USER 
S="${WV}/configuration.php"
if [ ! -f "$S" ]; then
 echo "ERROR - could not find the configuration.php file at $S"
 exit 2
fi
#echo ".Configuring the new database server db on file $S and get user / pass"
sed -i "s/gunganproduction.example.com/db/g" $S 
sed -i "s/iitdbuge003.example.com/db/g" $S 
sed -i "s/iitdbuge003s.example.com/db/g" $S 
#check if ssl force is enabled
sed -i "s/force_ssl = '1'/force_ssl = '0'/g" $S
sed -i "s/force_ssl = '2'/force_ssl = '0'/g" $S
#fix log_path and tmp_path to new DocumentRoot
sed -i "s/\/var\/www\/$SITE_NAME\/app\/public\/administrator\/logs/\/var\/www\/public\/tmp/g" $S
sed -i "s/\/var\/www\/$SITE_NAME\/app\/public\/tmp/\/var\/www\/public\/tmp/g" $S
DB_USER=$(grep "public \$user" $S|awk '{ print $NF }' |sed -e "s/'//g"  -e "s/;//g")
DB_PASS=$(grep "public \$password" $S|awk '{ print $NF }' |sed -e "s/'//g"  -e "s/;//g")

#echo " WEB - From joomla config - GOT DB_USER: $DB_USER AND DB_PASS: $DB_PASS"


# Set www-data for public
chown 33:33 -R ${WV} 
find $WV -type d -exec chmod 755 '{}' \;
echo "WEB - OK $SITE_NAME has been inserted into container and has $(du -sh $WV)"

sleep 5
#get container dynamicly
JOOMLA_DB=$(docker-compose ps |grep db |awk '{ print $1 }')

DI=${D}${DB_NAME}
if [ ! -f ${DI} ]; then 
 cd $D ; gunzip -k -d ${DB_NAME}.gz ; cd $P
fi
if [ ! -f ${DI} ]; then
 echo "ERROR - Could not find db file at $DI"
 exit 2
fi
echo -e "-------------------------------------------------------------------\n\n"

echo -e "\nDB: $DB_NAME is being imported to container: $JOOMLA_DB (please wait...) \n\n"
sleep 2

cat $DI | docker exec -i $JOOMLA_DB mysql -u root -p${DB_ROOT_PASSWORD}
if [ "$?" -ne "0" ]; then
 echo "ERROR $DI could not be inserted into $JOOMLA_DB"
 docker-compose logs $JOOMLA_DB |tail -n 10
# docker-compose down
 exit 2
fi
rm -f $DI

C=$(docker exec -i $JOOMLA_DB  mysql -u root -p${DB_ROOT_PASSWORD} -e "show databases;"|grep -c  $DB_NAME)
if [ "$C" -ne "1" ]; then
 echo "ERROR - DB could not be imported to $JOOMLA_DB"
 exit 2
fi

# MUST CREATE USER IN DB
docker exec -i $JOOMLA_DB  mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE USER '${DB_USER}' IDENTIFIED BY '${DB_PASS}';"

C=$(echo "$DB_NAME" | grep -c "-") 
if [ "$C" -ne "0" ]; then
 #\`andy-project_eu\` when there is - it causes problems!
 docker exec -i $JOOMLA_DB  mysql -u root -p${DB_ROOT_PASSWORD} -e "GRANT ALL privileges ON \`${DB_NAME}\`.* TO '${DB_USER}';"
else
 docker exec -i $JOOMLA_DB  mysql -u root -p${DB_ROOT_PASSWORD} -e "GRANT ALL privileges ON ${DB_NAME}.* TO '${DB_USER}';"
fi

sleep 6

#TEST NEED HOST IP ADDRESS
C=$(curl --connect-timeout 10 -s -I "http://$IP_HOST:$SITE_PORT" |head -n1  |grep -c " 200 ")
if [ "$C" -ne "1" ]; then
 echo "ERROR - Site http://$IP_HOST:$SITE_PORT did not open"
 docker-compose logs |tail -n 10
# docker-compose down 
else
 echo "Site is up at http://$IP_HOST:$SITE_PORT"
fi

if [ -d ${WV}installation ]; then
 echo "Removing ${WV}installation"
 rm -rf ${WV}installation
fi
echo -e "\n\n\n-------------------------------------------------------------------\n\n"

exit 0
