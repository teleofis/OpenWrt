#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	NOT_INCLUDED=1
	INCLUDE_ONLY=1

	. ../netifd-proto.sh
	. ./ppp.sh
	init_proto "$@"
}

proto_nbiot_init_config() {
	no_device=1
	available=1
	ppp_generic_init_config
	proto_config_add_string "device:device"
	proto_config_add_string "apn"
	proto_config_add_string "pincode"
	proto_config_add_string "dialnumber"
	proto_config_add_string "band"
}

proto_nbiot_setup() {
	local interface="$1"
	local chat

	json_get_var device device
	json_get_var apn apn
	json_get_var pincode pincode
	json_get_var dialnumber dialnumber
	json_get_var band band

	[ -n "$dat_device" ] && device=$dat_device
	[ -e "$device" ] || {
		proto_set_available "$interface" 0
		return 1
	}

	if [ -n "$band" ]; then
		COMMAND="AT+CBAND=$band" gcom -d "$device" -s /etc/gcom/runcommand.gcom &>/dev/null
		COMMAND="AT+CFUN=0" gcom -d "$device" -s /etc/gcom/runcommand.gcom &>/dev/null
		COMMAND="AT*MCGDEFCONT=\"IP\",\"$apn\"" gcom -d "$device" -s /etc/gcom/runcommand.gcom &>/dev/null
		COMMAND="AT+CFUN=1" gcom -d "$device" -s /etc/gcom/runcommand.gcom &>/dev/null
	fi

	sleep 2
	COMMAND="AT+CGACT=0,1" gcom -d "$device" -s /etc/gcom/runcommand.gcom &>/dev/null

	chat="/etc/chatscripts/nbiot.chat"
	if [ -n "$pincode" ]; then
		PINCODE="$pincode" gcom -d "$device" -s /etc/gcom/setpin.gcom || {
			proto_notify_error "$interface" PIN_FAILED
			proto_block_restart "$interface"
			return 1
		}
	fi

	if [ -z "$dialnumber" ]; then
		dialnumber="*99***1#"
	fi

	connect="${apn:+USE_APN=$apn }DIALNUMBER=$dialnumber /usr/sbin/chat -t5 -v -E -f $chat"
	ppp_generic_setup "$interface" \
		nobsdcomp \
		noauth \
		lock \
		nocrtscts \
		noipv6 \
		115200 "$device"
	return 0
}

proto_nbiot_teardown() {
	proto_kill_command "$interface"
}

[ -z "NOT_INCLUDED" ] || add_protocol nbiot
