#!/bin/bash
#
# by Felipe Ferreira 08/19/2019
# auto create instances and .env and call migrate.sh
# based on list defined here

LIST=(
"bsrom.example.com;bsrom_example_com;1801"
)

for ITEM in "${LIST[@]}"; do
 echo "$ITEM"

 S=$(echo "$ITEM" |awk -F";" '{ print $1 }')
 D=$(echo "$ITEM" |awk -F";" '{ print $2 }')
 P=$(echo "$ITEM" |awk -F";" '{ print $3 }')
 DIR="${P}_${S}"
 echo "Creating site: $S db: $D port: $P at $DIR"

 DI="/opt/data/imports/"
 SI="${DI}${S}.zip"
 DB="${DI}${D}.gz"

 echo "DB FILE: $DB"

 if [ ! -f $DB ]; then
  echo "ERROR - Database source file $DB not found!"
  continue;
 fi
 if [ ! -f $SI ]; then
  echo "ERROR - Site source file $SI not found!"
  continue;
 fi
 if [ -d $DIR ]; then
  echo "ERROR Directory $DIR already found!"
  continue;
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
DB_PASS=PASSYOU1919
_EOB_

 docker-compose up --force-recreate -d
 docker-compose ps
 bash migrate.sh
 cd ../
done
exit 0


