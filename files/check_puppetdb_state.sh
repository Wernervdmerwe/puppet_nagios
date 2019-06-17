#/bin/bash
# Requires valid puppet certname (hostname) as an argument
 
HOSTNAME=$1
 
#echo checking puppet status for $HOSTNAME...
 
puppetNodeStatusJson=`sudo curl -sS -k -X GET --tlsv1 --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem --cert /etc/puppetlabs/puppet/ssl/certs/tst-mon9999.moest.govt.nz.pem --key /etc/puppetlabs/puppet/ssl/private_keys/tst-mon9999.moest.govt.nz.pem https://dev-srv9001.moest.govt.nz:8081/pdb/query/v4/nodes/$HOSTNAME`
 
status=`echo $puppetNodeStatusJson | jq -r '.latest_report_status'`
correctiveChange=`echo $puppetNodeStatusJson | jq -r '.latest_report_corrective_change'`
isNoop=`echo $puppetNodeStatusJson | jq -r '.latest_report_noop'`
noopPending=`echo $puppetNodeStatusJson | jq -r '.latest_report_noop_pending'`
reportTime=`echo $puppetNodeStatusJson | jq -r '.report_timestamp'`
 
# Print full output for debugging
#echo $puppetNodeStatusJson | jq '.'
 
if [[ "$status" = "failed" ]]; then
    echo "Critical: Status is 'failed'."
    exitCode=2
 
elif [[ "$corrective_change" = "true" ]]; then
    if [[ "$is_noop" = "true" ]]; then
        echo "Warning: No-op corrective changes are pending."
    else
        echo "Warning: Corrective changes were made."
    fi
 
    exitCode=1
 
elif [[ "$is_noop" = "true" && "$noop_pending" = "true" ]]; then
    echo "No-op intentional changes are pending."
    exitCode=1

elif [[ "$status" = "changed" ]]; then
    echo "Intentional changes were made."
    exitCode=0
 
elif [[ "$status" = "unchanged" ]]; then
    echo "No changes."
    exitCode=0
else
    echo "Unknown status."
    exitCode=3
fi
 
echo "Last report ran at $reportTime."
 
if [[ -n $exitCode ]]; then
    exit $exitCode
fi