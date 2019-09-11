FROM ubuntu:18.04
MAINTAINER Felipe <felipe.ferreira@example.com>

ENV TZ=Europe/Rome

#RUN add-apt-repository ppa:apt-fast/stable 
#RUN apt -y install apt-fast
RUN apt update && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata locales
RUN echo "Europe/Rome" > /etc/timezone 
RUN dpkg-reconfigure -f noninteractive tzdata  
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN dpkg-reconfigure --frontend=noninteractive locales 

RUN DEBIAN_FRONTEND=noninteractive apt -y --no-install-recommends install \
    apache2 \
    unzip \
    wget \
    ca-certificates \
    bash \
    php7.2 php7.2-cli php7.2-fpm php7.2-json php7.2-mysql php7.2-curl \
    libapache2-mod-php php7.2-xml php7.2-zip gosu

ADD apache2.conf /etc/apache2/apache2.conf
ADD 000-default.conf  /etc/apache2/sites-enabled/000-default.conf

ADD initd.sh /usr/local/bin/initd.sh
RUN chmod +x /usr/local/bin/initd.sh

#CLEANUP
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean -y \
    apt-get clean -y \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;  \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#RUN printenv
RUN a2enmod rewrite
RUN a2enmod php7.2
RUN a2enconf php7.2-fpm
RUN a2enmod proxy_fcgi setenvif
ENTRYPOINT ["/usr/local/bin/initd.sh"]
