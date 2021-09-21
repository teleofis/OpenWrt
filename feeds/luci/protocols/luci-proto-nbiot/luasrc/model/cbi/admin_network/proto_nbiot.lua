local map, section, net = ...

local device, apn, service, pincode, username, password, dialnumber
local ipv6, maxwait, defaultroute, metric, peerdns, dns,
      keepalive_failure, keepalive_interval, demand


device = section:taboption("general", Value, "device", translate("Modem device"))
device.rmempty = false
device.default = "/dev/ttyAMA0"

local device_suggestions = nixio.fs.glob("/dev/tty[A-Z]*")
	or nixio.fs.glob("/dev/tts/*")

if device_suggestions then
	local node
	for node in device_suggestions do
		device:value(node)
	end
end

apn = section:taboption("general", Value, "apn", translate("APN"))
pincode = section:taboption("general", Value, "pincode", translate("PIN"))
username = section:taboption("general", Value, "username", translate("PAP/CHAP username"))
password = section:taboption("general", Value, "password", translate("PAP/CHAP password"))
password.password = true


dialnumber = section:taboption("general", Value, "dialnumber", translate("Dial number"))
dialnumber.placeholder = "*99***1#"

band = section:taboption("general", MultiValue, "band", translate("NB-IoT band"))
band:value(1)
band:value(3)
band:value(5)
band:value(8)
band:value(20)
band:value(28)
band.default = band.enabled
band.widget = "checkbox"
band.delimiter = ","
function band.cfgvalue(self, section)
	local value = self.map:get(section, "band")
	if value then
		return value
	else
		return "1,3,5,8,20,28"
	end
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
