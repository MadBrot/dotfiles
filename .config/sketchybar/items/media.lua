local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local supported_apps = {
	["Spotify"] = true,
	["Music"] = true,
	["YouTube Music"] = true,
	["Zen"] = true,
	["Zen Browser"] = true,
}

local app_bundle_ids = {
	["Spotify"] = "com.spotify.client",
	["Music"] = "com.apple.Music",
	["YouTube Music"] = "app.zen-browser.zen",
	["Zen"] = "app.zen-browser.zen",
	["Zen Browser"] = "app.zen-browser.zen",
}

local active_app = nil

local media = sbar.add("item", "media.now_playing", {
	position = "center",
	drawing = false,
	updates = true,
	update_freq = 2,
	icon = {
		string = app_icons["Spotify"],
		font = {
			family = "sketchybar-app-font",
			style = "Regular",
			size = 20.0,
		},
		padding_left = 8,
		padding_right = 6,
	},
	label = {
		max_chars = 42,
		width = "dynamic",
		scroll_duration = 1200,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = 12.0,
		},
		color = colors.text,
		padding_right = 10,
	},
	background = {
		color = colors.with_alpha(colors.bg2, 0.45),
		border_color = colors.with_alpha(colors.bg2, 0.45),
		height = 30,
		corner_radius = 10,
	},
})

local media_detail = sbar.add("item", "media.now_playing.detail", {
	position = "popup." .. media.name,
	icon = { drawing = false },
	label = {
		max_chars = 60,
		width = 260,
		align = "center",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 11.0,
		},
		color = colors.subtext1,
	},
})

local function is_supported(app)
	if supported_apps[app] then
		return true
	end

	local lower = string.lower(app or "")
	return lower:find("zen", 1, true) ~= nil
end

local function app_color(app)
	if app == "Spotify" then
		return colors.green
	end
	if app == "Music" then
		return colors.red
	end
	return colors.lavender
end

local function compact_text(title, artist)
	local clean_title = (title or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local clean_artist = (artist or ""):gsub("^%s+", ""):gsub("%s+$", "")

	if clean_title ~= "" and clean_artist ~= "" and clean_title ~= clean_artist then
		return clean_artist .. " - " .. clean_title
	end
	if clean_title ~= "" then
		return clean_title
	end
	if clean_artist ~= "" then
		return clean_artist
	end
	return nil
end

local function scrolling_text(text)
	return text .. "       "
end

local function refresh_media()
	sbar.exec("osascript -l JavaScript $CONFIG_DIR/helpers/media_now_playing.js", function(output)
		local state, app, artist, title = output:match("([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t\n]*)")

		if not state or state ~= "playing" or not app or app == "" or not is_supported(app) then
			active_app = nil
			media:set({
				drawing = false,
				popup = { drawing = false },
			})
			return
		end

		local text = compact_text(title, artist)
		if not text then
			active_app = nil
			media:set({
				drawing = false,
				popup = { drawing = false },
			})
			return
		end

		active_app = app
		media:set({
			drawing = true,
			icon = {
				string = app_icons[app] or app_icons["Default"],
				color = app_color(app),
			},
			label = {
				string = scrolling_text(text),
			},
		})

		media_detail:set({
			label = {
				string = app .. " - " .. text,
			},
		})
	end)
end

media:subscribe({ "routine", "system_woke", "forced" }, refresh_media)

media:subscribe("mouse.clicked", function()
	local bundle_id = app_bundle_ids[active_app or ""]
	if bundle_id then
		sbar.exec("open -b " .. bundle_id)
	end
end)

refresh_media()

return media
