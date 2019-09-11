#!/bin/bash
# for joomla install we need to delete a .txt file

V=$(docker volume inspect JOOMLA_WEB_1601 |grep Mountpoint | sed s'/\"//g' |sed 's/\,//g' |awk '{ print $NF }'
find $V -name '_Joomla*.txt' -exec rm -fv '{}'\;
exit 0
