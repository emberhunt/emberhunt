#!/bin/bash

# Copyright 2019 Emberhunt Team
# https://github.com/emberhunt
# Licensed under the GNU General Public License v3.0 or later
# SPDX-License-Identifier: GPL-3.0-or-later

git submodule update --init --recursive &&
git submodule foreach git pull origin master &&
echo "Submodules updated successfully. Press any key to continue"
read -n 1 -s -r -p ""