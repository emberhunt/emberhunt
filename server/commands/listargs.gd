func listargs(args = [], mainServer = null):
	var returnValue = "Arguments used in this command:\n"
	for arg in args:
		returnValue += "* "+arg+"\n"
	return returnValue