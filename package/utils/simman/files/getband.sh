#!/bin/sh

OPTIND=1

SCRIPT_BASESTINFO="/etc/simman/getbasestinfo.gcom"
SCRIPT_BASEIDINFO="/etc/simman/getbaseidinfo.gcom"
device=""
BASESTINFO=""
NETTYPE=""
BAND=""
proto=""

while getopts "h?d:" opt; do
        case "$opt" in
        h|\?)
          echo "Usage: ./getband.sh [option]"
          echo "Options:"
          echo " -d - AT modem device"
          echo "Example: getband.sh -d /dev/ttyACM3"
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
proto=$(uci -q get simman.core.proto)
if [ "$proto" = "0" ]; then
  BASESTINFO=$(gcom -d $device -s $SCRIPT_BASESTINFO)
  [ -z "$BASESTINFO" ] && BASESTINFO="NONE"

  NETTYPE=${BASESTINFO:0:2}

  if [ "$NETTYPE" == "3G" ]
  then
        BAND=$( echo $BASESTINFO | awk -F',' '{print $2}')
        [ -z "$BAND" ] && BAND="Search..."
        echo "'UARFCN $BAND'"
  else
        if [ "$NETTYPE" == "2G" ]
        then
                BAND=$( echo $BASESTINFO | awk -F',' '{print $2}')
                [ -z "$BAND" ] && BAND="Search..."
                echo "'ARFCN $BAND'"
        else
                echo "Identification failed"
        fi
  fi
else
  BASESTINFO=$(gcom -d $device -s $SCRIPT_BASEIDINFO)
  [ -z "$BASESTINFO" ] && BASESTINFO="NONE"
  NETTYPE=$( echo $BASESTINFO | awk -F',' '{print $1}')
  if [ "$NETTYPE" == "LTE" ]; then
    BAND=$( echo $BASESTINFO | awk -F',' '{print $7}')
    [ -z "$BAND" ] && BAND="Search..."
    echo $BAND
  else
        BAND=$( echo $BASESTINFO | awk -F',' '{print $6}')
    [ -z "$BAND" ] && BAND="Search..."
    echo $BAND
  fi
fi