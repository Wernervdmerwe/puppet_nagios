#!/bin/bash -
# Title:    nagios_commander.sh
# Author:   Brandon J. O'Connor <brandoconnor@gmail.com>
# Created:  08.19.12
# Purpose:  Provide a CLI to query and access common nagios functions remotely
# TODO:     password input from a plain text file
# TODO:     query service group or host group health
# TODO:     feedback given when downtime del isn't found or when it successfully dels

# Copyright 2012 Brandon J. O'Connor
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
##################

unalias -a
NAG_HTTP_SCHEMA='http'

# seconds to poll nagios till downtime is set
NAG_POLL_TIMEOUT=15
. ~/.nagios_commander.rc

# set credentials
USERNAME=$PT_username
PASSWORD=$PT_password

## PUPPET VARIABLES FOR JSON FILE
# Required options:
# 			-- $PT_NAG_HOST - determines which nagios host to run against
#			-- $PT_USERNAME
#			-- $PT_PASSWORD
#
# Other options:
# 			-- $PT_HOSTGROUP
#			-- $PT_HOST
#			-- $PT_QUERY
#			-- $PT_COMMAND
#			-- $PT_SERVICENAME
#			-- $PT_SERVICEGROUP
#			-- $PT_DOWN_ID
#			-- $PT_DOWN_TIME

## Puppet variable conversions
# Determine which nagios host to use:
if [ $PT_nagios_server == 'sharedtest' ]; then
	NAG_HOST='tst-mon9999.moest.govt.nz/nagios'
else
	NAG_HOST='pro-mon9999.moe.govt.nz/nagios'
fi

# Sets the enable/disable state value if applicable
if [ "$PT_state" == 'enable' ]; then
	VALUE='en'
elif [ "$PT_state" == 'disable' ]; then
	VALUE='dis'
fi

# Sets the HOST variable
if [ "$PT_host" ]; then
	HOST=$PT_host
fi

# Sets the HOSTGROUP variable
if [ "$PT_hostgroup" ]; then
	HOSTGROUP=$PT_hostgroup
fi

# Sets the SERVICE variable
if [ "$PT_service" ]; then
	SERVICE=$PT_service
fi

# Sets the SERVICEGROUP variable
if [ "$PT_servicegroup" ]; then
	SERVICEGROUP=$PT_servicegroup
fi

# Sets the SERVICEGROUP variable
if [ "$PT_downtime_id" ]; then
	DOWN_ID=$PT_downtime_id
fi

# Sets the COMMENT variable
if [ "$PT_comment" ]; then
	COMMENT=$PT_comment
fi

# Sets the MINUTES variable
if [ "$PT_time_in_minutes" ]; then
	MINUTES=$PT_time_in_minutes
fi

# Sets the list option to the query variable (for readability in the puppet console)
if [ "$PT_list" ]; then
	PT_query="list_$PT_list"
fi

# Sets the QUERY variable, among others
if [[ "$PT_query" == list* ]]; then
	# handles the QUERY requests
	case $PT_query in
		list_all_hosts ) QUERY='list'; HOST='list';;
		list_specific_host ) QUERY='list'; HOST=$PT_host;;
		list_all_hostgroups ) QUERY='list'; HOSTGROUP='list';;
		list_specific_hostgroup ) QUERY='list'; HOSTGROUP=$PT_hostgroup;;
		list_all_servicegroups ) QUERY='list'; SERVICEGROUP='list';;
		list_specific_servicegroup ) QUERY='list'; SERVICEGROUP=$PT_servicegroup;;
	esac 
else
	# handles the remaining query list searches
	QUERY=$PT_query
fi

