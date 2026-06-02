local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local slack = sbar.add("item", "widgets.slack", {
	position = "right",
	icon = {
		string = icons.slack,
		color = colors.mauve,
		font = {
			family = settings.font.icons,
			style = settings.font.style_map["Regular"],
			size = settings.font.icon_size,
		},
	},
	label = {
		drawing = false,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		color = colors.text,
		y_offset = 6,
		x_offset = -4,
	},
	padding_right = settings.paddings,
	update_freq = 5,
})

local function update_slack()
	sbar.exec(
		"osascript -e '"
			.. 'tell application "System Events" to tell process "Dock" to '
			.. 'try\nget value of attribute "AXStatusLabel" of '
			.. '(first UI element of list 1 whose name contains "Slack")\n'
			.. 'on error\nreturn ""\nend try'
			.. "' 2>/dev/null",
		function(result)
			local count = result:match("^%s*(.-)%s*$")
			local num = tonumber(count)
			if num and num > 0 then
				slack:set({
					icon = { color = colors.mauve },
					label = { string = tostring(num), drawing = true },
				})
			else
				slack:set({
					icon = { color = colors.with_alpha(colors.mauve, 0.4) },
					label = { drawing = false },
				})
			end
		end
	)
end

slack:subscribe("routine", update_slack)
slack:subscribe("system_woke", update_slack)

sbar.add("bracket", "widgets.slack.bracket", { slack.name }, {
	background = {
		color = colors.with_alpha(colors.bg2, 0.3),
		border_color = colors.with_alpha(colors.bg2, 0.3),
		height = 30,
	},
})

update_slack()
