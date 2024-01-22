local machineStates = require("lib.enum.machineStates")
local eventType = require("lib.enum.eventTypes")

local stateFilters = {
    [2] = {
        eventType = eventType.header,
        text = "all",
        key = "1"
    },
    [3] = {
        eventType = eventType.header,
        text = "working",
        key = "2",
        state = machineStates.working,

    },
    [4] = {
        eventType = eventType.header,
        text = "not working",
        key = "3",
        state = machineStates.not_working
    },
    [5] = {
        eventType = eventType.header,
        text = "fixed",
        key = "4",
        state = machineStates.fixed
    },
    [6] = {
        eventType = eventType.header,
        text = "errors",
        key = "5",
        state = machineStates.error
    },
    [28] = {
        eventType = eventType.header,
        text = "fix",
        key = "enter"
    },
    [57] = {
        eventType = eventType.header,
        text = "exit",
        key = "space"
    }
}
return stateFilters