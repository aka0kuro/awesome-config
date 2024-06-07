-----------------------------------------------------------------------------------------------------------------------
--                                                Side titlebars                                                     --
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
	titlebar_height      = 26,
	button_margin        = 8,
	button_spacing       = 8,
	button_spacing_outer = 7,
	base_color           = "#333333",
	border_width         = 0,
	corner_radius        = 0,
	color_caption_active = "#EEEEEE",
	color_caption_normal = "#888888",
	position             = "right"
}

-- merge any overrides from the beautiful theme definitions
style = redutil.table.merge(style, redutil.table.check(beautiful, "titlebars.side") or {})

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

function titlebar:get_corner_radius()
    return style.corner_radius
end

-- Apply titlebar configuration
-----------------------------------------------------------------------------------------------------------------------
function titlebar:init(args)

	local args = args or {}

	beautiful.titlebar_bg =        style.base_color
	beautiful.titlebar_bg_focus =  style.base_color
	beautiful.titlebar_bg_normal = style.base_color

	beautiful.titlebar_fg_focus  = style.color_caption_active
	beautiful.titlebar_fg_normal = style.color_caption_normal

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

		--                      |              width of a glyph               |
		local side_area_width = (style.titlebar_height - 2*style.button_margin)*num_buttons +
		                        (style.button_spacing)*(num_buttons*2) + style.button_spacing_outer

		-- separators between titlebar buttons
		local button_separator = wibox.widget.separator({
			orientation = "horizontal",
			color = beautiful.color.shadow1,
			forced_height = 1,
		})

		-- separation line between titlebar and client
		local client_separator = wibox.widget.separator({
			orientation = "vertical",
			color = beautiful.color.shadow1,
			forced_width = 1,
		})

		-- focus indicator bar
		local focus_indicator = wibox.widget.separator({
			orientation = "vertical",
			color = (client.focus == c) and beautiful.color.main or beautiful.color.gray,
			thickness = 3,
		})
		c:connect_signal("focus", function() focus_indicator.color = beautiful.color.main end)
		c:connect_signal("unfocus", function() focus_indicator.color = beautiful.color.gray end)

		local side_titlebar = awful.titlebar(c, { size = style.titlebar_height, position = style.position })
		side_titlebar : setup {
			(style.position == "right") and client_separator or nil,
			{
				{ -- Top (buttons)
					{
						-- only add minimize & maximize buttons for full-fledged windows
						awful.titlebar.widget.closebutton(c),
						button_separator,
						not is_dialog and awful.titlebar.widget.maximizedbutton(c) or nil,
						not is_dialog and button_separator,
						not is_dialog and awful.titlebar.widget.minimizebutton (c) or nil,
						not is_dialog and button_separator,
						spacing = style.button_spacing,
						layout = wibox.layout.fixed.vertical(),
					},
					widget = wibox.container.margin,
					top = style.button_margin,
					bottom = style.button_margin,
					left = style.button_spacing_outer,
					right = style.button_spacing_outer,
				},
				{ -- Middle (caption)
					{
						{ -- Title
							align  = "center",
							widget = caption,
						},
						layout = wibox.layout.flex.vertical,
					},
					buttons = title_actions,
					layout = wibox.container.rotate,
					direction = (style.position == "left") and "east" or "west",
				},
				{ -- Bottom (focus indicator)
					focus_indicator,
					forced_height = side_area_width,
					widget = wibox.container.margin,
					bottom = 12,
					top = 12,
					buttons = title_actions,

				},
				layout = wibox.layout.align.vertical,
			},
			(style.position == "left") and client_separator or nil,
			layout = wibox.layout.align.horizontal,
		}
	end)

	-- force titlebar redraw when resizing window
	-- mandatory for titlebars at the sides
	client.connect_signal("request::geometry", function(c)
		if not c.fullscreen and c._request_titlebars_called then
			awful.titlebar.show(c, style.position)
		end
	end)

end

-- End
-----------------------------------------------------------------------------------------------------------------------
return titlebar