func worlds(args = [], mainServer = null) -> String:
	var returnValue = "";
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	if args.size() == 0:
		return str(mainServer.worlds) + "\n"
	else:
		for worldArg in args:
			var world = mainServer.worlds[worldArg]
			if world != null:
				returnValue += str(world) + "\n"
			else:
				returnValue += worldArg + " does not exist\n"
		return returnValue