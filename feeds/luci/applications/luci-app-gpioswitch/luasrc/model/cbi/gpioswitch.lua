--
--
local fs  = require "nixio.fs"
local sys = require "luci.sys"

local gpios = { }

gpios[1] = {name =  "0 PULLUP",
            on =    "echo 71 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio71/direction && echo 0 > /sys/class/gpio/gpio71/value",
            off =   "echo 71 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio71/direction && echo 1 > /sys/class/gpio/gpio71/value" }

gpios[2] = {name = "0 PULLDOWN",
            on =    "echo 67 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio67/direction && echo 1 > /sys/class/gpio/gpio67/value",
            off =   "echo 67 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio67/direction && echo 0 > /sys/class/gpio/gpio67/value" }

gpios[3] = {name = "1 PULLUP",
            on =    "echo 68 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio68/direction && echo 0 > /sys/class/gpio/gpio68/value",
            off =   "echo 68 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio68/direction && echo 1 > /sys/class/gpio/gpio68/value" }

gpios[4] = {name = "1 PULLDOWN",
            on =    "echo 70 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio70/direction && echo 1 > /sys/class/gpio/gpio70/value",
            off =   "echo 70 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio70/direction && echo 0 > /sys/class/gpio/gpio70/value" }

gpios[5] = {name = "2 PULLUP",
            on =    "echo 74 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio74/direction && echo 0 > /sys/class/gpio/gpio74/value",
            off =   "echo 74 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio74/direction && echo 1 > /sys/class/gpio/gpio74/value" }

gpios[6] = {name = "2 PULLDOWN",
            on =    "echo 121 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio121/direction && echo 1 > /sys/class/gpio/gpio121/value",
            off =   "echo 121 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio121/direction && echo 0 > /sys/class/gpio/gpio121/value" }

gpios[7] = {name = "3 PULLUP",
            on =    "echo 64 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio64/direction && echo 0 > /sys/class/gpio/gpio64/value",
            off =   "echo 64 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio64/direction && echo 1 > /sys/class/gpio/gpio64/value" }

gpios[8] = {name = "3 PULLDOWN",
            on =    "echo 122 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio122/direction && echo 1 > /sys/class/gpio/gpio122/value",
            off =   "echo 122 > /sys/class/gpio/export && echo out > /sys/class/gpio/gpio122/direction && echo 0 > /sys/class/gpio/gpio122/value" }



m = SimpleForm("Gpioswitch", translate("GPIO management"))
m.submit = false
m.reset = false

s = m:section(Table, gpios)
-----
o = s:option(DummyValue, "name", translate("GPIO name"))
--
ena = s:option(Button, "enable", translate("Enable"))
ena.write = function(self, section)
    sys.call("%s" %{gpios[section].on})
end
--
disa = s:option(Button, "disable", translate("Disable"))
disa.write = function(self, section)
    sys.call("%s" %{gpios[section].off})
end
-----


return m
