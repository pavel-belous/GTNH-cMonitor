local Placeholder = {}
function Placeholder:new(config_)
    local obj = {}
    obj.config = config_

    setmetatable(obj, self)
    self.__index = self

    return obj
end

return Placeholder
