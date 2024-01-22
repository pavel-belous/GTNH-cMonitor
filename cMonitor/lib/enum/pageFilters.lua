local eventType = require("lib.enum.eventTypes")

local pageFilters = {
    dysons = {
        [1] = {
            eventType = eventType.dysonPaginator,
            text = "prev",
            key = "q"
        },
        [2] = {
            eventType = eventType.dysonPaginator,
            text = "current",
            key = "w",
        },
        [3] = {
            eventType = eventType.dysonPaginator,
            text = "next",
            key = "e"
        }
    },
    computers = {
        [1] = {
            eventType = eventType.computerPaginator,
            text = "prev",
            key = "a"
        },
        [2] = {
            eventType = eventType.computerPaginator,
            text = "current",
            key = "s",
        },
        [3] = {
            eventType = eventType.computerPaginator,
            text = "next",
            key = "d"
        }
    }

}
return pageFilters
