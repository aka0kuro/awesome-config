-----------------------------------------------------------------------------------------------------------------------
--                                                   Aka-Kuro config                                                    --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
local redflat = require("redflat")
local redflat_extra = require("redflat-extra")
redflat.startup:activate()


-- Compositor
------------------------------------------------------------
local picom_args = _G.is_laptop and "" or ""
awful.spawn.with_shell("killall picom; sleep 0.25; picom" .. picom_args)

-- debug locker
local lock = lock or {}

redflat.startup.locked = lock.autostart
redflat.startup:activate()

-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("aka-kuro.ercheck-config") -- load file with error handling


-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("aka-kuro.env-config") -- load file with environment
env:init({ theme = "aka-kuro" })

-- Screen blanking
local splashscreen = require("redflat-extra.splashscreen")
splashscreen:show()

-- Setup rofi styling
local rofi = require("aka-kuro.rofi-config")
rofi:init({ env = env })
env.rofi = rofi.cmd


-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("aka-kuro.layout-config") -- load file with tile layouts setup
layouts:init()


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("aka-kuro.menu-config") -- load file with menu configuration
mymenu:init({ env = env })


-- Logout screen configuration
-----------------------------------------------------------------------------------------------------------------------
local logout = require("aka-kuro.logout-config")
logout:init()


-- Additional widgets
-----------------------------------------------------------------------------------------------------------------------
local widgets = require("aka-kuro.widgets-config")
local controlcenter = redflat_extra.controlcenter
controlcenter:init()

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()
local startmenu_separator = redflat.gauge.separator.vertical(beautiful.panel.start.separator or {})

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

-- load list of app name aliases from files and set it as part of tasklist theme
tasklist.style = { appnames = require("aka-kuro.alias-config")}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, redflat.widget.tasklist.action.select),
	awful.button({}, 2, redflat.widget.tasklist.action.close),
	awful.button({}, 3, redflat.widget.tasklist.action.menu),
	awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
	awful.button({}, 5, redflat.widget.tasklist.action.switch_prev)
)

-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}
taglist.style = { separator = separator, widget = redflat.gauge.tag.orange.new }
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%d. %b %H:%M" })

redflat.float.calendar:init()
textclock.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.float.calendar:show() end)
)

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({ }, 3, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end)
)

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
)

-- PA volume control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = redflat.widget.pulse(nil, { widget = redflat.gauge.audio.blue.new })

-- activate player widget
redflat.float.player:init({ name = env.player })

volume.buttons = awful.util.table.join(
	awful.button({}, 1, function() volume.widget:change_volume()                end),
	awful.button({}, 3, function() volume.widget:change_volume({ down = true }) end),
	awful.button({}, 2, function() volume.widget:mute()                         end),
	awful.button({}, 9, function() redflat.float.player:show()                  end),
	awful.button({}, 8, function() redflat.float.player:action("PlayPause")     end),
	awful.button({}, 8, function() redflat.float.player:action("Previous")      end),
	awful.button({}, 9, function() redflat.float.player:action("Next")          end)
)

-- System resource monitoring widgets
--------------------------------------------------------------------------------
local sysmon = { widget = {}, buttons = {}, icon = {} }


-- icons
sysmon.icon.network = redflat.util.table.check(beautiful, "icon.widget.wireless")
sysmon.icon.cpuram = redflat.util.table.check(beautiful, "icon.widget.monitor")
sysmon.icon.battery = redflat.util.table.check(beautiful, "icon.widget.battery")

	-- Battery
	sysmon.widget.battery = redflat.widget.sysmon(
		{ func = redflat.system.pformatted.bat(25), arg = "BAT0" },
		{
			timeout = 15,
			widget = redflat.gauge.icon.single,
			monitor = {
				is_vertical = true,
				icon = sysmon.icon.battery,
				color = beautiful.gauge.icon.single.gray.color
			},
		}
	)



-- CPU usage
-- we need to store this callback outside of the widget definition because it
-- internally defines storage tables which need to be persistent across calls
-- which will not work if the '.cpu()' call is inside the 'func' definition of
-- the sysmon widget!
local cpu_func = redflat.system.pformatted.cpu(80)
sysmon.widget.cpu = redflat.widget.sysmon(
	{ func = function()
		local info = cpu_func()
		info.text = info.text .. " CPU"
		return info
	end },
	{ timeout = 2, monitor = { label = "CPU" } }
)

sysmon.buttons.cpu = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("cpu") end),
	awful.button({ }, 3, function() awful.spawn(env.sysmon) end)
)

-- RAM usage
sysmon.widget.ram = redflat.widget.sysmon(
	{ func = function()
		local mem = redflat.system.memory_info()
		local info = redflat.system.pformatted.mem(80)()
		info.text = info.text .. " RAM | " .. mem.swp.usep .. "% SWAP"
		return info
	end },
	{ timeout = 10, monitor = { label = "RAM" } }
)

sysmon.buttons.ram = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("mem") end),
	awful.button({ }, 3, function() awful.spawn(env.sysmon) end)
)




