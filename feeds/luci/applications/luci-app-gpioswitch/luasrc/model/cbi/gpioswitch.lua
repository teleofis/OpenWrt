--
--
local fs  = require "nixio.fs"
local sys = require "luci.sys"

local gpios = { }

gpios[1] = {name =  "i1",
			mode10 = "echo 71 > /sys/class/gpio/export",
			mode11 = "echo in > /sys/class/gpio/gpio71/direction",
			mode12 = "echo 67 > /sys/class/gpio/export", 
            mode13 = "echo out > /sys/class/gpio/gpio67/direction", 
            mode14 = "echo 0 > /sys/class/gpio/gpio67/value",

            mode20 = "echo 71 > /sys/class/gpio/export",
            mode21 = "echo out > /sys/class/gpio/gpio71/direction",
            mode22 = "echo 0 > /sys/class/gpio/gpio71/value",
            mode23 = "echo 67 > /sys/class/gpio/export",
            mode24 = "echo out > /sys/class/gpio/gpio67/direction",
            mode25 = "echo 0 > /sys/class/gpio/gpio67/value",

            mode30 = "echo 71 > /sys/class/gpio/export",
            mode31 = "echo out > /sys/class/gpio/gpio71/direction",
            mode32 = "echo 1 > /sys/class/gpio/gpio71/value",
            mode33 = "echo 67 > /sys/class/gpio/export",
            mode34 = "echo out > /sys/class/gpio/gpio67/direction",
            mode35 = "echo 1 > /sys/class/gpio/gpio67/value" }

gpios[2] = {name = "i2",
            mode10 = "echo 68 > /sys/class/gpio/export",
			mode11 = "echo in > /sys/class/gpio/gpio68/direction",
			mode12 = "echo 70 > /sys/class/gpio/export", 
            mode13 = "echo out > /sys/class/gpio/gpio70/direction", 
            mode14 = "echo 0 > /sys/class/gpio/gpio70/value",

            mode20 = "echo 68 > /sys/class/gpio/export",
            mode21 = "echo out > /sys/class/gpio/gpio68/direction",
            mode22 = "echo 0 > /sys/class/gpio/gpio68/value",
            mode23 = "echo 70 > /sys/class/gpio/export",
            mode24 = "echo out > /sys/class/gpio/gpio70/direction",
            mode25 = "echo 0 > /sys/class/gpio/gpio70/value",

            mode30 = "echo 68 > /sys/class/gpio/export",
            mode31 = "echo out > /sys/class/gpio/gpio68/direction",
            mode32 = "echo 1 > /sys/class/gpio/gpio68/value",
            mode33 = "echo 70 > /sys/class/gpio/export",
            mode34 = "echo out > /sys/class/gpio/gpio70/direction",
            mode35 = "echo 1 > /sys/class/gpio/gpio70/value" }

gpios[3] = {name = "i3",
            mode10 = "echo 74 > /sys/class/gpio/export",
			mode11 = "echo in > /sys/class/gpio/gpio74/direction",
			mode12 = "echo 121 > /sys/class/gpio/export", 
            mode13 = "echo out > /sys/class/gpio/gpio121/direction", 
            mode14 = "echo 0 > /sys/class/gpio/gpio121/value",

            mode20 = "echo 74 > /sys/class/gpio/export",
            mode21 = "echo out > /sys/class/gpio/gpio74/direction",
            mode22 = "echo 0 > /sys/class/gpio/gpio74/value",
            mode23 = "echo 121 > /sys/class/gpio/export",
            mode24 = "echo out > /sys/class/gpio/gpio121/direction",
            mode25 = "echo 0 > /sys/class/gpio/gpio121/value",

            mode30 = "echo 74 > /sys/class/gpio/export",
            mode31 = "echo out > /sys/class/gpio/gpio74/direction",
            mode32 = "echo 1 > /sys/class/gpio/gpio74/value",
            mode33 = "echo 121 > /sys/class/gpio/export",
            mode34 = "echo out > /sys/class/gpio/gpio121/direction",
            mode35 = "echo 1 > /sys/class/gpio/gpio121/value" }

gpios[4] = {name = "i4",
            mode10 = "echo 64 > /sys/class/gpio/export",
			mode11 = "echo in > /sys/class/gpio/gpio64/direction",
			mode12 = "echo 122 > /sys/class/gpio/export", 
            mode13 = "echo out > /sys/class/gpio/gpio122/direction", 
            mode14 = "echo 0 > /sys/class/gpio/gpio122/value",

            mode20 = "echo 64 > /sys/class/gpio/export",
            mode21 = "echo out > /sys/class/gpio/gpio64/direction",
            mode22 = "echo 0 > /sys/class/gpio/gpio64/value",
            mode23 = "echo 122 > /sys/class/gpio/export",
            mode24 = "echo out > /sys/class/gpio/gpio122/direction",
            mode25 = "echo 0 > /sys/class/gpio/gpio122/value",

            mode30 = "echo 64 > /sys/class/gpio/export",
            mode31 = "echo out > /sys/class/gpio/gpio64/direction",
            mode32 = "echo 1 > /sys/class/gpio/gpio64/value",
            mode33 = "echo 122 > /sys/class/gpio/export",
            mode34 = "echo out > /sys/class/gpio/gpio122/direction",
            mode35 = "echo 1 > /sys/class/gpio/gpio122/value" }

m = SimpleForm("Gpioswitch", "GPIO management", translate("Mode 1 - voltage measurement; Mode 2 - connection of resistance sensors; Mode 3 - load management"))
m.submit = false
m.reset = false

s = m:section(Table, gpios)
-----
o = s:option(DummyValue, "name", translate("GPIO name"))
--
mode1 = s:option(Button, "mode1on", translate("Mode 1"))
mode1.write = function(self, section)
    sys.call("%s" %{gpios[section].mode10})
    sys.call("%s" %{gpios[section].mode11})
    sys.call("%s" %{gpios[section].mode12})
    sys.call("%s" %{gpios[section].mode13})
    sys.call("%s" %{gpios[section].mode14})
end
--
mode2 = s:option(Button, "mode2on", translate("Mode 2"))
mode2.write = function(self, section)
    sys.call("%s" %{gpios[section].mode20})
    sys.call("%s" %{gpios[section].mode21})
    sys.call("%s" %{gpios[section].mode22})
    sys.call("%s" %{gpios[section].mode23})
    sys.call("%s" %{gpios[section].mode24})
    sys.call("%s" %{gpios[section].mode25})
end
--
mode3 = s:option(Button, "mode3on", translate("Mode 3"))
mode3.write = function(self, section)
    sys.call("%s" %{gpios[section].mode30})
    sys.call("%s" %{gpios[section].mode31})
    sys.call("%s" %{gpios[section].mode32})
    sys.call("%s" %{gpios[section].mode33})
    sys.call("%s" %{gpios[section].mode34})
    sys.call("%s" %{gpios[section].mode35})
end
-----

return m
