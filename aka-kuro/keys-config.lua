-----------------------------------------------------------------------------------------------------------------------
--                                          Hotkeys and mouse buttons config                                         --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local gears = require("gears")
local redflat = require("redflat")
local controlcenter = require("redflat-extra.controlcenter")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = { mouse = {}, raw = {}, keys = {}, fake = {} }

-- key aliases
local current = redflat.widget.tasklist.filter.currenttags
local laybox = redflat.widget.layoutbox
local redtip = redflat.float.hotkeys
local laycom = redflat.layout.common
local logout = redflat.service.logout
local clientmenu = redflat.float.clientmenu

-- Key support functions
-----------------------------------------------------------------------------------------------------------------------

-- change window focus by history
local function focus_to_previous()
	awful.client.focus.history.previous()
	if client.focus then client.focus:raise() end
end

-- change window focus by direction
local focus_switch_byd = function(dir)
	return function()
		awful.client.focus.bydirection(dir)
		if client.focus then client.focus:raise() end
	end
end

-- changes tag to prev/next or specified index and moves focused client
local move_to_tag = function(direction_or_index)
	local t = client.focus and client.focus.first_tag or nil
	if t == nil then return end
	local tags = client.focus.screen.tags
	-- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
	local tag_idx = tonumber(direction_or_index) -- will be nil if it's not a number
	if tag_idx == nil then
		tag_idx = ( direction_or_index == "right" ) and ( t.index % #tags + 1 ) or ( (t.index - 2) % #tags + 1 )
	end
	local new_tag = tags[tag_idx]
	if new_tag then
		awful.client.movetotag(new_tag)
		new_tag:view_only()
	end
end

-- minimize and restore windows
local function minimize_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) then c.minimized = true end
	end
end

local function minimize_all_except_focused()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c ~= client.focus then c.minimized = true end
	end
end

local function restore_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c.minimized then c.minimized = false end
	end
end

local function restore_client()
	local c = awful.client.restore()
	if c then client.focus = c; c:raise() end
end

-- close window
local function kill_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and not c.sticky then c:kill() end
	end
end

-- new clients placement
local function toggle_placement(env)
	env.set_slave = not env.set_slave
	redflat.float.notify:show({ text = (env.set_slave and "Slave" or "Master") .. " placement" })
end

-- numeric keys function builders
local function tag_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then action(tag) end
		end
	)
end

local function client_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then action(tag) end
			end
		end
	)
end

local function force_focus_screen_byd(direction)
	local current_screen = awful.screen.focused()
	local target_screen = current_screen:get_next_in_direction(direction) or current_screen
	awful.screen.focus_bydirection(direction)
	-- if the cursor is already on the outmost screen for the given 'direction'
	-- then awful.screen.focus_bydirection() will not trigger, so we force focus
	-- the screen in order to focus the most recent client on this screen at least
	if client.focus and target_screen then
		if client.focus.screen ~= target_screen then
			awful.screen.focus(target_screen)
		end
	end
end

-- right bottom corner position
local rb_corner = function()
	return { x = screen[mouse.screen].workarea.x + screen[mouse.screen].workarea.width,
	         y = screen[mouse.screen].workarea.y + screen[mouse.screen].workarea.height }
end

