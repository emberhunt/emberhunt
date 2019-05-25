![Emberhunt logo](https://i.imgur.com/RQtmQoM.png)
# Emberhunt [![Discord](https://img.shields.io/discord/546682836326023208.svg?label=discord&logo=discord&style=flat)](https://discord.gg/J5B478u) ![Commit activity](https://img.shields.io/github/last-commit/PonasKovas/emberhunt.svg?color=yellow) [![Server Status](http://mykolo.we2host.lt/pingServer?)](http://mykolo.we2host.lt/pingServer) [![License](https://img.shields.io/badge/license-GPLv3%2FCC--BY--NC--SA-blue.svg)](LICENSE) [![Beerpay](https://img.shields.io/beerpay/PonasKovas/emberhunt.svg)](https://beerpay.io/PonasKovas/emberhunt)


This project is completely free and open-source mobile MMORPG game, created with [Godot](https://godotengine.org/).

## Lore

A God of Darkness sends knights of darkness to the surface world to conquer it, but the Royal Empire resists. The player is one of those dark knights who must explore the world, killing everyone who is not a dark knight (cooperative style) and gathering items, gaining experience, leveling up and becoming stronger.

## Contributing

Everyone is welcome to contribute and help develop this project. We need programmers, artists, sound-engineers, testers, writers... If you want to help, just [join our discord](https://discord.gg/eEVGG7v), and we will discuss how you can help.

## Donating

You can donate [here](https://beerpay.io/PonasKovas/emberhunt)<br />
The money will be used to keep the servers running.

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
 - Code ― [GNU GENERAL PUBLIC LICENSE](LICENSE.GPLv3)
   - The [GPLv3 license](LICENSE.GPLv3) applies to all non-asset files.

## Credits

This game is being created thanks to these people:
* [PonasM](https://github.com/PonasKovas) - programming
* Rokas Sutkus - sound design
* [Altered Beats](https://soundcloud.com/altrdbts) - composer
* [cobrapitz](https://github.com/cobrapitz) - programming
* Maksym Novikov - writing
* Cap’n Saicin - art
* Varied Scribbles - sound design
