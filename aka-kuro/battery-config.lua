-----------------------------------------------------------------------------------------------------------------------
--                                           Battery handling config                                                 --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
local timer = require("gears.timer")
local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local battery = {}

-- Build table
-----------------------------------------------------------------------------------------------------------------------
function battery:init(args)

    local args = args or {}

    -- if battery is not charging and drops below the lower bounds
    -- or if battery is charging and exceeds the upper bounds
    -- then display a notification that the power cord may be
    -- plugged/unplugged respectively to keep the battery healthy
    local battery_bounds_lo = args.low or 40
    local battery_bounds_hi = args.high or 80
    local battery_notify_interval_s = args.interval or 120
    local battery_name = args.battery_name or "BAT0"

    if _G.is_laptop then
        local t = timer({ timeout = battery_notify_interval_s })
        t:connect_signal("timeout", function()
            local state = redflat.system.pformatted.bat(25)(battery_name)
            local percentage = math.floor(state.value*100)

            local notification_triggered = false
            local bat_state = redflat.system.battery(battery_name)
            local is_charging = bat_state[1] == "+"

            if is_charging and percentage > battery_bounds_hi then
                notification_triggered = true
            elseif not is_charging and percentage < battery_bounds_lo then
                notification_triggered = true
            end

            if notification_triggered then
                redflat.float.notify:show({
                    screen = screen.primary,
                    icon = redflat.util.table.check(beautiful, "icon.widget.battery"),
                    value = state.value,
                    text = string.format("Battery (%.0f", percentage) .. "%)",
                    set_position = function(wibox)
                        -- only show on primary screen
                        local geometry = { x = screen.primary.workarea.x + screen.primary.workarea.width,
                                           y = screen.primary.workarea.y }
                        wibox:geometry(geometry)
                    end
                })
            end
        end)
        t:start()
        t:emit_signal("timeout")
    end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return battery