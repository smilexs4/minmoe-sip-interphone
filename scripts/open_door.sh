#!/bin/sh
# Fires an ISAPI "open door" request at a Hikvision Minmoe terminal.
# Called from the Asterisk dialplan (open-door context) when the '*'
# dynamic feature is triggered during a bridged call.
set -eu

: "${HIKVISION_IP:?HIKVISION_IP is not set}"
: "${HIKVISION_USER:?HIKVISION_USER is not set}"
: "${HIKVISION_PASS:?HIKVISION_PASS is not set}"
DOOR_PATH="${HIKVISION_DOOR_PATH:-/ISAPI/AccessControl/RemoteControl/door/1}"

RESPONSE=$(curl -s -S -o /dev/null -w '%{http_code}' \
  --digest -u "${HIKVISION_USER}:${HIKVISION_PASS}" \
  --max-time 5 \
  -X PUT "http://${HIKVISION_IP}${DOOR_PATH}" \
  -H "Content-Type: application/xml" \
  -d '<RemoteControlDoor><cmd>open</cmd></RemoteControlDoor>') || {
    echo "open_door.sh: curl request failed" >&2
    exit 1
  }

echo "open_door.sh: HTTP ${RESPONSE} from ${HIKVISION_IP}${DOOR_PATH}"

case "$RESPONSE" in
  2??) exit 0 ;;
  *) echo "open_door.sh: unexpected status ${RESPONSE}" >&2; exit 1 ;;
esac
