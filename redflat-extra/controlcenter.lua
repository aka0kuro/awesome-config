local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local separator = require("redflat.gauge.separator")

local toggle_functions = require("aka-kuro.toggles-config")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local controlcenter = { }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		border_radius       = beautiful.border_radius,
		border_width        = beautiful.border_width_float,
		entry_height        = 42,
		width               = 400,
		min_height          = 200,
		margin              = { 15, 15, 15, 15 },
		icon_size           = 24,
		title_height        = 20,
		title_font          = "RobotoCondensed 14",
		spacing             = 10,
		screen_gap          = 2 * beautiful.useless_gap,
		separator_thickness = 2,
		font                = "RobotoCondensed 13",
		systray = {
			margin        = { 4, 4, 4, 4 },
			size          = 24,
			icon_spacing  = 8,
		},
		switch = {
			width         = 42,
			height        = 24,
			border_width  = 2,
			border_radius = 4,
			knob_margin   = 2,
			knob_radius   = 2,
		},
		color = {
			wibox       = beautiful.color.wibox,
			main        = beautiful.color.main,
			gray        = beautiful.color.gray,
			shadow1     = beautiful.color.shadow1,
			text        = beautiful.color.text,
			icon        = beautiful.color.icon,
			border      = beautiful.color.border,
			entry_bg    = "#aaaaaa22",
			entry_hover = "#aaaaaa44",
			systray_bg  = beautiful.color.wibox,
		},
		shape = function(cr, width, height) return gears.shape.rounded_rect(cr, width, height, beautiful.border_radius) end,
		set_position = function(widg)
			local geometry = { x = mouse.screen.workarea.x + mouse.screen.workarea.width,
							   y = mouse.screen.workarea.y + mouse.screen.workarea.height }
			widg:geometry(geometry)
		end
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "float.controlcenter") or {})
end


local make_switch = function(style, parent)
	local slider = wibox.widget.base.make_widget()

	function slider:fit(context, width, height)
		local fw, fh = self:get_forced_width(), self:get_forced_height()
		return fw or width, fh or height
	end

	-- shape of outline and knob
	local switch_shape = function(cr, width, height)
		return gears.shape.rounded_rect(cr, width, height, style.switch.border_radius)
	end
	local knob_shape = function(cr, width, height)
		return gears.shape.rounded_rect(cr, width, height, style.switch.knob_radius)
	end

	function slider:draw(context, cr, width, height)
		cr:set_source(parent.active and gears.color(style.color.main) or gears.color(style.color.gray))

		-- outline
		local border_width = style.switch.border_width
		local margin = border_width
		gears.shape.transform(switch_shape):translate(margin, margin)(cr, width-2*margin, height-2*margin, height/2)
		cr:set_line_width(border_width)
		cr:stroke()

		-- knob
		local inner_margin = style.switch.knob_margin
		local knob_offset = margin + border_width + inner_margin
		local knob_size = height - 2*knob_offset
		local knob_pos = parent.active and (width - knob_offset - knob_size) or knob_offset
		gears.shape.transform(knob_shape):translate(knob_pos, knob_offset)(cr, knob_size, knob_size)
		cr:set_line_width(0)
		cr:fill()
	end

	return slider
end

local build_entry_panel = function(style, toggle_meta)

	local panel = { ico = nil, txt = nil, swt = nil, w = nil, active = false }

	function panel:toggle()
		if self.active then
			toggle_meta.action_off()
		else
			toggle_meta.action_on()
		end
		-- delayed update
		gears.timer.start_new(0.25, function() self:update() end)
	end

	function panel:handle_update(input)
		local val = input:gsub("%s+", "") -- trim string
		if val == "on" then
			self.active = true
		else
			self.active = false
		end
		self.group:emit_signal("widget::redraw_needed")
	end

	function panel:update()
		toggle_meta.check_state(function(retval) self:handle_update(retval) end)
	end

	local line_height = style.entry_height
	local toggle_size = { width = style.switch.width, height = style.switch.height }
	local icon_padding = (line_height - style.icon_size)/2
	local toggle_padding = (line_height - toggle_size.height)/2

	panel.ico = svgbox(toggle_meta.icon, true, style.color.icon)
	panel.ico:set_forced_width(style.icon_size)
	panel.ico:set_forced_height(style.icon_size)

	local txt = wibox.widget.textbox()
	txt.align = "center"
	txt.font = style.font
	txt:set_markup('<span color="' .. style.color.text .. '">' .. toggle_meta.label .. '</span>')
	panel.txt = txt

	panel.swt = make_switch(style, panel)
	panel.swt:set_forced_width(toggle_size.width)
	panel.swt:set_forced_height(toggle_size.height)

	panel.group = wibox.container.background(
		wibox.layout.align.horizontal(
			wibox.container.margin(panel.ico, icon_padding, icon_padding, icon_padding, icon_padding),
			wibox.container.place(panel.txt),
			wibox.container.margin(panel.swt, icon_padding, icon_padding, toggle_padding, toggle_padding)
		)
	)
	panel.group.forced_height = line_height
	panel.group.shape = function(cr, width, height)
							return gears.shape.rounded_rect(cr, width, height, style.border_radius)
						end
	panel.group.bg = style.color.entry_bg

	-- mouse interactions
	panel.group:connect_signal('mouse::enter', function() panel.group.bg = style.color.entry_hover end)
	panel.group:connect_signal('mouse::leave', function() panel.group.bg = style.color.entry_bg end)
	panel.group:buttons(awful.util.table.join(awful.button({}, 1, nil, function() panel:toggle() end)))

	gears.timer.start_new(1, function() panel:update() end)

	return panel
