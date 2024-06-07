-----------------------------------------------------------------------------------------------------------------------
--                                 Shared helper functions for Axent titlebar renderers                              --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local gears = require("gears")
local lgi = require("lgi")
local cairo = lgi.cairo
local pixbuf
local function load_pixbuf()
	local _ = require("lgi").Gdk
	pixbuf = require("lgi").GdkPixbuf
end
local is_pixbuf_loaded = pcall(load_pixbuf)

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local helpers = {}

helpers.scale_hex_color = function(hex, scale)
	hex = hex:gsub("#", "")
	local r, g, b = tonumber("0x"..hex:sub(1,2)),
	                tonumber("0x"..hex:sub(3,4)),
	                tonumber("0x"..hex:sub(5,6))
	r, g, b = math.min(math.max(r*scale, 0), 255),
	          math.min(math.max(g*scale, 0), 255),
	          math.min(math.max(b*scale, 0), 255)
	return "#" .. string.format('%02x', math.floor(r))
	           .. string.format('%02x', math.floor(g))
	           .. string.format('%02x', math.floor(b))
end

-- alternative to gears.color.recolor_image which works better with transparency
-- due to not leaving artifacts of the original image on the resulting image,
-- preventing color bleed and unintended alteration of stroke thicknesses
helpers.recolor_image = function(image, new_color)
	image = gears.surface.duplicate_surface(image)
	local mask = gears.surface.duplicate_surface(image)
	local cr = cairo.Context.create(image)
	cr:save()
	cr:set_operator("clear")
	local w, h = gears.surface.get_size(image)
	cr:rectangle(0, 0, w, h)
	cr:fill()
	cr:restore()
	cr:set_source(gears.color(new_color))
	cr:mask_surface(mask, 0, 0)
	return image
end

-- image recolor with non-blurry SVG scaling according to specified size
helpers.recolor_image_scaled = function(image, width, height, new_color)
	if is_pixbuf_loaded then
		local buf = pixbuf.Pixbuf.new_from_file_at_scale(image, width, height, true)
		local image = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)
		local cr = cairo.Context(image)
		-- paint the loaded and scaled SVG onto temporary buffer
		cr:set_source_pixbuf(buf, 0, 0)
		cr:push_group()
		cr:paint()
		-- load the temporary buffer into pattern and restore original context
		local pattern = cr:pop_group()
		-- paint the pattern with a different color using mask
		cr:set_source(gears.color(new_color))
		cr:mask(pattern, 0, 0)
		return image
	else
		-- fallback to blurry builtin scaling if pixbuf is unavailable
		return helpers.recolor_image(image, new_color)
	end
end

-- utility function to help determine if a window should have rounded corners etc.
helpers.client_is_maximized = function(c)

	local function _fills_screen()
		local wa = c.screen.workarea
		local cg = c:geometry()
		return wa.x == cg.x and wa.y == cg.y and wa.width == cg.width and wa.height == cg.height
	end

	return c.maximized or (not c.floating and _fills_screen())
end

-- hide specific sides of titlebars on maximized windows
helpers.activate_titlebar_retraction = function()

	local function refresh_titlebar_geometry(c)
		local is_max = helpers.client_is_maximized(c)

		if is_max then
			-- hide side borders
			awful.titlebar.hide(c, "left")
			awful.titlebar.hide(c, "right")
			-- dirty size correction to fill up space of hidden borders
			if c.width ~= c.screen.workarea.width then
				c.width = c.screen.workarea.width
			end
		elseif not c.fullscreen and c._request_titlebars_called then
			awful.titlebar.show(c, "top")
			awful.titlebar.show(c, "left")
			awful.titlebar.show(c, "right")
			awful.titlebar.show(c, "bottom")
		end
	end

	-- attach to all possible signals that may change a client's geometry
	client.connect_signal("property::maximized", refresh_titlebar_geometry)
	client.connect_signal("request::geometry", refresh_titlebar_geometry)
	client.connect_signal("manage", refresh_titlebar_geometry) -- when clients spawn
	client.connect_signal("focus", refresh_titlebar_geometry) -- catch edge cases*
	-- * edge case: when a client moves from any layout to a max layout and gets
	--              resized to maximized state (due to gap=0 for max layout) then
	--              the 'tagged' signal does not seem to trigger is_maximized(c)
	--              correctly, so we force refresh on the next focus instead; note
	--              that we cannot use 'property::size' because of infinite looping
	--              with awful.titlebar.{show,hide}
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return helpers
