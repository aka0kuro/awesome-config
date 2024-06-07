-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local tonumber = tonumber
local string = string
local math = math

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local system = { pformatted = {} }

-- Thermals formatted special for panel widget
--------------------------------------------------------------------------------
function system.pformatted.sensors(crit, max)
	crit = crit or 90
	max  = max or 100

	local function query()
		local sensor = "'Package id 0'"
		local output = redutil.read.output("sensors | grep " .. sensor)
		local temp = string.match(output, "%+(%d+%.%d)°[CF]")
		return temp and math.floor(tonumber(temp)) or 0
	end

	return function()
		local usage = query()
		return {
			value = usage / max,
			text  = usage .. "°",
			alert = usage > crit
		}
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return system