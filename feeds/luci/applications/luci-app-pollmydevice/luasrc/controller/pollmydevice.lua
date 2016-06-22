
module("luci.controller.pollmydevice", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/pollmydevice") then
		return
	end

	local page

	page = entry({"admin", "services", "pollmydevice"}, cbi("pollmydevice"), _(translate("PollMyDevice")))
	page.dependent = true
end