-- Emacs like key sequences
--------------------------------------------------------------------------------
function hotkeys.setup_keyseq(args)
	local env = args.env

	-- initial key
	local keyseq = { { env.mod }, "c", {}, {} }

	-- group
	keyseq[3] = {
		{ {}, "k", {}, {} },   -- application kill group
		{ {}, "c", {}, {} },   -- client managment group
		{ {}, "r", {}, {} },   -- client managment group
		{ {}, "n", {}, {} },   -- client managment group
		{ {}, "m", {}, {} },   -- monitor setting group
		{ {}, "Tab", {}, {} }, -- tag setting group
	}

	-- application kill sequence actions
	keyseq[3][1][3] = {
		{
			{}, "f", function() if client.focus then client.focus:kill() end end,
			{ description = "Kill focused client", group = "Kill application", keyset = { "f" } }
		},
		{
			{}, "a", kill_all,
			{ description = "Kill all clients with current tag", group = "Kill application", keyset = { "a" } }
		},
	}

	-- client managment sequence actions
	keyseq[3][2][3] = {
		{
			{}, "p", function () toggle_placement(env) end,
			{ description = "Switch master/slave window placement", group = "Clients managment", keyset = { "p" } }
		},
	}

	keyseq[3][3][3] = {
		{
			{}, "f", restore_client,
			{ description = "Restore minimized client", group = "Clients managment", keyset = { "f" } }
		},
		{
			{}, "a", restore_all,
			{ description = "Restore all clients with current tag", group = "Clients managment", keyset = { "a" } }
		},
	}

	keyseq[3][4][3] = {
		{
			{}, "f", function() if client.focus then client.focus.minimized = true end end,
			{ description = "Minimized focused client", group = "Clients managment", keyset = { "f" } }
		},
		{
			{}, "a", minimize_all,
			{ description = "Minimized all clients with current tag", group = "Clients managment", keyset = { "a" } }
		},
		{
			{}, "e", minimize_all_except_focused,
			{ description = "Minimized all clients except focused", group = "Clients managment", keyset = { "e" } }
		},
	}

	-- monitor handling
	keyseq[3][5][3] = {
		{
			{}, "p", function() awful.spawn.with_shell("bash " .. awful.util.get_configuration_dir() .. "scripts/xrandr.sh primary") end,
			{ description = "Only activate PRIMARY screen", group = "Monitor management", keyset = { "p" } }
		},
		{
			{}, "s", function() awful.spawn.with_shell("bash " .. awful.util.get_configuration_dir() .. "scripts/xrandr.sh secondary") end,
			{ description = "Only activate SECONDARY screen", group = "Monitor management", keyset = { "s" } }
		},
		{
			{}, "e", function() awful.spawn.with_shell("bash " .. awful.util.get_configuration_dir() .. "scripts/xrandr.sh extend") end,
			{ description = "Extend the internal screen to the right", group = "Monitor management", keyset = { "e" } }
		},
		{
			{}, "m", function() awful.spawn.with_shell("bash " .. awful.util.get_configuration_dir() .. "scripts/xrandr.sh mirror") end,
			{ description = "Mirror both screens", group = "Monitor management", keyset = { "m" } }
		},
		{
			{}, "o", function() awful.spawn.with_shell("bash " .. awful.util.get_configuration_dir() .. "scripts/xrandr.sh ontop") end,
			{ description = "Set the external screen ontop", group = "Monitor management", keyset = { "o" } }
		},
	}

	-- tag movement handling
	keyseq[3][6][3] = {
		{
			{}, "Tab", function()
				redflat.service.mover:run()
			end,
			{ description = "Activate tab mover", group = "Tag movement", keyset = { "Tab" } }
		},
	}
	for k = 1,9
	do
		local k_str = tostring(k)
		table.insert(keyseq[3][6][3],
		{
			{}, k_str, function() move_to_tag(k) end,
			{ description = "Move current client to tag #" .. k_str, group = "Tag movement", keyset = { k_str } }
		})
	end

	return keyseq
end

-- Shared tiling layout keys
--------------------------------------------------------------------------------
function hotkeys.setup_tile_keys(args)
	local env = args.env
	local tile_keys = {
		{
			{}, "d", function () awful.tag.incmwfact( 0.05) end,
			{ description = "Increase master width factor", group = "Layout" }
		},
		{
			{}, "a", function () awful.tag.incmwfact(-0.05) end,
			{ description = "Decrease master width factor", group = "Layout" }
		},
		{
			{}, "w", function () awful.client.incwfact( 0.05) end,
			{ description = "Increase window factor of a client", group = "Layout" }
		},
		{
			{}, "s", function () awful.client.incwfact(-0.05) end,
			{ description = "Decrease window factor of a client", group = "Layout" }
		},
		{
			{}, "y", function () awful.tag.incnmaster(-1, nil, true) end,
			{ description = "Decrease the number of master clients", group = "Layout" }
		},
		{
			{}, "x", function () awful.tag.incnmaster( 1, nil, true) end,
			{ description = "Increase the number of master clients", group = "Layout" }
		},
		{
			{}, "+", function () awful.tag.incnmaster( 1, nil, true) end,
			{ description = "Increase the number of master clients", group = "Layout" }
		},
		{
			{}, "-", function () awful.tag.incnmaster(-1, nil, true) end,
			{ description = "Decrease the number of master clients", group = "Layout" }
		},
		{
			{}, "e", function () awful.tag.incncol( 1, nil, true) end,
			{ description = "Increase the number of columns", group = "Layout" }
		},
		{
			{}, "q", function () awful.tag.incncol(-1, nil, true) end,
			{ description = "Decrease the number of columns", group = "Layout" }
		},
	}
	return tile_keys
end