# Sets the ACTION variable, among others.
if [ "$PT_action" ]; then
	# handles the ACTION commands
	case $PT_action in
		set_downtime ) ACTION='set'; SCOPE='downtime';;
		remove_downtime ) ACTION='del';;
		set_notifications ) ACTION='set'; SCOPE='notifications';;
		set_event_handlers ) ACTION='set'; SCOPE='event_handlers';;
		set_active_service_checks ) ACTION='set'; SCOPE='active_service_checks';;
		set_passive_service_checks ) ACTION='set'; SCOPE='passive_service_checks';;
		set_active_host_checks ) ACTION='set'; SCOPE='active_host_checks';;
		set_passive_host_checks ) ACTION='set'; SCOPE='passive_host_checks';;
	esac
fi

# Set $DEBUG to check variables
if [ -n "$DEBUG" ]; then
    echo "DEBUG INFO: NAG_HOST=$NAG_HOST, SCOPE=$SCOPE, ACTION=$ACTION, VALUE=$VALUE, HOST=$HOST, HOSTGROUP=$HOSTGROUP, SERVICE=$SERVICE, SERVICEGROUP=$SERVICEGROUP, TIME=$MINUTES, QUERY=$QUERY, COMMENT=$COMMENT, QUIET=$QUIET"
fi

# Check to ensure both $ACTION and $QUERY are not set
if [ "$ACTION" ] && [ "$QUERY" ]; then
    echo "Cannot execute both a query and an action. Exiting."
	exit
fi

# Set nagios base URL
NAGIOS_INSTANCE="$NAG_HTTP_SCHEMA://$NAG_HOST/cgi-bin"

# Check connectivity
RESPONSE=`curl -Ss $NAGIOS_INSTANCE/extinfo.cgi -u $USERNAME:$PASSWORD`

if [[ $RESPONSE =~ 401\ Unauthorized ]]; then
    echo "Bad credentials. Exiting"
    exit 1
elif [[ $RESPONSE =~ Error:\ Could\ not\ read\ host\ and\ service\ status ]]; then
    echo "Cannot read host and service status. Check if the Nagios server is running."
    exit 2
fi

