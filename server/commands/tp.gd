# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "teleports a player to a given position"

var _description = """teleports a player to a given position

USAGE:	tp <nickname> <x> <y>"""


func tp(args = [], mainServer = null):
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	
	# Make sure all arguments are present
	if args.size() != 3:
		return "Invalid amount of arguments provided."
	
	var nickname = args[0]
	var x = float(args[1])
	var y = float(args[2])
	
	# Find the player's ID
	# and in which world they are
	var data = find_player(mainServer, nickname)
	if data.empty():
		return "Player with nickname "+nickname+" was not found."
	
	mainServer.worlds[data.world].players[data.id].position = Vector2(x, y)
	mainServer.get_node("/root/MainServer/"+data.world+"/Entities/players/" + str(data.id)).position = Vector2(x, y)
	
	return nickname+" moved to ("+str(x)+", "+str(y)+")."

func find_player(mainServer, nickname):
	for world in mainServer.worlds.keys():
		for player in mainServer.worlds[world].players.keys():
			if mainServer.worlds[world].players[player].nickname == nickname:
				return {"world":world, "id": player}
	return {}