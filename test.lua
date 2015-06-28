-- Copyright (c) 2012 dodo <dodo.the.last@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

print"require"
local udev = require 'udev'
local socket = require 'socket'
print"start"

local ud = udev() print("ud", ud, ud and ud._native)

local enum = udev.enumerate(ud)
assert(enum:match_subsystem("power_supply"))
enum:match_property("power_supply_name", "AC")
print"scan subsystems"
assert(enum:scan_subsystems()) for k,v in pairs(enum:getlist()) do print(k,v) end
print"scan devices"
assert(enum:scan_devices())    for k,v in pairs(enum:getlist()) do print(k,v) end
enum:close()

local mon = udev.monitor(ud, "udev") print("monitor", mon, mon and mon._native, mon:getfd())

    print("add subsystem devtype", mon:filter_subsystem_devtype())

print("start monitor", mon:start())



while true do
    if #socket.select({mon}, nil, nil) > 0 then
        local device = mon:receive()
        print("["..tostring(device:getseqnum()).."] "..device:getaction().." device", device:getsyspath())
        print("properties:")
        for k,v in pairs(device:getproperties()) do
            print("", k, v)
        end
        print("sysattrs:")
        for k,v in pairs(device:getsysattrs()) do
            print("", k, v)
        end
        device:close()
    end
end

mon:close()
ud:close()

print"done."