function MAIN {
    if  [ $QUERY ]; then
        if [[ $QUERY = list ]]; then
            if [[ $HOST = list  ]]; then
                DATA="--data hostgroup=all --data style=hostdetail"
                LIST_HOSTS
            elif [ $HOST ]; then
                DATA="--data host=$HOST --data style=detail"
                LIST_SERVICES
                exit 0
            elif [[ $HOSTGROUP = list ]]; then
                DATA="--data hostgroup=all --data style=summary"
                TYPE='host'
                LIST_GROUPS
            elif [ $HOSTGROUP ]; then
                DATA="--data hostgroup=$HOSTGROUP --data style=hostdetail"
                LIST_HOSTS
            elif [[ $SERVICEGROUP = list ]]; then
                DATA="--data servicegroup=all --data style=summary"
                TYPE='service'
                LIST_GROUPS
            elif [ $SERVICEGROUP ]; then
                DATA="--data servicegroup=$SERVICEGROUP --data style=detail"
                #LIST_SERVICES
                #This function will have to be separated out
                echo "Feature pending"
                exit
            fi
        else
            if [[ $QUERY = event_handlers ]]; then
                SEARCH='Event Handlers Enabled'
            elif [[ $QUERY = notifications ]]; then
                SEARCH='Notifications Enabled'
            elif [[ $QUERY = active_svc_checks ]]; then
                SEARCH='Service Checks Being Executed'
            elif [[ $QUERY = passive_svc_checks ]]; then
                SEARCH='Passive Service Checks'
            elif [[ $QUERY = active_host_checks ]]; then
                SEARCH='Host Checks Being Executed'
            elif [[ $QUERY = passive_host_checks ]]; then
                SEARCH='Passive Host Checks'
            elif [[ $QUERY = host_downtime ]]; then
                SCOPE='hosts'; DOWNTIME_QUERY; exit
            elif [[ $QUERY = service_downtime ]]; then
                SCOPE='services'; DOWNTIME_QUERY; exit
            else
                echo "A global object is required.";
                exit
            fi
            GLOBAL_QUERY
        fi

    elif [ $ACTION ]; then
        if [ ! $HOST ] && [ ! $HOSTGROUP ] && [ ! $SERVICEGROUP ] && [[ $ACTION = set ]]; then
            if [[ $SCOPE = notifications ]]; then
                if [[ $VALUE =~ en ]]; then CMD_TYP='12'; VALUE='enabled'; GLOBAL_COMMAND;
                elif [[ $VALUE =~ dis ]]; then CMD_TYP='11'; VALUE='disabled'; GLOBAL_COMMAND;
                else
                    echo "An action is required (enable or disable)"
                    SEARCH='Notifications Enabled'; GLOBAL_QUERY
                fi
            elif [[ $SCOPE = event_handlers ]]; then
                if [[ $VALUE =~ en ]]; then CMD_TYP='41'; VALUE='enabled';GLOBAL_COMMAND;
                elif [[ $VALUE =~ dis ]]; then CMD_TYP='42';VALUE='disabled'; GLOBAL_COMMAND;
                else
                    echo "An action is required (enable or disable)"
                    SEARCH='Event Handlers Enbled'; GLOBAL_QUERY
                fi
            elif [[ $SCOPE = active_service_checks ]]; then
                if [[ $VALUE =~ en ]]; then CMD_TYP='35'; VALUE='enabled'; GLOBAL_COMMAND;
                elif [[ $VALUE =~ dis ]]; then CMD_TYP='36'; VALUE='disabled'; GLOBAL_COMMAND;
                else
                    echo "An action is required (enable or disable)"
                    SEARCH='Service Checks Being Executed'; GLOBAL_QUERY
                fi
            elif [[ $SCOPE = passive_service_checks ]]; then
                if [[ $VALUE =~ en ]]; then CMD_TYP='37';  VALUE='enabled'; GLOBAL_COMMAND;
                elif [[ $VALUE =~ dis ]]; then CMD_TYP='38'; VALUE='disabled'; GLOBAL_COMMAND;
                else
                    echo "An action is required (enable or disable)"
                    SEARCH='Passive Service Checks'; GLOBAL_QUERY
                fi
            elif [[ $SCOPE = active_host_checks ]]; then
                if [[ $VALUE =~ en ]]; then CMD_TYP='88'; VALUE='enabled';  GLOBAL_COMMAND;
                elif [[ $VALUE =~ dis ]]; then  CMD_TYP='89'; VALUE='disabled'; GLOBAL_COMMAND;
                else
                    echo "An action is required (enable or disable)"
                    SEARCH='Host Checks Being Executed'; GLOBAL_QUERY
                fi
            elif [[ $SCOPE = passive_host_checks ]]; then
                if [[ $VALUE =~ en ]]; then CMD_TYP='90';  VALUE='enabled'; GLOBAL_COMMAND;
                elif [[ $VALUE =~ dis ]]; then CMD_TYP='91'; VALUE='disabled'; GLOBAL_COMMAND;
                else
                    echo "An action is required (enable or disable)"
                    SEARCH='Passive Host Checks'; GLOBAL_QUERY
                fi
            fi
        elif [[ $ACTION = set ]] || [[ $ACTION = ack ]] || [[ $ACTION = recheck ]] ; then
            if [[ $SCOPE = downtime ]]; then
                if [ $HOST ] && [ ! $SERVICE ]; then
                    CMD_TYP='55'; DATA="--data host=$HOST --data trigger=0"
                elif [ $HOST ] && [ $SERVICE ]; then
                    CMD_TYP='56'
                    DATA="--data service=$SERVICE --data host=$HOST --data trigger=0"
                elif [ $HOSTGROUP ]; then
                    CMD_TYP='84'; DATA="--data hostgroup=$HOSTGROUP"
                elif [ $SERVICEGROUP ]; then
                    CMD_TYP='122'; DATA="--data servicegroup=$SERVICEGROUP"
                else
                    echo "$SCOPE needs to be applied to a service, host, hostgroup or servicegroup. Exiting."
                    exit 1
                fi
                SET_DOWNTIME
            elif [[ $ACTION = ack ]] && [ $HOST ] && [ $SERVICE ] ; then
                DATA="--data cmd_typ=34 --data service=$SERVICE"; ACKNOWLEDGE
            elif [[ $ACTION = ack ]] && [ $HOST ] ; then
                DATA="--data cmd_typ=33"; ACKNOWLEDGE
            elif [[ $ACTION = recheck ]] && [ $HOST ] && [ $SERVICE ] ; then
                DATA="--data cmd_typ=7 --data service=$SERVICE"; RECHECK
            elif [[ $ACTION = recheck ]] && [ $HOST ] ; then
                DATA="--data cmd_typ=96"; RECHECK
            fi
        elif [[ $ACTION = del ]]; then
            if [ $DOWN_ID ]; then
                CMD_TYP=79 ; DELETE_DOWNTIME; CMD_TYP=78 ; DELETE_DOWNTIME
                exit 0
            elif [ $SERVICE ] && [ $HOST ]; then
                CMD_TYP=79
                COUNT=1; SCOPE=services
                while [ ! $DOWN_ID ] && [ $COUNT -lt 5 ] ; do
                    FIND_DOWN_ID; COUNT=$[$COUNT+1]
                done
                if [ ! $DOWN_ID ]; then echo "Could not find downtime for $HOST. Exiting."
                    exit 1
                fi
                DELETE_DOWNTIME; exit 0
            elif [ $HOST ]; then
                CMD_TYP=78
                COUNT=1; SCOPE=hosts
                while [ ! $DOWN_ID ] && [ $COUNT -lt 5 ] ; do
                    FIND_DOWN_ID; COUNT=$[$COUNT+1]
                done
                if [ ! $DOWN_ID ]; then echo "Could not find downtime for $HOST. Exiting."
                    exit 1
                fi
                DELETE_DOWNTIME; exit
            elif [ $HOSTGROUP ]; then
                DELETE_DOWNTIME_HOSTGROUP
            else
                echo "No host, service or downtime-id specified. Listing current downtimes now."
                SCOPE=hosts; DOWNTIME_QUERY; SCOPE=services; DOWNTIME_QUERY
            fi
        else
            echo "Command not recognized."; usage
        fi
    else
        echo "Method not specified."; usage
    fi

}

