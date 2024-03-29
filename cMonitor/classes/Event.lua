local colors = require("cMonitor.lib.enum.colors")
local Main = require("cMonitor.classes.Main")

local Event = {}
function Event:new(config_)
    local obj = {}
    obj.config = config_
    obj.program = Main:new(config_)
    setmetatable(obj, self)
    self.__index = self

    return obj
end

return Event
