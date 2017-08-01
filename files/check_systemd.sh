#! /bin/sh

SERVICE=$1

systemctl --quiet is-active $SERVICE
if [ "$?" -ne 0 ]; then
    echo "ERROR: service ${SERVICE} is not running"
    exit 2
fi


systemctl --quiet is-enabled $SERVICE
if [ "$?" -ne 0 ]; then
    echo "WARN: service ${SERVICE} is running but not enabled"
    exit 1
fi

echo "OK: service ${SERVICE} is running"
exit 0
