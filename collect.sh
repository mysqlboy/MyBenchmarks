#!/bin/sh

INTERVAL=5
PREFIX=$INTERVAL-sec-status
RUNFILE=/tmp/running
USER=root
mysql -e 'SHOW GLOBAL VARIABLES' >> mysql_variables
while test -e $RUNFILE; do
   file=$(date +%F_%I)
   sleep=$(date +%s.%N | awk "{print $INTERVAL - (\$1 % $INTERVAL)}")
   sleep $sleep
   ts="$(date +"TS %s.%N %F %T")"
   loadavg="$(uptime)"
   echo "$ts $loadavg" >> $PREFIX-${file}-status
   mysql -u${USER} -e 'SHOW GLOBAL STATUS' >> $PREFIX-${file}-status &
   echo "$ts $loadavg" >> $PREFIX-${file}-innodbstatus
   mysql -u${USER} -e 'SHOW ENGINE INNODB STATUS\G' >> $PREFIX-${file}-innodbstatus &
   echo "$ts $loadavg" >> $PREFIX-${file}-processlist
   mysql -u${USER} -e 'SHOW FULL PROCESSLIST' >> $PREFIX-${file}-processlist
   echo "$ts $loadavg" >> $PREFIX-${file}-IO
   cat /proc/diskstats >> $PREFIX-${file}-IO &
done
echo Exiting because $RUNFILE does not exist.
   
