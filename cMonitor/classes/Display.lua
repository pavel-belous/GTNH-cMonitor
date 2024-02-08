local tty = require("tty")
local term = require("term")
local colors = require("cMonitor.lib.enum.colors")

local Display = {}
function Display:new(config_, stateFilter)
    local obj = {}
    obj.config = config_
    obj.gpu = tty.gpu()
    obj.noop = function(...) return ...; end
    obj.setc = obj.gpu.setForeground or obj.noop
    obj.getc = obj.gpu.getForeground or obj.noop
    obj.colors = colors
    obj.stateFilter = stateFilter or {}
    obj.stateFilters = require("cMonitor.lib.enum.stateFilters") or {}

    --write colored text into stdout, restore previous color
    ---@param part string text to display
    ---@param color? integer one of the lib.enum.colors or null
    function obj:drawText(part, color)
        local prev_color = color and obj:getc()
        if color then obj.setc(color) end
        io.write(part)
        if color then obj.setc(prev_color) end
    end


    --display machines data
    function obj:printMachineLines(machinesArray)
        --header
        obj:drawText("coords\t\t\t", obj.colors.YELLOW)
        obj:drawText("status\t\t", obj.colors.YELLOW)
        obj:drawText("progress\n", obj.colors.YELLOW)
        local machinesPrinted = 0
        for _, v in pairs(machinesArray) do
            local shouldPrint = true

            if obj.stateFilter.state and v:getState().code ~= obj.stateFilter.state.code then
                shouldPrint = false
            end

            if shouldPrint then
                machinesPrinted = machinesPrinted + 1
                obj:drawText(v:getCoordinatesString() .. "\t")
                obj:drawText(v:getStateText(), v:getStateColor())
                obj:drawText(v:getWorkProgressString() .. "\n")
            end
        end

        if machinesPrinted == 0 then
            obj:printHorizontalSeparator()
            obj:drawText("there is no machines with state ", obj.colors.YELLOW)
            obj:drawText(string.format("%s\n", stateFilter.state.text), obj.colors.GREEN)
        end
    end

    --display keys info on top of the screen
    function obj:printKeysInfo(currentKey)
        obj:printHorizontalSeparator()
        for k, v in pairs(obj.stateFilters) do
            if currentKey == v.key then
                obj:drawText(string.format("%s:%s", v.key, v.text), obj.colors.GREEN)
                obj:drawText("|")
            else
                obj:drawText(string.format("%s:%s|", v.key, v.text))
            end
        end
        obj:drawText("\n")
    end

    --self-explaining
    function obj:setStateFilter(newStateFilter)
        obj.stateFilter = newStateFilter
    end

    --self-explaining
    function obj:printHorizontalSeparator()
        print("--------------------------------------------------------------------")
    end


    function obj:clear()
        term.clear()
    end

    setmetatable(obj, self)
    self.__index = self

    return obj
end

return Display
