local eventSource = require("cMonitor.lib.enum.eventSource")

local pageFilters = {
    dysons = {
        [1] = {
            eventSource = eventSource.dysonPaginator,
            text = "prev",
            key = "q"
        },
        [2] = {
            eventSource = eventSource.dysonPaginator,
            text = "current",
            key = "w",
        },
        [3] = {
            eventSource = eventSource.dysonPaginator,
            text = "next",
            key = "e"
        }
    },
    computers = {
        [1] = {
            eventSource = eventSource.computerPaginator,
            text = "prev",
            key = "a"
        },
        [2] = {
            eventSource = eventSource.computerPaginator,
            text = "current",
            key = "s",
        },
        [3] = {
            eventSource = eventSource.computerPaginator,
            text = "next",
            key = "d"
        }
    }

}
return pageFilters
