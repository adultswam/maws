mp.enable_messages("error")

mp.add_periodic_timer(5, function()
	local myTime = mp.get_property_osd("time-pos")
	local myDura = mp.get_property_osd("duration")
	local myPerc = mp.get_property_osd("percent-pos")
	local file = io.open("c:\\path\\to\\ahkbot_directory\\mpvprogress.txt", "w")
	file:write(myTime, "\n", myDura, "\n", myPerc, "\n")
	file:close()
end)

function my_fn(event)
    local file2 = io.open("c:\\path\\to\\ahkbot_directory\\mpverror.txt", "w")
	file2:write(event.prefix, "\n", event.level, "\n", event.text)
	file2:close()
end

mp.register_event("log-message", my_fn)
