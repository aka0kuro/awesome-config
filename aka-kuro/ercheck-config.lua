local naughty = require("naughty")

if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title  = "WINDOW MANAGER STARTUP ERROR",
		text   = awesome.startup_errors
	})
end

do
	local in_error = false
	awesome.connect_signal(
		"debug::error",
		function (err)
			if in_error then return end
			in_error = true

			naughty.notify({
				preset  = naughty.config.presets.critical,
				title   = "WINDOW MANAGER ERROR",
				text    = err,
				font    = "Sans 8",
				height  = 500
			})
			in_error = false
		end
	)
end
