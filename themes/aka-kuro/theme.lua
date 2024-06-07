-----------------------------------------------------------------------------------------------------------------------
--                                                  Aka-Kuro theme                                                      --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local gears = require("gears")
local redutil = require("redflat.util")
local helpers = require("redflat-extra.helpers")

local theme = {}

-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color = {
    main      = "#FF4D4D",
    gray      = "#777777",  -- used for inactive elements and bar trunks
    bg        = "#333438",  -- bg used for custom widgets (e.g. appswitcher, top)
    bg_second = "#3C3E42",  -- alternating lines for 'bg'
    wibox     = "#252629",  -- border, panel and general background color
    icon      = "#EEEEEE",  -- icons in menus
    text      = "#EEEEEE",  -- text in menus and titlebars
    urgent    = "#FF4070",  -- urgent window highlight in taglist, tasklist also volume mute
    highlight = "#252629",  -- text when highlighted in menu
    empty     = "#FFFFFF66",  -- circle tag empty color

    border    = "#454545",  -- tooltip border
    shadow1   = "#FFFFFF19",  -- separator dark side
    shadow2   = "#FFFFFF19",  -- separator bright side
    shadow3   = "#808080",  -- buttons outer border
    shadow4   = "#626A6B",  -- buttons inner border

    secondary = "#A8ABB3",
    title_off = "#B3B3B3",   -- unfocused titlebar color
    border_normal = "#999999",
    border_focus  = "#70A800",
    panel_border = "#454545",

    window_base_active   = "#F7F7F7",
    window_base_inactive = "#F7F7F7",
    window_accent_inactive = "#DBDBDB",
    window_title_active = "#333333",
    window_title_inactive = "#AAAAAA",
}

-- bg used for custom widgets (e.g. appswitcher, top)
theme.color.bg        = helpers.scale_hex_color(theme.color.wibox, 1.25 )
-- alternating lines for 'bg'
theme.color.bg_second = helpers.scale_hex_color(theme.color.wibox, 1.5 )

-- buttons outer border (for top etc.)
theme.color.shadow3 = helpers.scale_hex_color(theme.color.wibox, 1.5 )
-- buttons inner border (for top etc.)
theme.color.shadow4 = "transparent"

-- theme.wallpaper = theme.path .. "/wallpaper/custom.png"

-- Color variations

-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/aka-kuro"
theme.homedir = os.getenv("HOME")

-- Main config
------------------------------------------------------------
theme.transparency_enabled = false  -- global transparency effect toggle
theme.enable_start_decor   = false  -- use start button decorator?
theme.panel_height         = 38
theme.border_width_tip     = 1   -- tooltip border width
theme.border_width_tasktip = 2   -- taskbar popup border width
theme.border_width_rofi    = 1   -- Rofi border width
theme.border_width_float   = 1   -- float border width
theme.border_width_panel   = 3   -- panel border width
theme.border_radius        = 3   -- widget corner radius
theme.useless_gap          = 3   -- useless gap

-- theme details (such as colors, sizes and shapes) are configured for each
-- titlebar theme in theme.titlebars.* definitions further down in this file
theme.titlebar_theme = "breeze" -- any of redflat-extra/titlebar-*.lua

-- Transparency config
------------------------------------------------------------
theme.transparency_rofi  = "" -- will be set below if transparency enabled
-- copy the base color scheme to color_t which will contain transparency
-- effects if transparency is enabled and be passed to widgets that should
-- receive transparency
theme.color_t = {}
for k, v in pairs(theme.color) do
	theme.color_t[k] = v
	theme.color_t[k] = v
end
if theme.transparency_enabled then
	theme.color_t.wibox = "#2D2D2D" .. "D0"
	theme.color_t.bg = "#00000025"
	theme.color_t.bg_second = "#FFFFFF05"
	theme.transparency_rofi  = "EE" -- the 'AA' modifiers of the '#AARRGGBB' color format of rofi
end

-- Fonts
------------------------------------------------------------
theme.fonts = {
	main     = "RobotoCondensed 13",         -- main font
	menu     = "RobotoCondensed 13",         -- main menu font
	rofi     = "Iosevka Curly Medium 14",    -- rofi launcher font
	tooltip  = "RobotoCondensed 13",         -- tooltip font
	notify   = "RobotoCondensed medium 15",  -- redflat notify popup font
	clock    = "RobotoCondensed medium 14",  -- textclock widget font
	keychain = "RobotoCondensed medium 16",  -- key sequence tip font
	mtitle   = "RobotoCondensed medium 14",  -- menu titles font
	title    = "RobotoCondensed medium 13",  -- widget titles font
	titlebar = "Play semibold 10",           -- client titlebar font
	control  = "RobotoCondensed bold 15",    -- floating control label font
	splash   = "Play semibold 32",           -- splashcreen message font
	hotkeys  = {
		main  = "RobotoCondensed 13",        -- hotkeys helper main font
		key   = "Iosevka SS14 Semibold 13",  -- hotkeys helper key font (use monospace for align)
		title = "RobotoCondensed medium 14", -- hotkeys helper group title font
	},
	player   = {
		main = "RobotoCondensed medium 15", -- player widget main font
		sub = "RobotoCondensed medium 13",  -- player widget sub font
		time = "RobotoCondensed medium 15", -- player widget current time font
	},
	calendar = {
		clock       = "RobotoCondensed 28",
		date        = "RobotoCondensed 14",
		days        = "RobotoCondensed 13",
		today       = "RobotoCondensed medium 13",
		label       = "RobotoCondensed medium 13",
		header      = "RobotoCondensed 12",
		weeknumbers = "RobotoCondensed 12",
	},
	logout = {
		label   = "RobotoCondensed medium 14", -- entry labels
		counter = "RobotoCondensed 24",        -- countdown message
	},
}

