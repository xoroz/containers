#!/bin/bash
#
# automate joomla  web site creation using ENV from docker-compose
# run as docker entrypoint 
# by Felipe Ferreira 08/19

set -e

cleanup() {
 SECONDS=1
 DI="${D}/installation/"
 SLEEPT=10
 END=1800  # 30m 
 while [ $SECONDS -lt $END ]; 
 do
  if [ ! -d $DI ]; then
   echo "Joomla was already installed, could not find $DI"
   break;
  fi
  C=$(find $DI  -name "*Joomla*.txt")
  if [ ! -z  $C ]; then
   find $DI  -name "*Joomla*.txt" -exec rm -fv '{}' \;
   echo "Joomla temp install file was deleted."
   echo -e "------------------------------------------------\n\n"
#   break; 
  fi
  sleep $SLEEPT
  SECONDS=$((SECONDS+$SLEEPT))
 done
}


function runapache {
# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid
/usr/sbin/apachectl -D FOREGROUND "$@"
#/usr/sbin/apachectl start
}



function startas {
#NOT USING YET
if [ -z $USER_ID ]; then
 echo "ERROR - missing env $USER_ID"
 USER_ID=${LOCAL_USER_ID:-9001}
fi
echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m user
export HOME=/home/user
exec /usr/local/bin/gosu user "$@"
}


#printenv 
if [ -z $SITE_NAME ]; then 
#echo "Missing ENV SITE_NAME using generic public"
 SITE_NAME=public
fi

D="/var/www/logs"
if [ ! -d "$D" ] ; then
 mkdir -p $D
fi

D="/var/www/$SITE_NAME"
if [ ! -d "$D" ] ; then
 mkdir -p $D
fi

cd $D

fixphp() {
#############
 echo "Fixing php setting at /etc/php/7.2/apache2/php.ini"

 echo "memory_limit = 128M"         >> /etc/php/7.2/apache2/php.ini
 echo "allow_url_fopen = On"        >> /etc/php/7.2/apache2/php.ini
 echo "upload_max_filesize = 12M"   >> /etc/php/7.2/apache2/php.ini
 echo "max_execution_time = 300"    >> /etc/php/7.2/apache2/php.ini
 echo "date.timezone = Europe/Rome" >> /etc/php/7.2/apache2/php.ini
 echo "output_buffering = Off"      >> /etc/php/7.2/apache2/php.ini
 echo "post_max_size = 12M"        >> /etc/php/7.2/apache2/php.ini
}



down() {
################
#Function Download and unzip package under public folder
#Should happen only on first boot, never again otherwise it will overwrite existing valid site!
 F=$1
 U=$2
 if [ ! -f "$F" ]; then
  echo "Downloading $F"
  wget -q -O "$F" "$U"
  if [ ! -f "$F" ]; then
   echo "ERROR - could not download $F from $U do you have internet access?"
   exit 2
  fi
 else
 return 0
 fi 
 cd $D
 echo "--ONLY FIRST BOOT-------------"
 echo  "creating a new fresh Joomla site: $SITE_NAME"
 echo "Unziping $F - Please wait..."
 unzip -o -q $F
 fixphp
}

#call function to download and unzip
down "${D}/joomla3.zip" "https://downloads.joomla.org/cms/joomla3/3-9-11/Joomla_3-9-11-Stable-Full_Package.zip?format=zip"

chown -R www-data:www-data $D
find  $D -type d -print0 | xargs -0 chmod 775
find  $D -type f -print0 | xargs -0 chmod 664

echo "Checking apache config"
apachectl -t


cleanup &
runapache
