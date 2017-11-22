#!/bin/sh
NTPSTATUS=$(ntpq -p 2>/dev/null | grep "*")
if [ ! -z "$NTPSTATUS" ]; then
        /usr/sbin/hwclock -w --localtime
fi