function SET_DOWNTIME {
    # Ensure the comment and minutes arguments have been set
    if [ -z "$COMMENT" ]; then
        echo "Comment required. Specify with the -C option."
        exit 1
    fi

    if [ -z "$MINUTES" ]; then
        echo "Time value not set. Cannot submit downtime requests without a duration."
        exit 1
    fi

    NOW=$(date +"%m-%d-%Y+%H%%3A%M%%3A%S")
    NOW_ADD_MINS=$(date +"%m-%d-%Y+%H%%3A%M%%3A%S" -d "+$MINUTES minute")

    echo "Setting downtime for hostgroup $HOSTGROUP host $HOST service $SERVICE for 20 mins with comment $COMMENT"

    RESPONSE=`curl -sS $NAGIOS_INSTANCE/cmd.cgi -u "$USERNAME:$PASSWORD" \
        $DATA \
        --data cmd_typ=$CMD_TYP \
        --data cmd_mod=2 \
        --data "com_data=$COMMENT" \
        --data "start_time=$NOW" \
        --data "end_time=$NOW_ADD_MINS" \
        --data fixed=1 \
        --data hours=2 \
        --data minutes=0 \
        --data btnSubmit=Commit`

    CHECK_RESPONSE
    
    if [ -z $QUIET ]; then
        if [ $SERVICE ]; then
            SCOPE=services
        elif [ $HOST ]; then
            SCOPE=hosts
        elif [ $HOSTGROUP ]; then
            SCOPE=hostgroups
        fi

        if [ $HOST ] || [ $SERVICE ] || [ $HOSTGROUP ]; then
            COUNT=2;
            FIND_DOWN_ID
            OLD_DID=$DOWN_ID

            if [ $OLD_DID ]; then
                sleep 1
            else
                OLD_DID=1 && DOWN_ID=1
            fi

            while [ $DOWN_ID -eq $OLD_DID  ] && [ $COUNT -le $NAG_POLL_TIMEOUT ] ; do
                sleep 1
                FIND_DOWN_ID
                COUNT=$[$COUNT+1]
            done

            if [ $DOWN_ID -eq 1 ]; then
                echo "Could not find newly created downtime. Exiting."
                exit 1
            fi
        fi

        echo $DOWN_ID
    fi

    exit
}

