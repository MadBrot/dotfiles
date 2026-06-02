local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local sbar = require("sketchybar")

local spaces = {}
-- local space_windows = {}
AEROSPACE_FOCUSED_SPACE = nil
do
	local cmd = io.popen("aerospace list-workspaces --focused 2>/dev/null")
	if cmd then
		AEROSPACE_FOCUSED_SPACE = cmd:read("l")
		cmd:close()
	end
end

local app_colors = {
	["Code"] = colors.blue,
	["Terminal"] = colors.green,
	["Default"] = colors.overlay1,
	["Firefox"] = colors.orange,
	["WezTerm"] = colors.lavender,
	["LM Studio"] = colors.mauve,
	["Microsoft Edge"] = colors.sapphire,
	["Microsoft Excel"] = colors.green,
	["Microsoft Outlook"] = colors.blue,
	["Microsoft PowerPoint"] = colors.red,
	["Microsoft Teams"] = colors.mauve,
	["Microsoft Word"] = colors.blue,
	["Google Chrome"] = colors.red,
	["Maps"] = colors.teal,
	["Mail"] = colors.sky,
	["Messages"] = colors.green,
	["Spotify"] = colors.green,
	["Music"] = colors.maroon,
	["Slack"] = colors.mauve,
	["Safari"] = colors.blue,
	["PyCharm"] = colors.orange,
	["Datagrip"] = colors.sapphire,
	["Dataspell"] = colors.green,
	["IntelliJ IDEA"] = colors.orange,
	["Finder"] = colors.sky,
	["Cursor"] = colors.rosewater,
	["Home"] = colors.yellow,
	["Notes"] = colors.yellow,
	["Games"] = colors.orange,
	["Photos"] = colors.red,
	["Calendar"] = colors.red,
	["Reminders"] = colors.mauve,
	["FaceTime"] = colors.green,
	["TV"] = colors.lavender,
	["Books"] = colors.brown,
	["Podcasts"] = colors.mauve,
	["News"] = colors.red,
	["Stocks"] = colors.overlay2,
	["Voice Memos"] = colors.overlay2,
	["Contacts"] = colors.yellow,
	["Calculator"] = colors.overlay2,
	["Preview"] = colors.subtext1,
	["Keynote"] = colors.mauve,
	["Numbers"] = colors.green,
	["Proton Mail"] = colors.mauve,
	["Proton Mail Bridge"] = colors.mauve,
	["Pages"] = colors.orange,
	["GarageBand"] = colors.green,
	["iMovie"] = colors.mauve,
	["Weather"] = colors.sky,
	["Journal"] = colors.pink,
	["Xcode"] = colors.blue,
	["Find My"] = colors.green,
	["Steam"] = colors.sapphire,
	["Discord"] = colors.lavender,
	["Zoom"] = colors.sky,
	["Stickies"] = colors.yellow,
	["App Store"] = colors.blue,
	["MongoDB Compass"] = colors.green,
	["Passwords"] = colors.overlay0,
	["Clock"] = colors.text,
}

