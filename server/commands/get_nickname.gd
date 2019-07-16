# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "displays a player's nickname"

var _description = """displays a player's nickname

USAGE:	get_nickname <player ID>"""


func get_nickname(args = [], mainServer = null):
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	
	if args.size()!=1:
		return "Please specify (only) a player's ID."
	
	var nickname = ""
	
	for world in mainServer.worlds.keys():
		if int(args[0]) in mainServer.worlds[world].players:
			nickname = mainServer.worlds[world].players[int(args[0])].nickname
			break
	
	if nickname == "":
		return "No player with the specified ID was found"
	
	return nickname