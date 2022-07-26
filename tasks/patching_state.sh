#! /bin/bash
# Task used to remove or display contents of the auto-generated patching state file
# This is used for any errors that may occur during patching and causes nagios to alert
# based upon it's existence.

patching_state_file='/tmp/patching_state.tmp'

if [ $PT_action == 'remove' ]; then
  echo "Removing patching state file: ${patching_state_file}"
  rm $patching_state_file
elif [ $PT_action == 'display' ]; then
  echo "Displaying contents of patching state file: ${patching_state_file}"
  cat $patching_state_file
fi

