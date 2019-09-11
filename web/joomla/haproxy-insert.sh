#!/bin/bash
#
# inset haproxy config for container instances
# by Felipe Ferreira 08/2019

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

F="/etc/haproxy/haproxy.cfg"

if [ ! -f $F ]; then
 echo "ERROR $F not found!"
 exit 2
fi

for ITEM in "${LIST[@]}"; do

 S=$(echo "$ITEM" |awk -F";" '{ print $1 }')
 D=$(echo "$ITEM" |awk -F";" '{ print $2 }')
 P=$(echo "$ITEM" |awk -F";" '{ print $3 }')

 echo -e "\nInsert Site:$S Domain:$D Port:$P"

#INSERT FRONTEND on correct line

 L1=$(grep -n INSERTFE $F |awk -F":" '{ print $1+1}')
 L2=$(grep -n INSERTFE $F |awk -F":" '{ print $1+2}')
 L3=$(grep -n INSERTFE $F |awk -F":" '{ print $1+3}')

#CHECK IF EXISTS
 C=$(grep -c "BACKEND_${D}_${P}" $F)
 if [ $C -ne 0 ]; then
  echo -e "WARNING - BACKEND_${D}_${P} already exists SKIPPING IT \n"
  continue;
 else
  sed -i "${L1}i   # ${ITEM}" $F
  sed -i "${L2}i   acl host_$D hdr(host) -i $S" $F
  sed -i "${L3}i   use_backend BACKEND_${D}_${P} if host_${D}" $F

#INSERT BACKEND
  echo "backend BACKEND_${D}_${P}" >> $F
  echo "    mode http" >> $F
  echo "    option forwardfor" >> $F
  echo "    http-request set-header X-Forwarded-Port %[dst_port]" >> $F
  echo "    http-request add-header X-Forwarded-Proto https" >> $F
  echo "    server doc09s 10.192.21.9:${P} maxconn 12  check" >> $F
 fi
 C=$(haproxy -c -f $F 2>/dev/null  |grep -c valid)
 if [ $C -eq 1 ]; then
  echo "OK - Data $ITEM inserted into $F" 
 else
  echo "ERROR - Something very wrong happened please fix $F"
  exit 2
 fi

done ;

