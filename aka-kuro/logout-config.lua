-----------------------------------------------------------------------------------------------------------------------
--                                            Logout screen config                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local logoutscreen = require("redflat.service.logout")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local logout = {}

function logout:init()
    local logout_entries = {
        {   -- Logout
            callback   = function() awesome.quit() end,
            icon_name  = 'logout',
            label      = 'Cerrar Sesion',
            close_apps = true,
        },
        {   -- Lock screen
            callback   = function() awful.spawn.with_shell("sleep 0.5 && i3lock -c 000000") end,
            icon_name  = 'lock',
            label      = 'Bloquear',
            close_apps = false,
        },
        {   -- Shutdown
            callback   = function() awful.spawn.with_shell("systemctl poweroff") end,
            icon_name  = 'poweroff',
            label      = 'Apagar',
            close_apps = true,
        },
        {   -- Suspend
            callback   = function() awful.spawn.with_shell("systemctl suspend") end,
            icon_name  = 'suspend',
            label      = 'Suspender',
            close_apps = false,
        },
        {   -- Reboot
            callback   = function() awful.spawn.with_shell("systemctl reboot") end,
            icon_name  = 'reboot',
            label      = 'Reiniciar',
            close_apps = true,
        },
    }
    logoutscreen:set_entries(logout_entries)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return logout
