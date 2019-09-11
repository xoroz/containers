#!/bin/bash
#
# by Felipe Ferreira 19/08/2019
#
# this will clean up / delete all containers in this host

docker system prune -a
docker swarm leave --force
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q -f dangling=true)
docker volume prune -f
docker network prune -f
docker image rm $(docker image ls | awk '{ print $1}')
iptables -t nat -F
ifconfig docker0 down
brctl delbr docker0
docker system df
systemctl stop docker
systemctl start docker
