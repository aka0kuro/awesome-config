-----------------------------------------------------------------------------------------------------------------------
--                                                Rules config                                                       --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local beautiful = require("beautiful")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local rules = {}

rules.base_properties = {
	border_width     = beautiful.border_width,
	border_color     = beautiful.border_normal,
	focus            = awful.client.focus.filter,
	raise            = true,
	size_hints_honor = false,
	screen           = awful.screen.preferred,
}

rules.floating_any = {
	role = { "AlarmWindow", "pop-up", },
	type = { "dialog" }
}

rules.messaging_apps = {
	class = {
		"Firefox-esr",
		"Pidgin",
		"Thunderbird",
		"Rocket.Chat+",
		"Hexchat"
	}
}

-- Build rule table
-----------------------------------------------------------------------------------------------------------------------
function rules:init(args)

	local args = args or {}
	self.base_properties.keys = args.hotkeys.keys.client
	self.base_properties.buttons = args.hotkeys.mouse.client


	-- Build rules
	--------------------------------------------------------------------------------
	self.rules = {
		{
			rule       = {},
			properties = args.base_properties or self.base_properties
		},
		{
			rule_any   = args.floating_any or self.floating_any,
			properties = { floating = true }
		},
		{
			rule_any   = { type = { "normal", "dialog" }},
			properties = { titlebars_enabled = true }
		},
		-- default placement for normal windows
		{
			rule_any   = { type = { "normal" }},
			properties = { placement = function (c)
				awful.placement.no_overlap(c, { margins = beautiful.useless_gap*2 })
				awful.placement.no_offscreen(c, { honor_workarea=true })
			end }
		},
		-- Thunderbird's compose new message/appointment window
		{
			rule_any = { instance = { "Msgcompose", "Calendar"  } },
			properties = {
				floating = true,
				callback = function(c)
					awful.placement.centered(c)
				end,
				size_hints_honor = true,
			}
		},
		-- messaging apps tag pinning
		{
			rule_any = self.messaging_apps,
			except_any = { type = { "dialog" }},
			properties = { screen = 1, tag = screen.primary.tags[2] }
		},
		-- size hint honor
		{
			rule_any = { class = { "Audacious", "mpv", "Gnome-clocks", "Org.gnome.Weather.Application" } },
			properties = {
				size_hints_honor = true,
			}
		},
		-- size hint honor & floating
		{
			rule_any = { class = { "Wine", "Steam", "VirtualBox Machine" } },
			properties = {
				size_hints_honor = true,
				floating = true,
			}
		},
		{
			rule = { class = "TeamSpeak 3" },
			properties = {
				size_hints_honor = true,
				floating = true,
				sticky = true,
				ontop = true,
			}
		},
		-- special desktop apps
		{
			rule = { class = "jetbrains-pycharm" },
			properties = {
				size_hints_honor = true,
				placement = awful.placement.centered,
			}
		},
		{
			rule = { name = "Nextcloud" },
			properties = {
				size_hints_honor = true,
				placement = awful.placement.top_right,
				rule_borderless = true,
				titlebars_enabled = false,
			}
		},
		{
			rule = { class = "mGBA" },
			properties = {
				placement = awful.placement.centered,
				floating = true,
				size_hints_honor = true,
			}
		},
		{
			rule = { class = "Xfce4-taskmanager" },
			properties = {
				ontop = true,
				sticky = true,
				floating = true,
				placement = awful.placement.bottom_right,
				size_hints_honor = true,
			}
		},
		{
			rule_any = { class = { "Gnome-calculator", "Galculator", "SpeedCrunch" } },
			properties = {
				placement = awful.placement.centered,
				size_hints_honor = true,
				floating = true,
				ontop = true
			}
		},
		{	-- password input prompt (pinentry)
			rule = { class = "Gcr-prompter" },
			properties = {
				placement = awful.placement.centered,
				name = "PIN",
				ontop = true,
				floating = true,
				sticky = true,
			}
		},
		{
			rule_any = { role = { "descot", "ofuda" } },
			-- enable click-through: this allows to reach desktop menus
			-- (and the like) by clicking the mascot
			callback = function(c)
				local cairo = require("lgi").cairo
				local img = cairo.ImageSurface(cairo.Format.A1, 0, 0)
				c.shape_input = img._native img:finish()
			end,
			properties = {
				floating = true,
				sticky = true,
				border_width = 0,
				focusable = false,
				rule_borderless = true,
				no_rounded_corners = true,
				titlebars_enabled = false,
			}
		},
		{
			-- this rule requires a patched version of xwinwrap that adds
			-- the corresponding window class hints
			rule = { class = "XWinWrap" },
			-- enable click-through: this allows to reach desktop menus
			callback = function(c)
				local cairo = require("lgi").cairo
				local img = cairo.ImageSurface(cairo.Format.A1, 0, 0)
				c.shape_input = img._native img:finish()
			end,
			properties = {
				floating = true,
				below = true,
				sticky = true,
				border_width = 0,
				focusable = false,
				titlebars_enabled = false
			}
		},
		{
			rule = { role = "ImgTile" },
			properties = {
				border_width = 1,
				border_color = "#555555AA",
				titlebars_enabled = false,
				sticky = true,
				below = true,
			}
		},
		{
			-- hacky hack for LO Impress presentations
			-- the Impress are split in presentator view and presentation slides
			-- the latter is identified by its WM_NAME being "LibreOffice 5.2"
			-- whereas the former has the opened file prepended to its name
			--
			-- this is a very dirty way and may break at any new update of LO
			-- sadly there seems to be no cleaner way to do this
			-- NOTE: the presentation slides will always be on the second screen
			-- whereas the presentator view will always be on the first here
			rule = { name = "LibreOffice 5.2", class = "Soffice" },
			properties = { screen = screen.count()>1 and 2 or 1 }
		},
		{
			-- see above
			rule = { name = "LibreOffice 6.1", class = "Soffice" },
			properties = { screen = screen.count()>1 and 2 or 1 }
		},
		{
			-- for german Ubuntu 20.04
			rule = { name = "^Präsentieren:.*", class = "Soffice" },
			properties = { screen = screen.count()>1 and 2 or 1 }
		}
	}


	-- Set rules
	--------------------------------------------------------------------------------
	awful.rules.rules = rules.rules
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return rules