theme.cairo_fonts = {
	tag         = { font = "Roboto", size = 16, face = 1 }, -- tag and tasklist widget font
	monitor     = { font = "Play",   size = 16, face = 1 }, -- system monitoring widget font
	navigator   = {
		title = { font = "RobotoCondensed", size = 28, face = 1, slant = 0 }, -- window navigation title font
		main  = { font = "RobotoCondensed", size = 22, face = 1, slant = 0 }  -- window navigation  main font
	},
}

-- Utility functions
------------------------------------------------------------
local function scale_hex_color (hex, scale)
	hex = hex:gsub("#", "")
	local r, g, b = tonumber("0x"..hex:sub(1,2)),
	                tonumber("0x"..hex:sub(3,4)),
	                tonumber("0x"..hex:sub(5,6))
	r, g, b = math.min(math.max(r*scale, 0), 255),
	          math.min(math.max(g*scale, 0), 255),
	          math.min(math.max(b*scale, 0), 255)
	return "#" .. string.format('%02x', math.floor(r)) ..
	              string.format('%02x', math.floor(g)) ..
	              string.format('%02x', math.floor(b))
end

local widget_shape = function(cr, width, height)
	if theme.border_radius < 1 then
		gears.shape.rectangle(cr, width, height)
	else
		gears.shape.rounded_rect(cr, width, height, theme.border_radius)
	end
end

-- Shared icons
--------------------------------------------------------------------------------
theme.icon = {
	check      = theme.path .. "/icons/check.svg",
	blank      = theme.path .. "/icons/blank.svg",
	warning    = theme.path .. "/icons/warning.svg",
	awesome    = theme.path .. "/icons/awesome.svg",
	places     = theme.path .. "/icons/symbolic/files.svg",
	files      = theme.path .. "/icons/symbolic/docs.svg",
	music      = theme.path .. "/icons/symbolic/music.svg",
	logout     = theme.path .. "/icons/symbolic/logout.svg",
	editor     = theme.path .. "/icons/symbolic/editor.svg",
	terminal   = theme.path .. "/icons/symbolic/terminal.svg",
	sysmon     = theme.path .. "/icons/symbolic/sysmon.svg",
	calculator = theme.path .. "/icons/symbolic/calculator.svg",
	documents  = theme.path .. "/icons/symbolic/file.svg",
	downloads  = theme.path .. "/icons/symbolic/download.svg",
	pictures   = theme.path .. "/icons/symbolic/photos.svg",
	videos     = theme.path .. "/icons/symbolic/video.svg",
}

-- Widget icons
--------------------------------------------------------------------------------
theme.icon.widget = {
	controls = theme.path .. "/widget/control-center.svg",
	battery  = theme.path .. "/widget/battery.svg",
	wireless = theme.path .. "/widget/wireless.svg",
	monitor  = theme.path .. "/widget/monitor.svg",
	sensor   = theme.path .. "/widget/sensor.svg"
}

-- Logout screen icons
--------------------------------------------------------------------------------
theme.icon.logout_screen = {
	poweroff = theme.path .. "/icons/logout/power.svg",
	reboot   = theme.path .. "/icons/logout/restart.svg",
	suspend  = theme.path .. "/icons/logout/sleep.svg",
	lock     = theme.path .. "/icons/logout/lock.svg",
	logout   = theme.path .. "/icons/logout/logout.svg",
}

theme.icon.toggles = {
	loopback   = theme.path .. "/icons/symbolic/pulseaudio.svg",
	fan        = theme.path .. "/icons/symbolic/fan.svg",
	touchpad   = theme.path .. "/icons/symbolic/cursor.svg",
	audio      = theme.path .. "/icons/symbolic/pci.svg",
	redshift   = theme.path .. "/icons/symbolic/nightlight.svg",
	blur       = theme.path .. "/icons/symbolic/blur.svg",
	compositor = theme.path .. "/icons/symbolic/compton.svg",
	gamemode   = theme.path .. "/icons/symbolic/dpad.svg",
	wifi       = theme.path .. "/icons/symbolic/wifi.svg",
	bluetooth  = theme.path .. "/icons/symbolic/bluetooth.svg",
	system     = theme.path .. "/icons/symbolic/system.svg",
}

