local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local ram = sbar.add("graph", "widgets.ram", 42, {
	position = "right",
	graph = { color = colors.mauve },
	background = {
		height = 30,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = false,
	},
	icon = { string = icons.ram },
	label = {
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Regular"],
			size = 9.0,
		},
		align = "right",
		padding_right = 0,
		width = 0,
		y_offset = 8,
	},
	padding_right = settings.paddings + 6,
	update_freq = 5,
})

local function update_ram()
	sbar.exec("$CONFIG_DIR/helpers/ram_usage.sh", function(result)
		local pct, gb = result:match("(%d+)%s+([%d%.]+)")
		pct = tonumber(pct)
		gb = tonumber(gb)
		if not pct then return end

		ram:push({ pct / 100.0 })

		local color = colors.mauve
		if pct > 80 then
			color = colors.red
		elseif pct > 60 then
			color = colors.orange
		elseif pct > 40 then
			color = colors.yellow
		end

		ram:set({
			graph = { color = color },
			label = string.format("ram %.1fG", gb),
			icon = { color = color },
		})
	end)
end

ram:subscribe("routine", update_ram)
ram:subscribe("system_woke", update_ram)

sbar.add("bracket", "widgets.ram.bracket", { ram.name }, {
	background = {
		color = colors.with_alpha(colors.bg2, 0.3),
		border_color = colors.with_alpha(colors.bg2, 0.3),
		height = 30,
	},
})

update_ram()
