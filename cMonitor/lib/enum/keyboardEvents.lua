local eventSource = require("cMonitor.lib.enum.eventSource")
local keyboardEvents = {
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
return keyboardEvents