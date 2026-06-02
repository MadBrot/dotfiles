ObjC.import("Foundation")

function unwrap(value) {
	if (value === null || value === undefined) return ""
	try {
		return ObjC.unwrap(value)
	} catch (_) {
		return value.js !== undefined ? value.js : ""
	}
}

function clean(value) {
	return String(value || "")
		.replace(/[\t\r\n]+/g, " ")
		.replace(/\s+/g, " ")
		.trim()
}

function run() {
	const MediaRemote = $.NSBundle.bundleWithPath("/System/Library/PrivateFrameworks/MediaRemote.framework/")
	if (!MediaRemote) {
		return "stopped\t\t\t"
	}
	MediaRemote.load

	const MRNowPlayingRequest = $.NSClassFromString("MRNowPlayingRequest")
	if (!MRNowPlayingRequest) {
		return "stopped\t\t\t"
	}

	const playerPath = MRNowPlayingRequest.localNowPlayingPlayerPath
	const item = MRNowPlayingRequest.localNowPlayingItem
	if (!playerPath || !item) {
		return "stopped\t\t\t"
	}

	const info = item.nowPlayingInfo
	if (!info) {
		return "stopped\t\t\t"
	}

	const app = clean(unwrap(playerPath.client.displayName))
	const title = clean(unwrap(info.valueForKey("kMRMediaRemoteNowPlayingInfoTitle")))
	const artist = clean(unwrap(info.valueForKey("kMRMediaRemoteNowPlayingInfoArtist")))
	const rate = Number(unwrap(info.valueForKey("kMRMediaRemoteNowPlayingInfoPlaybackRate")) || 0)
	const state = rate > 0 ? "playing" : "paused"

	return [state, app, artist, title].join("\t")
}
