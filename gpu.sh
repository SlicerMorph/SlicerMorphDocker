#!/bin/sh

set -u
set -e

if [ -z ${VGL_DISPLAY+x} ]; then
        export VGL_DISPLAY=/dev/dri/card0
        if [ ! -c /dev/dri/card0 ]; then
                echo ERROR: /dev/dri/card0 does not exist.
                exit 1
        fi
        if [ ! -r /dev/dri/card0 ]; then
                echo ERROR: /dev/dri/card0 is not readable.
                exit 1
        fi
        if [ ! -c /dev/dri/renderD128 ]; then
                echo ERROR: /dev/dri/renderD128 does not exist.
                exit 1
        fi
        if [ ! -r /dev/dri/renderD128 ]; then
                echo ERROR: /dev/dri/renderD128 is not readable.
                exit 1
        fi
fi

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

USER_DATA="/data/users/${USERNAME}"
if [ ! -d ${USER_DATA} ]; then
        mkdir ${USER_DATA}
        chmod 777 ${USER_DATA}
fi

CONTAINER_NAME=${USERNAME}
CONTAINER_ID=$(docker run -it \        
        --expose 5801 \
        --expose 5901 \
        --gpus=all \
        -P \
        -v /data/sample/:/home/docker/workshop_data:ro \
        -v ${USER_DATA}:/home/docker/${USERNAME} \
        -v /mnt/resource/:/home/docker/temp \
        --rm \
        -m 100g \
        --cpus=8 \
        cloud \
        /opt/TurboVNC/bin/vncserver -fg -autokill -otp -vgl )
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
        --name ${CONTAINER_NAME} \
        -d \
        --device /dev/dri \
        -e VGL_DISPLAY \
        