-- Global keys
--------------------------------------------------------------------------------
function hotkeys.setup_root_keys(args)
	local env = args.env
	local mainmenu = args.menu

	-- volume functions
	local volume = args.volume
	local volume_raise = function() volume:change_volume({ show_notify = true })              end
	local volume_lower = function() volume:change_volume({ show_notify = true, down = true }) end
	local volume_mute  = function() volume:mute() end

	local root_keys = {
		{
			{ }, "Super_L", function() awful.spawn(env.rofi) end,
			{ description = "Show Application Launcher", group = "Main" }
		},
		{
			{ }, "Print", function() awful.spawn(env.screenshot) end,
			{ description = "Take a screenshot", group = "Applications" }
		},
		{
			{ }, "XF86Calculator", function() awful.spawn(env.calculator) end,
			{ description = "Start calculator", group = "Applications" }
		},
		{
			{ }, "XF86Tools", function() awful.spawn(env.player) end,
			{ description = "Start audio player", group = "Applications" }
		},
		{
			{ env.mod }, "F1", function() redtip:show() end,
			{ description = "Show hotkeys helper", group = "Main" }
		},
		{
			{ env.mod }, "g", function () redflat.service.navigator:run() end,
			{ description = "Window control mode (tiled)", group = "Window control" }
		},
		{
			{ env.mod, "Control" }, "r", env.reload_awesome or awesome.restart,
			{ description = "Reload awesome", group = "Main" }
		},
		{
			{ env.mod }, "c", function() redflat.float.keychain:activate(hotkeys.setup_keyseq(args), "User") end,
			{ description = "User key sequence", group = "Main" }
		},
		{
			{ env.mod }, "Return", function() awful.spawn(env.terminal) end,
			{ description = "Open a terminal", group = "Applications" }
		},
		{
			{ env.mod }, "#", function() awful.spawn(env.terminal .. " -q") end,
			{ description = "Open quake-style terminal", group = "Applications" }
		},
		{
			{ env.mod, "Shift" }, "Return", function() awful.spawn(env.fm) end,
			{ description = "Open a file manager", group = "Applications" }
		},
		{
			{ "Control", "Shift" }, "Escape", function() awful.spawn(env.sysmon) end,
			{ description = "Open the system monitor", group = "Applications" }
		},
		{
			{ env.mod }, "x", function() mainmenu:show() end,
			{ description = "Show main menu", group = "Widgets" }
		},
		{
			{ env.mod }, "F2", function() redflat.float.prompt:run() end,
			{ description = "Show the prompt box", group = "Widgets" }
		},
		{
			{ env.mod }, "v", function() controlcenter:toggle() end,
			{ description = "Show control center", group = "Widgets" }
		},
		{
			{}, "XF86AudioRaiseVolume", volume_raise,
			{ description = "Increase volume", group = "Volume control" }
		},
		{
			{}, "XF86AudioLowerVolume", volume_lower,
			{ description = "Reduce volume", group = "Volume control" }
		},
		{
			{}, "XF86AudioMute", volume_mute,
			{ description = "Toggle mute", group = "Volume control" }
		},
		{
			{ env.mod }, "e", function() redflat.float.player:show(rb_corner()) end,
			{ description = "Show/hide widget", group = "Audio player" }
		},
		{
			{ env.mod }, "less", function() laybox:toggle_menu(mouse.screen.selected_tag) end,
			{ description = "Show layout menu", group = "Layouts" }
		},
		-- WINDOW NAVIGATION
		{
			{ env.mod }, "d", focus_switch_byd("right"),
			{ description = "Go to right client", group = "Client focus" }
		},
		{
			{ env.mod }, "a", focus_switch_byd("left"),
			{ description = "Go to left client", group = "Client focus" }
		},
		{
			{ env.mod }, "w", focus_switch_byd("up"),
			{ description = "Go to upper client", group = "Client focus" }
		},
		{
			{ env.mod }, "s", focus_switch_byd("down"),
			{ description = "Go to lower client", group = "Client focus" }
		},
		{
			{ env.mod }, "u", awful.client.urgent.jumpto,
			{ description = "Go to urgent client", group = "Client focus" }
		},
		{
			{ env.mod }, "dead_circumflex", focus_to_previous,
			{ description = "Go to previous client", group = "Client focus" }
		},
		{
			-- window cycle with autoraise
			{ env.mod }, "Tab", function() awful.client.focus.byidx(-1); if client.focus then client.focus:raise(); end; end,
			{ description = "Go to previous client", group = "Client focus" }
		},
		{
			-- reverse window cycle with autoraise
			{ env.mod, "Shift" }, "Tab", function() awful.client.focus.byidx(1); if client.focus then client.focus:raise(); end; end,
			{ description = "Go to next client", group = "Client focus" }
		},
		-- SCREEN NAVIGATION
		{
			{ env.mod, "Shift" }, "d", function() force_focus_screen_byd("right") end,
			{ description = "Focus right screen", group = "Screen focus" }
		},
		{
			{ env.mod, "Shift" }, "a", function() force_focus_screen_byd("left") end,
			{ description = "Focus left screen", group = "Screen focus" }
		},
		{
			{ env.mod, "Shift" }, "w", function() force_focus_screen_byd("up") end,
			{ description = "Focus upper screen", group = "Screen focus" }
		},
		{
			{ env.mod, "Shift" }, "s", function() force_focus_screen_byd("down") end,
			{ description = "Focus lower screen", group = "Screen focus" }
		},
		-- TAG NAVIGATION
		{
			{ env.mod }, "Escape", awful.tag.history.restore,
			{ description = "Go previous tag", group = "Tag navigation" }
		},
		{
			{ env.mod, "Control" }, "Right", function() awful.tag.viewnext(mouse.screen) end,
			{ description = "View next tag", group = "Tag navigation" }
		},
		{
			{ env.mod, "Control" }, "Left", function() awful.tag.viewprev(mouse.screen) end,
			{ description = "View previous tag", group = "Tag navigation" }
		},
		{
			{ env.mod, "Shift", "Control" }, "Right", function() move_to_tag("right") end,
			{ description = "View next tag and move client", group = "Tag navigation" }
		},
		{
			{ env.mod, "Shift", "Control" }, "Left", function() move_to_tag("left") end,
			{ description = "View previous tag and move client", group = "Tag navigation" }
		},
		{
			{ env.mod}, "space", function() awful.layout.inc(1) end,
			{ description = "Select next layout", group = "Layouts" }
		},
		{
			{ env.mod, "Shift" }, "space", function() awful.layout.inc(-1) end,
			{ description = "Select previous layout", group = "Layouts" }
		},
	}
	return root_keys
