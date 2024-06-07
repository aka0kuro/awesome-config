-----------------------------------------------------------------------------------------------------------------------
--                                                Splashscreen                                                       --
-----------------------------------------------------------------------------------------------------------------------

-- This is a helper module that draws a screen-filling black rectangle for a fixed period of time to blank out
-- the entire screen. This is to be used at the startup or reload of awesome in conjunction with compositor
-- restarts. It prevents flickering artifacts at awesome+compositor startup from persisting on screen and
-- allows the screen to settle down before displaying the actual screen contents.
-- simply call splashscreen:show() in the beginning section of your awesome rc file.

-- Grab environment
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local timer = require("gears.timer")
local svgbox = require("redflat.gauge.svgbox")
local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local splashscreen = {}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
    local style = {
        bg         = "black",
        logo_image = awful.util.get_configuration_dir() .. "redflat-extra/assets/awesome.svg",
        logo_size  = { w = 256, h = 256 },
        logo_color = "#202020",
        text       = "Iniciando ...",
        text_align = "left",
        text_color = "#FF4D4D",
        font       = "Sans 32",
        spacing    = 20,
        timeout    = 4,  -- removes the splashscreen after this amount of seconds
    }
    return redutil.table.merge(style, redutil.table.check(beautiful, "service.splashscreen") or {})
end

local style = default_style()

local function content_widget()
    local icon = style.logo_image
    local iconbox = svgbox(icon, nil, style.logo_color)
    iconbox:set_vector_resize(true)
    iconbox:set_forced_width(style.logo_size.w)
    iconbox:set_forced_height(style.logo_size.h)
    local textbox = wibox.widget.textbox()
    textbox.markup = style.text
    textbox.align = style.text_align
    textbox.font = style.font

    local container = wibox.widget.base.make_widget_declarative {
        {
            {
                nil,
                iconbox,
                expand = "outside",
                layout = wibox.layout.align.horizontal()
            },
            textbox,
            layout = wibox.layout.fixed.vertical(),
            spacing = style.spacing,
        },
        widget = wibox.container.place(),
    }

    return container
end

function splashscreen:show()
    local w = content_widget()
    self.splashes = {}
    for s in screen do
        local area = s.geometry
        self.splashes[s] = wibox({
            x = area.x,
            y = area.y,
            fg = style.text_color,
            width = area.width,
            height = area.height,
            bg = style.bg,
            border_width = 0,
            ontop = true,
            type = "splash",
            visible = true,
            widget = w,
        })
        local hidetimer = timer({ timeout = style.timeout })
        hidetimer:connect_signal("timeout",
            function()
                self.splashes[s].visible = false
                if hidetimer.started then hidetimer:stop() end
            end
        )
	hidetimer:start()
    end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return splashscreen
