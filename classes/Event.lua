local event = require("event")
local colors = require("lib.enum.colors")
local Main = require("classes.Main")
local stateFilters = require("lib.enum.stateFilters")

local Event = {}
function Event:new(config_)
    local obj = {}
    obj.config = config_
    obj.program = Main:new(config_)
    -- state variable so the loop can terminate
    obj.running = true
    --screen refresh timer, seconds
    obj.REFRESH_SCREEN_TIMER = 1.5
    --timer id for fixing all machines task
    --machines fix timer, seconds
    obj.FIX_ALL_TIMER = 5
    obj.stateFilter = stateFilters[2]


    --task for updating screen and fixing machines.
    --runs every CONSTANT seconds infinite number of times
    function obj:runBackgroundTasks()
        obj.refreshScreenEventId = event.timer(obj.REFRESH_SCREEN_TIMER, obj.program.refreshScreen, math.huge)
        obj.fixAllEventId = event.timer(obj.FIX_ALL_TIMER, obj.program.fixAllMachinesState, math.huge)
    end

    --destroy corresponding events on program exit
    function obj:destroyEvents()
        event.cancel(obj.refreshScreenEventId)
        event.cancel(obj.fixAllEventId)
    end

    function obj:unknownEvent()
        -- do nothing if the event wasn't relevant
    end

    -- table that holds all event handlers
    -- in case no match can be found returns the dummy function unknownEvent
    obj.eventHandlers = setmetatable({}, { __index = function() return obj.unknownEvent end })

    -- Example key-handler that simply sets running to false if the user hits space
    function obj.eventHandlers:key_up(char, code, playerName)
        print(char, code, playerName)
        if (stateFilters[code]) then
            local stateFilterEvent = stateFilters[code]
            local shouldRefreshState = true
            if stateFilterEvent.text == "fix" then
                obj.program:fixAllMachinesState()
                shouldRefreshState = false
            elseif stateFilterEvent.text == "exit" then
                obj.running = false
                obj:destroyEvents()
            else
                obj.stateFilter = stateFilterEvent
            end

            if shouldRefreshState then
                obj.program:refreshAllMachinesStates()
            end
            obj.program:printMachinesInfo()
        end
    end

    -- The main event handler as function to separate eventID from the remaining arguments
    function obj:handleEvent(eventID, ...)
        if (eventID) then                    -- can be nil if no event was pulled for some time
            self.eventHandlers[eventID](...) -- call the appropriate event handler with all remaining arguments
        end
    end

    function obj:runProgram()
        --main program code
        obj.program:fillTables()
        obj.program:printMachinesInfo()
        obj:runBackgroundTasks()
        -- main event loop which processes all events, or sleeps if there is nothing to do
        while obj.running do
            --printComponentFunctions(computers[1].proxy)
            self:handleEvent(event.pull()) -- sleeps until an event is available, then process it
        end
    end

    setmetatable(obj, self)
    self.__index = self

    return obj
end

return Event