-- Main menu button (start button)
local startmenu = { widget = {}, buttons = {}, deco = {} }
startmenu.widget = redflat.gauge.svgbox(
	beautiful.icon.awesome, nil, beautiful.panel.start.color.icon or beautiful.color.icon
)
startmenu.buttons = awful.util.table.join(
	awful.button({ }, 1, function ()
		local wa = mouse.screen.workarea
		mymenu.mainmenu:toggle({ coords = { x = wa.x, y = wa.y + wa.height } })
	end),
	awful.button({ }, 3, function ()
		local wa = mouse.screen.workarea
		mymenu.sysmenu:toggle({ coords = { x = wa.x, y = wa.y + wa.height } })
	end)
)
if beautiful.start_button_decorator_enabled then
	startmenu.deco = widgets.start_button_decorator()
	startmenu.deco:buttons(startmenu.buttons)
end

-- Keyboard layout indicator
--------------------------------------------------------------------------------
local kbindicator = {}
redflat.widget.keyboard:init({ "Español", "Ingles" })
kbindicator.widget = redflat.widget.keyboard()

kbindicator.buttons = awful.util.table.join(
	awful.button({}, 1, function () redflat.widget.keyboard:toggle_menu() end),
	awful.button({}, 4, function () redflat.widget.keyboard:toggle()      end),
	awful.button({}, 5, function () redflat.widget.keyboard:toggle(true)  end)
)

-- Wallpaper setup
-----------------------------------------------------------------------------------------------------------------------

-- redraw the wallpaper(s) on the root window according to the current layout
local function draw_wallpaper()
	awful.spawn.with_shell("bash ~/.fehbg")
end

-- draw wallpaper initially after startup
draw_wallpaper()

-- redraw wallpaper if screen layout/size changes
screen.connect_signal("property::geometry", function()
	draw_wallpaper()
end)


-- Screen setup
-----------------------------------------------------------------------------------------------------------------------

-- panel setup
local wibar_ontop = true

-- setup
local wibar_bg = beautiful.panel.color.bg or beautiful.color.wibox

awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper (DEPRECATED in favor of nitrogen)
		-- env.wallpaper(s)

		-- tags
		if screen.primary.index == s.index then
			-- PRIMARY SCREEN
			awful.tag({ "Main", "Com", "Code", "Tile", "Free" }, s,
				{
					layouts.float,
					layouts.max,
					layouts.tile,
					layouts.tile,
					layouts.float
				}
			)

			-- layoutbox widget
			layoutbox[s] = redflat.widget.layoutbox({ screen = s })

			-- taglist widget
			taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = widgets.tagtip }, taglist.style)

			-- tasklist widget
			tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons }, tasklist.style)

			-- panel wibox
			s.panel = awful.wibar({
				position = "bottom",
				ontop = wibar_ontop,
				screen = s,
				height = beautiful.panel.height or 36,
				bg = wibar_bg,
			})
			s.panel_border = widgets.panel_border(s)

			-- add widgets to the wibox
			s.panel:setup {
				layout = wibox.layout.align.horizontal,
				{ -- left widgets
					layout = wibox.layout.fixed.horizontal,

					widgets.wrapper(startmenu.widget, "startmenu", startmenu.buttons),
					beautiful.start_button_decorator_enabled and startmenu.deco or startmenu_separator,
					widgets.wrapper(taglist[s], "taglist"),
					separator,
					widgets.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
					separator,
					widgets.wrapper(kbindicator.widget, "keyboard", kbindicator.buttons),
					separator,
				},
				{ -- middle widget
					layout = wibox.layout.align.horizontal,
					expand = "outside",
					nil,
					widgets.wrapper(tasklist[s], "tasklist"),
				},
				{ -- right widgets
					layout = wibox.layout.fixed.horizontal,

					separator,
					widgets.wrapper(volume.widget, "volume", volume.buttons),
					separator,
					widgets.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
					separator,
					widgets.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),
				    separator,
					widgets.wrapper(sysmon.widget.battery, "battery"),
					separator,
					widgets.wrapper(textclock.widget, "textclock", textclock.buttons),
					separator,
				    widgets.wrapper(tray.widget, "tray", tray.buttons),
				},
			}

		end

	end
)



-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
local edges = require("aka-kuro.edges-config") -- load file with edges configuration
edges:init()

-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = require("aka-kuro.keys-config") -- load file with hotkeys configuration
hotkeys:init({ env = env, menu = mymenu.mainmenu, volume = volume.widget })


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("aka-kuro.titlebar-config") -- load file with titlebar configuration
titlebar:init()


-- Rules
-----------------------------------------------------------------------------------------------------------------------
-- NOTE: titlebar:init() needs to precede this, because it might adjust beautiful.border_width!
local rules = require("aka-kuro.rules-config") -- load file with rules configuration
rules:init({ hotkeys = hotkeys})


-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("aka-kuro.signals-config") -- load file with signals configuration
signals:init({ env = env })


-- Battery charge listener
-----------------------------------------------------------------------------------------------------------------------
local signals = require("aka-kuro.battery-config") -- load file with signals configuration
signals:init({ low = 20, high = 100 })


-- Autostart user applications
-----------------------------------------------------------------------------------------------------------------------
if redflat.startup.is_startup then
	local autostart = require("aka-kuro.autostart-config") -- load file with autostart application list
	autostart.run()
end
