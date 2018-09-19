#! /bin/bash
#
# Initial author : Diego Martin Gardella [dgardella@gmail.com]
# Modified by Erling Ouweneel to switch OK and CRITICAL
# Modified by Jasper Connery to check the file for nagios status and display relevant line, also
# updated the syntax of a couple of commands
#
# Desc : Plugin to verify if a file exists
#
# 

PROGNAME=$(basename $0)
PROGPATH=$(echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,')
TMP_FILE="/tmp/patching_state.tmp"

if [ "$1" = "" ]; then
  echo -e " Use : $PROGNAME -- Ex : $PROGNAME /etc/hosts \n "
  exit 3
else
  TMP_FILE=$1
fi

if [ -f $TMP_FILE ]; then
  if grep -Fq "CRIT:" $TMP_FILE; then
    echo $(cat $TMP_FILE | grep "CRIT")
    exit 2
  elif grep -Fq "WARN:" $TMP_FILE; then
    echo $(cat $TMP_FILE | grep "WARN")
    exit 1
  else
    echo "UNKNOWN: $TMP_FILE SYNTAX INCORRECT"
    exit 3
  fi
else
  echo "OK : $TMP_FILE Does NOT exists "
  exit 0
fi

