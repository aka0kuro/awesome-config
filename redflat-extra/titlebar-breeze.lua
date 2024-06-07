-----------------------------------------------------------------------------------------------------------------------
--                                              Breeze titlebars                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local textbox = require("wibox.widget.textbox")

local redutil = require("redflat.util")
local helpers = require("redflat-extra.helpers")

local asset_path = awful.util.get_configuration_dir() .. "redflat-extra/breeze/"

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = {}

-- Style constants with optional overrides by theme
-----------------------------------------------------------------------------------------------------------------------
local style = {
	top_height       = 28, -- top titlebar height, minus the accent line's width
	accentline_width = 1,  -- width of the colored line at the bottom
	outer_padding    = 4,  -- outer padding of buttons and caption
	button_size      = { w = 18, h = 18 }, -- titlebar button size
	icon_size        = 20, -- size of the window icon
	icon_margin      = { left = 5, top = 5 }, -- distance of the window icon from the edges
	button_padding   = 5,  -- padding between titlebar buttons
	caption_enabled  = true,
	icon_enabled     = true,

	----------------------------------------------------------
	-- base colors
	color_titlebar_gradient_start          = "#556068",
	color_titlebar_gradient_stop           = "#475057",
	color_titlebar_accentline              = "#3DADE8",
	color_titlebar_gradient_start_inactive = "#EFF0F1",
	color_titlebar_gradient_stop_inactive  = "#EFF0F1",
	color_titlebar_accentline_inactive     = "#EFF0F1",
	-- titlebar caption colors
	color_title_active                     = "#EFF0F1",
	color_title_inactive                   = "#BDC3C7",
	color_close_hover                      = "#FE8F8F",

	glyph_minimize         = asset_path .. "minimize.svg",
	glyph_minimize_hover   = asset_path .. "minimize-hover.svg",
	glyph_maximize         = asset_path .. "maximize.svg",
	glyph_maximize_hover   = asset_path .. "maximize-hover.svg",
	glyph_unmaximize       = asset_path .. "unmaximize.svg",
	glyph_unmaximize_hover = asset_path .. "unmaximize-hover.svg",
	glyph_close            = asset_path .. "close.svg",
	glyph_close_hover      = asset_path .. "close-hover.svg",
}

-- merge any overrides from the beautiful theme definitions
style = redutil.table.merge(style, redutil.table.check(beautiful, "titlebars.breeze") or {})

-- pre-render all button images
local glyph_images = {}
for _, action in ipairs({ 'close', 'minimize', 'maximize', 'unmaximize' }) do
	local glyph_color_active   = style.color_title_active
	local glyph_color_inactive = style.color_title_inactive

	-- active, normal
	glyph_images[ action .. '_active' ] = helpers.recolor_image_scaled(
		style[ 'glyph_' .. action ],
		style.button_size.w, style.button_size.h,
		glyph_color_active
	)
	-- inactive, normal
	glyph_images[ action .. '_inactive' ] = helpers.recolor_image_scaled(
		style[ 'glyph_' .. action ],
		style.button_size.w, style.button_size.h,
		glyph_color_inactive
	)
	-- active, hover
	glyph_images[ action .. '_active_hover' ] = helpers.recolor_image_scaled(
		style[ 'glyph_' .. action .. '_hover' ],
		style.button_size.w, style.button_size.h,
		(action == "close") and style.color_close_hover or glyph_color_active
	)
	-- inactive, hover
	glyph_images[ action .. '_inactive_hover' ] = helpers.recolor_image_scaled(
		style[ 'glyph_' .. action .. '_hover' ],
		style.button_size.w, style.button_size.h,
		(action == "close") and style.color_close_hover or glyph_color_inactive
	)
end

local full_height = style.top_height + style.accentline_width

local gradient_stops = {
	{ 0,                            style.color_titlebar_gradient_start },
	{ style.top_height/full_height, style.color_titlebar_gradient_stop },
	{ style.top_height/full_height, style.color_titlebar_accentline },
	{ 1,                            style.color_titlebar_accentline },
}
local gradient_stops_inactive = {
	{ 0,                            style.color_titlebar_gradient_start_inactive },
	{ style.top_height/full_height, style.color_titlebar_gradient_stop_inactive },
	{ style.top_height/full_height, style.color_titlebar_accentline_inactive },
	{ 1,                            style.color_titlebar_accentline_inactive },
}

style.color_active = gears.color.create_pattern({
	type = "linear",
	from = {0, 0},
	to = {0, full_height},
	stops = gradient_stops
})
style.color_inactive = gears.color.create_pattern({
	type = "linear",
	from = {0, 0},
	to = {0, full_height},
	stops = gradient_stops_inactive
})

---------------------------------------------------------------------------------------------------

-- mouse button mapping for the whole titlebar
local function default_title_actions(c)
	return awful.button(
		{ }, 1,
		function()
			if c.focusable then client.focus = c end; c:raise()
			awful.mouse.client.move(c)
		end
	)
end

local function draw_top(c)
	return function(widget, context, cr, width, height)
		local active = client.focus == c

		-- main titlebar surface
		cr:set_source(active and style.color_active or style.color_inactive)
		cr:rectangle(0, 0, width, height)
		cr:fill()
	end
end

