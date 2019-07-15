# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "gives the account data with UUID as parameter."

var _description = """gives the account data with UUID as parameter

USAGE:	get_account_data <player_uuid>."""


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