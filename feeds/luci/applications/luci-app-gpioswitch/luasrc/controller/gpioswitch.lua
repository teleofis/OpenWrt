module("luci.controller.gpioswitch", package.seeall)

function index()
    local page
    page = entry({"admin", "system", "gpioswitch"}, cbi("gpioswitch"), _(translate("GPIO")))
    page.dependent = true
end
