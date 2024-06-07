-----------------------------------------------------------------------------------------------------------------------
--                                               Titlebar config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local clientmenu = require("redflat.float.clientmenu")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = {}

-- mouse button mapping for the whole titlebar
local function title_buttons(c)
    return awful.util.table.join(
        awful.button(
            { }, 1,
            function()
                if c.focusable then client.focus = c end; c:raise()
                awful.mouse.client.move(c)
            end
        ),
        awful.button(
            { }, 2,
            function()
                c:lower()
            end
        ),
        awful.button(
            { }, 3,
            function()
                if c.focusable then client.focus = c end; c:raise()
                clientmenu:show(c)
            end
        )
    )
end

-- Activate titlebar configuration
-----------------------------------------------------------------------------------------------------------------------
function titlebar:init()

    awful.titlebar.enable_tooltip = false -- show tooltips when hover on titlebar buttons
    awful.titlebar.fallback_name  = "" -- Title to display if client name is not set

    -- load the main titlebar module depending on config
    local tbar_module = require("redflat-extra.titlebar-" .. (beautiful.titlebar_theme or "mini") )
    tbar_module:init({
        title_actions = title_buttons
    })

    -- adjust the shape of navigator overlays according to the window corner
    -- radius as reported by the corresponding titlebar renderer module
    local window_radius = tbar_module:get_corner_radius()
    beautiful.service.navigator.shape = (window_radius > 0) and (function(cr, width, height) return gears.shape.rounded_rect(cr, width, height, window_radius) end) or nil

    client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
    client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

    -- workarounds for https://github.com/awesomeWM/awesome/issues/2195
    client.connect_signal("property::fullscreen", function(c)
        if not c.fullscreen and not c.maximized and c._request_titlebars_called and not c.rule_borderless then
            -- restore borders upon leaving fullscreen
            c.border_width = beautiful.border_width
        end
    end)

    -- keep borders trimmed on maximized clients after awesome restart
    client.connect_signal("manage", function(c)
        if c.maximized then
            c.border_width = 0
        end
    end)

    -- trim borders when maximizing clients
    client.connect_signal("property::maximized", function(c)
        if not c.maximized and c._request_titlebars_called and not c.rule_borderless then
            -- restore borders upon leaving maximized state
            c.border_width = beautiful.border_width
        elseif c.maximized then
            -- remove borders in maximized state
            c.border_width = 0
        end
    end)

end

-- End
-----------------------------------------------------------------------------------------------------------------------
return titlebar