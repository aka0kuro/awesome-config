-----------------------------------------------------------------------------------------------------------------------
--                                              Autostart app list                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local autostart = {}

-- Application list function
--------------------------------------------------------------------------------
function autostart.run()

	-- gnome environment
	awful.spawn.with_shell("lxsession")
	awful.spawn.with_shell("xautolock -detectsleep -time 3 -locker 'i3lock -c 000000'")
	awful.spawn.with_shell("/usr/bin/nm-applet")
    awful.spawn.with_shell("setxkbmap -layout 'es,us' -option grp:rctrl_rshift_toggle")
	awful.spawn.with_shell("copyq")
end

-- Read and commads from file and spawn them
--------------------------------------------------------------------------------
function autostart.run_from_file(file_)
	local f = io.open(file_)
	for line in f:lines() do
		if line:sub(1, 1) ~= "#" then awful.spawn.with_shell(line) end
	end
	f:close()
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return autostart
