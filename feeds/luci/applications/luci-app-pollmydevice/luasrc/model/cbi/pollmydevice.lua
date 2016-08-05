--
--

require 'luci.sys'

arg[1] = arg[1] or ""

m = Map("pollmydevice", translate("PollMyDevice"), translate("TCP to RS232/RS485 converter"))

s = m:section(NamedSection, arg[1], "pollmydevice", translate("Utility Settings"))
s.addremove = false

teleofisid = s:option(DummyValue, "teleofisid",  translate("Teleofis ID"))

mode = s:option(ListValue, "mode", translate("Mode"))
  mode.default = "disabled"
  mode:value("disabled")
  mode:value("server")
  mode:value("client")
  mode.optional = false

baudrate = s:option(Value, "baudrate",  translate("BaudRate"))
  baudrate.default = 9600
  baudrate.datatype = "uinteger"
  baudrate.rmempty = false
  baudrate.optional = false

bytesize = s:option(ListValue, "bytesize", translate("ByteSize"))
  bytesize.default = 8
  bytesize:value(5)
  bytesize:value(6)
  bytesize:value(7)
  bytesize:value(8)
  bytesize.optional = false
  bytesize.datatype = "uinteger"

parity = s:option(ListValue, "parity", translate("Parity"))
  parity.default = "none"
  parity:value("even")
  parity:value("odd")
  parity:value("none")
  parity.optional = false
  parity.datatype = "string"

stopbits = s:option(ListValue, "stopbits", translate("StopBits"))
  stopbits.default = 1
  stopbits:value(1)
  stopbits:value(2)
  stopbits.optional = false
  stopbits.datatype = "uinteger"

server_port = s:option(Value, "server_port",  translate("Server Port"))
  server_port.default = 33333
  server_port.datatype = "and(uinteger, min(1025), max(65535))"
  server_port.rmempty = false
  server_port.optional = false

conn_time = s:option(Value, "conn_time",  translate("Connection Hold Time"))
  conn_time.default = 60
  conn_time.datatype = "and(uinteger, min(0), max(100000))"
  conn_time.rmempty = false
  conn_time.optional = false

client_host = s:option(Value, "client_host",  translate("Client Host or IP Address"))
  client_host.datatype = "string"

client_port = s:option(Value, "client_port",  translate("Client Port"))
  client_port.default = 6008
  client_port.datatype = "and(uinteger, min(1025), max(65535))"
  client_port.rmempty = false
  client_port.optional = false

client_timeout = s:option(Value, "client_timeout",  translate("Client Reconnection Timeout"))
  client_timeout.default = 60
  client_timeout.datatype = "and(uinteger, min(0), max(100000))"
  client_timeout.rmempty = false
  client_timeout.optional = false

client_auth = s:option(Flag, "client_auth", translate("Client Authentification"), translate("Use Teleofis Authentification"))  -- create enable checkbox
  client_auth.rmempty = false

return m
