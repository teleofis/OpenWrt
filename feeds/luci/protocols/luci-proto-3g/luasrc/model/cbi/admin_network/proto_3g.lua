-- Copyright 2011 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local map, section, net = ...

local device, apn, service, pincode, username, password, dialnumber
local ipv6, maxwait, defaultroute, metric, peerdns, dns,
      keepalive_failure, keepalive_interval, demand


device = section:taboption("general", Value, "device", translate("Modem device"))
device.rmempty = false

local device_suggestions = nixio.fs.glob("/dev/tty[A-Z]*")
	or nixio.fs.glob("/dev/tts/*")

if device_suggestions then
	local node
	for node in device_suggestions do
		device:value(node)
	end
end


service = section:taboption("general", Value, "service", translate("Service Type"))
service:value("", translate("-- Please choose --"))
service:value("umts", "ALL")
service:value("lte_only", translate("LTE only"))
service:value("umts_only", translate("UMTS only"))
service:value("gprs_only", translate("GPRS only"))

local simman = map.uci:get("simman", "core", "enabled") or "0"
if simman == "0" then
	apn = section:taboption("general", Value, "apn", translate("APN"))
	pincode = section:taboption("general", Value, "pincode", translate("PIN"))
	username = section:taboption("general", Value, "username", translate("PAP/CHAP username"))
	password = section:taboption("general", Value, "password", translate("PAP/CHAP password"))
	password.password = true
else
	apn = section:taboption("general", DummyValue, "apn", translate("APN"), translate("You can configure this value in the SIM manager, or after disabling it"))
	pincode = section:taboption("general", DummyValue, "pincode", translate("PIN"), translate("You can configure this value in the SIM manager, or after disabling it"))
	username = section:taboption("general", DummyValue, "username", translate("PAP/CHAP username"), translate("You can configure this value in the SIM manager, or after disabling it"))
	password = section:taboption("general", DummyValue, "password", translate("PAP/CHAP password"), translate("You can configure this value in the SIM manager, or after disabling it"))
end

dialnumber = section:taboption("general", Value, "dialnumber", translate("Dial number"))
dialnumber.placeholder = "*99***1#"

if luci.model.network:has_ipv6() then

	ipv6 = section:taboption("advanced", Flag, "ipv6",
		translate("Enable IPv6 negotiation on the PPP link"))

	ipv6.default = ipv6.disabled

end


maxwait = section:taboption("advanced", Value, "maxwait",
	translate("Modem init timeout"),
	translate("Maximum amount of seconds to wait for the modem to become ready"))

maxwait.placeholder = "20"
maxwait.datatype    = "min(1)"


defaultroute = section:taboption("advanced", Flag, "defaultroute",
	translate("Use default gateway"),
	translate("If unchecked, no default route is configured"))

defaultroute.default = defaultroute.enabled


metric = section:taboption("advanced", Value, "metric",
	translate("Use gateway metric"))

metric.placeholder = "0"
metric.datatype    = "uinteger"
metric:depends("defaultroute", defaultroute.enabled)


peerdns = section:taboption("advanced", Flag, "peerdns",
	translate("Use DNS servers advertised by peer"),
	translate("If unchecked, the advertised DNS server addresses are ignored"))

peerdns.default = peerdns.enabled


dns = section:taboption("advanced", DynamicList, "dns",
	translate("Use custom DNS servers"))

dns:depends("peerdns", "")
dns.datatype = "ipaddr"
dns.cast     = "string"


keepalive_failure = section:taboption("advanced", Value, "_keepalive_failure",
	translate("LCP echo failure threshold"),
	translate("Presume peer to be dead after given amount of LCP echo failures, use 0 to ignore failures"))

function keepalive_failure.cfgvalue(self, section)
	local v = m:get(section, "keepalive")
	if v and #v > 0 then
		return tonumber(v:match("^(%d+)[ ,]+%d+") or v)
	end
end

function keepalive_failure.write() end
function keepalive_failure.remove() end

keepalive_failure.placeholder = "0"
keepalive_failure.datatype    = "uinteger"


keepalive_interval = section:taboption("advanced", Value, "_keepalive_interval",
	translate("LCP echo interval"),
	translate("Send LCP echo requests at the given interval in seconds, only effective in conjunction with failure threshold"))

function keepalive_interval.cfgvalue(self, section)
	local v = m:get(section, "keepalive")
	if v and #v > 0 then
		return tonumber(v:match("^%d+[ ,]+(%d+)"))
	end
end

function keepalive_interval.write(self, section, value)
	local f = tonumber(keepalive_failure:formvalue(section)) or 0
	local i = tonumber(value) or 5
	if i < 1 then i = 1 end
	if f > 0 then
		m:set(section, "keepalive", "%d %d" %{ f, i })
	else
		m:del(section, "keepalive")
	end
end

keepalive_interval.remove      = keepalive_interval.write
keepalive_interval.placeholder = "5"
keepalive_interval.datatype    = "min(1)"


demand = section:taboption("advanced", Value, "demand",
	translate("Inactivity timeout"),
	translate("Close inactive connection after the given amount of seconds, use 0 to persist connection"))

demand.placeholder = "0"
demand.datatype    = "uinteger"
