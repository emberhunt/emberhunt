func help(args = []):
	if args.size() == 0:
		print("Here's some help:\n\n\tList of commands:\n\t* help - display a manual for a specific command\n\t* listArgs - just lists the arguments")
	elif args.size() > 1:
		print("help: Too many arguments!")
	else:
		if args[0] == "listArgs":
			print("\nlistArgs -- lists the arguments you use\n\nUSAGE:\tlistArgs arg1 arg2 arg3 ...\n\nThis command is used to check if you type your arguments correctly")
		else:
			print("help: There's no help page for this command ("+args[0]+")")
