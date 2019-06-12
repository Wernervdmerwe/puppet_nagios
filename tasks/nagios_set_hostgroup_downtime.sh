#!/bin/bash
# Puppet task to set downtime for Nagios hostgroup

# Required options:
#   -- $PT_nagios_server - determines which nagios host to run against
#   -- $PT_username
#   -- $PT_password
#
# Other options:
#	-- $PT_hostgroup
#	-- $PT_time_in_minutes
#   -- $PT_comment
#   -- $PT_debug

# Seconds to poll nagios till downtime is set
NAG_POLL_TIMEOUT=15

# Load PT_* variables from a configuration file for command line testing
RCFILE=~/.nagios_commander.rc

if [[ -r $RCFILE ]] ; then
     . "$RCFILE"
fi

# Check for jq (dependency for processing JSON output from Nagios)
command -v jq >/dev/null 2>&1 || { echo "Command jq is missing. Exiting."; exit 1; }

# Set credentials
USERNAME=$PT_username
PASSWORD=$PT_password

# Set nagios base URL
if [ $PT_nagios_server == 'sharedtest' ]; then
	NAGIOS_INSTANCE='http://tst-mon9999.moest.govt.nz/nagios/cgi-bin'
else
    NAGIOS_INSTANCE='http://pro-mon9999.moe.govt.nz/nagios/cgi-bin'
fi

# Sets the HOSTGROUP variable
if [ "$PT_hostgroup" ]; then
	HOSTGROUP="$PT_hostgroup"
else
    HOSTGROUP="Linux"
fi

# Sets the COMMENT variable
if [ "$PT_comment" ]; then
	COMMENT="$PT_comment"
else
    COMMENT="Downtime for hostgroup $HOSTGROUP"
fi

# Sets the MINUTES variable
if [ "$PT_time_in_minutes" ]; then
	MINUTES="$PT_time_in_minutes"
else
    MINUTES=60
fi

# Print debug info
if [[ "$PT_debug" = "true" ]]; then
	DEBUG=1
fi

# This task only sets downtime
ACTION='set'
SCOPE='downtime'

# Set $DEBUG to check variables
if [ -n "$DEBUG" ]; then
    echo "DEBUG INFO:"
    echo "Instance: $NAGIOS_INSTANCE"
    echo "Scope: $SCOPE"
    echo "Action: $ACTION"
    echo "Hostgroup: $HOSTGROUP"
    echo "Downtime duration: $MINUTES"
    echo "Comment: $COMMENT"
    echo
fi

# Turn on debug output
if [ -n "$DEBUG" ]; then
    set -x
fi

# Find the most recent downtime ID
function find_max_downtime_id {
    DOWN_ID=`curl -sS "$NAGIOS_INSTANCE/statusjson.cgi?query=downtimelist" -u $USERNAME:$PASSWORD |\
        jq -Sr '.data.downtimelist | max'`
        
    if [[ "$DOWN_ID" = "null" || -z "$DOWN_ID" ]]; then
        DOWN_ID=1
    fi
}

# Check if the curl command was successful
function check_response {
    if [[ $RESPONSE =~ 401\ Unauthorized ]]; then
        echo "Bad credentials. Exiting"
        exit 1
    elif [[ $RESPONSE =~ Error:\ Could\ not\ read\ host\ and\ service\ status ]]; then
        echo "Cannot read host and service status. Check if the Nagios server is running. Exiting"
        exit 2
    elif [[ $RESPONSE =~ Error:\ Could\ not\ stat\(\)\ command\ file ]]; then
        echo "Could not read program status information. Check if the Nagios server is running. Exiting"
        exit 3
    elif [[ $RESPONSE =~ errorMessage ]]; then
        # Get error message if not (t & d in sed below transfers to end of output and deletes lines)
        echo "$RESPONSE" | sed -e "/errorMessage/ s/<P><DIV CLASS='errorMessage'>\([^>]\+\)<\/DIV><\/P>/\1/;t;d"
        echo "Command failed. Exiting"
        exit 4
    fi
}

# Get start and end times for downtime
NOW=$(date +"%m-%d-%Y+%H%%3A%M%%3A%S")
NOW_ADD_MINS=$(date +"%m-%d-%Y+%H%%3A%M%%3A%S" -d "+$MINUTES minute")

echo "Setting downtime for hostgroup $HOSTGROUP for $MINUTES mins with comment '$COMMENT'..."

# Find the most recent existing downtime ID and save in $OLD_DID
find_max_downtime_id
OLD_DID=$DOWN_ID

# Issue downtime command
RESPONSE=`curl -sS $NAGIOS_INSTANCE/cmd.cgi -u "$USERNAME:$PASSWORD" \
    --data cmd_typ=84 \
    --data cmd_mod=2 \
    --data hostgroup="$HOSTGROUP" \
    --data "com_data=$COMMENT" \
    --data start_time=$NOW \
    --data end_time=$NOW_ADD_MINS \
    --data fixed=1 \
    --data hours=2 \
    --data minutes=0 \
    --data btnSubmit=Commit`

check_response

# The downtime command usually takes 7-10 seconds to execute
# Keep checking until a new downtime ID appears or we reach the poll timeout
COUNT=1
while [ $DOWN_ID -eq $OLD_DID  ] && [ $COUNT -le $NAG_POLL_TIMEOUT ] ; do
    sleep 1
    find_max_downtime_id
    ((COUNT++))
done

if [ $DOWN_ID -eq 1 ]; then
    echo "Could not find newly created downtime. Exiting."
    exit 1
fi

echo "Created downtime for hostgroup $HOSTGROUP successfully."

exit 0
