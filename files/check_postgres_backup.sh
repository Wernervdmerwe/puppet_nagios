#!/bin/bash
# Script will check file for string OK/NOK and return critical if the file is older 24h.
#######################################################################################

statusFileLocation="/tmp"
statusFileName="postgresBackupStatus"
if [ -f ${statusFileLocation}/${statusFileName} ]; then
  status=$(/bin/cat ${statusFileLocation}/${statusFileName})
  file_old=$(/bin/find /tmp -name $statusFileName -mtime +1)
  if [ -n $status ]; then
    if [ -z $file_old ]; then
      if [ "$status" == "OK" ]; then
        echo "OK - Last backup was successfull."
        exit 0
      elif [ "$status" == "NOK" ]; then
        echo "CRITICAL - Last backup was NOT successfull!"
        exit 1
      else
        echo "CRITICAL - Could not retrieve the status!"
        exit 1
      fi
    else
      echo "CRITICAL - Backud status file is older then 24h!!"
      exit 1
    fi
  fi
else
  echo "Status file doesn't exist."
  exit 2
fi
