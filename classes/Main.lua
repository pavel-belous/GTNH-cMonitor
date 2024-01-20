local component = require("component")
local colors = require("lib.enum.colors")
local Machine = require("classes.Machine")
local Display = require("classes.Display")

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
        local display = self.display
        display:clear()
        display:printKeysInfo()
        display:printVerticalSeparator()
        print("computers detected: " .. #self.computers)
        print("dysons detected: " .. #self.dysons)
        print("machines fixed: " .. self.machinesFixed)
        display:printVerticalSeparator()
        display:drawText("dysons\n", colors.BLUE)
        display:printVerticalSeparator()
        display:printMachineLines(self.dysons)
        display:printVerticalSeparator()
        display:drawText("computers\n", colors.BLUE)
        display:printVerticalSeparator()
        display:printMachineLines(self.computers)
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
        dysonsFlag = dysonsFlag or false

        if computersFlag then
            obj:refreshMachinesState(self.computers)
        end

        if dysonsFlag then
            obj:refreshMachinesState(self.dysons)
        end
    end

    --try to fix every machine state from array
    function obj:fixMachinesState(machinesArray)
        for _, v in pairs(machinesArray) do
            v:fixState()
        end
    end

    --try to fix every dysons/computers states
    function obj:fixAllMachinesState(computersFlag, dysonsFlag)
        --fix all quantum computers by default
        computersFlag = computersFlag or true
        --do not fix dysons by default
        dysonsFlag = dysonsFlag or false

        if computersFlag then
            self:fixMachinesState(self.computers)
        end

        if dysonsFlag then
            self:fixMachinesState(self.dysons)
        end
    end

    --redraw screen
    function obj:refreshScreen()
        self:refreshAllMachinesStates()
        self:printMachinesInfo()
    end

    setmetatable(obj, self)
    self.__index = self

    return obj
end

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
