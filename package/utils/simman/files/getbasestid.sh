#!/bin/sh

OPTIND=1

SCRIPT_BASESTINFO="/etc/simman/getbasestinfo.gcom"
device=""
BASESTINFO=""
NETTYPE=""
BASESTID=""

while getopts "h?d:" opt; do
        case "$opt" in
        h|\?)
          echo "Usage: ./getbasestid.sh [option]"
          echo "Options:"
          echo " -d - AT modem device"
          echo "Example: getbasestid.sh -d /dev/ttyACM3"
          exit 0
        ;;
        d) device=$OPTARG
        ;;
        esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

[ -z "$device" ] && device=$(uci -q get simman.core.atdevice)

# Check if device exists
[ ! -e $device ] && exit 0

BASESTINFO=$(gcom -d $device -s $SCRIPT_BASESTINFO)
[ -z "$BASESTINFO" ] && BASESTINFO="NONE"

NETTYPE=${BASESTINFO:0:2}

if [ "$NETTYPE" == "3G" ]
then
        BASESTID=$( echo $BASESTINFO | awk -F',' '{print $9}')
        [ -z "$BASESTID" ] && BASESTID="SEARCH"
        echo $BASESTID
else
        if [ "$NETTYPE" == "2G" ]
        then
                BASESTID=$( echo $BASESTINFO | awk -F',' '{print $7}')
                [ -z "$BASESTID" ] && BASESTID="SEARCH"
                echo $BASESTID
        else
                echo "Identification failed"
        fi
fi
