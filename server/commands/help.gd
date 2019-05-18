func help(args = []):
	if args.size() == 0:
		print("Here's some help:\n\n\tList of commands:\n\t* help - display a manual for a specific command\n\t* listargs - just lists the arguments\n\t* fps - gives server FPS (frames per second)")
	elif args.size() > 1:
		print("help: Too many arguments!")
	else:
		if args[0] == "help":
			print("\nhelp -- displays a manual for a specific command\n\nUSAGE:\thelp command ...\n\nEXAMPLE:\thelp listargs")
		elif args[0] == "listargs":
			print("\nlistargs -- lists the arguments you use\n\nUSAGE:\tlistargs arg1 arg2 arg3 ...\n\nThis command is used to check if you type your arguments correctly")
		else:
			print("help: There's no help page for this command ("+args[0]+")")
