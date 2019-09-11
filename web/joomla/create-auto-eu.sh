#!/bin/bash
#
# by Felipe Ferreira 08/19/2019
# auto create instances and .env and call migrate.sh
# based on list defined here that are only .eu Joomlas from web026

LIST=(
"3dsits.eu;3dsits;1601"
"andy-project.eu;andy-project_eu;1602"
"cogitor.eu;www_cogitor_eu;1603"
"compassproject.eu;www_compassproject_eu;1604"
"engicoin.eu;engicoin_example.com;1605"
"growbot.eu;growbot;1606"
"heroicproject.eu;heroicproject_eu;1607"
"instanceproject.eu;instanceproject_eu;1608"
"minded-cofund.eu;minded-cofund_eu;1609"
"moptopus-h2020.eu;moptopus-h2020_eu;1610"
"msca-bionics.eu;www_msca-bionics_eu;1611"
"neuroplasmonics.eu;www_neuroplasmonics_eu;1612"
"neutouch.eu;neutouch_eu;1613"
"rebus-project.eu;www_rebus-project_eu;1614"
"singleproteinsequencing.eu;www_singleproteinsequencing_eu;1615"
"slammerc.eu;slammerc_eu;1616"
"teep-sla.eu;www_teep-sla_eu;1617"
"treerobotics.eu;treerobotics_eu;1618"
"walk-man.eu;www_walk-man_eu;1619"
"whisperproject.eu;whisperproject;1620"
)

LIST=(
"3dsits.eu;3dsits;1601"
"cogitor.eu;www_cogitor_eu;1603"
)

#NO DB?
#vinum-robot.eu;
#sinapsprobes.eu;
#sbdd-congress.it
#recodeh2020.eu;
#hermes-fet.eu;
#libra-molecules.eu;

LOGERROR=create-auto-eu-error.log
LOG=create-auto-eu.log


for ITEM in "${LIST[@]}"; do

 S=$(echo "$ITEM" |awk -F";" '{ print $1 }')
 D=$(echo "$ITEM" |awk -F";" '{ print $2 }')
 P=$(echo "$ITEM" |awk -F";" '{ print $3 }')

 DIR="${P}_${S}"
 echo "Creating site: $S db: $D port: $P at $DIR" |tee -a $LOG

 DI="/opt/data/imports/"
 SI="${DI}${S}.zip"
 DB="${DI}${D}.gz"


 if [ ! -f $DB ]; then
  echo "ERROR - Database source file $DB not found!" |tee -a $LOGERROR
  continue;
 fi
 if [ ! -f $SI ]; then
  echo "ERROR - Site source file $SI not found!" |tee -a $LOGERROR
  continue;
 fi
 if [ -d $DIR ]; then
  echo "ERROR Directory $DIR already found!" |tee -a $LOGERROR
  continue;
 fi
 #could check if nothing is running in this port 

###############################

 mkdir -p $DIR
 cp docker-compose.yml migrate.sh ${DIR}/
 cd $DIR
cat > .env  <<_EOB_
SITE_PORT=$P
SITE_NAME=$S
SITE_VOLUME=JOOMLA_WEB_${P}
DB_VOLUME=JOOMLA_DB_${P}
DB_ROOT_PASSWORD=PASSME1919
DB_NAME=$D
DB_USER=$D
_EOB_

 docker-compose up --force-recreate -d
 docker-compose ps
 bash migrate.sh |tee -a $LOG
 cd ../
done
echo "----------------------------------------"
./check.sh
exit 0


