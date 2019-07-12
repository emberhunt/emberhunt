# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

func exit(args = [], mainServer = null) -> String:
	if mainServer == null:
		return "Instance of MainServer.gd is invalid"
	if args.empty() or args[0] == "0":
		mainServer.get_tree().quit()
	else:
		var exception = mainServer.doSomethingToCrash()
	return "Exited"