function FIND_DOWN_ID {
    if [[ $SCOPE = hosts ]]; then
        DOWN_ID=$(curl -Ss $NAGIOS_INSTANCE/extinfo.cgi -u $USERNAME:$PASSWORD \
        --data type=6 | grep "extinfo.cgi" | sed -e'/service=/d' |\
        awk -F"<td CLASS='downtime" '{print $2" "$4" "$7" "$10" "$5}' |\
        awk -F'>' '{print $3"|||"$10}' | sed -e's/<\/td//g' -e's/<\/A//g' |\
        egrep "$HOST" | egrep -o "[0-9]+$" | sort -rn | head -n1)

        if [ ! $DOWN_ID ]; then
            DOWN_ID=1
        fi
    elif [[ $SCOPE = services ]]; then
        DOWN_ID=$(curl -Ss $NAGIOS_INSTANCE/extinfo.cgi -u $USERNAME:$PASSWORD \
        --data type=6 | grep "extinfo.cgi" | grep "service=" |\
        awk -F"<td CLASS='downtime" '{print $2" "$3" "$5" "$7" "$8" "$6" "$11}' |\
        awk -F'>' '{print $3"|||"$7"|||"$18}' | sed -e's/<\/td//g' -e's/<\/A//g' |\
        column -c8 -t -s"|||" | egrep "$HOST" | grep "$SERVICE" | egrep -o "[0-9]+$" |\
        sort -rn | head -n1)

        if [ ! $DOWN_ID ]; then
            DOWN_ID=1
        fi
    elif [[ $SCOPE = hostgroups ]]; then
        DOWN_ID=`curl -sS "$NAGIOS_INSTANCE/statusjson.cgi?query=downtimelist" -u $USERNAME:$PASSWORD |\
            jq -Sr '.data.downtimelist | max'`
        
        if [[ "$DOWN_ID" = "null" ]]; then
            DOWN_ID=1
        fi
    fi
}

function DOWNTIME_QUERY {
    if [[ $SCOPE = hosts ]]; then
        curl -Ss $NAGIOS_INSTANCE/extinfo.cgi --data type=6 -u $USERNAME:$PASSWORD |\
        grep "extinfo.cgi" | sed -e'/service=/d' |\
        awk -F"<td CLASS='downtime" '{print $2" "$4" "$7" "$10" "$5}' |\
        awk -F'>' '{print $3"|||"$10"|||"$8"|||"$6"|||"$12}' |\
        sed -e's/<\/td//g' -e's/<\/A//g' |\
        sed "1 i \Hostname|||Downtime-id|||End_date_and_time|||Author|||Comment" |\
        column -c7 -t -s"|||"
    elif [[ $SCOPE = services ]]; then
        curl -Ss $NAGIOS_INSTANCE/extinfo.cgi --data type=6 -u $USERNAME:$PASSWORD |\
        grep "extinfo.cgi" | grep "service=" |\
        awk -F"<td CLASS='downtime" '{print $2" "$3" "$5" "$7" "$8" "$6" "$11}' |\
        awk -F'>' '{print $3"|||"$7"|||"$18"|||"$14"|||"$10"|||"$16}' |\
        sed -e's/<\/td//g' -e's/<\/A//g' |\
        sed "1 i \Hostname|||Service|||Downtime-id|||End_date_and_time|||Author|||Comment" |\
        column -c8 -t -s"|||"
    fi
    if [ $? -eq 1 ]; then echo "curl failed"; exit 1; fi
}

