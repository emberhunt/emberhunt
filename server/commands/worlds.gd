func worlds(args = [], mainServer = null) -> String:
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	if args.size() == 0:
		return str(mainServer.worlds) + "\n"
	else:
		var worlds = mainServer.worlds.duplicate()
		for arg in args:
			if worlds.has(str(arg)):
				worlds = worlds[str(arg)]
			elif worlds.has(int(arg)):
				worlds = worlds[int(arg)]
			else:
				return arg+" does not exist"
		return str(worlds)