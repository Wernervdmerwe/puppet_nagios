#!/bin/bash
# Puppet task to remove downtime for Nagios hostgroup

# Required options:
#   -- $PT_nagios_server - determines which nagios host to run against
#   -- $PT_username
#   -- $PT_password
#
# Other options:
#	-- $PT_hostgroup
#   -- $PT_debug

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

# Set the HOSTGROUP variable
if [ "$PT_hostgroup" ]; then
	HOSTGROUP="$PT_hostgroup"
else
    HOSTGROUP="Linux"
fi

# Print debug info
if [[ "$PT_debug" = "true" ]]; then
	DEBUG=1
fi

# Turn on debug output
if [ -n "$DEBUG" ]; then
    set -x
fi

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

# Remove a specific downtime
function delete_downtime_by_id {
    RESPONSE=`curl -Ss --output /dev/null $NAGIOS_INSTANCE/cmd.cgi \
        --data cmd_mod=2 \
        --data cmd_typ=$CMD_TYP \
        --data down_id=$DOWN_ID \
        --data btnSubmit=Commit \
        -u $USERNAME:$PASSWORD`
    
    check_response
}

# Counter to track downtimes
COUNT=0

# Set command to CMD_DEL_HOST_DOWNTIME
CMD_TYP=78

# Find all hosts in hostgroup
HOSTLIST=`curl -Ss -u $USERNAME:$PASSWORD "$NAGIOS_INSTANCE/statusjson.cgi?query=hostlist&details=true&hostgroup=$HOSTGROUP" | jq -r '.data.hostlist[].name'`

for HOST in $HOSTLIST; do
    # Find all downtime IDs for host
    DOWNTIME_IDS=`curl -Ss -u $USERNAME:$PASSWORD "$NAGIOS_INSTANCE/statusjson.cgi?query=downtimelist&details=true&hostname=$HOST" | jq -r '.data.downtimelist[].downtime_id'`

    # Delete each downtime ID
    for DOWN_ID in $DOWNTIME_IDS; do
        echo "Deleting downtime $DOWN_ID for host $HOST."
        delete_downtime_by_id
        ((COUNT++))
    done
done

echo "Deleted $COUNT downtimes for hostgroup $HOSTGROUP."