local function make_title_caption(c)
	local ret = textbox()
	ret:set_font(beautiful.fonts.titlebar or "Sans 10")
	ret:set_align("left")
	local function update()
		local name = awful.util.escape(c.name or "")
		local focus = client.focus == c
		local text_color = focus and style.color_title_active or style.color_title_inactive
		ret:set_markup("<span foreground='" .. text_color .. "'> " .. name .. " </span>")
	end
	c:connect_signal("property::name", update)
	c:connect_signal("focus", update)
	c:connect_signal("unfocus", update)
	update()
	return ret
end

local function make_button_wrapper(widget)
	local ret = wibox.container.place(widget)
	ret.forced_width = style.button_size.w + style.button_padding
	ret.forced_height = full_height
	return ret
end

local function make_button(c, button_type)
	local glyph_icon = style['glyph_' .. button_type]
	local ret = wibox.widget.imagebox(glyph_icon, true)
	ret:set_forced_width(style.button_size.w)
	ret:set_forced_height(style.button_size.h)
	ret.button_type = button_type
	ret.client = c
	ret.hover = false

	ret.update_image = function(widget)
		local state = (client.focus == ret.client and "_active" or "_inactive") .. (ret.hover and "_hover" or "")
		local btype = ret.button_type
		if btype == "maximize" and ret.client.maximized then btype = "unmaximize" end
		ret.image = glyph_images[btype .. state]
	end

	ret:connect_signal("mouse::enter", function()
		ret.hover = true
		ret:update_image()
	end)
	ret:connect_signal("mouse::leave", function()
		ret.hover = false
		ret:update_image()
	end)
	c:connect_signal("focus", function() ret:update_image() end)
	c:connect_signal("unfocus", function() ret:update_image() end)
	c:connect_signal("property::maximized", function()
		-- properly refresh button state when the window switches between maximized states
		ret.hover = false
		ret:update_image()
	end)
	ret:update_image()

	return ret
end

local function make_close_button(c)
	local btn = make_button(c, "close")
	btn:buttons(awful.button({ }, 1, nil, function()
		c:kill()
	end))
	local ret = make_button_wrapper(btn)
	return ret
end

local function make_maximize_button(c)
	local btn = make_button(c, "maximize")
	btn:buttons(awful.button({ }, 1, nil, function()
		c.maximized = not c.maximized
	end))
	local ret = make_button_wrapper(btn)
	return ret
end

local function make_minimize_button(c)
	local btn = make_button(c, "minimize")
	btn:buttons(awful.button({ }, 1, nil, function()
		btn.state = ""
		c.minimized = not c.minimized
	end))
	local ret = make_button_wrapper(btn)
	return ret
end

local function make_titlebar_top(c, inner_top)
	local top = wibox.widget.base.make_widget(inner_top)

	top.draw = draw_top(c)

	local function redraw_all()
		top:emit_signal("widget::redraw_needed")
	end
	c:connect_signal("focus", redraw_all)
	c:connect_signal("unfocus", redraw_all)

	return top
end

function titlebar:get_corner_radius()
	return 0
end

-- Apply titlebar configuration
-----------------------------------------------------------------------------------------------------------------------
function titlebar:init(args)

	local args = args or {}

	-- enable full transparency below drawn titlebars
	beautiful.titlebar_bg        = "transparent"
	beautiful.titlebar_bg_focus  = "transparent"
	beautiful.titlebar_bg_normal = "transparent"

	-- Add a titlebar if titlebars_enabled is set to true in the rules.
	client.connect_signal("request::titlebars", function(c)

		-- mouse click actions
		local build_actions = args.title_actions or default_title_actions
		local title_actions = build_actions(c)

		-- Titlebar buttons
		local button_panel = wibox.layout.fixed.horizontal()

		-- add minimize and maximize buttons only for non-dialog type clients
		local is_dialog = (c.type == "dialog") or (c.type == "utility") or c.skip_taskbar or c.modal
		if not is_dialog then
			button_panel:add(make_minimize_button(c))
			button_panel:add(make_maximize_button(c))
		end

		local close_button = make_close_button(c)
		button_panel:add(close_button)

		local button_count = 0
		for _ in pairs(button_panel.children) do button_count = button_count + 1 end

		local icon = wibox.widget.base.make_widget_declarative {
			{
				awful.titlebar.widget.iconwidget(c),
				layout = wibox.container.constraint,
				height = style.icon_size,
				width = style.icon_size,
			},
			top = style.icon_margin.top,
			left = style.icon_margin.left,
			layout = wibox.container.margin
		}


		local inner_top = wibox.widget.base.make_widget_declarative {
			layout = wibox.layout.align.horizontal,
			expand = "inside",
			{
				style.icon_enabled and icon or nil,
				layout = wibox.layout.flex.horizontal(),
				buttons = title_actions,
			},
			{   -- center widget: client title
				style.caption_enabled and make_title_caption(c) or nil,
				layout = wibox.layout.margin(),
				buttons = title_actions,
				left = style.outer_padding,
			},
			{
				button_panel,  -- rightmost widget: titlebar button panel
				layout = wibox.layout.margin(),
				right = style.outer_padding,
				forced_width = button_count * (style.button_size.w + style.button_padding) + style.outer_padding,
			}
		}

		local top = make_titlebar_top(c, inner_top)
		awful.titlebar(c, {size = full_height}):set_widget(top)
	end)

end

-- End
-----------------------------------------------------------------------------------------------------------------------
return titlebar