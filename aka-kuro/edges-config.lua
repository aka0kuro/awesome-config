-----------------------------------------------------------------------------------------------------------------------
--                                           Active screen edges config                                              --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local edges = {}

-- threshold in pixels from the screen corner that still count as a corner click
local hot_corner_threshold = 25

-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
function edges:init(args)

	local args = args or {}
	local ew = args.width or 1 -- edge width
	local workarea = args.workarea or screen[screen.primary].workarea

	-- edge geometry
	local egeometry = {
		top   = { width = workarea.width - 2 * ew, height = ew , x = ew, y = 0 },
		right = { width = ew, height = workarea.height - ew, x = workarea.width - ew, y = 0 },
		left  = { width = ew, height = workarea.height, x = 0, y = 0 }
	}

	-- Right
	--------------------------------------------------------------------------------
	local right = redflat.util.desktop.edge("vertical")
	right.wibox:geometry(egeometry["right"])

	right.layout:buttons(awful.util.table.join(
		-- left click
		awful.button({}, 1, function()
			local mouse_y = mouse.coords().y
			if mouse_y >= workarea.y and mouse_y < workarea.y + hot_corner_threshold then
				-- hot corner
				awful.tag.history.restore(mouse.screen)
			else
				awful.tag.viewnext(mouse.screen)
			end
		end),
		-- middle click
		awful.button({}, 2, function() awful.tag.history.restore(mouse.screen) end),
		-- right click
		awful.button({}, 3, function()
			local mouse_y = mouse.coords().y
			if mouse_y >= workarea.y and mouse_y < workarea.y + hot_corner_threshold then
				-- hot corner
				awful.tag.history.restore(mouse.screen)
			else
				-- outside hot corner
				awful.tag.viewprev(mouse.screen)
			end
		end),
		-- 'back' mouse side button
		awful.button({}, 8, function() awful.tag.history.restore(mouse.screen) end),
		-- 'next' mouse side button
		awful.button({}, 9, function() awful.tag.history.restore(mouse.screen) end)
	))

	-- Left
	--------------------------------------------------------------------------------
	local left = redflat.util.desktop.edge("vertical", { ew, workarea.height - ew })
	left.wibox:geometry(egeometry["left"])

	left.layout:buttons(awful.util.table.join(
		-- left click
		awful.button({}, 1, function()
			local mouse_y = mouse.coords().y
			if mouse_y >= workarea.y and mouse_y < workarea.y + hot_corner_threshold then
				-- hot corner
				awful.tag.history.restore(mouse.screen)
			else
				-- outside hot corner
				awful.tag.viewnext(mouse.screen)
			end
		end),
		-- middle click
		awful.button({}, 2, function() awful.tag.history.restore(mouse.screen) end),
		-- right click
		awful.button({}, 3, function()
			local mouse_y = mouse.coords().y
			if mouse_y >= workarea.y and mouse_y < workarea.y + hot_corner_threshold then
				-- hot corner
				awful.tag.history.restore(mouse.screen)
			else
				awful.tag.viewprev(mouse.screen)
			end
		end),
		-- 'back' mouse side button
		awful.button({}, 8, function() awful.tag.history.restore(mouse.screen) end),
		-- 'next' mouse side button
		awful.button({}, 9, function() awful.tag.history.restore(mouse.screen) end)
	))
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return edges
