-----------------------------------------------------------------------------------------------------------------------
--                                                Mini titlebars                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = {}

-- Style constants with optional overrides by theme
-----------------------------------------------------------------------------------------------------------------------
local style = {
	titlebar_height = 18,
	border_width    = 0,
	corner_radius   = 0,
	button_width    = 20,
	button_height   = 3,
	button_spacing  = 8,
	indicator_width = 120,
	color_gloss_line = "#424242",
	color_gradient_start = "#303030",
	color_gradient_stop = "#303030",
}

-- merge any overrides from the beautiful theme definitions
style = redutil.table.merge(style, redutil.table.check(beautiful, "titlebars.mini") or {})

style.tbar_gradient = gears.color.create_pattern({
	type = "linear",
	from = {0, 0                  },
	to =   {0, style.titlebar_height},
	-- the first stop is the highlight gloss line which is less than 2 pixels in height
	stops = {
		{ 0.025, style.color_gloss_line }, -- ~1px gloss line
		{ 0.030, style.color_gradient_start }, -- gradient start
		{ 1.000, style.color_gradient_stop }, -- gradient stop
	},
})

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

local function make_titlebutton(action)
	local b = wibox.widget.separator({
		orientation = "horizontal",
		color = beautiful.color.gray,
		forced_height = style.button_height,
		thickness = style.button_height,
	})
	local w = wibox.container.place(b)
	w:buttons(awful.button({}, 1, nil, action))
	w.forced_width = style.button_width
	w:connect_signal("mouse::enter", function() b.color = beautiful.color.main end)
	w:connect_signal("mouse::leave", function() b.color = beautiful.color.gray end)
	return w
end

function titlebar:get_corner_radius()
    return style.corner_radius
end

-- Apply titlebar configuration
-----------------------------------------------------------------------------------------------------------------------
function titlebar:init(args)

	local args = args or {}

	beautiful.titlebar_bg =        style.tbar_gradient
	beautiful.titlebar_bg_focus =  style.tbar_gradient
	beautiful.titlebar_bg_normal = style.tbar_gradient

	beautiful.border_width = style.border_width
	if style.corner_radius > 0 then
		beautiful.window_shape = function(cr,w,h)
			gears.shape.rounded_rect(cr, w, h, style.corner_radius)
		end
	end

	-- Add a titlebar if titlebars_enabled is set to true in the rules.
	client.connect_signal("request::titlebars", function(c)

		-- mouse click actions
		local build_actions = args.title_actions or default_title_actions
		local title_actions = build_actions(c)

		local caption = awful.titlebar.widget.titlewidget(c)
		caption:set_font(beautiful.fonts.titlebar or "Sans 10")

		local is_dialog = (c.type == "dialog") or (c.type == "utility") or c.skip_taskbar or c.modal
		local num_buttons = is_dialog and 1 or 3

		local side_area_width = style.button_spacing+(style.button_width+style.button_spacing)*num_buttons

		-- separation line between titlebar and client
		local client_separator = wibox.widget.separator({
			orientation = "horizontal",
			color = beautiful.titlebar_dark_theme and "#FFFFFF10" or "#0000001A",
			forced_height = 1,
			thickness = 1,
		})

		-- focus indicator bar
		local focus_indicator = wibox.widget.separator({
			orientation = "horizontal",
			color = (client.focus == c) and beautiful.color.main or beautiful.color.gray,
			thickness = style.button_height,
			forced_width = style.indicator_width,
		})
		c:connect_signal("focus", function() focus_indicator.color = beautiful.color.main end)
		c:connect_signal("unfocus", function() focus_indicator.color = beautiful.color.gray end)

		local top_titlebar = awful.titlebar(c, { size = style.titlebar_height })
		top_titlebar : setup {
			nil,
			{
				{ -- Middle (caption)
					layout = wibox.container.margin,
					right = side_area_width,
					buttons = title_actions,
				},
				{ -- Left (focus indicator)
					focus_indicator,
					forced_width = side_area_width,
					widget = wibox.container.place,
					buttons = title_actions,
				},
				{ -- Right (buttons)
					{
						-- only add minimize & maximize buttons for full-fledged windows
						not is_dialog and make_titlebutton(function() c.minimized = true end) or nil,
						not is_dialog and make_titlebutton(function() c.maximized = not c.maximized end) or nil,
						make_titlebutton(function() c:kill() end),
						spacing = style.button_spacing,
						layout = wibox.layout.fixed.horizontal(),
					},
					layout = wibox.container.margin,
					right = style.button_spacing,
					left = style.button_spacing,
				},
				layout = wibox.layout.align.horizontal,
			},
			client_separator,
			layout = wibox.layout.align.vertical,
		}
	end)

end

-- End
-----------------------------------------------------------------------------------------------------------------------
return titlebar