local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local xdg_config_dir = gears.filesystem.get_xdg_config_home()

-- Define all available toggles for the control center
-----------------------------------------------------------------------------------------------------------------------
local toggles = {}
if _G.is_laptop then
	toggles = {
		"Compositing",
		{
			icon = beautiful.icon.toggles.compositor,
			label = "Compositor",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/picom.sh check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/picom.sh on")
			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/picom.sh off")
			end,
		},
		"---", -- separator
		"Hardware",
		{
			icon = beautiful.icon.toggles.touchpad,
			label = "Touchpad tapping",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/laptop/input.sh tapping-check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/laptop/input.sh tapping-on")
			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/laptop/input.sh tapping-off")
			end,
		},
		{
			icon = beautiful.icon.toggles.audio,
			label = "HDMI Audio",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/laptop/audio.sh hdmi-check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/laptop/audio.sh hdmi-on")
			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/laptop/audio.sh hdmi-off")
			end,
		},
		{
			icon = beautiful.icon.toggles.fan,
			label = "Quiet fan control mode",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/laptop/thermal.sh quiet-check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/laptop/thermal.sh quiet-on")
			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/laptop/thermal.sh quiet-off")
			end,
		},
		{
			icon = beautiful.icon.toggles.system,
			label = "Intel Turbo Boost",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell("intel_pstate_turbo check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell("sudo intel_pstate_turbo on")
			end,
			action_off = function()
				awful.spawn.with_shell("sudo intel_pstate_turbo off")
			end,
		},
		"---", -- separator
		"Connectivity",
		{
			icon = beautiful.icon.toggles.bluetooth,
			label = "Bluetooth",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/rfkill.sh bt-check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/rfkill.sh bt-on")
			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/rfkill.sh bt-off")
			end,
		},
		{
			icon = beautiful.icon.toggles.wifi,
			label = "Wireless LAN",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/rfkill.sh wifi-check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/rfkill.sh wifi-on")
			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/rfkill.sh wifi-off")
			end,
		},
	}
else
	toggles = {
		"Compositing",
		{
			icon = beautiful.icon.toggles.compositor,
			label = "Compositor",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/picom.sh check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/picom.sh on")
			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/picom.sh off")
			end,
		},
		{
			icon = beautiful.icon.toggles.blur,
			label = "Blur effect",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/picom.sh blur-check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/picom.sh blur-on")
			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/picom.sh blur-off")
			end,
		},
		"---", -- separator
		"General",
		{
			icon = beautiful.icon.toggles.redshift,
			label = "Redshift blue light filter",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell("bash -c '(pgrep redshift > /dev/null && echo on) || echo off'", callback)
			end,
			action_on = function()
				awful.spawn.with_shell("redshift &")
			end,
			action_off = function()
				awful.spawn.with_shell("killall redshift")
			end,
		},
		"---", -- separator
		"Hardware",
		{
			icon = beautiful.icon.toggles.loopback,
			label = "PulseAudio input loopback",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/pa-loopback.sh check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/pa-loopback.sh on")

			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/pa-loopback.sh off")
			end,
		},
		{
			icon = beautiful.icon.toggles.audio,
			label = "VFIO audio input",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/pa-loopback.sh input-is-mic", callback)
			end,
			action_on = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/pa-loopback.sh input-use-mic")

			end,
			action_off = function()
				awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "/scripts/pa-loopback.sh input-use-linein")
			end,
		},
		{
			icon = beautiful.icon.toggles.system,
			label = "Intel Turbo Boost",
			check_state = function(callback)
				awful.spawn.easy_async_with_shell("intel_pstate_turbo check", callback)
			end,
			action_on = function()
				awful.spawn.with_shell("sudo intel_pstate_turbo on")
			end,
			action_off = function()
				awful.spawn.with_shell("sudo intel_pstate_turbo off")
			end,
		},
	}
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return toggles
