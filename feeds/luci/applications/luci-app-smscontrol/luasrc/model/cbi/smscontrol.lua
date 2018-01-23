local fs  = require "nixio.fs"
local sys = require "luci.sys"

m = Map("smscontrol", "Remote SMS control", translate("For example, if you enter '1234' for the password and send an SMS with the content of '1234;reboot' to the router, the router will reboot."))

n = m:section(NamedSection, "common", "smscontrol")

enabled = n:option(Flag, "enabled", translate("Enabled"), translate(""))
  enabled.rmempty = false

pass = n:option(Value, "pass",  translate("Password"))
  function pass.cfgvalue(self, section)
    value = self.map:get(section, self.option)
    if value == nil then
      local test = io.popen("getserialnum")
      local value = test:read("*a")
      test:close()
      return value
    else
      return value
    end
  end
  pass.rmempty = false
  pass.optional = false
  pass.datatype = "and(uciname,maxlength(15))"

whitelist = n:option(DynamicList, "whitelist",  translate("Allowed numbers"))
  whitelist.datatype = "phonedigit"
  whitelist.cast = "string"
  whitelist.rmempty =true

c = m:section(TypedSection, "call", translate("Command over call"))
c.rmempty = true
c.anonymous = true
c.addremove = false
c.template = "cbi/tblsection"

enabled = c:option(Flag, "enabled", translate("Enable"))
  enabled.rmempty = false

ack = c:option(Flag, "ack", translate("Reply via SMS"))
  ack.rmempty = true

command = c:option(Value, "command", translate("Linux command"))
  command.rmempty =false
  command.optional = false

s = m:section(TypedSection, "remote", translate("Command over SMS"))
s.rmempty = true
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

enabled = s:option(Flag, "enabled", translate("Enable"))
  enabled.rmempty = false

ack = s:option(Flag, "ack", translate("Reply via SMS"))
  ack.rmempty = true

msgtxt = s:option(Value, "received", translate("Message text"))
  msgtxt.rmempty =false
  msgtxt.optional = false

command = s:option(Value, "command", translate("Linux command"))
  command.rmempty =false
  command.optional = false

return m