-- Service utils config
-----------------------------------------------------------------------------------------------------------------------
theme.service = {}

-- Window control mode appearance
--------------------------------------------------------------------------------
theme.service.navigator = {
	border_width = 0,
	gradstep     = 9999,  -- fake a huge gradstep to achieve solid colored highlight
	marksize     = { width = 160, height = 80, r = theme.border_radius },
	linegap      = 32,
	titlefont    = theme.cairo_fonts.navigator.title,
	font         = theme.cairo_fonts.navigator.main,
	color        = { border = theme.color.main, mark = theme.color.icon, text = theme.color.wibox,
	                 fbg1 = theme.color.main .. "90",   fbg2 = theme.color.main .. "90",
	                 hbg1 = theme.color.urgent .. "90", hbg2 = theme.color.urgent .. "90",
	                 bg1  = theme.color.wibox .. "90",   bg2  = theme.color.wibox .. "90" },
	shape        = nil,
	window_type  = "utility"
}

theme.service.navigator.keytip = {}
theme.service.navigator.keytip["fairv"] = { geometry = { width = 600, height = 440 }, exit = true }
theme.service.navigator.keytip["fairh"] = theme.service.navigator.keytip["fairv"]

theme.service.navigator.keytip["tile"] = { geometry = { width = 600, height = 660 }, exit = true }
theme.service.navigator.keytip["tileleft"]   = theme.service.navigator.keytip["tile"]
theme.service.navigator.keytip["tiletop"]    = theme.service.navigator.keytip["tile"]
theme.service.navigator.keytip["tilebottom"] = theme.service.navigator.keytip["tile"]

theme.service.navigator.keytip["grid"] = { geometry = { width = 1400, height = 520 }, column = 2, exit = true }
theme.service.navigator.keytip["usermap"] = { geometry = { width = 1400, height = 580 }, column = 2, exit = true }

-- Logout screen appearance
--------------------------------------------------------------------------------
theme.service.logout = {
	button_size    = { width = 128, height = 128 },
	icon_margin    = 16,
	text_margin    = 12,
	label_font     = theme.fonts.logout.label,
	counter_font   = theme.fonts.logout.counter,
	button_spacing = 48,
	color          = {
		wibox  = theme.color_t.wibox,
		text   = theme.color_t.text,
		gray   = theme.color_t.gray,
		main   = theme.color_t.main,
		icon   = theme.color_t.icon
	},
	icons                 = theme.icon.logout_screen,
	keytip                = { geometry = { width = 400 } },
	client_kill_timeout   = 2,
	double_key_activation = true,
	button_shape          = function(cr, w, h) return gears.shape.rounded_rect(cr, w, h, 6) end
}

-- Splash screen appearance
--------------------------------------------------------------------------------
theme.service.splashscreen = {
	font = theme.fonts.splash,
}


-- Menu config
-----------------------------------------------------------------------------------------------------------------------
theme.menu = {
	border_width = 1,
	screen_gap   = theme.useless_gap + theme.border_width_float,
	height       = 32,
	width        = 160,
	margin       = { 4, 4, 4, 4 },
	icon_margin  = { 4, 7, 8, 8 },
	ricon_margin = { 9, 9, 9, 9 },
	font         = theme.fonts.menu,
	keytip       = { geometry = { width = 400, height = 380 } },
	hide_timeout = 1,
	submenu_icon = theme.path .. "/widget/forward.svg",
	shape        = widget_shape,
	action_on_release = true
}

theme.menu.color = {
	border       = theme.color_t.border,
	text         = theme.color_t.text,
	highlight    = theme.color_t.highlight,
	main         = theme.color_t.main,
	wibox        = theme.color_t.wibox,
	left_icon    = theme.color_t.icon,
	submenu_icon = theme.color_t.icon,
}


-- Gauge style
-----------------------------------------------------------------------------------------------------------------------
theme.gauge = { tag = {}, task = {}, icon = {}, audio = {}, monitor = {}, graph = {} }

-- Separator
------------------------------------------------------------
theme.gauge.separator = {
	marginv = { 2, 2, 4, 4 },
	marginh = { 6, 6, 3, 3 },
	color  = theme.color
}



-- Icon indicator
------------------------------------------------------------
theme.gauge.icon.single = {
	color  = theme.color
}

theme.gauge.icon.single.gray = {
	color  = {
		main   = theme.color.main,
		icon   = theme.color.gray,
		urgent = theme.color.urgent
	}
}

-- Monitor
--------------------------------------------------------------
theme.gauge.monitor.double = {
	width    = 90,
	dmargin  = { 10, 0, 0, 0 },
	color    = theme.color,

	-- progressbar style
	line = {
		width = 4, -- progressbar height
		v_gap = 6, -- space between progressbar
		gap = 4,   -- gap between progressbar dashes
		num = 5    -- number of progressbar dashes
	},
}

