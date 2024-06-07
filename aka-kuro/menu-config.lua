-----------------------------------------------------------------------------------------------------------------------
--                                                  Menu config                                                      --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
local redflat = require("redflat")
local awful = require("awful")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local menu = {}

-- Build function
-----------------------------------------------------------------------------------------------------------------------
function menu:init(args)

	-- vars
	local args = args or {}
	local env = args.env or {} -- fix this?
	local separator = args.separator or { widget = redflat.gauge.separator.horizontal() }
	local theme = args.theme or { auto_hotkey = true }

	-- theme vars
	local deficon = redflat.util.base.placeholder()
	local icon = redflat.util.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or deficon
	local color = redflat.util.table.check(beautiful, "color.icon") and beautiful.color.icon or nil

	local appmenu = redflat.service.dfparser.menu({ icons = icon_style, wm_name = "awesome" })


	-- Places submenu
	------------------------------------------------------------
	local placesmenu = {
		{ "Downloads", "bash -c '" .. env.fm .. " `xdg-user-dir DOWNLOAD`'",  icon = beautiful.icon.downloads},
		{ "Music",     "bash -c '" .. env.fm .. " `xdg-user-dir MUSIC`'",     icon = beautiful.icon.music},
		{ "Pictures",  "bash -c '" .. env.fm .. " `xdg-user-dir PICTURES`'",  icon = beautiful.icon.pictures},
		{ "Documents", "bash -c '" .. env.fm .. " `xdg-user-dir DOCUMENTS`'", icon = beautiful.icon.documents},
		{ "Videos",    "bash -c '" .. env.fm .. " `xdg-user-dir VIDEOS`'",    icon = beautiful.icon.videos},
	}

	-- Main menu
	------------------------------------------------------------
	local logout = function() redflat.service.logout:show() end
	self.mainmenu = redflat.menu({ theme = theme,
		items = {
			{ "Aplicaciones",  		appmenu,      			icon = beautiful.icon.files },
			{ "Places",            	placesmenu,             icon = beautiful.icon.places,    key = "c" },
			separator,
			{ "Terminal",          	"terminator",           icon = beautiful.icon.terminal },
			{ "Geany",           	"geany",              	icon = beautiful.icon.editor },
			{ "Archivos",           "nemo",                 icon = beautiful.icon.files },
			{ "Librewolf",          "librewolf",            icon = beautiful.icon.navi},

			separator,
			{ "Task Manager",      	"terminator -e btop",   icon = beautiful.icon.sysmon },
			separator,
			{ "Reiniciar WM", 		awesome.restart,  		icon = beautiful.icon.awesome},
			{ "Leave Session ...", 	logout,                 icon = beautiful.icon.logout },
		}
	})

	self.sysmenu = redflat.menu({ theme = theme,
		items = {
			{ "Awesome",       awesomemenu, icon = beautiful.icon.awesome },
		}
	})

	-- Menu panel widget
	------------------------------------------------------------

	self.widget = redflat.gauge.svgbox(icon, nil, color)
	self.buttons = awful.util.table.join(
		awful.button({ }, 1, function () self.mainmenu:toggle() end)
	)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return menu
