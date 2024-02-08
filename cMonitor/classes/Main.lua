local component = require("component")
local colors = require("cMonitor.lib.enum.colors")
local stateFilters = require("cMonitor.lib.enum.stateFilters")
local machineStates = require("cMonitor.lib.enum.machineStates")
local event = require("event")
local eventSource = require("cMonitor.lib.enum.eventSource")
local kb = require("keyboard")
local Machine = require("cMonitor.classes.Machine")
local Display = require("cMonitor.classes.Display")

local Main = {}

function Main:new(config_)
    local obj = {}
    obj.config = config_
    --machines arrays
    obj.computers = {}
    obj.computersFiltered = {}
    obj.dysons = {}
    obj.dysonsFiltered = {}
    --machine types to filter out. Only GT controllers
    obj.filterGTMachines = "gt_machine"
    --quantum computer
    obj.filterComputerName = "multimachine.em.computer"
    --dyson
    obj.filterDysonName = "dysonswarm"
    --machines fixed counter
    obj.machinesFixed = 0
    --display object
    obj.display = Display:new(config_)
    -- state variable so the loop can terminate
    obj.running = true
    --screen refresh timer, seconds
    obj.REFRESH_SCREEN_TIMER = 1.5
    --timer id for fixing all machines task
    --machines fix timer, seconds
    obj.FIX_ALL_TIMER = 5
    --current machine state filter from machineStates enum. nil mean all states
    obj.currentStateFilter = stateFilters[2]
    -- table that holds all event handlers
    -- in case no match can be found returns the dummy function unknownEvent
    obj.eventHandlers = setmetatable({}, { __index = function() return obj.unknownEvent end })
    obj.keyboardEvents = {
        ["1"] = {
            source = eventSource.header,
            text = "all"
        },
        ["2"] = {
            source = eventSource.header,
            text = "working"
        },
        ["3"] = {
            source = eventSource.header,
            text = "not working"
        },
        ["4"] = {
            source = eventSource.header,
            text = "fixed",
            callback = function() end
        },
        ["5"] = {
            source = eventSource.header,
            text = "errors"
        },
        ["enter"] = {
            source = eventSource.header,
            text = "fix"
        },
        ["space"] = {
            source = eventSource.header,
            text = "exit"
        },
        ["q"] = {
            source = eventSource.dysonPaginator,
            text = "next"
        },
        ["e"] = {
            source = eventSource.dysonPaginator,
            text = "prev"
        },
        ["a"] = {
            source = eventSource.computerPaginator,
            text = "next"
        },
        ["d"] = {
            source = eventSource.computerPaginator,
            text = "prev"
        },
    }


    --task for updating screen and fixing machines.
    --runs every CONSTANT seconds infinite number of times
    function obj:runBackgroundTasks()
        obj.refreshScreenEventId = event.timer(obj.REFRESH_SCREEN_TIMER, obj.refreshScreen, math.huge)
        obj.fixAllEventId = event.timer(obj.FIX_ALL_TIMER, obj.fixAllMachinesState, math.huge)
    end

    --destroy corresponding events on program exit
    function obj:destroyEvents()
        event.cancel(obj.refreshScreenEventId)
        event.cancel(obj.fixAllEventId)
    end

    function obj:unknownEvent()
        -- do nothing if the event wasn't relevant
    end


    -- key-handler that simply sets running to false if the user hits space
    function obj.eventHandlers:key_up(char, code, playerName)
        local keyName = kb.keys[code]
        if (obj.keyboardEvents[keyName]) then
            local stateFilterEvent = stateFilters[code]
            local shouldRefreshState = true
            if stateFilterEvent.text == "fix" then
                obj:fixAllMachinesState()
                shouldRefreshState = false
            elseif stateFilterEvent.text == "exit" then
                obj.running = false
                obj:destroyEvents()
            else
                obj.currentStateFilter = stateFilterEvent
            end

            if shouldRefreshState then
                obj:refreshAllMachinesStates()
            end
            obj:printScreen()
        end
    end

    function obj.eventHandlers:interrupted()
        obj:destroyEvents()
    end

    -- The main event handler as function to separate eventID from the remaining arguments
    function obj:handleEvent(eventID, ...)
        if (eventID) then                    -- can be nil if no event was pulled for some time
            self.eventHandlers[eventID](...) -- call the appropriate event handler with all remaining arguments
        end
    end

    --fill computers/dysons tables
    function obj:fillTables(filter_)
        local filter = filter_ or self.filterGTMachines
        for address, _ in component.list(filter) do
            local machineProxy = component.proxy(address)
            local machine = Machine:new(machineProxy)
            --there is two machine types: quantum computer or dyson
            if machineProxy.getName() == self.filterComputerName then
                table.insert(self.computers, machine)
            else
                table.insert(self.dysons, machine)
            end
        end
    end


    --draw all information on the screen
    function obj:printScreen()
        local display = obj.display
        display:clear()
        display:printKeysInfo(obj.currentStateFilter and obj.currentStateFilter.key or nil)
        display:printHorizontalSeparator()
        print("computers detected: " .. #obj.computers)
        print("dysons detected: " .. #obj.dysons)
        print("machines fixed: " .. obj.machinesFixed)
        -- display:printHorizontalSeparator()
        -- display:drawText("dysons\n", colors.BLUE)
        -- display:printHorizontalSeparator()
        -- display:printMachineLines(obj.dysons)
        -- display:printHorizontalSeparator()
        -- display:drawText("computers\n", colors.BLUE)
        -- display:printHorizontalSeparator()
        -- display:printMachineLines(obj.computers)
        -- display:printHorizontalSeparator()
    end

    --refresh every machine state from array
    function obj:refreshMachinesState(machinesArray)
        for _, v in pairs(machinesArray) do
            v:setMachineState()
        end
    end

    --refresh every dysons/computers state
    function obj:refreshAllMachinesStates(computersFlag, dysonsFlag)
        computersFlag = computersFlag or true
        dysonsFlag = dysonsFlag or true

        if computersFlag then
            obj:refreshMachinesState(obj.computers)
        end

        if dysonsFlag then
            obj:refreshMachinesState(obj.dysons)
        end
    end

    --try to fix every machine state from array
    function obj:fixMachinesState(machinesArray)
        for _, v in pairs(machinesArray) do
            if v:fixState() then
                obj.machinesFixed = obj.machinesFixed + 1
            end
        end
    end

    --try to fix every dysons/computers states
    function obj:fixAllMachinesState(computersFlag, dysonsFlag)
        --fix all quantum computers by default
        computersFlag = computersFlag or true
        --do not fix dysons by default
        dysonsFlag = dysonsFlag or false

        if computersFlag then
            obj:fixMachinesState(obj.computers)
        end

        if dysonsFlag then
            obj:fixMachinesState(obj.dysons)
        end
    end

    --redraw screen
    function obj:refreshScreen()
        obj:refreshAllMachinesStates()
        obj:filterAllMachines(obj.currentStateFilter)
        obj:printScreen()
    end

    --filters machines (both dysons and computers) based on current machine state filter
    function obj:filterAllMachines(state)
        if state then
            obj.computersFiltered = obj:filterMachinesByState(obj.computers, state)
            obj.dysonsFiltered = obj:filterMachinesByState(obj.dyson, state)
        else
            obj.computersFiltered = obj.computers
            obj.dysonsFiltered = obj.dysons
        end
    end

    --filter machine list by filter
    function obj:filterMachinesByState(machines, state)
        local result = {}
        if type(machines) == "table" and #machines > 0 and state then
            for k, v in ipairs(machines) do
                if v:getState() == state then
                    table.insert(result, v)
                end
            end
        end
        return result
    end

    --main program code
    function obj:run()
        self:fillTables()
        self:refreshScreen()
        self:runBackgroundTasks()
        -- main event loop which processes all events, or sleeps if there is nothing to do
        while self.running do
            --printComponentFunctions(computers[1].proxy)
            self:handleEvent(event.pull()) -- sleeps until an event is available, then process it
        end
    end

    setmetatable(obj, self)
    self.__index = self

    return obj
end

--static members
--show available componetns, using filter
function Main:printComponents(filter)
    for k, v in component.list(filter) do
        print(k, v)
    end
end

--expose availvable component functions
function Main:printComponentFunctions(localComponent)
    for k, v in pairs(localComponent) do
        print(k, v)
    end
end

--dumps table into string
function Main:dumpTable(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. Main:dumpTable(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

return Main
