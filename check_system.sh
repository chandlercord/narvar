#!/bin/bash

#define syslog date format
log_date=$(date '+%b %Y %d %H:%M:%S')

check_disk(){
#Disk critical percentage threshold
DISK_CRIT=90

df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 " " $6 }' | while read output; do
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  mount=$(echo $output | awk '{ print $2 }' )
  partition=$(echo $output | awk '{ print $3 }' )

  if [ ${usep} -ge ${DISK_CRIT} ]; then
    echo "${log_date}: Disk space critical on ${partition} ($usep%)"
    exit 1
  else
    echo "${log_date}: Disk space is OK on ${partition} ($usep%)"
  fi
done
}

check_mem(){
MEM_CRIT=95
MEM_TOTAL=`free | fgrep "Mem:" | awk '{print $2}'`;
MEM_USED=`free | fgrep "/+ buffers/cache" | awk '{print $3}'`;

PERCENTAGE=$(($MEM_USED*100/$MEM_TOTAL))

if [ ${PERCENTAGE} -ge ${MEM_CRIT} ]; then
  echo "${log_date}: Memory usage is critical - ${PERCENTAGE}"
  exit 2
else
  echo "${log_date}: Memory usage is OK - ${PERCENTAGE}"
fi
}

check_cpu(){
  CPU_CRIT=95
  CPU_USAGE=`echo $[100-$(vmstat|tail -1|awk '{print $15}')]`
  if [ ${CPU_USAGE} -ge ${CPU_CRIT} ]; then
    echo "${log_date}: CPU usage is critical - ${CPU_USAGE} percent"
    exit 3
  else
    echo "${log_date}: CPU usage is OK - ${CPU_USAGE} percent"
  fi
}

check_disk
check_mem
check_cpu
