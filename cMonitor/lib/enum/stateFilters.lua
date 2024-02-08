local machineStates = require("cMonitor.lib.enum.machineStates")
local eventSource = require("cMonitor.lib.enum.eventSource")

local stateFilters = {
    [2] = {
        eventSource = eventSource.header,
        text = "all",
        key = "1"
    },
    [3] = {
        eventSource = eventSource.header,
        text = "working",
        key = "2",
        state = machineStates.working,

    },
    [4] = {
        eventSource = eventSource.header,
        text = "not working",
        key = "3",
        state = machineStates.not_working
    },
    [5] = {
        eventSource = eventSource.header,
        text = "fixed",
        key = "4",
        state = machineStates.fixed
    },
    [6] = {
        eventSource = eventSource.header,
        text = "errors",
        key = "5",
        state = machineStates.error
    },
    [28] = {
        eventSource = eventSource.header,
        text = "fix",
        key = "enter"
    },
    [57] = {
        eventSource = eventSource.header,
        text = "exit",
        key = "space"
    }
}
return stateFilters