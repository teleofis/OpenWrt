#!/bin/sh

OPTIND=1

SCRIPT_PACKINFO="/etc/simman/getpackinfo.gcom"
device=""
PACKINFO=""

while getopts "h?d:" opt; do
	case "$opt" in
	h|\?)
	  echo "Usage: ./getpackinfo.sh [option]"
	  echo "Options:"
	  echo " -d - AT modem device"
	  echo "Example: getpackinfo.sh -d /dev/ttyACM3"
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

PACKINFO=$(gcom -d $device -s $SCRIPT_PACKINFO | awk -F',' '{print $3}')
[ -z "$PACKINFO" ] && PACKINFO="NONE"

if [ "$PACKINFO" -eq 0 ]; then
	echo "'GPRS/EGPRS not available'"
else 
	if [ "$PACKINFO" -eq 2 ]; then
		echo "'GPRS'"
	else 
		if [ "$PACKINFO" -eq 4 ]; then
			echo "'EGPRS'"
		else 
			if [ "$PACKINFO" -eq 6 ]; then
				echo "'WCDMA'"
			else
				if [ "$PACKINFO" -eq 8 ]; then
					echo "'HSDPA'"
				else
					if [ "$PACKINFO" -eq 10 ]; then
						echo "'HSDPA/HSUPA'"
					else
						echo "'UNKNOWN'"
					fi
				fi
			fi
		fi
	fi
fi