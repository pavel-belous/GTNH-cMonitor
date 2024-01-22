DEBUG_ = true
PROGRAM_NAME = "cMonitor"

--Unload all modules which starts with "programName"
--Once loaded, module will stay in lua cache
--and any code changes wont be reflected
--This will be a problem in active development phase.
--So in debug mode we just force to reload all project modules
local function unloadModules(debug, programName)
    if debug then
        for k,_ in pairs(package.loaded) do
            if string.match(k, string.format("^%s", programName)) then
                package.loaded[k] = nil
            end
        end
    end
end

unloadModules(DEBUG_,PROGRAM_NAME)

local Main = require("cMonitor.classes.Main")
local program = Main:new({})

program:run()