function DELETE_DOWNTIME {
    curl -Ss --output /dev/null $NAGIOS_INSTANCE/cmd.cgi \
        --data cmd_mod=2 \
        --data cmd_typ=$CMD_TYP \
        --data down_id=$DOWN_ID \
        --data btnSubmit=Commit \
        -u $USERNAME:$PASSWORD
    if [ $? -eq 1 ]; then echo "curl failed"; exit 1; fi
}

function DELETE_DOWNTIME_HOSTGROUP {
    # Delete host downtimes for hostgroup

    # Counter to track downtimes
    COUNT=0

    # Set command to CMD_DEL_HOST_DOWNTIME
    CMD_TYP=78

    # Find all hosts in hostgroup
    HOSTLIST=`curl -Ss -u $USERNAME:$PASSWORD "$NAGIOS_INSTANCE/statusjson.cgi?query=hostlist&details=true&hostgroup=$HOSTGROUP" | jq -r '.data.hostlist[].name'`

    for HOST in $HOSTLIST; do
    # Find all downtime IDs for host
    DOWNTIME_IDS=`curl -Ss -u $USERNAME:$PASSWORD "$NAGIOS_INSTANCE/statusjson.cgi?query=downtimelist&details=true&hostname=$HOST" | jq -r '.data.downtimelist[].downtime_id'`

    for DOWN_ID in $DOWNTIME_IDS; do
        echo "Deleting downtime $DOWN_ID for host $HOST."
        DELETE_DOWNTIME
        ((COUNT++))
    done
    done

    echo "Deleted $COUNT downtimes for hostgroup $HOSTGROUP."
}

function GLOBAL_COMMAND {
    curl -sS $DATA \
        "$NAGIOS_INSTANCE/cmd.cgi" \
        --data cmd_mod=2 \
        --data cmd_typ=$CMD_TYP \
        --data btnSubmit=Commit \
        -u $USERNAME:$PASSWORD |\
        grep -o 'Your command request was successfully submitted to Nagios for processing.'
    if [ $? -eq 1 ]; then
        echo "curl failed. Command not sent.";
        exit 1;
    fi

    QUERY=$SCOPE
    RESULT=`MAIN`
    until [[ $SCOPE:$VALUE = $RESULT ]]; do
        sleep 1
        RESULT=`MAIN`
    done
    echo $RESULT
    exit 0
}

function GLOBAL_QUERY {
    HTML=`curl  -sS $NAGIOS_INSTANCE/extinfo.cgi \
        --data type=0 \
        -u $USERNAME:$PASSWORD | grep "$SEARCH"`

    if [ $? -eq 1 ]; then
        echo "curl failed"
        exit 1
    fi

    MATCH=`echo $HTML | grep -i 'yes'`
    
    if [ -n "$MATCH" ]; then
        echo "$QUERY:enabled"
        exit
    else
        echo  "$QUERY:disabled"
        exit 0
    fi
}

function ACKNOWLEDGE {
    # Notification emails are enabled by default. Change send_notifications to 'off' below to disable.

    # Set a comment if none has been supplied
    if [ -z "$COMMENT" ]; then
        COMMENT="Acknowledging service $SERVICE on $HOST."
    fi

    # $DATA is set when ACKNOWLEDGE() is called, e.g.:
    #   DATA="--data cmd_typ=34 --data service=$SERVICE"; ACKNOWLEDGE


    RESPONSE=`curl -sS \
        $NAGIOS_INSTANCE/cmd.cgi \
        -u $USERNAME:$PASSWORD \
        $DATA \
        --data cmd_mod=2 \
        --data host=$HOST \
        --data "com_data=$COMMENT" \
        --data sticky_ack=on \
        --data send_notification=on \
        --data btnSubmit=Commit`

    CHECK_RESPONSE
}

