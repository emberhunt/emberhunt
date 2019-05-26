func get_player_data(args = [], mainServer = null) -> String:
	var returnValue = "";
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	for nickname in args:
		var uuid_hash = mainServer.getUuidFromNickname(nickname)
		if uuid_hash != null:
			var path = "user://serverData/accounts/"+uuid_hash+"/"
			var file = File.new()
			file.open(path+"data.json", file.READ)
			var text = file.get_as_text()
			file.close()
			returnValue += text + "\n"
		else:
			returnValue += nickname + " is not found"
	return returnValue;