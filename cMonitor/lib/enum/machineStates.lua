local colors = require("cMonitor.lib.enum.colors")
local machineStates = {
    working = {
        code = 1,
        text = "working\t\t",
        color = colors.GREEN
    },
    not_working = {
        code = 2,
        text = "not working\t",
        color = colors.RED
    },
    fixed = {
        code = 3,
        text = "fixed\t\t",
        color = colors.YELLOW
    },
    error = {
        code = 4,
        text = "error\t\t",
        color = colors.RED
    },
    idle = {
        code = 4,
        text = "idle\t\t",
        color = colors.YELLOW
    }
}

return machineStates
