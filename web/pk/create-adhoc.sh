#!/bin/bash
#
# by Felipe Ferreira 08/19/2019
# auto create instances and .env and call migrate.sh
# get from args SITE_NAME DB_NAME PORT, create a directory and .env start instance then migrate script

function help {
 echo "$basename <SITE_NAME> <DB_NAME> <PORT_NUMBER>"
 exit 2
}

########### ARGS
if [ -z $3  ]; then
 help
else 
 S=$1
 D=$2
 P=$3
fi

########## CHECKS
DIR="${P}_${S}"
echo "Creating site: $1 db: $D port: $P at $DIR"

DI="/opt/data/imports/"
SI="${DI}${S}.zip"
DB="${DI}${D}.gz"

echo "DB FILE: $DB"

if [ ! -f $DB ]; then
 echo "ERROR - Database source file $DB not found!"
 exit 2
fi
if [ ! -f $SI ]; then
 echo "ERROR - Site source file $SI not found!"
 exit 2
fi
if [ -d $DIR ]; then
 echo "ERROR Directory $DIR already found!"
 exit 2
fi
#could check if nothing is running in this port 

###############################

mkdir -p $DIR
cp docker-compose.yml migrate.sh $DIR/
cd $DIR

cat > .env  <<_EOB_
SITE_PORT=$P
SITE_NAME=$S
SITE_VOLUME=PK_WEB_${P}
DB_VOLUME=PK_DB_${P}
DB_ROOT_PASSWORD=PASSME1919
DB_NAME=$D
_EOB_

docker-compose up -d 
docker-compose ps
bash migrate.sh
exit 0


