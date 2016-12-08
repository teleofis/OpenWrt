--
--
local fs  = require "nixio.fs"
local sys = require "luci.sys"

local gpios = { }

gpios[1] = {name =  "0 PULLUP",
            on0 = "echo 71 > /sys/class/gpio/export", 
            on1 = "echo out > /sys/class/gpio/gpio71/direction", 
            on2 = "echo 0 > /sys/class/gpio/gpio71/value",
            off0 = "echo 71 > /sys/class/gpio/export", 
            off1 = "echo out > /sys/class/gpio/gpio71/direction", 
            off2 = "echo 1 > /sys/class/gpio/gpio71/value" }

gpios[2] = {name = "0 PULLDOWN",
            on0 = "echo 67 > /sys/class/gpio/export", 
            on1 =  "echo out > /sys/class/gpio/gpio67/direction", 
            on2 =  "echo 1 > /sys/class/gpio/gpio67/value",
            off0 = "echo 67 > /sys/class/gpio/export", 
            off1 = "echo out > /sys/class/gpio/gpio67/direction", 
            off2 = "echo 0 > /sys/class/gpio/gpio67/value" }

gpios[3] = {name = "1 PULLUP",
            on0 = "echo 68 > /sys/class/gpio/export", 
            on1 = "echo out > /sys/class/gpio/gpio68/direction", 
            on2 = "echo 0 > /sys/class/gpio/gpio68/value",
            off0 = "echo 68 > /sys/class/gpio/export", 
            off1 = "echo out > /sys/class/gpio/gpio68/direction", 
            off2 = "echo 1 > /sys/class/gpio/gpio68/value" }

gpios[4] = {name = "1 PULLDOWN",
            on0 = "echo 70 > /sys/class/gpio/export", 
            on1 = "echo out > /sys/class/gpio/gpio70/direction", 
            on2 = "echo 1 > /sys/class/gpio/gpio70/value",
            off0 = "echo 70 > /sys/class/gpio/export", 
            off1 = "echo out > /sys/class/gpio/gpio70/direction", 
            off2 = "echo 0 > /sys/class/gpio/gpio70/value" }

gpios[5] = {name = "2 PULLUP",
            on0 = "echo 74 > /sys/class/gpio/export", 
            on1 = "echo out > /sys/class/gpio/gpio74/direction", 
            on2 = "echo 0 > /sys/class/gpio/gpio74/value",
            off0 = "echo 74 > /sys/class/gpio/export", 
            off1 = "echo out > /sys/class/gpio/gpio74/direction", 
            off2 = "echo 1 > /sys/class/gpio/gpio74/value" }

gpios[6] = {name = "2 PULLDOWN",
            on0 = "echo 121 > /sys/class/gpio/export", 
            on1 = "echo out > /sys/class/gpio/gpio121/direction", 
            on2 = "echo 1 > /sys/class/gpio/gpio121/value",
            off0 = "echo 121 > /sys/class/gpio/export", 
            off1 = "echo out > /sys/class/gpio/gpio121/direction", 
            off2 = "echo 0 > /sys/class/gpio/gpio121/value" }

gpios[7] = {name = "3 PULLUP",
            on0 = "echo 64 > /sys/class/gpio/export", 
            on1 = "echo out > /sys/class/gpio/gpio64/direction", 
            on2 = "echo 0 > /sys/class/gpio/gpio64/value",
            off0 = "echo 64 > /sys/class/gpio/export", 
            off1 = "echo out > /sys/class/gpio/gpio64/direction", 
            off2 = "echo 1 > /sys/class/gpio/gpio64/value" }

gpios[8] = {name = "3 PULLDOWN",
            on0 = "echo 122 > /sys/class/gpio/export", 
            on1 = "echo out > /sys/class/gpio/gpio122/direction", 
            on2 = "echo 1 > /sys/class/gpio/gpio122/value",
            off0 = "echo 122 > /sys/class/gpio/export", 
            off1 = "echo out > /sys/class/gpio/gpio122/direction", 
            off2 = "echo 0 > /sys/class/gpio/gpio122/value" }



m = SimpleForm("Gpioswitch", translate("GPIO management"))
m.submit = false
m.reset = false

s = m:section(Table, gpios)
-----
o = s:option(DummyValue, "name", translate("GPIO name"))
--
ena = s:option(Button, "enable", translate("Enable"))
ena.write = function(self, section)
    sys.call("%s" %{gpios[section].on0})
    sys.call("%s" %{gpios[section].on1})
    sys.call("%s" %{gpios[section].on2})
end
--
disa = s:option(Button, "disable", translate("Disable"))
disa.write = function(self, section)
    sys.call("%s" %{gpios[section].off0})
    sys.call("%s" %{gpios[section].off1})
    sys.call("%s" %{gpios[section].off2})
end
-----


return m