theme.gauge.monitor.circle = {
	width        = 32,
	line_width   = 3,
	iradius      = 7,
	radius       = 12,
	color        = theme.color
}

-- Monitor (plain bar)
--------------------------------------------------------------
theme.gauge.monitor.plain = {
	width      = 36,
	font       = theme.cairo_fonts.monitor,
	text_shift = 20,
	line       = { height = 3, y = 27 },
	color      = theme.color
}

-- Tag
------------------------------------------------------------
-- tag style similar to gauge.task.blue (label with bars)
theme.gauge.tag.blue = {
	width      = 93,
	font       = theme.cairo_fonts.tag,
	point      = { width = 60, height = 3, gap = 27, dx = 1 },
	text_shift = 20,
	color      = theme.color
}

-- circle tag style (set 'widget = redflat.gauge.tag.orange.new'
-- within 'taglist.style = {...}' of the main rc-*.lua file in
-- order to switch to circled tag buttons of the redflat lib)
theme.gauge.tag.orange = {
	width        = 40,
	line_width   = theme.gauge.monitor.circle.line_width,
	iradius      = theme.gauge.monitor.circle.iradius,
	radius       = theme.gauge.monitor.circle.radius,
	hilight_min  = false,
	color        = theme.color
}

-- Task
------------------------------------------------------------
theme.gauge.task.blue = {
	width      = 65,
	show_min   = true,
	font       = theme.cairo_fonts.tag,
	point      = { width = 60, height = 3, gap = 5, dx = 4 },
	text_shift = 29,
	color      = theme.color
}

-- Dotcount
------------------------------------------------------------
theme.gauge.graph.dots = {
	column_num   = { 3, 5 }, -- { min, max }
	row_num      = 3,
	dot_size     = 3,
	dot_gap_h    = 5,
	color        = theme.color
}

-- Volume indicator
------------------------------------------------------------
theme.gauge.audio.blue = {
	width   = 60,
	dash    = { bar = { num = 4, width = 3 }, color = theme.color },
	dmargin = { 10, 0, 2, 2 },
	icon    = theme.path .. "/widget/headphones.svg",
	color = { icon = theme.color.icon, mute = theme.color.urgent },
}


-- Panel (wibar)
--------------------------------------------------------------------------------
theme.panel = { color = {}, start = {} }

theme.panel = {
	height       = theme.panel_height,
	border_width = theme.border_width_panel,
	border_is_shadow = true,
	border_ontop = true,
}

theme.panel.color = {
	border = theme.color_t.panel_border,
	bg = theme.color_t.wibox
}

-- start menu button
theme.panel.start = {
	color = {
		bg   = "transparent",
		icon = theme.color.gray,
	},
	separator = {}
}

-- separator to the right of the start menu button
theme.panel.start.separator = {
	marginv = theme.gauge.separator.marginv,
	color   = theme.gauge.separator.color,
}

-- enable decorator element to right side of the start button instead of plain separator
theme.start_button_decorator_enabled = theme.enable_start_decor

-- overrides for the start button decorator
if theme.start_button_decorator_enabled then
	theme.panel.start.color.bg = gears.color.create_pattern({
		type  = "linear",
		from  = { 0, 0 },
		to    = { 0, theme.panel.height },
		stops = {
			{ 0, scale_hex_color(theme.color.main, 1.025) },
			{ 1, scale_hex_color(theme.color.main, 0.975) }
		},
	})
	theme.panel.start.color.icon = "#00000077"
end

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------
theme.widget = {}

-- individual margins for palnel widgets
------------------------------------------------------------
theme.widget.wrapper = {
	startmenu   = { 8, 8, 7, 7 },
	layoutbox   = { 8, 8, 7, 7 },
	textclock   = { 8, 8, 0, 0 },
	volume      = { 8, 8, 6, 6 },
	network     = { 10, 10, 6, 6 },
	cpuram      = { 10, 10, 6, 6 },
	ram         = { 8, 8, 0, 0 },
	cpu         = { 8, 8, 0, 0 },
	battery     = { 5, 5, 8, 8 },
	tray        = { 8, 8, 9, 8 },
	tasklist    = { 4, 0, 0, 0 }, -- centering tasklist widget
}

-- Pulseaudio volume control
------------------------------------------------------------
theme.widget.pulse = {
	notify      = { icon = theme.path .. "/widget/audio.svg" }
}

-- Brightness control
------------------------------------------------------------
theme.widget.brightness = {
	notify      = { icon = theme.path .. "/widget/brightness.svg" }
}

-- Textclock
------------------------------------------------------------
theme.widget.textclock = {
	font  = theme.fonts.clock,
	color = { text = theme.color.icon }
}

-- Keyboard layout indicator
------------------------------------------------------------
theme.widget.keyboard = {
	icon         = theme.path .. "/widget/keyboard.svg",
	micon        = theme.icon,
	layout_color = { theme.color.icon, theme.color.main }
}

