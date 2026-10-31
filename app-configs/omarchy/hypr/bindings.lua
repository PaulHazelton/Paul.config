-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
-- omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

--#region Helpers

-- Number keys
local numRowKeys = {
	[0] = "code:19",
	[1] = "code:10",
	[2] = "code:11",
	[3] = "code:12",
	[4] = "code:13",
	[5] = "code:14",
	[6] = "code:15",
	[7] = "code:16",
	[8] = "code:17",
	[9] = "code:18",
	[10] = "code:19",
}

-- Num pad keys
local numPadKeys = {
	[0] = "code:90",
	[1] = "code:87",
	[2] = "code:88",
	[3] = "code:89",
	[4] = "code:83",
	[5] = "code:84",
	[6] = "code:85",
	[7] = "code:79",
	[8] = "code:80",
	[9] = "code:81",
	[10] = "code:90"
}

local comms = "acomms"
local notes = "bnotes"
local media = "cmedia"

-- Make a function to bind both top row numbers and num_pad keys
local function bind_number(keys_prefix, number, name, command)
	o.bind(keys_prefix .. numRowKeys[number], name, command)
	o.bind(keys_prefix .. numPadKeys[number], name, command)
end

-- Focus special workspace
local function focus_special(name)
	local activeSpecial = hl.get_active_special_workspace()

	-- A special is focussed
	if activeSpecial ~= nil then
		local shortName = activeSpecial.config_name:sub(9)

		-- It's the one we want focussed
		if shortName ~= name then
			hl.dispatch(hl.dsp.workspace.toggle_special(name))
		end
	else
		-- No special focussed, just toggle one we want
		hl.dispatch(hl.dsp.workspace.toggle_special(name))
	end
end

-- Un-focus special workspace
local function close_special()
	local activeSpecial = hl.get_active_special_workspace()

	if activeSpecial ~= nil then
		hl.dispatch(hl.dsp.workspace.toggle_special(activeSpecial.config_name:sub(9)))
	end
end

-- Launch or focus apps
local function launchOrFocusDiscord()
	focus_special(comms)
	-- TODO: If it's already running, focus it instead
	hl.dispatch(hl.dsp.exec_cmd("omarchy-launch-webapp https://discord.com/channels/@me"))
end

local function launchOrFocusObsidian()
	focus_special(notes)
	hl.dispatch(hl.dsp.exec_cmd('omarchy-launch-or-focus ^obsidian$ "uwsm-app -- obsidian"'))
end

local function launchOrFocusSpotify()
	focus_special(media)
	hl.dispatch(hl.dsp.exec_cmd('spotify --uri=%u'))
end

--#endregion

hl.config({
	binds = {
		movefocus_cycles_fullscreen = true,
	}
})

-- Omarchy menu and app launcher.
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SUPER_L", "Apps menu", "omarchy-menu toggle apps")

--#region Workspace Switching

-- Unbinding workspace switching for 7, 8, 9, 0
for workspace = 7, 10 do
	hl.unbind("SUPER + " .. numRowKeys[workspace])
	hl.unbind("SUPER + SHIFT + " .. numRowKeys[workspace])
	hl.unbind("SUPER + SHIFT + ALT +" .. numRowKeys[workspace])
end

-- Unbind scratchpad workspaces
hl.unbind("SUPER + S")
hl.unbind("SUPER + ALT + S")

-- Workspace switching
for i = 1, 6 do
	bind_number("SUPER + ", i, "Switch to workspace " .. i, hl.dsp.focus({ workspace = tostring(i) }))
	bind_number("SUPER + SHIFT + ", i, "Move window to workspace " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
	bind_number("SUPER + SHIFT + ALT + ", i, "Move window silently to workspace " .. i, hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end

-- Left and right workspaces
hl.unbind("SUPER + CTRL + LEFT")
hl.unbind("SUPER + CTRL + RIGHT")

o.bind("SUPER + CTRL + LEFT", "Previous Workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("SUPER + CTRL + RIGHT", "Next Workspace", hl.dsp.focus({ workspace = "e+1" }))

-- Special Workspaces

-- Communications

-- Comms
bind_number("SUPER + ", 7, "Comms Space", hl.dsp.workspace.toggle_special(comms))
bind_number("SUPER + SHIFT + ", 7, "Move to Comms Space", hl.dsp.window.move({ workspace = "special:" .. comms }))

-- Notes
bind_number("SUPER + ", 8, "Notes Space", hl.dsp.workspace.toggle_special(notes))
bind_number("SUPER + SHIFT + ", 8, "Move to Notes Space", hl.dsp.window.move({ workspace = "special:" .. notes }))

-- Media
bind_number("SUPER + ", 9, "Media Space", hl.dsp.workspace.toggle_special(media))
bind_number("SUPER + SHIFT + ", 9, "Move to Media Space", hl.dsp.window.move({ workspace = "special:" .. media }))

-- Close special
bind_number("SUPER + ", 0, "Dismiss special workspace", close_special)

-- Launch or focus apps on special workspaces
bind_number("SUPER + CTRL + ", 7, "Launch or focus Discord", launchOrFocusDiscord)
bind_number("SUPER + CTRL + ", 8, "Launch or focus Obsidian", launchOrFocusObsidian)
bind_number("SUPER + CTRL + ", 9, "Launch or focus Spotify", launchOrFocusSpotify)

hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })
-- o.bind(
--   "SUPER + E",
--   "Yazi File manager",
--   'ghostty -e bash -ic "y; exec bash"'
-- )
