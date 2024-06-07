-----------------------------------------------------------------------------------------------------------------------
--                                                     Rofi config                                                   --
-----------------------------------------------------------------------------------------------------------------------

local beautiful = require("beautiful")
local gears = require("gears")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local rofi = {}

-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function rofi:init(args)

	local args = args or {}
	local env = args.env or {}

	-- rofi command building
	--
	local rofi_cmd = "rofi -no-config" -- ignore config, we setup everything here
	-- rofi color adjustment
	local rofi_accent_color = beautiful.color.secondary or beautiful.color.main
	local rofi_alpha = beautiful.transparency_rofi or nil

	local rofi_bg_color       = (rofi_alpha ~= nil) and beautiful.color.wibox:gsub("#", "#" .. rofi_alpha)  or beautiful.color.wibox
	local rofi_entry_bg_color = (rofi_alpha ~= nil) and beautiful.color.wibox:gsub("#", "#00")              or beautiful.color.wibox
	local rofi_border_color   = (rofi_alpha ~= nil) and beautiful.color.border:gsub("#", "#" .. rofi_alpha) or beautiful.color.border

	--
	-- SYNTAX: -color-window background, border_color, separator_color
	rofi_cmd = rofi_cmd .. " -color-window '" .. rofi_bg_color .. "," .. rofi_border_color .. "," .. rofi_accent_color .. "'"
	--
	-- SYNTAX: -color-normal background, foreground, background_alt, highlight_background, highlight_foreground
	rofi_cmd = rofi_cmd .. " -color-normal '" .. rofi_entry_bg_color .. "," .. beautiful.color.text:sub(1, 7) .. "," .. rofi_entry_bg_color .. "," .. beautiful.color.main .. "," .. beautiful.color.highlight .. "'"
	--
	-- SYNTAX: color-urgent background, foreground, background_alt, highlight_background, highlight_foreground
	rofi_cmd = rofi_cmd .. " -color-urgent '" .. beautiful.color.wibox .. "," .. beautiful.color.urgent .. "," .. beautiful.color.wibox .. "," .. beautiful.color.urgent .. "," .. beautiful.color.highlight .. "'"
	--
	-- SYNTAX: color-active background, foreground, background_alt, highlight_background, highlight_foreground
	rofi_cmd = rofi_cmd .. " -color-active '" .. beautiful.color.wibox .. "," .. rofi_accent_color .. "," .. beautiful.color.wibox .. "," .. rofi_accent_color .. "," .. beautiful.color.highlight .. "'"
	--
	-- generic styling
	rofi_cmd = rofi_cmd .. " -bw " .. (beautiful.border_width_rofi or 1) .. " -lines 10 -separator-style none -padding 5 -scrollbar-width 5 -line-margin 5 -line-padding 2 -sidebar-mode true"
	rofi_cmd = rofi_cmd .. " -font '" .. beautiful.fonts.rofi .. "'"
	-- clear/change conflicting key bindings first
	rofi_cmd = rofi_cmd .. " -kb-row-tab Control+Shift+Tab -kb-row-first Shift+Page_Up -kb-row-last Shift+Page_Down -kb-row-up Up,Control+p"
	-- set custom key bindings, hint: ISO_Left_Tab == Shift+Tab (!)
	rofi_cmd = rofi_cmd .. " -kb-mode-next Tab -kb-mode-previous ISO_Left_Tab -kb-move-front Home -kb-move-end End -kb-clear-line Control+l"

	-- inject additional styling hints in .rasi format specification
	-- !! ATTENTION !! in more recent versions of rofi the 'sidebar' is renamed to 'mode-switcher'!
	local separator_height = 2
	rofi_cmd = rofi_cmd .. " -theme-str '#window { border-radius: " .. tostring(beautiful.border_radius or 0) .. "; }'"
	rofi_cmd = rofi_cmd .. " -theme-str '#inputbar { padding: 0 0 5 2; border: 0 0 " .. tostring(separator_height) .. " 0; border-color: " .. (beautiful.color.shadow1 or "White") .. "; }'"
	rofi_cmd = rofi_cmd .. " -theme-str '#sidebar { padding: 5 0 0 0; border: " .. tostring(separator_height) .. " 0 0 0; border-color: " .. (beautiful.color.shadow1 or "White") .. "; }'"
	rofi_cmd = rofi_cmd .. " -theme-str '#listview { padding: 3 0 3 0; }'" -- '-line-padding' has to be accounted for here for consistency
	rofi_cmd = rofi_cmd .. " -theme-str '#scrollbar { handle-color: " .. (beautiful.color.gray or "White") .. "; }'"

	-- display modes
	local rofi_ext_script = gears.filesystem.get_configuration_dir() .. "/scripts/" .. (_G.is_laptop and "laptop/rofi-extra" or "rofi-extra") .. ".sh"
	rofi_cmd = rofi_cmd .. " -display-drun APP -display-run RUN -display-window WIN -display-combi APP"
	rofi_cmd = rofi_cmd .. " -terminal " .. (env.terminal or "xterm") .. " -modi 'combi,run,window' -combi-modi drun,EXT:" .. rofi_ext_script .. " -show"
	self.cmd = rofi_cmd

end

-- End
-----------------------------------------------------------------------------------------------------------------------
return rofi