end

-- Client keys
--------------------------------------------------------------------------------
function hotkeys.setup_client_keys(args)
	local env = args.env
	local client = {
		{
			{ env.mod }, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
			{ description = "Toggle fullscreen", group = "Client keys" }
		},
		{
			{ env.mod }, "q", function(c) c:kill() end,
			{ description = "Close", group = "Client keys" }
		},
		{
			{ env.mod, "Control" }, "f", awful.client.floating.toggle,
			{ description = "Toggle floating", group = "Client keys" }
		},
		{
			{ env.mod, "Control" }, "w", function(c) c.ontop = not c.ontop end,
			{ description = "Toggle keep on top", group = "Client keys" }
		},
		{
			{ env.mod, "Control" } ,"s", function(c) c.sticky = not c.sticky end,
			{ description = "Toggle sticky", group = "Client keys" }
		},
		{
			{ env.mod }, "n", function(c) c.minimized = true end,
			{ description = "Minimize", group = "Client keys" }
		},
		{
			{ env.mod }, "y", function(c) c.minimized = true end,
			{} -- hidden key
		},
		{
			{ env.mod }, "m", function(c) c.maximized = not c.maximized; c:raise() end,
			{ description = "Maximize", group = "Client keys" }
		}
	}
	return client
end

-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:init(args)

	-- Init vars
	local args = args or {}
	local env = args.env
	local mainmenu = args.menu

	-- Desktop click actions
	self.mouse.root = (awful.util.table.join(
		awful.button({ }, 3, function () mainmenu:toggle() end)
	))

	-- Keys for widgets
	--------------------------------------------------------------------------------

	-- Menu widget
	------------------------------------------------------------
	local menu_keys_move = {
		-- MENU WASD NAVIGATION
		{
			{ env.mod }, "s", redflat.menu.action.down,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ env.mod }, "w", redflat.menu.action.up,
			{ description = "Select previous item", group = "Navigation" }
		},
		{
			{ env.mod }, "a", redflat.menu.action.back,
			{ description = "Go back", group = "Navigation" }
		},
		{
			{ env.mod }, "d", redflat.menu.action.enter,
			{ description = "Open submenu", group = "Navigation" }
		},
	}
	redflat.menu:set_keys(menu_keys_move, "move")

	-- Logout screen
	------------------------------------------------------------
	local logout_keys = {
		{
			{ }, "Escape", logout.action.hide,
			{ description = "Close the logout screen", group = "Action" }
		},
		{
			{ env.mod }, "a", logout.action.select_prev,
			{ description = "Select previous option", group = "Selection" }
		},
		{
			{ env.mod }, "d", logout.action.select_next,
			{ description = "Select next option", group = "Selection" }
		},
		{
			{ }, " ", logout.action.execute_selected,
			{ } -- space will appear as empty string, use fake key for redtip instead
		},
		{
			{ }, "Return", logout.action.execute_selected,
			{ } -- hidden
		},
		{
			{ env.mod }, "F1", function() redtip:show() end,
			{ description = "Show hotkeys helper", group = "Action" }
		},
		-- fake keys for redtip
		{
			{ }, "Space", nil, -- fake key to document space behavior
			{ description = "Execute selected option", group = "Action",
			  keyset = { " " } }
		},
		{
			{ }, "1..9", nil,
			{ description = "Select option by number", group = "Selection",
			  keyset = { "1", "2", "3", "4", "5", "6", "7", "8", "9" } }
		}
	}
	for i = 1, 9 do
		table.insert(logout_keys, {
			{ }, tostring(i), function(_logout)
				logout.action.select_by_id(i)
			end,
			{ } -- hide from redtip
		})
	end
	logout:set_keys(logout_keys)

	local tile_keys = hotkeys.setup_tile_keys(args)
	laycom:set_keys(tile_keys, "tile")

	self.raw.root = hotkeys.setup_root_keys(args)
	self.raw.client = hotkeys.setup_client_keys(args)

	self.keys.root = redflat.util.key.build(self.raw.root)
	self.keys.client = redflat.util.key.build(self.raw.client)

	-- Numkeys
	--------------------------------------------------------------------------------

	-- add real keys without description here
	for i = 1, 9 do
		self.keys.root = awful.util.table.join(
			self.keys.root,
			tag_numkey(i,    { env.mod },                     function(t) t:view_only()               end),
			tag_numkey(i,    { env.mod, "Control" },          function(t) awful.tag.viewtoggle(t)     end),
			client_numkey(i, { env.mod, "Shift" },            function(t) client.focus:move_to_tag(t) end),
			client_numkey(i, { env.mod, "Control", "Shift" }, function(t) client.focus:toggle_tag(t)  end)
		)
	end

	-- make fake keys with description special for key helper widget
	local numkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

	self.fake.numkeys = {
		{
			{ env.mod }, "1..9", nil,
			{ description = "Switch to tag", group = "Numeric keys", keyset = numkeys }
		},
		{
			{ env.mod, "Control" }, "1..9", nil,
			{ description = "Toggle tag", group = "Numeric keys", keyset = numkeys }
		},
		{
			{ env.mod, "Shift" }, "1..9", nil,
			{ description = "Move focused client to tag", group = "Numeric keys", keyset = numkeys }
		},
		{
			{ env.mod, "Control", "Shift" }, "1..9", nil,
			{ description = "Toggle focused client on tag", group = "Numeric keys", keyset = numkeys }
		},
	}

	-- Hotkeys helper setup
	--------------------------------------------------------------------------------
	redflat.float.hotkeys:set_pack("Main", awful.util.table.join(self.raw.root, self.raw.client, self.fake.numkeys), 2)

	-- Mouse buttons
	--------------------------------------------------------------------------------
	self.mouse.client = awful.util.table.join(
		awful.button({}, 1, function (c) if c.focusable then client.focus = c; c:raise() end end), -- focus client on left-click
		awful.button({}, 3, function (c) if c.focusable then client.focus = c; c:raise() end end), -- focus client on right-click
		awful.button({ env.mod }, 1, function (c) if c.focusable then client.focus = c end; c:raise(); awful.mouse.client.move(c) end),
		awful.button({ env.mod }, 2, function (c)
			clientmenu:show(c)
			-- the redflat.float.clientmenu's redflat.menu will start a
			-- awful.keygrabber upon show(). It seems that an
			-- awful.keygrabber.start() command within an awful.button()
			-- here will prevent any subsequent mouse hover/click,
			-- rendering Awesome unusable, so we need to quickly stop it
			-- (Awesome bug: https://github.com/awesomeWM/awesome/issues/2398)
			awful.keygrabber.stop(clientmenu.menu._keygrabber)
			-- There is a workaround to use a gears.timer to break free from the lockdown
			gears.timer.start_new(0.1, function()
				awful.keygrabber.run(clientmenu.menu._keygrabber)
			end)
		end),
		awful.button({ env.mod }, 3, function (c)
			-- only enable right-click resizing for floating clients and layouts
			if c.floating or (c.screen.selected_tag.layout == redflat.layout.grid) or (c.screen.selected_tag.layout == awful.layout.suit.floating) then
				awful.mouse.client.resize(c)
			end
		end)
	)

	-- Set root hotkeys
	--------------------------------------------------------------------------------
	root.keys(self.keys.root)
	root.buttons(self.mouse.root)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
