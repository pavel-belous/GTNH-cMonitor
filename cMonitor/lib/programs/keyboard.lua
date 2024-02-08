
local event = require("event")
local kb = require("keyboard")
local running = true

local eventHandlers = setmetatable({}, { __index = function() return function() end end })

-- The main event handler as function to separate eventID from the remaining arguments
local function handleEvent(eventID, ...)
    if (eventID) then                    -- can be nil if no event was pulled for some time
        eventHandlers[eventID](...) -- call the appropriate event handler with all remaining arguments
    end
end

function eventHandlers:key_up(char, code, playerName)
    print(
        string.format("char:%s\t\t\tcode:%s\t\t\tplayer:%s\t\t\tkey:%s",
        char, code, playerName, kb.keys[code])
    )
    if kb.keys[code] == "space" then
        running = false
    end

end

local test = {
    ["1"] = "test"
}

print(test["1"])

print("press space to exit")
while running do
    handleEvent(event.pull()) -- sleeps until an event is available, then process it
end
