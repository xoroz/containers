#!/bin/bash
#
# automate pagekit web site creation using ENV from docker-compose
# run as docker entrypoint 
# by Felipe Ferreira 08/19

set -e

function runapache {
# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid
/usr/sbin/apachectl -D FOREGROUND "$@"
#/usr/sbin/apachectl start
}

function startas {
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
 echo "Missing ENV SITE_NAME "
 SITE_NAME=public
fi

D="/var/www/public"
if [ ! -d "$D" ] ; then
 mkdir -p $D
fi

echo  "creating a new pagekit site: $SITE_NAME"
cd $D
wget -q -O pagekit.zip https://pagekit.com/api/download/latest 
unzip -q pagekit.zip && rm pagekit.zip
chown www-data. -R .

chown www-data -R /etc/apache2/sites-enabled/
echo "creating config file for the new site\n"
cat > /etc/apache2/sites-enabled/$SITE_NAME.conf  <<_EOB_
<VirtualHost *>
        DocumentRoot /var/www/public
        ServerAdmin digital@example.com
        <Directory /var/www/public>
                AllowOverride none 
                RewriteEngine on
                RewriteCond %{REQUEST_FILENAME} !-f
                RewriteCond %{REQUEST_FILENAME} !-d
                RewriteRule ^ index.php [L]
                RedirectMatch (.*)(?<!index.php)\/admin$ \$1/index.php/admin
       </Directory>
<IfModule mod_php5.c>
    php_value always_populate_raw_post_data -1
</IfModule>
</VirtualHost>
_EOB_


#PHP tuning for pagekit
echo "memory_limit = 128M"         >> /etc/php/7.2/apache2/php.ini
echo "allow_url_fopen = On"        >> /etc/php/7.2/apache2/php.ini
echo "upload_max_filesize = 80M"   >> /etc/php/7.2/apache2/php.ini
echo "max_execution_time = 300"    >> /etc/php/7.2/apache2/php.ini
echo "date.timezone = Europe/Rome" >> /etc/php/7.2/apache2/php.ini

runapache