theme.widget.keyboard.menu = {
	width        = 180,
	color        = { right_icon = theme.color.icon },
	nohide       = true
}

-- Upgrades
------------------------------------------------------------
theme.widget.upgrades = {
	notify      = { icon = theme.path .. "/widget/upgrades.svg" },
	color       = theme.color
}

-- Mail
------------------------------------------------------------
theme.widget.mail = {
	icon        = theme.path .. "/widget/mail.svg",
	notify      = { icon = theme.path .. "/widget/mail.svg" },
	color       = theme.color,
}

-- Minitray
------------------------------------------------------------
theme.widget.minitray = {
	geometry     = { height = 40 },
	screen_gap   = 2 * theme.useless_gap,
	border_width = theme.border_width_float,
	color        = { wibox = theme.color.wibox, border = theme.color.border },
	set_position = function(wibox)
		local geometry = { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
		                   y = mouse.screen.workarea.y + mouse.screen.workarea.height }
		wibox:geometry(geometry)
	end,
	shape        = widget_shape,
}


-- Layoutbox
------------------------------------------------------------
theme.widget.layoutbox = {
	micon = theme.icon,
	color = { icon = theme.color.gray }
}

theme.widget.layoutbox.icon = {
	floating          = theme.path .. "/icons/layouts/floating.svg",
	max               = theme.path .. "/icons/layouts/max.svg",
	fullscreen        = theme.path .. "/icons/layouts/fullscreen.svg",
	tilebottom        = theme.path .. "/icons/layouts/tilebottom.svg",
	tileleft          = theme.path .. "/icons/layouts/tileleft.svg",
	tile              = theme.path .. "/icons/layouts/tile.svg",
	tiletop           = theme.path .. "/icons/layouts/tiletop.svg",
	fairv             = theme.path .. "/icons/layouts/fair.svg",
	fairh             = theme.path .. "/icons/layouts/fair.svg",
	grid              = theme.path .. "/icons/layouts/grid.svg",
	usermap           = theme.path .. "/icons/layouts/map.svg",
	magnifier         = theme.path .. "/icons/layouts/magnifier.svg",
	cornerne          = theme.path .. "/icons/layouts/cornerne.svg",
	cornernw          = theme.path .. "/icons/layouts/cornernw.svg",
	cornerse          = theme.path .. "/icons/layouts/cornerse.svg",
	cornersw          = theme.path .. "/icons/layouts/cornersw.svg",
	unknown           = theme.path .. "/icons/unknown.svg",
}

theme.widget.layoutbox.menu = {
	icon_margin  = { 8, 12, 9, 9 },
	width        = 220,
	auto_hotkey  = true,
	nohide       = false,
	color        = { right_icon = theme.color.icon, left_icon = theme.color.icon }
}

theme.widget.layoutbox.name_alias = {
	floating          = "Floating",
	fullscreen        = "Fullscreen",
	max               = "Maximized",
	grid              = "Grid",
	usermap           = "User Map",
	tile              = "Right Tile",
	fairv             = "Fair Tile",
	tileleft          = "Left Tile",
	tiletop           = "Top Tile",
	tilebottom        = "Bottom Tile",
	magnifier         = "Magnifier",
	cornerne          = "Corner NE",
	cornernw          = "Corner NW",
	cornerse          = "Corner SE",
	cornersw          = "Corner SW",
}

-- Tasklist
------------------------------------------------------------
theme.widget.tasklist = {
	width         = 70,
	char_digit    = 5,
	task          = theme.gauge.task.blue,
	sort_by_class = true
}

-- main
theme.widget.tasklist.winmenu = {
	micon                = theme.icon,
	titleline            = { font = theme.fonts.title, height = 25 },
	tagline              = { height = 30, spacing = 0, rows = 1 },
	menu                 = { width = 220, color = { right_icon = theme.color.icon }, ricon_margin = { 9, 9, 9, 9 } },
	state_iconsize       = { width = 18, height = 18 },
	layout_icon          = theme.widget.layoutbox.icon,
	hide_action          = { min = true, move = true, max = true, add = true },
	color                = theme.color,
	enable_tagline       = true,
	tagline_mod_key      = "Mod1",
	enable_screen_switch = true,
}

-- tasktip
theme.widget.tasklist.tasktip = {
	margin = { 8, 8, 5, 5 },
	color  = theme.color_t,
	sl_highlight = true,
	border_width = theme.border_width_tasktip,
	shape        = widget_shape,
	max_width    = 500,
}

-- tags submenu
theme.widget.tasklist.winmenu.tagmenu = {
	width       = 180,
	icon_margin = { 9, 9, 9, 9 },
	color       = { right_icon = theme.color.icon, left_icon = theme.color.icon },
}

