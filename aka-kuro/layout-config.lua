-----------------------------------------------------------------------------------------------------------------------
--                                                Layouts config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local beautiful = require("beautiful")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local layouts = {}


-- Build  table
-----------------------------------------------------------------------------------------------------------------------
function layouts:init()

	self.float = awful.layout.suit.floating
	self.tile = awful.layout.suit.tile
	self.bottom = awful.layout.suit.tile.bottom
	self.center = awful.layout.suit.magnifier
	self.fair = awful.layout.suit.fair
	self.max = awful.layout.suit.max

	-- layouts list
	local layset = {
		self.float,
		self.tile,
		self.center,
		self.fair,
		self.bottom,
		self.max
	}

	awful.layout.layouts = layset

	-- remove useless_gap for maximized layout to simulate maximized windows
    tag.connect_signal(
        "property::selected", function(t)
        t.gap = t.layout.name == "max" and 0 or beautiful.useless_gap
        end
    )
end


-- End
-----------------------------------------------------------------------------------------------------------------------
return layouts
