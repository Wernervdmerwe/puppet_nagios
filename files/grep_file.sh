#!/bin/bash
# 
# WARNING: This file is managed by Puppet and any local changes will be overwritten!!
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Nagios script to grep through a file, searching for a provided phrase and alerting based upon
# provided alert value
#
# Created for:
# ------------ Nagios monitoring via Puppet
#
# Created date and author:
# ------------ 18/03/2020, Jasper Connery
#
# Updated on and by:
# ------------
#
# Usage:
# -----  This script requires four arguments, the first being an identifier to show what the alert context is (e.g. prod_db), the second being
#        the (full-path) file to grep through, the third is a comma-delimited string of phrases or words to query, also containing the
#        nagios alert state separated from the phrase by a hash #, and the fourth defines whether the file must exist or not, at all times.
#        E.g:
#             grep_file.sh 'prod_db' '/var/log/prodDB.log' 'Snapshot failed|Crit,No disk space|Crit,Timeout|Warning,SUCCESSFUL|OK' false
#
#        Each 'query' is processed in the order they appear - i.e. if 'Snapshot failed' is found, it will alert on that 
#	       and exit the script, not continuing to search for 'No disk space' or 'Timeout'. 
#
#        The phrase to be searched for is case-insensitive
#
# Limitations: 
# ----------- Cannot search for a phrase that contains a comma or '|' - to be resolved (eventually)
#


# Save current IFS value and set IFS to comma delimiter
OIFS=$IFS
IFS=','

# Alert identifier
context=$1
# Log file to grep through
file=$2
# Assign phrases and nagios alert states to an array of strings
queries=($3)
# Determine whether the file must exist or not
file_must_exist=$4
# Default exit code value - relates to UNKOWN alert for nagios
exit_code=3

# If file for grepping does not exist, exit script and alert
if [ "$file_must_exist" = true ]; then
  if [ ! -f $file ]; then
    echo "File ${file} does not exist!! Either syntax or application error!"
    IFS=$OIFS
    exit 2
  fi
fi

# Loop through array searching for each query, ordered by first-in,first-checked
for((i=0; i<${#queries[@]}; ++i)); do
  # Separate out query and nagios alert value from array string
  query="$(cut -d '|' -f1 <<< ${queries[$i]})"
  state="$(cut -d '|' -f2 <<< ${queries[$i]})"
  
  # Set relevant exit codes
  if [[ ${state,,} == *"crit"* ]]; then
    exit_code=2
  elif [[ ${state,,} == *"warn"* ]]; then
    exit_code=1
  elif [[ ${state,,} == *"ok"* ]]; then
    exit_code=0
  fi
  
  # Search through file for obtained query, alerting and exiting script if found. ${foo^^} converts $foo value to uppercase, ${foo,,} to lowercase
  if grep -Fqi "${query}" $file; then
    echo "${state^^}: ${context} ${query,,}!"
    IFS=$OIFS
    exit $exit_code
  fi
done

# If no errors found, gracefully exit script
echo "OK: ${context} - no detected errors in ${file}."
IFS=$OIFS
exit 0