end


-- Main functions
-----------------------------------------------------------------------------------------------------------------------
function controlcenter:init()

	-- Style
	------------------------------------------------------------
	local style = default_style()
	self.style = style


	self.keygrabber = function(mod, key, event)
		if key == 'Escape' or key == 'q' then
			controlcenter:hide()
		end
	end

	self.wibox = wibox({
		ontop        = true,
		visible      = false,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape,
		width        = style.width,
		height       = style.min_height,
	})

	local layout = wibox.layout.fixed.vertical()
	layout.spacing = style.spacing

	-- generic separator
	local separator = separator.horizontal({
		marginv = { 0, 0, 0, 0 },
		marginh = { 0, 0, 0, 0 },
		color  = { shadow1 = beautiful.color.shadow1,
				   shadow2 = beautiful.color.shadow2 }
	})

	self.panels = {}
	local num_toggles = 0
	local num_separators = 0
	local num_titles = 0
	for _, entry in ipairs(toggle_functions) do
		if entry == "---" then
			layout:add(separator)
			num_separators = num_separators + 1
		elseif type(entry) == "string" then
			local tb = wibox.widget.textbox()
			tb.font = style.title_font
			tb:set_markup('<span color="' .. style.color.gray .. '">' .. entry .. '</span>')
			tb.forced_height = style.title_height
			layout:add(tb)
			num_titles = num_titles + 1
		else
			local toggle = build_entry_panel(style, entry)
			layout:add(toggle.group)
			table.insert(self.panels, toggle)
			num_toggles = num_toggles + 1
		end
	end

	-- SYSTRAY
	beautiful.systray_icon_spacing = style.systray.icon_spacing
	local systray_panel = wibox.layout.fixed.vertical()
	systray_panel.spacing = style.spacing
	self.tray = wibox.widget.systray()
	self.tray.forced_height = style.systray.size

	systray_panel:add(separator)
	num_separators = num_separators + 1

	local shape = function(cr, width, height) return gears.shape.rounded_rect(cr, width, height, style.border_radius) end
	local systray_embed = wibox.container.background(
		wibox.container.place(wibox.container.margin(self.tray, table.unpack(style.systray.margin)), "right", "center"),
		style.color.systray_bg, -- unmodified color, without alpha
		shape
	)
	systray_panel:add(systray_embed)

	local bottom_embed = wibox.container.place(systray_panel, "center", "bottom")
	bottom_embed.fill_vertical = true
	layout:add(bottom_embed)

	self.wibox:set_widget(wibox.container.margin(layout, table.unpack(style.margin)))

	local height = style.margin[3] + style.margin[4] +
		num_toggles*(style.entry_height+style.spacing) +
		num_separators*(style.separator_thickness + style.spacing) +
		num_titles*(style.title_height + style.spacing) +
		style.systray.margin[3] + style.systray.margin[4] + style.systray.size
	self.wibox.height = math.max(height, style.min_height)

	self.update_timer = gears.timer {
		timeout   = 1,
		call_now  = false,
		autostart = false,
		callback  = function()
			for _, panel in ipairs(self.panels) do
				panel:update()
			end
			return true -- start again
		end
	}
end

-- Hide
--------------------------------------------------------------------------------
function controlcenter:hide()
	-- awful.keygrabber.stop(self.keygrabber)
	self.update_timer:stop()
	self.wibox.visible = false
end

-- Show
--------------------------------------------------------------------------------
function controlcenter:show(geometry)
	if not self.wibox then self:init() end

	if geometry then
		self.wibox:geometry(geometry)
	elseif self.style.set_position then
		self.style.set_position(self.wibox)
	else
		awful.placement.under_mouse(self.wibox)
	end
	redutil.placement.no_offscreen(self.wibox, self.style.screen_gap, screen[mouse.screen].workarea)

	self.tray.screen = mouse.screen
	self.wibox.visible = true
	self.update_timer:start()
	-- awful.keygrabber.run(self.keygrabber)
end

-- Toggle
--------------------------------------------------------------------------------
function controlcenter:toggle()
	if self.wibox.visible then
		self:hide()
	else
		self:show()
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return controlcenter
