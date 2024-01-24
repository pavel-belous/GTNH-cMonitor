local component = require("component")
local colors = require("cMonitor.lib.enum.colors")
local stateFilters = require("cMonitor.lib.enum.stateFilters")
local event = require("event")
local Machine = require("cMonitor.classes.Machine")
local Display = require("cMonitor.classes.Display")

local Main = {}

function Main:new(config_)
    local obj = {}
    obj.config = config_
    --machines arrays
    obj.computers = {}
    obj.dysons = {}
    --machine types to filter out. Only GT controllers
    obj.filterMachines = "gt_machine"
    --quantum computer
    obj.filterComputerName = "multimachine.em.computer"
    --dyson
    obj.filterDysonName = "dysonswarm"
    --machines fixed counter
    obj.machinesFixed = 0
    obj.display = Display:new(config_)
    -- state variable so the loop can terminate
    obj.running = true
    --screen refresh timer, seconds
    obj.REFRESH_SCREEN_TIMER = 1.5
    --timer id for fixing all machines task
    --machines fix timer, seconds
    obj.FIX_ALL_TIMER = 5
    obj.stateFilter = stateFilters[2]
    -- table that holds all event handlers
    -- in case no match can be found returns the dummy function unknownEvent
    obj.eventHandlers = setmetatable({}, { __index = function() return obj.unknownEvent end })


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
        if (stateFilters[code]) then
            local stateFilterEvent = stateFilters[code]
            local shouldRefreshState = true
            if stateFilterEvent.text == "fix" then
                obj:fixAllMachinesState()
                shouldRefreshState = false
            elseif stateFilterEvent.text == "exit" then
                obj.running = false
                obj:destroyEvents()
            else
                obj.stateFilter = stateFilterEvent
            end

            if shouldRefreshState then
                obj:refreshAllMachinesStates()
            end
            obj:printMachinesInfo()
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
        local filter = filter_ or self.filterMachines
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
    function obj:printMachinesInfo()
        local display = obj.display
        display:clear()
        display:printKeysInfo()
        display:printVerticalSeparator()
        print("computers detected: " .. #obj.computers)
        print("dysons detected: " .. #obj.dysons)
        print("machines fixed: " .. obj.machinesFixed)
        display:printVerticalSeparator()
        display:drawText("dysons\n", colors.BLUE)
        display:printVerticalSeparator()
        display:printMachineLines(obj.dysons)
        display:printVerticalSeparator()
        display:drawText("computers\n", colors.BLUE)
        display:printVerticalSeparator()
        display:printMachineLines(obj.computers)
        display:printVerticalSeparator()
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
        obj:printMachinesInfo()
    end

    --main program code
    function obj:run()
        self:fillTables()
        self:printMachinesInfo()
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


return Main
