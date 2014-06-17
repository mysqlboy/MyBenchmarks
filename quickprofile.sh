#!/bin/sh

# hacked together to collect some OS details for quick use in profile of system

# Variables
TS=`date +%Y%m%d%H%M`
COLLECTDIR="/tmp/${TS}"

if [ ! -d $COLLECTDIR ];
then 
	mkdir $COLLECTDIR;
fi

function capture_innodb_status () {
  interval=10
  while [ ! -f ${COLLECTDIR}/stop_collection ]
  do
    mysql -e "show engine innodb status\G" \
      >> ${COLLECTDIR}/innodb_status.out
    sleep ${interval}
  done
}

# Start Collect
mpstat 1 > ${COLLECTDIR}/mpstat.out &
mpstat_pid=$!

vmstat 1 > ${COLLECTDIR}/vmstat.out &
vmstat_pid=$!

iostat -mx 1 > ${COLLECTDIR}/iostat.out &
iostat_pid=$!

mysqladmin ext -i1 > ${COLLECTDIR}/mysqladmin.out &
mysqladmin_pid=$!

function kill_collection() {
  touch ${COLLECTDIR}/stop_collection
  echo "Collecting last pieces of data ... wait a minute."
  kill -9 ${mpstat_pid}
  kill -9 ${vmstat_pid}
  kill -9 ${iostat_pid}
  kill -9 ${mysqladmin_pid}
}

trap kill_collection INT

capture_innodb_status

wait ${mpstat_pid}
wait ${vmstat_pid}
wait ${iostat_pid}
wait ${diskstats_pid}
wait ${mysqladmin_pid}
