#!/bin/sh

OPTIND=1

SCRIPT_CCID="/etc/simman/getccid.gcom"
SCRIPT_CICCID="/etc/simman/getciccid.gcom"
device=""
CCID=""
proto=""

while getopts "h?d:" opt; do
	case "$opt" in
	h|\?)
	  echo "Usage: ./getccid.sh [option]"
	  echo "Options:"
	  echo " -d - AT modem device"
	  echo "Example: getccid.sh -d /dev/ttyACM3"
	  exit 0
	;;
	d) device=$OPTARG
	;;
	esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

[ -z "$device" ] && device=$(uci -q get simman.core.atdevice) 

proto=$(uci -q get simman.core.proto)

# Check if device exists
[ ! -e $device ] && exit 0

if [ "$proto" = "0" ]; then
	CCID=$(gcom -d $device -s $SCRIPT_CCID)
else 
	CCID=$(gcom -d $device -s $SCRIPT_CICCID)
fi
#CCID=$(gcom -d $device -s $SCRIPT_CCID | grep -e [0-9] | sed 's/"//g')
[ -z "$CCID" ] && CCID="NONE"

echo $CCID