local refresh_active_windows = function(workspace, window)
	if workspace == nil then
		return
	end
	local cmd = "aerospace list-windows --workspace "
		.. workspace
		.. " --format '%{monitor-id} %{window-id} %{app-name} %{window-title}  %{workspace}' --json"
	sbar.exec(cmd, function(output)
		local is_selected = (AEROSPACE_FOCUSED_SPACE == workspace)
		local has_any = false
		local app_index = 0
		-- space_windows[workspace] = {}
		sbar.set("/space" .. workspace .. ".app\\.*/", {
			drawing = false,
			updates = false,
			background = { drawing = false, color = nil, border_width = 0 },
		})
		for k, v in pairs(output) do
			app_index = app_index + 1
			has_any = true
			local app_name = v["app-name"]
			local newly_focused_window = v["window-id"] == window
			local icon = app_icons[app_name] or app_icons["Default"]
			local color = app_colors[app_name] or colors.overlay1
			if app_index > 5 then
				sbar.set("space" .. workspace .. ".app.ellipses", {
					drawing = true,
				})
			else
				local highlight_opacity = newly_focused_window and 1.0 or 0.5
				local window_title = v["window-title"] or app_name
				-- if newly_focused_window then
				-- window_title = app_name -- because it's going to be updating a lot
				if v["window-title"]:len() > 50 then
					window_title = v["window-title"]:sub(1, 27) .. "..."
				end
				sbar.set("space" .. workspace .. ".app." .. app_index, {
					drawing = true,
					updates = true,
					icon = {
						string = icon,
						color = colors.with_alpha(color, 0.3),
						-- color = colors.grey,
						highlight_color = colors.with_alpha(color, highlight_opacity),
					},
					label = {
						drawing = false,
					},
					background = {
						drawing = newly_focused_window,
						color = newly_focused_window and colors.with_alpha(colors.surface2, 0.45) or nil,
						height = 20,
						corner_radius = 100,
					},
				})
			end
		end
		sbar.set("space" .. workspace .. ".label", {
			drawing = has_any,
			width = 20,
			updates = has_any,
			-- padding_right = has_any and 100 or 0,
		})
		sbar.set("space" .. workspace, {
			drawing = has_any,
			updates = has_any,
		})
		-- sbar.set("space" .. workspace .. ".app.1", {
		-- drawing = has_any,
		-- padding_right = has_any and 100 or 0,
		-- })
		-- sbar.set("space" .. workspace, {
		-- drawing = has_any and 100,
		-- })

		-- sbar.animate("tanh", 10, function()
		-- spaces[workspace]:set({ label = icon_line, drawing = has_any })
		-- })
		-- end)
	end)
end

local get_aerospace_workspaces = function()
	local cmd = io.popen("aerospace list-workspaces --all")
	if not cmd then
		return {}
	end

	local aerospace_spaces = {}
	for line in cmd:lines() do
		table.insert(aerospace_spaces, line)
	end
	cmd:close()
	return aerospace_spaces
end

local aerospace_spaces = get_aerospace_workspaces()

