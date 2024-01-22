-- local tty = require("tty")
-- local gpu = tty.gpu()

local Main = require("cMonitor.classes.Main")
local program = Main:new({})

program:run()

-- print("test11")

-- local function printComponentFunctions(localComponent)
--     for k, v in pairs(localComponent) do
--         print(k, v)
--     end
-- end

-- local Main = require("classes.Main")
-- local test = Main:printComponentFunctions(gpu)