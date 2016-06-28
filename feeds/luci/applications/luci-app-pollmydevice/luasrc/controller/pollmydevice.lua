
module("luci.controller.pollmydevice", package.seeall)

function index()

    if not nixio.fs.access("/etc/config/pollmydevice") then
            return
    end

    local uci = require("luci.model.uci").cursor()
    local page
    page = node("admin", "services")

    page = entry({"admin", "services", "pollmydevice"}, cbi("pollmydevice")$
    page.leaf   = true
    page.subindex = true

    uci:foreach--("pollmydevice", "interface",
            function (section)
                    local ifc = section[".name"]
                    entry({"admin", "services", "pollmydevice", ifc},
                    true, ifc:upper())
            end)

end
