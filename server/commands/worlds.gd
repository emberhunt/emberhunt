# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "gives the world data with optional parameters"

var _description = """gives the world data with optional parameters

USAGE:	worlds [world_name] [players|bags|enemies|npc] [...]"""


func worlds(args = [], mainServer = null) -> String:
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	if args.size() == 0:
		return str(mainServer.worlds) + "\n"
	else:
		var worlds = mainServer.worlds.duplicate()
		for arg in args:
			if worlds.has(str(arg)):
				worlds = worlds[str(arg)]
			elif worlds.has(int(arg)):
				worlds = worlds[int(arg)]
			else:
				return arg+" does not exist"
		return str(worlds)