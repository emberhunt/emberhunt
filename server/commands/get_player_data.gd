# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "displays the account data of given player"

var _description = """displays the account data of given player

USAGE:	get_player_data <player_nickname>"""


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
