[//]: <> (Copyright 2019 Emberhunt Team)
[//]: <> (https://github.com/emberhunt)
[//]: <> (Licensed under the GNU General Public License v3.0 or later)
[//]: <> (SPDX-License-Identifier: GPL-3.0-or-later)

![Emberhunt logo](https://i.imgur.com/YqUsW5u.png)
# Emberhunt [![Discord](https://img.shields.io/discord/546682836326023208.svg?label=discord&logo=discord&style=flat)](https://discord.gg/J5B478u) ![Commit activity](https://img.shields.io/github/last-commit/PonasKovas/emberhunt.svg?color=yellow) [![Server Status](http://mykolo.we2host.lt/pingServer?)](http://mykolo.we2host.lt/pingServer) [![License](https://img.shields.io/badge/license-GPLv3%2FCC--BY--NC--SA-blue.svg)](LICENSE)


This project is completely free and open-source mobile MMORPG game, created with [Godot](https://godotengine.org/).

## Lore

The Dark Lord has fallen, and the alliance rejoices in victory. The last battalion lies in ruins and remains of the dark army hide under the stones. Who would stand for what the Dark Lord believed in? Who would tear the broken blade out of cold hands of those who rested untimely? Pick up the blade! Burn down your foes! Gather your friends and siege the deepest dungeons, the highest peaks to reclaim the Lords power to depose the forces of the Empire! Get your best gear, grind to the highest level and march through the gates of the High Inquisitor palace!

## Set up

Before working on the project, make sure that you have the latest version of the [emberfont](https://github.com/emberhunt/emberfont). To do that, just execute [update_font.sh](update_font.sh)

## Contributing

Everyone is welcome to contribute and help develop this project. We need programmers, artists, sound-engineers, testers, writers... If you want to help, just [join our discord](https://discord.gg/eEVGG7v), and we will discuss how you can help.

## Documentation

Read the [wiki](../../wiki).

## Docker

The server can be run in a docker container. To get the container up and running simply install docker [installation instructions](https://docs.docker.com/install/).  

Build the image
```
docker build -t emberhunt_server:latest .
```

Run the container
```
docker run -it -p "22122:22122/udp" emberhunt_server:latest
```

## License

Emberhunt uses 2 licenses.

 - Assets ― [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License](LICENSE.CC-BY-NC-SA-4.0)
   - The [CC-BY-NC-SA 4.0 license](LICENSE.CC-BY-NC-SA-4.0) applies to all files in [assets](assets) folder, except for files with `.import` file extension.
 - Code ― [GNU GENERAL PUBLIC LICENSE](LICENSE.GPL-3.0)
   - The [GPLv3 license](LICENSE.GPL-3.0) applies to all non-asset files.
