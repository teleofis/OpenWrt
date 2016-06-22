--
--

require 'luci.sys'


function split(text, delim)
    -- returns an array of fields based on text and delimiter (one character only)
    local result = {}
    local magic = "().%+-*?[]^$"

    if delim == nil then
        delim = "%s"
    elseif string.find(delim, magic, 1, true) then
        -- escape magic
        delim = "%"..delim
    end

    local pattern = "[^"..delim.."]+"
    for w in string.gmatch(text, pattern) do
        table.insert(result, w)
    end
    return result
end

m = Map("pollmydevice", translate("PollMyDevice"), translate("TCP to RS232/RS485 converter"))

s = m:section(TypedSection, "pollmydevice", translate("Utility Settings"))
s.anonymous = true

s:tab("rs485", translate("RS485"))
s:tab("rs232", translate("RS232"))

--- RS485 settings ---

mode = s:taboption("rs485", ListValue, "mode", translate("Mode"))
  mode.default = "0"
  mode:value("0", "disabled")
  mode:value("1", "server")
  mode:value("2", "client")
  mode.optional = false

baudrate = s:taboption("rs485", Value, "baudrate",  translate("BaudRate"))
  baudrate.default = 9600
  baudrate.datatype = "and(uinteger)"
  baudrate.rmempty = false
  baudrate.optional = false

bytesize = s:taboption("rs485", ListValue, "bytesize", translate("ByteSize"))
  bytesize.default = "3"
  bytesize:value("0", "5")
  bytesize:value("1", "6")
  bytesize:value("2", "7")
  bytesize:value("3", "8")
  bytesize.optional = false
  bytesize.datatype = "uinteger"

parity = s:taboption("rs485", ListValue, "parity", translate("Parity"))
  parity.default = "0"
  parity:value("0", "even")
  parity:value("1", "odd")
  parity:value("2", "none")
  parity.optional = false
  parity.datatype = "uinteger"

stopbits = s:taboption("rs485", ListValue, "stopbits", translate("StopBits"))
  stopbits.default = "0"
  stopbits:value("0", "1")
  stopbits:value("1", "1.5")
  stopbits:value("2", "2")
  stopbits.optional = false
  stopbits.datatype = "number"


client_auth = s:taboption("rs485", Flag, "client_auth", translate("Authentification"), translate("Use Teleofis Client Authentification"))  -- create enable checkbox
  client_auth.rmempty = false

server_port = s:taboption("rs485", Value, "server_port",  translate("Server Port"))
  server_port.default = 33333
  server_port.datatype = "and(uinteger, min(1025), max(65535))"
  server_port.rmempty = false
  server_port.optional = false

client_host = s:taboption("rs485", Value, "client_host",  translate("Client Host or IP Address"))
  client_host.datatype = "string"

client_port = s:taboption("rs485", Value, "client_port",  translate("Client Port"))
  client_port.default = 6008
  client_port.datatype = "and(uinteger, min(1025), max(65535))"
  client_port.rmempty = false
  client_port.optional = false

client_auth = s:taboption("rs485", Flag, "client_auth", translate("Authentification"), translate("Use Teleofis Client Authentification"))  -- create enable checkbox
  client_auth.rmempty = false





--- RS232 settings ---

mode = s:taboption("rs232", ListValue, "mode", translate("Mode"))
  mode.default = "0"
  mode:value("0", "disabled")
  mode:value("1", "server")
  mode:value("2", "client")
  mode.optional = false

server_port = s:taboption("rs232", Value, "server_port",  translate("Server Port"))
  server_port.default = 33333
  server_port.datatype = "and(uinteger, min(1025), max(65535))"
  server_port.rmempty = false
  server_port.optional = false

client_host = s:taboption("rs232", Value, "client_host",  translate("Client Host or IP Address"))
  client_host.datatype = "string"

client_port = s:taboption("rs232", Value, "client_port",  translate("Client Port"))
  client_port.default = 6008
  client_port.datatype = "and(uinteger, min(1025), max(65535))"
  client_port.rmempty = false
  client_port.optional = false

client_auth = s:taboption("rs232", Flag, "client_auth", translate("Authentification"), translate("Use Teleofis Client Authentification"))  -- create enable checkbox
  client_auth.rmempty = false


function m.on_commit(self)
  -- Modified configurations got committed and the CBI is about to restart associated services
end

function m.on_init(self)
  -- The CBI is about to render the Map object
end

return m
