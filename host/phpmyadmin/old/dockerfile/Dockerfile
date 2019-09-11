FROM php:7.2-apache

LABEL maintainer "Felipe Ferreira <felipe.ferreira@example.com>"
ENV PHPMYADMIN_VERSION=4.9.0.1
# Set desired phpMyAdmin version
RUN  apt-get update && apt-get install -y --no-install-recommends libbz2-dev zlib1g-dev && \
apt-get clean ; rm -rf /var/lib/apt/lists/* 

# Install PHP Extensions
RUN  docker-php-ext-install bz2 mbstring mysqli zip 

# Download and extract phpMyAdmin
RUN curl https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz | tar --extract --gunzip --file - --strip-components 1 
RUN rm -rf examples setup sql

COPY .htaccess /var/www/html/.htaccess
COPY config.inc.php /var/www/html/config.inc.php

RUN chgrp -R 0 /tmp /etc/apache2 /var/run/apache2 /var/www/html && \
	chmod -R g=u /tmp /etc/apache2 /var/run/apache2 /var/www/html

WORKDIR /home
COPY entrypoint.sh /home/entrypoint.sh
ENTRYPOINT ["/home/entrypoint.sh"]
