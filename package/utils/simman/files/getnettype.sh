#!/bin/sh

OPTIND=1

SCRIPT_BASESTINFO="/etc/simman/getbasestinfo.gcom"
device=""
BASESTINFO=""

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

BASESTINFO=$(gcom -d $device -s $SCRIPT_BASESTINFO | awk -F',' '{print $1}')
[ -z "$BASESTINFO" ] && BASESTINFO="NONE"

echo $BASESTINFO