# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later


var _short_description = "shuts down the server."

var _description = """shuts down the server. Use with caution!"""


func exit(args = [], mainServer = null):
  if mainServer == null:
    return "Instance of MainServer.gd is invalid"
  get_tree().quit()
