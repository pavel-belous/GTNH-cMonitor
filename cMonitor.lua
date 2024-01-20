-- local tty = require("tty")
-- local gpu = tty.gpu()

local Event = require("classes.Event")
local event = Event:new({})

event:runProgram()

-- print("test11")

-- local function printComponentFunctions(localComponent)
--     for k, v in pairs(localComponent) do
--         print(k, v)
--     end
-- end

-- local Main = require("classes.Main")
-- local test = Main:printComponentFunctions(gpu)