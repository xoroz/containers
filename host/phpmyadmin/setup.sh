#!/bin/bash
#
# script to download phpmyadmin and configure apache
# by Felipe Ferreira 09/2019
#
#

ACONF="/etc/apache2/sites-enabled/000-default.conf"
D="/var/www/app/phpmyadmin/"


if [ ! -d $D ]; then
 mkdir -p $D
 cd $D
 wget "https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-english.tar.gz"
 tar -zxf phpMyAdmin-4.9.0.1-english.tar.gz
 mv -f phpMyAdmin-4.9.0.1-english/* .
 chown www-data. -R $D
 ll $D
else
 echo "Already found directory $D"
fi
cd $D

cat > $ACONF  <<_EOB_
<VirtualHost *>
        ServerAdmin felipe.ferreira@example.com
        DocumentRoot /var/www/html
        Alias /pma/ "$D"
        ProxyPass "/portainer" "http://127.0.0.1:8090" connectiontimeout=5 timeout=120
        ProxyPassReverse "/portainer" "http://127.0.0.1:8090"
</VirtualHost>
_EOB_

a2enmod proxy
a2enmod proxy_http
apachectl -t 
apachectl restart
echo -e "\nShould work for:\n /pma to PHPMyAdmin\n/portainer to portainer on port 8090"


