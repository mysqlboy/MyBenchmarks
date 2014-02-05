#!/bin/sh

INTERVAL=5
COLLECTDIR=`date +%Y%m%d%H%M`
if [[ ! -d ${COLLECTDIR} ]];
then
	mkdir ${COLLECTDIR}
else
	print 'collect dir already exists'
	exit 1
fi

PREFIX=$INTERVAL-sec-status
RUNFILE=/tmp/running
USER=root
mysql -e 'SHOW GLOBAL VARIABLES' >> ${COLLECTDIR}/mysql_variables
echo $ts >> ${COLLECTDIR}/vmstat.out
vmstat 2 >> ${COLLECTDIR}/vmstat.out &
echo $ts >> ${COLLECTDIR}/iostat.out
iostat -dx 3 >> ${COLLECTDIR}/iostat.out &
pt-diskstats --interval=${INTERVAL} --show-timestamps --devices-regex 'dm-5.*|sd.*' >> ${COLLECTDIR}/$PREFIX-pt-diskstats &

while test -e $RUNFILE; do
   file=$(date +%F_%I)
   sleep=$(date +%s.%N | awk "{print $INTERVAL - (\$1 % $INTERVAL)}")
   sleep $sleep
   ts="$(date +"TS %s.%N %F %T")"
   loadavg="$(uptime)"
   echo "$ts $loadavg" >> ${COLLECTDIR}/$PREFIX-${file}-status
   mysql -u${USER} -e 'SHOW GLOBAL STATUS' >> ${COLLECTDIR}/$PREFIX-${file}-status &
   echo "$ts $loadavg" >> ${COLLECTDIR}/$PREFIX-${file}-innodbstatus
   mysql -u${USER} -e 'SHOW ENGINE INNODB STATUS\G' >> ${COLLECTDIR}/$PREFIX-${file}-innodbstatus &
   echo "$ts $loadavg" >> ${COLLECTDIR}/$PREFIX-${file}-processlist
   mysql -u${USER} -e 'SHOW FULL PROCESSLIST' >> ${COLLECTDIR}/$PREFIX-${file}-processlist
done
echo Exiting because $RUNFILE does not exist.
   