function RECHECK {
    NOW=$(date +"%m-%d-%Y+%H%%3A%M%%3A%S")
    curl -sS $NAGIOS_INSTANCE/cmd.cgi \
        -u $USERNAME:$PASSWORD \
        $DATA \
        --data cmd_mod=2 \
        --data host=$HOST \
        --data start_time=$NOW \
        --data force_check=on \
        --data btnSubmit=Commit |\
        grep -o 'Your command request was successfully submitted to Nagios for processing.'
        
    if [ $? -eq 1 ]; then
        echo "curl failed. Command not sent."
        exit 1
    fi
    exit 0
}

function SET_STATUS {
    # not implemented yet
    curl -sS  $DATA \
        $NAGIOS_INSTANCE/cmd.cgi \
        --data host=$HOST \
        --data "com_data=$COMMENT" \
        --data cmd_mod=2 \
        --data btnSubmit=Commit \
        -u $USERNAME:$PASSWORD |\
        grep -o 'Your command request was successfully submitted to Nagios for processing.'

    if [ $? -eq 1 ]; then
        echo "curl failed. Command not sent."
        exit 1
    fi
    exit 0
}

function LIST_HOSTS {
    echo -e "Hostname\tStatus"
    curl -Ss $DATA $NAGIOS_INSTANCE/status.cgi -u $USERNAME:$PASSWORD |\
        grep 'extinfo.cgi?type=1&host=' | grep "statusHOST" | awk -F'</A>' '{print $1}' |\
        awk -F'statusHOST' '{print $2}'  |  awk -F"'>" '{print $3"\t"$1}' | sed 's/<\/a>&nbsp;<\/td>//g' | column -c2 -t
    exit 0
}

function LIST_GROUPS {
    echo "List of all $TYPE\groups"
    echo "---"
    curl -Ss $DATA $NAGIOS_INSTANCE/status.cgi -u $USERNAME:$PASSWORD |\
        egrep "status(Even|Odd)" | grep "status.cgi?$TYPE\group=" | awk -F'</A>' '{print $1}' |\
        awk -F"${TYPE}group=" '{print $2}' | awk -F'&' '{print $1}' | column -c2 -t
    exit 0
}

function LIST_SERVICES {
    echo Fetching services and health on $HOST
    echo ---
    HOSTS=($(curl -Ss $DATA $NAGIOS_INSTANCE/status.cgi -u $USERNAME:$PASSWORD |\
        grep "extinfo.cgi?type=2&host=" | cut -d"=" -f8 | cut -d"'" -f1))
    STATUSES=($(curl -Ss $DATA $NAGIOS_INSTANCE/status.cgi -u $USERNAME:$PASSWORD |\
        egrep "status(OK|CRITICAL|WARNING|UNKNOWN)" | cut -d"'" -f2 | cut -c 7-))

    for i in $(seq 0 $(( ${#HOSTS[@]} - 1 )) ); do
        COMBINED=(${COMBINED[@]} ${HOSTS[$i]}@${STATUSES[$i]})
    done

    echo ${COMBINED[@]} | tr ' ' '\n' |  sed '1 i \---' |  sed '1 i \Service@State' |\
        tr '@' ' ' | column -c2 -t
}

function CHECK_RESPONSE {
    # Check if command was successful
    echo "$RESPONSE" | grep -o 'Your command request was successfully submitted to Nagios for processing.'

    if [ $? -eq 1 ]; then
    # Get error message if not (t & d in sed below transfers to end of output and deletes lines)
    echo "$RESPONSE" | sed -e "/errorMessage/ s/<P><DIV CLASS='errorMessage'>\([^>]\+\)<\/DIV><\/P>/\1/;t;d"
    echo "curl failed. Command not sent."
    exit 1
    fi
}

MAIN
