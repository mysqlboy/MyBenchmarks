#!/bin/bash

RUNFILE=/tmp/running
COLLECTDIR=./
COLLECT=collect.sh

DURATION=7200

touch /tmp/running
mysql -uroot -e"set global server_audit_logging=0"
/home/moore/MyBenchmarks/collect.sh &
ts="$(date +"TS %s.%N %F %T")"
#echo $ts >> ./vmstat.out 
#vmstat 2 >> ./vmstat.out &
#echo $ts >> ./iostat.out
#iostat -dx 3 >> ./iostat.out &


for i in 4 6;
do
	/usr/local/bin/sysbench --test=/home/moore/MyBenchmarks/tests/db/oltp.lua \
	--oltp-tables-count=6 \
	--oltp-table-size=1000000 \
	--oltp-read-only=off \
	--rand-init=on \
	--num-threads=${i} \
	--max-requests=0 \
	--rand-type=uniform \
	--max-time=${DURATION} \
	--mysql-user=root \
	--mysql-socket=/data/mysql/mysql.sock \
	run
done

rm /tmp/running
killall vmstat
killall iostat
killall pt-diskstats
