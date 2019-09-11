This phpmyadmin will run on HOST local Apache and have a dropdown with all current DB servers in this host

Run the phpmyadmin insde the HOST not as a container but inside a regular apache
should be installed to run as DocumentRoot here /var/www/app/phpmyadmin/



NOTE:
tmp FOLDER secure modifcation require this change or local apache can hav problems
/lib/systemd/system/apache.service  ...  [Service]  PrivateTmp=false


