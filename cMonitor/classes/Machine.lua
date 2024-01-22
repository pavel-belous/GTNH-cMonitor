local machineStates = require("lib.enum.machineStates")
local Machine = {}
function Machine:new(proxy_, shouldFix)

	shouldFix = shouldFix or false
    local obj = {}
        obj.proxy = proxy_
        obj.state = machineStates.idle
		obj.x, obj.y, obj.z = proxy_.getCoordinates()
		obj.workProgress = proxy_.getWorkProgress()
		obj.workMaxProgress = proxy_.getWorkMaxProgress()


	function obj:refreshProgress()
		obj.workProgress = obj.proxy.getWorkProgress()
		obj.workMaxProgress = obj.proxy.getWorkMaxProgress()
	end


	--get work progress string
	function obj:getWorkProgressString()
		obj:refreshProgress()
		return string.format("%d/%d", obj.workProgress, obj.workMaxProgress)
	end

	--get machine coordinates string
	function obj:getCoordinatesString()
		return string.format("x:%d y:%d z:%d", obj.x, obj.y, obj.z)
	end

	--get machine state text
	function obj:getStateText()
		return obj.state.text
	end

	--get machine state color
	function obj:getStateColor()
		return  obj.state.color
	end

	--set machine state
	function obj:setMachineState()
		obj.state = obj.proxy.isMachineActive() and machineStates.working or machineStates.not_working
	end

	--get machine state
	function obj:getState()
		return obj.state
	end

	--try to fix not working machine
	function obj:fixState()
		local result = false
		obj:setMachineState()
		if obj.state == machineStates.not_working then
			obj.proxy.setWorkAllowed(true)
			if obj.proxy.isWorkAllowed() then
				obj.state = machineStates.fixed
				result = true
			else
				obj.state = machineStates.error
			end
		end
		return result
	end

    setmetatable(obj, self)
    self.__index = self

	if shouldFix then
		obj:fixState()
	end

	return obj
end

return Machine