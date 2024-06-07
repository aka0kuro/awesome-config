-----------------------------------------------------------------------------------------------------------------------
--                                               Widgets config                                                      --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local widgets = {}

-- Panel widgets wrapper
--------------------------------------------------------------------------------
widgets.wrapper = function(widget, name, buttons)
    local margin = redflat.util.table.check(beautiful, "widget.wrapper") and beautiful.widget.wrapper[name]
                   and beautiful.widget.wrapper[name] or { 0, 0, 0, 0 }


    if redflat.util.table.check(beautiful, "widget.wrapper") and beautiful.widget.wrapper[name] then
        margin = beautiful.widget.wrapper[name]
    end

    if name == "startmenu" then
        local ret = wibox.container.background(
            wibox.container.margin(widget, unpack(margin)), beautiful.panel.start.color.bg or beautiful.color.main
        )
        ret:buttons(buttons)
        return ret
    else
        if buttons then
            widget:buttons(buttons)
        end
        return wibox.container.margin(widget, unpack(margin))
    end
end

-- create a widget for drawing a fake panel_border for non-detached wibars
widgets.panel_border = function(screen)
    local border = { }
    local workarea = screen.workarea

    local border_color = beautiful.panel.color.border or "#444444"
    local border_is_shadow = beautiful.panel.border_is_shadow

    border.wibox = wibox({
        bg      = gears.color.create_pattern({
            type = "linear",
            from = {0, 0},
            to = {0, beautiful.panel.border_width or 1},
            stops = {
                { 0, border_is_shadow and "transparent" or border_color },
                { 1, border_color }
            },
        }),
        ontop   = beautiful.panel.border_ontop,
        visible = true,
        type    = "desktop"   -- use "dock" or "desktop" to suppress shadows (if applicable)
    })

    border.layout = wibox.layout.fixed["horizontal"]()
    border.wibox:set_widget(border.layout)
    border.wibox:geometry({
        width = workarea.width,
        height = beautiful.panel.border_width or 1,
        x = workarea.x,
        y = workarea.y + workarea.height - (beautiful.panel.border_width or 1)
    })

    -- since the normal panel_border line is too dark at the edge of the start
    -- button we render a brighter section where the start button is located if
    -- the panel border is only 1px in height and acts as a fake shadow line
    if beautiful.enable_xforce_style and beautiful.panel.border_width == 1 then
        local start_button_shader = wibox.widget {
            color        = beautiful.panel.color.border_start or "#FFFFFF22",
            orientation  = "horizontal",
            thickness    = beautiful.panel.border_width or 1,
            forced_width = beautiful.panel_height + 1,
            widget       = wibox.widget.separator,
        }
        border.layout:add(start_button_shader)
    end

    return border
end

-- arrow (>) shaped decorator element for the start button
widgets.start_button_decorator = function()
    local deco_widget = wibox.widget.base.make_widget()
    local element_width = beautiful.start_button_decorator_width or 15
    local right_margin = beautiful.start_button_decorator_margin or 3

    function deco_widget:fit(ctx, w, h)
        return element_width+right_margin, h
    end

    function deco_widget:draw(ctx, cr, w, h)
        cr:set_source(beautiful.panel.start.color.bg or gears.color(beautiful.color.main))
        cr:move_to(0, 0)
        cr:line_to(element_width, h/2.1)
        cr:line_to(element_width, h/1.9)
        cr:line_to(0, h)
        cr:fill()
    end

    return deco_widget
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return widgets