-- menu
theme.widget.tasklist.winmenu.icon = {
	floating             = theme.path .. "/icons/window_control/floating.svg",
	sticky               = theme.path .. "/icons/window_control/pin.svg",
	ontop                = theme.path .. "/icons/window_control/ontop.svg",
	below                = theme.path .. "/icons/window_control/below.svg",
	close                = theme.path .. "/icons/window_control/close.svg",
	minimize             = theme.path .. "/icons/window_control/minimize.svg",
	switch_screen        = theme.path .. "/icons/window_control/switch.svg",
	tag                  = theme.path .. "/icons/tagsymbol.svg",
	maximized            = theme.path .. "/icons/window_control/maximized.svg",
}


-- Floating widgets
-----------------------------------------------------------------------------------------------------------------------
theme.float = { decoration = {} }

-- Clientmenu
------------------------------------------------------------
theme.float.clientmenu = {
	micon                = theme.icon,
	color                = theme.color,
	actionline           = { height = 26 },
	tagline              = theme.widget.tasklist.winmenu.tagline,
	layout_icon          = theme.widget.layoutbox.icon,
	menu                 = theme.widget.tasklist.winmenu.menu,
	state_iconsize       = theme.widget.tasklist.winmenu.state_iconsize,
	action_iconsize      = { width = 16, height = 16 },
	tagmenu              = theme.widget.tasklist.winmenu.tagmenu,
	icon                 = theme.widget.tasklist.winmenu.icon,
	hide_action          = { move = true, add = true, floating = true, sticky = false,
	                         ontop = false, below = false, maximized = true },
	enable_tagline       = true,
	tagline_mod_key      = theme.widget.tasklist.winmenu.tagline_mod_key,
	enable_screen_switch = true,
}

-- Audio player
------------------------------------------------------------
theme.float.player = {
	geometry        = { width = 520, height = 140 },
	screen_gap      = 2 * theme.useless_gap,
	border_margin   = { 15, 15, 15, 15 },
	elements_margin = { 15, 0, 0, 0 },
	controls_margin = { 0, 0, 20, 10 },
	volume_margin   = { 0, 0, 0, 0 },
	buttons_margin  = { 0, 0, 2, 2 },
	pause_margin    = { 12, 12, 0, 0 },
	volume_width    = 45,
	line_height     = 28,
	bar_width       = 5,
	titlefont       = theme.fonts.player.main,
	artistfont      = theme.fonts.player.sub,
	timefont        = theme.fonts.player.time,
	dashcontrol     = { color = theme.color, bar = { num = 7, width = 3 } },
	progressbar     = { color = theme.color },
	border_width    = theme.border_width_float,
	timeout         = 1,
	set_position    = nil,
	color           = theme.color_t,
	shape           = widget_shape
}

theme.float.player.icon = {
	cover   = theme.path .. "/icons/player/cover.svg",
	next_tr = theme.path .. "/icons/player/next.svg",
	prev_tr = theme.path .. "/icons/player/previous.svg",
	play    = theme.path .. "/icons/player/play.svg",
	pause   = theme.path .. "/icons/player/pause.svg"
}

-- Calendar
------------------------------------------------------------
theme.float.calendar = {
	geometry                  = { width = 450, height = 450 },
	margin                    = { 20, 20, 20, 10 },
	controls_margin           = { 0, 0, 5, 0 },
	calendar_item_margin      = { 2, 6, 2, 2 },
	spacing                   = { separator = 28, datetime = 0, controls = 5, calendar = 6 },
	separator                 = { marginh = { 0, 0, 14, 0 } },
	controls_icon_size        = { width = 24, height = 24 },
	border_width              = 1,
	clock_format              = "%H:%M",
	date_format               = "%A, %d. %B",
	weeks_start_sunday        = false,
	show_week_numbers         = false,
	show_weekday_header       = true,
	long_weekdays             = false,
	weekday_name_replacements = { Mo = 'Lu', Tu = 'Ma', We = 'Mi', Th = 'Ju', Fr = 'Vi', Sa = 'Sa', Su = 'Do' },
	screen_gap                = 2 * theme.useless_gap,
	shape                     = widget_shape,
	color                     = theme.color_t,
	icon                      = { next   = redutil.base.placeholder({ txt = "⯈" }),
		                          prev   = redutil.base.placeholder({ txt = "⯇" }),},
	days                      = {
		weeknumber = { fg = theme.color_t.gray,      bg = "transparent" },
		weekday    = { fg = theme.color_t.gray,      bg = "transparent" },
		weekend    = { fg = theme.color_t.text,      bg = "#BBBBBB22" },
		today      = { fg = theme.color_t.highlight, bg = theme.color_t.main },
		day        = { fg = theme.color_t.text,      bg = "transparent"},
	}
}

theme.float.calendar.fonts = {
	clock           = theme.fonts.calendar.clock,
	date            = theme.fonts.calendar.date,
	week_numbers    = theme.fonts.calendar.weeknumbers,
	weekdays_header = theme.fonts.calendar.header,
	days            = theme.fonts.calendar.days,
	focus           = theme.fonts.calendar.today,
	controls        = theme.fonts.calendar.label
}


