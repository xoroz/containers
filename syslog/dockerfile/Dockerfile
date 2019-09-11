FROM ubuntu
MAINTAINER Felipe Ferreira felipe.ferreira@iit.it
RUN apt-get update && apt-get install -y syslog-ng-core syslog-ng tzdata 
RUN mkdir -p /var/log/hosts/
RUN echo Europe/Rome >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata
EXPOSE 514
#CMD syslog-ng -F --no-caps -d
CMD syslog-ng --no-caps -d > /dev/null 2>&1


