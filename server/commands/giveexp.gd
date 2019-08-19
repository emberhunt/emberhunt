# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "gives a player a specified amount of experience."

var _description = """gives a player a specified amount of experience.

USAGE:	giveexp <player_id> <amount>."""


func giveexp(args = [], mainServer = null) -> String:
	var special_slots = 1
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	if args.size() == 0:
		return "Please specify an ID, because I need to know who to give the exp to"
	if args.size() == 1:
		return "Please specify an amount"
	
	# Check if a player with specified ID is playing right now
	var all_players = {}
	for world in mainServer.worlds.keys():
		for player_id in mainServer.worlds[world].players.keys():
			all_players[player_id] = world
	if not (int(args[0]) in all_players.keys()):
		return "Nobody is playing with ID "+args[0]+" right now..."
	
	# Check if the exp amount is valid
	if int(args[1]) < 0:
		return "Can't give a negative amount of experience. ("+str(int(args[1]))+")"
	if int(args[1]) == 0:
		return "Is there a point in giving someone 0 experience? Why are you wasting time"
	
	# Give exp
	mainServer.give_exp(all_players[int(args[0])], int(args[0]), int(args[1]))
	
	return "Gave "+args[0]+" "+str(int(args[1]))+" experience."