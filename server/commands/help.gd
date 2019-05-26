func help(args = [], mainServer = null) -> String:
	var result = ""
	if args.size() == 0:
		result = "Here's some help:\n\n\tList of commands:\n\t* help - display a manual for a specific command\n\t* listargs - just lists the arguments\n\t* fps - gives server FPS (frames per second)\n\t* get_player_data - gives the account data of given player"
	elif args.size() > 1:
		result = "help: Too many arguments!"
	else:
		if args[0] == "help":
			result = "\nhelp -- displays a manual for a specific command\n\nUSAGE:\thelp command ...\n\nEXAMPLE:\thelp listargs"
		elif args[0] == "listargs":
			result = "\nlistargs -- lists the arguments you use\n\nUSAGE:\tlistargs arg1 arg2 arg3 ...\n\nThis command is used to check if you type your arguments correctly"
		elif args[0] == "get_player_data":
			result = "\get_player_data -- displays the account data of given player\n\nUSAGE:\tget_player_data player_nickname"
		else:
			result = "help: There's no help page for this command ("+args[0]+")"
	return result