-- Control Center
------------------------------------------------------------
theme.float.controlcenter = {
	color = theme.color_t,
}

-- Hotkeys helper
------------------------------------------------------------
theme.float.hotkeys = {
	geometry      = { width = 1400, height = 800 },
	border_margin = { 20, 20, 8, 10 },
	border_width  = theme.border_width_float,
	is_align      = true,
	separator     = { marginh = { 0, 0, 3, 6 } },
	heights       = { key = 24, title = 26 },
	font          = theme.fonts.hotkeys.main,
	keyfont       = theme.fonts.hotkeys.key,
	titlefont     = theme.fonts.hotkeys.title,
	color         = theme.color,
	shape         = widget_shape,
}

-- Tooltip
------------------------------------------------------------
theme.float.tooltip = {
	margin       = 5,
	padding      = { vertical = 5, horizontal = 7 },
	timeout      = 0,
	font         = theme.fonts.tooltip,
	border_width = theme.border_width_tip,
	color        = theme.color_t,
	shape        = widget_shape,
}

-- Floating prompt
------------------------------------------------------------
theme.float.prompt = {
	border_width = theme.border_width_float,
	color        = theme.color,
	shape        = widget_shape,
}

-- Top processes
------------------------------------------------------------
theme.float.top = {
	geometry      = { width = 460, height = 440 },
	screen_gap    = 2 * theme.useless_gap,
	border_margin = { 15, 15, 15, 0 },
	button_margin = { 140, 140, 15, 15 },
	title_height  = 36,
	border_width  = theme.border_width_float,
	bottom_height = 60,
	title_font    = theme.fonts.title,
	color         = theme.color_t,
	set_position  = nil,
	shape = widget_shape
}

-- Key sequence tip
------------------------------------------------------------
theme.float.keychain = {
	geometry        = { width = 250, height = 56 },
	font            = theme.fonts.keychain,
	border_width    = theme.border_width_float,
	keytip          = { geometry = { width = 1200, height = 580 }, column = 2 },
	color           = theme.color_t,
	shape           = widget_shape,
}

-- Notify
------------------------------------------------------------
theme.float.notify = {
	geometry     = { width = 512, height = 110 },
	screen_gap   = 2 * theme.useless_gap,
	font         = theme.fonts.notify,
	border_margin   = { 20, 20, 20, 20 },
	elements_margin = { 20, 0, 10, 10 },
	border_width = theme.border_width_float,
	bar_width    = 6,
	icon         = theme.icon.warning,
	color        = theme.color_t,
	progressbar  = { color = theme.color },
	set_position = function(wibox)
		wibox:geometry({ x = mouse.screen.workarea.x + mouse.screen.workarea.width, y = mouse.screen.workarea.y })
	end,
	shape        = widget_shape,
}

-- Decoration elements
------------------------------------------------------------
theme.float.decoration.button = {
	color = {
		shadow3 = theme.color.shadow3,
		shadow4 = theme.color.shadow4,
		gray    = theme.color.gray,
		text    = "#cccccc"
	},
}

theme.float.decoration.field = {
	color = theme.color
}

theme.float.control = {
	geometry      = { width = 320, height = 64 },
	border_width  = 1,
	font          = theme.fonts.control,
	steps         = { 10, 25, 50, 100, 500 }, -- move/resize step
	default_step  = 4,                        -- select default step by index
	onscreen      = false,                    -- no off screen for window placement
	set_position  = nil,                      -- widget placement function
	shape         = widget_shape,
	color         = theme.color,

	-- margin around widget elements
	margin = { icon = { onscreen = { 15, 15, 15, 15 }, mode = { 15, 15, 15, 15 } } },

	-- redflat key tip settings
	keytip = { geometry = { width = 540 } },
}

theme.float.control.icon = {
	onscreen = theme.path .. "/icons/control/onscreen.svg",
	resize = {
		theme.path .. "/icons/control/full.svg",
		theme.path .. "/icons/control/horizontal.svg",
		theme.path .. "/icons/control/vertical.svg",
	},
}

-- Titlebar renderer configurations
-----------------------------------------------------------------------------------------------------------------------

-- initialize defaults
theme.titlebar_bg        = "transparent"
theme.titlebar_bg_focus  = "transparent"
theme.titlebar_bg_normal = "transparent"
theme.border_width       = 0

theme.titlebars = {}

-- overrides for redflat-extra/titlebar-mini.lua
theme.titlebars.mini = {
	titlebar_height      = 20,  -- default: 18
	button_width         = 20,  -- default: 20
	button_height        = 3,   -- default: 3
	button_spacing       = 8,   -- default: 8
	border_width         = 0,
	color_gloss_line     = "#ECECEC",
	color_gradient_start = "#E0E0E0",
	color_gradient_stop  = "#D9D9D9",
}

