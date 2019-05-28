func get_account_data(args = [], mainServer = null) -> String:
	var returnValue = "";
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	for uuid_hash in args:
		if uuid_hash != null:
			var path = "user://serverData/accounts/"+uuid_hash+"/"
			var file = File.new()
			file.open(path+"data.json", file.READ)
			var text = file.get_as_text()
			file.close()
			returnValue += text + "\n"
		else:
			returnValue += uuid_hash + " is not found"
	return returnValue;