-- for monitor_idx 1, 3 do
-- sbar.set("item", monitor.name, {
-- padding_left = settings.paddings,
-- padding_right = settings.paddings,
-- })
-- end
for idx, i in pairs(aerospace_spaces) do
	spaceapps = { "space" .. i .. ".label" }

	local space_label = sbar.add("item", "space" .. i .. ".label", {
		position = "space." .. i,
		width = 20,
		icon = {
			font = { family = settings.font.numbers, size = 16.0 },
			string = i,
			padding_left = 4,
			padding_right = 0,
			color = colors.overlay1,
			highlight_color = colors.text,
		},
		drawing = false,
	})

	for index = 1, 5 do
		local app_color = colors.text
		local app_icon_size = 22.0
		sbar.add("item", "space" .. i .. ".app." .. index, {
			position = "space." .. i, -- Place it after the workspace number
			drawing = false,
			updates = false,
			icon = {
				string = ":default:", -- Placeholder icon,
				font = {
					family = "sketchybar-app-font",
					style = "Regular",
					size = app_icon_size,
				},
				padding_left = 0,
				padding_right = 0,
				width = app_icon_size,
			},
			label = { drawing = false },
			background = { drawing = false },
		})
		spaceapps[#spaceapps + 1] = "space" .. i .. ".app." .. index
	end

	sbar.add("item", "space" .. i .. ".app.ellipses", {
		position = "space." .. i, -- Place it after the workspace number
		drawing = false,
		align = "left",
		icon = {
			string = "...",
			color = colors.overlay1,
			highlight_color = colors.text,
			font = {
				family = "sketchybar-app-font",
				style = "Regular",
				size = 16.0,
			},
			padding_left = 0,
			padding_right = 0,
		},
		-- label = { drawing = false },
		background = { drawing = false },
	})
	spaceapps[#spaceapps + 1] = "space" .. i .. ".app.ellipses"

	local space = sbar.add("bracket", "space" .. i, spaceapps, {
		-- associated_space = i,
		-- space = i,
		updates = false,
		-- drawing = true,
		-- updates = true,
		-- icon = {
		-- font = { family = settings.font.numbers, size = 16.0 },
		-- string = i,
		-- padding_left = 8,
		-- padding_right = 0,
		-- color = colors.grey,
		-- highlight_color = colors.white,
		-- },
		-- label = {
		-- padding_right = 10,
		-- padding_left = 10,
		-- string = i,
		-- color = colors.grey,
		-- highlight_color = colors.white,
		-- font = "sketchybar-app-font:Regular:20.0",
		-- y_offset = -1,
		-- },
		-- padding_right = 0,
		-- padding_left = 0,
		background = {
			color = colors.with_alpha(colors.bg2, 0.3),
			border_color = colors.with_alpha(colors.bg2, 0.3),
			-- border_width = 1,
			height = 30,
		},
	})

	spaces[i] = space

	-- Padding space
	-- sbar.add("space", "space.padding." .. i, {
	-- script = "",
	-- width = settings.group_paddings,
	-- })

	-- local space_popup = sbar.add("item", {
	-- position = "popup." .. space.name,
	-- padding_left = 5,
	-- padding_right = 0,
	-- background = {
	-- drawing = true,
	-- image = {
	-- corner_radius = 9,
	-- scale = 0.2
	-- }
	-- }
	-- })
	--
	local function show_active_opacity(selected)
		sbar.set("/space" .. i .. "\\.*/", {
			-- space_label:set({
			icon = { highlight = selected },
			-- background = { border_color = selected and colors.black or colors.bg2 },
		})
		sbar.set("space" .. i .. ".label", {
			icon = { highlight = selected },
		})
		local opacity = selected and 0.7 or 0.3
		space:set({
			background = {
				color = colors.with_alpha(colors.bg2, opacity),
				border_color = colors.with_alpha(colors.bg2, opacity),
			},
		})
	end

	space:subscribe("aerospace_workspace_change", function(env)
		local selected = env.FOCUSED_WORKSPACE == i
		local last_selected = env.PREV_WORKSPACE == i
		local color = selected and colors.overlay1 or colors.bg2
		AEROSPACE_FOCUSED_SPACE = env.FOCUSED_WORKSPACE
		if selected or last_selected then
			refresh_active_windows(i)
		end
		show_active_opacity(selected)
	end)

	for idx, name in pairs(spaceapps) do
		sbar.subscribe(name, "mouse.clicked", function(env)
			print(name .. " clicked, switching to workspace " .. i)
			sbar.exec("aerospace workspace " .. i)
		end)
		sbar.subscribe(name, "mouse.exited", function(_)
			if AEROSPACE_FOCUSED_SPACE ~= i then
				print("animating to inactive opacity for space " .. i)
				sbar.animate("tanh", 30, function()
					show_active_opacity(false)
				end)
			end
			print("exited space " .. i)
		end)

		sbar.subscribe(name, "mouse.entered", function(_)
			if AEROSPACE_FOCUSED_SPACE ~= i then
				print("animating to active opacity for space " .. i)
				sbar.animate("tanh", 30, function()
					show_active_opacity(true)
				end)
			end
			-- space:set({ popup = { drawing = false } })
			print("entered space " .. i)
		end)
		-- sbar.subscribe(name, "mouse.entered", function(env)
		-- someething
		-- end
		-- end)
	end

	refresh_active_windows(i)
end

local spaces_indicator = sbar.add("item", {
	padding_left = -3,
	padding_right = 0,
	icon = {
		padding_left = 8,
		padding_right = 9,
		color = colors.overlay1,
		string = icons.switch.on,
	},
	label = {
		width = 0,
		padding_left = 0,
		padding_right = 8,
		string = "Spaces",
		color = colors.bg1,
	},
	background = {
		color = colors.with_alpha(colors.overlay1, 0.0),
		border_color = colors.with_alpha(colors.bg1, 0.0),
	},
})

local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
	update_freq = 5,
})

space_window_observer:subscribe("aerospace_window_focus_change", function(env)
	refresh_active_windows(AEROSPACE_FOCUSED_SPACE, tonumber(env.FOCUSED_WINDOW))
end)

space_window_observer:subscribe("routine", function()
	refresh_active_windows(AEROSPACE_FOCUSED_SPACE)
end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

spaces_indicator:subscribe("mouse.entered", function(env)
	-- sbar.delay(1, function()
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 1.0 },
				border_color = { alpha = 1.0 },
			},
			icon = { color = colors.bg1 },
			label = { width = "dynamic" },
		})
	end)
	-- end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.0 },
				border_color = { alpha = 0.0 },
			},
			icon = { color = colors.overlay1 },
			label = { width = 0 },
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
	sbar.trigger("swap_menus_and_spaces")
end)

spaces[spaces_indicator.name] = spaces_indicator

return spaces