-- overrides for redflat-extra/titlebar-breeze.lua
theme.titlebars.breeze = {
	top_height       = 28, -- top titlebar height, minus the accent line's width
	accentline_width = 2,
	-- base colors
	color_titlebar_gradient_start          = "#484E52",
	color_titlebar_gradient_stop           = "#3F4447",
	color_titlebar_accentline              = theme.color.main,
	color_titlebar_gradient_start_inactive = "#F0F0F0",
	color_titlebar_gradient_stop_inactive  = "#E6E6E6",
	color_titlebar_accentline_inactive     = "#CECECE",
	-- titlebar caption colors
	color_title_active        = "#EFF0F1",
	color_title_inactive      = "#B0B0B0",
}

theme.titlebars.side = {
	base_color           = "#2A2C2E",
	border_width         = 0,
	titlebar_height      = 28,
	color_caption_active = theme.color.text,
	color_caption_normal = theme.color.gray,
}

-- Titlebar button glyph definitions (only applies to titlebar themes that use them)
-----------------------------------------------------------------------------------------------------------------------

-- button glyphs - inactive window
theme.titlebar_minimize_button_normal           = theme.path .. "/titlebar/minimize-hover.svg"
theme.titlebar_maximized_button_normal_inactive = theme.path .. "/titlebar/maximize-hover.svg"
theme.titlebar_maximized_button_normal_active   = theme.path .. "/titlebar/unmaximize-hover.svg"
theme.titlebar_close_button_normal              = theme.path .. "/titlebar/close-hover.svg"

local titlebars_are_dark = true
local glyph_suffix = titlebars_are_dark and "-white" or ""

-- button glyphs - active window
theme.titlebar_minimize_button_focus           = theme.path .. "/titlebar/minimize"   .. glyph_suffix .. ".svg"
theme.titlebar_maximized_button_focus_inactive = theme.path .. "/titlebar/maximize"   .. glyph_suffix .. ".svg"
theme.titlebar_maximized_button_focus_active   = theme.path .. "/titlebar/unmaximize" .. glyph_suffix .. ".svg"
theme.titlebar_close_button_focus              = theme.path .. "/titlebar/close"      .. glyph_suffix .. ".svg"

-- button glyphs - inactive window hover
theme.titlebar_minimize_button_normal_hover           = theme.path .. "/titlebar/minimize"   .. glyph_suffix .. ".svg"
theme.titlebar_maximized_button_normal_inactive_hover = theme.path .. "/titlebar/maximize"   .. glyph_suffix .. ".svg"
theme.titlebar_maximized_button_normal_active_hover   = theme.path .. "/titlebar/unmaximize" .. glyph_suffix .. ".svg"
theme.titlebar_close_button_normal_hover              = theme.path .. "/titlebar/close"      .. glyph_suffix .. ".svg"

-- button glyphs - active window hover
theme.titlebar_minimize_button_focus_hover           = theme.path .. "/titlebar/minimize-hover.svg"
theme.titlebar_maximized_button_focus_inactive_hover = theme.path .. "/titlebar/maximize-hover.svg"
theme.titlebar_maximized_button_focus_active_hover   = theme.path .. "/titlebar/unmaximize-hover.svg"
theme.titlebar_close_button_focus_hover              = theme.path .. "/titlebar/close-hover.svg"

-- Aero Snap
--------------------------------------------------------------------------------
theme.snap_border_width = theme.border_width_float
theme.snap_bg = theme.color.main
theme.snap_shape = widget_shape

-- Naughty config
-----------------------------------------------------------------------------------------------------------------------
theme.naughty = {}

theme.naughty.base = {
	timeout      = 10,
	margin       = 20,
	icon_size    = 64,
	font         = theme.fonts.main,
	bg           = theme.color_t.wibox,
	fg           = theme.color_t.text,
	height       = theme.float.notify.geometry.height,
	width        = theme.float.notify.geometry.width,
	border_width = theme.border_width_float,
	border_color = theme.color_t.border or theme.color.main,
	shape        = widget_shape,
}

theme.naughty.normal = theme.naughty.base
theme.naughty.critical = { timeout = 0, border_color = theme.color.main }
theme.naughty.low = { timeout = 5 }


-- Default awesome theme vars
-----------------------------------------------------------------------------------------------------------------------

-- colors
theme.bg_normal     = theme.color.wibox
theme.bg_focus      = theme.color.main
theme.bg_urgent     = theme.color.urgent
theme.bg_minimize   = theme.color.gray

theme.fg_normal     = theme.color.text
theme.fg_focus      = theme.color.highlight
theme.fg_urgent     = theme.color.highlight
theme.fg_minimize   = theme.color.highlight

theme.border_normal = theme.color.border_normal or theme.color.wibox
theme.border_focus  = theme.color.border_focus  or theme.color.wibox
theme.border_marked = theme.color.border_marked or theme.color.main

-- font
theme.font = theme.fonts.main

-- prevent master from filling entire screen when slave stack is empty
theme.master_fill_policy = "master_width_factor"



return theme
