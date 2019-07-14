# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

func exit(args = [], mainServer = null):
  if mainServer == null:
    return "Instance of MainServer.gd is invalid"
  get_tree().quit()
