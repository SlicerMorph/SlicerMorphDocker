#!/bin/bash

set -u
set -e

# Run this with a command like:
#
#  for user in $(cat users); do ./nogpu.run $user ; done > instance-table.csv
#

# convenience function to send feedback to stderr so stdout can go to csv
errcho(){ >&2 echo $@; }

if [ "$1" == "" ]; then
        echo "Usage: ./nogpu.run <User>"
        exit
fi
USERNAME=$1

CONTAINER_NAME=${USERNAME}
CONTAINER_ID=$(docker run -it \
        --name ${CONTAINER_NAME} \
        -d \
        --expose 5801 \
        --expose 5901 \
        -P \
        --rm \
        -m 100g \
        --cpus=4 \
        cloud \
        /opt/TurboVNC/bin/vncserver -fg -autokill -otp )
# CONTAINER_NAME=$(docker ps --filter "id=$CONTAINER_ID" --format "{{.Names}}")
errcho
errcho Execute:
errcho docker stop $CONTAINER_NAME
errcho "to stop container (or log out of the window manager in the TurboVNC session.)"
errcho
PORT=$(docker port $CONTAINER_NAME 5901 | cut -f2 -d:)
NOVNC_PORT=$(docker port $CONTAINER_NAME 5801 | cut -f2 -d:)
VNC_DISPLAY=`hostname`::$PORT
errcho "VNC DISPLAY is ${VNC_DISPLAY}"
NOVNC_URL="http://`hostname`:${NOVNC_PORT}/vnc.html?host=`hostname`&port=$PORT&resize=remote"
errcho "NOVNC URL is ${NOVNC_URL}"
OTP=
while [ "$OTP" = "" ]; do
        sleep 1
        OTP=$(docker logs $CONTAINER_NAME | grep "Full control one-time password" | sed 's/.*: //g')
done
errcho SESSION PASSWORD is $OTP
docker exec $CONTAINER_NAME sh -c "echo $OTP| /opt/TurboVNC/bin/vncpasswd -f >/home/docker/.vnc/passwd 2>/dev/null"


errcho USERNAME, PORT, NOVNC_PORT, VNC_DISPLAY, NOVNC_URL, OTP
echo ${USERNAME}, ${PORT}, ${NOVNC_PORT}, ${VNC_DISPLAY}, ${NOVNC_URL}, ${OTP}
