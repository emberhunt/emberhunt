# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

func help(args = [], mainServer = null) -> String:
	var result = ""
	if args.size() == 0:
		result = "Here's some help:\n\n\tList of commands:\n\t* help - display a manual for a specific command\n\t* listargs - just lists the arguments\n\t* fps - gives server FPS (frames per second)\n\t* get_player_data <nickname> - gives the account data with nickname as parameter\n\t* get_account_data <uuid> - gives the account data with UUID as parameter\n\t* worlds [world_name] [players|bags|enemies|npc] [...] - gives the world data with optional parameters\n\t* give <player id> <item id> [amount] - gives a player an item"
	elif args.size() > 1:
		result = "help: Too many arguments!"
	else:
		if args[0] == "help":
			result = "\nhelp -- displays a manual for a specific command\n\nUSAGE:\thelp <command> ...\n\nEXAMPLE:\thelp listargs"
		elif args[0] == "listargs":
			result = "\nlistargs -- lists the arguments you use\n\nUSAGE:\tlistargs arg1 arg2 arg3 ...\n\nThis command is used to check if you type your arguments correctly"
		elif args[0] == "get_player_data":
			result = "\nget_player_data -- displays the account data of given player\n\nUSAGE:\tget_player_data <player_nickname>"
		elif args[0] == "get_account_data":
			result = "\nget_account_data - gives the account data with UUID as parameter \n\nUSAGE:\tget_account_data <player_uuid>."
		elif args[0] == "worlds":
			result = "\nworlds - gives the world data with optional parameters \n\nUSAGE:\tworlds [world_name] [players|bags|enemies|npc] [...]"
		elif args[0] == "give":
			result = "\ngive - gives a player an item \n\nUSAGE:\tgive <player id> <item id> [amount]"
		else:
			result = "help: There's no help page for this command ("+args[0]+")"
	return result
