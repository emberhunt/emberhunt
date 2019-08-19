[//]: <> (Copyright 2019 Emberhunt Team)
[//]: <> (https://github.com/emberhunt)
[//]: <> (Licensed under the GNU General Public License v3.0 or later)
[//]: <> (SPDX-License-Identifier: GPL-3.0-or-later)

![Emberhunt logo](https://i.imgur.com/RyI6qDt.png)
# Emberhunt [![Discord](https://img.shields.io/discord/546682836326023208.svg?label=discord&logo=discord&style=flat)](https://discord.gg/J5B478u) ![Commit activity](https://img.shields.io/github/last-commit/PonasKovas/emberhunt.svg?color=yellow) [![License](https://img.shields.io/badge/license-GPLv3%2FCC--BY--NC--SA-blue.svg)](LICENSE)

*The Dark Lord has fallen, and the Empire rejoices in victory. The last battalion lies in ruins and remains of the dark army hide under the stones. Who would stand for what the Dark Lord believed in? Who would tear the broken blade out of cold hands of those who rested untimely? Pick up the blade! Burn down your foes! Gather your friends and siege the deepest dungeons, the highest peaks to reclaim the Lords power to depose the forces of the Empire! Get your best gear, grind to the highest level and march through the gates of the High Inquisitor palace!*

This project is completely free and open-source mobile game, created with [Godot](https://godotengine.org/).

It's an 8-bit-style realtime bullet-hell MMORPG.
The objective of the game is to fight enemies, pick up their gear and get better. There's no end.
At the beginning, the player choose from 10 classes and then plays until their character dies, and their progress is lost. Then the player can make a new character and play again.

Similar games: [Realm of the Mad God](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=2ahUKEwj4jbiQybzjAhUIqIsKHb6AD1sQFjAAegQIABAB&url=https%3A%2F%2Fwww.realmofthemadgod.com%2F&usg=AOvVaw3oF6qy-HgZqTsGN0X4awir), [Soul Knight](https://play.google.com/store/apps/details?id=com.ChillyRoom.DungeonShooter&hl=en).

## Table of contents
 - [Screenshots](#screenshots)
 - [Goals](#goals)
 - [State of the project](#state)
   - [Scalability](#scalability)
   - [Security](#security)
 - [Setup](#setup)
   - [Server](#server)
   - [Client](#client)
 - [Documentation](#documentation)
 - [Contributing](#contributing)
 - [Who's behind this project](#behind)
 - [License](#license)

<a name="screenshots" />

## Screenshots

<img src='https://i.imgur.com/aXJkYIR.png' width='420'> <img src='https://i.imgur.com/OxiGC7H.png' width='420'> <img src='https://i.imgur.com/Y25NcbY.png' width='420'> <img src='https://i.imgur.com/7RrH5em.gif' width='420'>

<a name="goals" />

## Goals

The main three goals of this project are

 - to provide the mobile game industry a **free** quality MMORPG,
 - to be a good example to other mobile games,
 - and to contribute to the Open-Source software world.
 
<a name="state" />

## State of the project

This project is not very mature yet, we're still working on the core mechanics.

But with the passion and love of our team, it's moving forward very fast.
 
<a name="scalability" />

### Scalabilty

Currently the server is not very scalable, since we're using Godot engine on the server side too.

We have plans to write our own low-level scalable server with Rust in the near future, as Godot wasn't really designed for these kind of things, and is extremely inefficient.
 
<a name="security" />

### Security

We do not guarantee the security of your computer if you try to expose Emberhunt's server to the internet, because, as written before, the server is using Godot engine, which was not designed for this purpose, and might have security flaws. No security flaws have been encountered yet though, so don't assume it's very dangerous too.

Again, this will change in the near future, as we have plans to write our own low-level secure and scalable server dedicated to this game.
 
<a name="setup" />

## Setup

To start working on this project, you will have to download [Godot's executable](https://godotengine.org/download/) first. Godot is very lightweight, so you won't need to install anything, just run the executable and import this project.

You can configure what items there are in the game, and what are the classes initial stats and inventories at `data/`.
 
<a name="server" />

### Server

*[The server can be run in a docker container](../../wiki/Server-Docker)*
To launch the game as server, you have to launch the `server/scenes/MainServer.tscn` scene. It will initialize the server on port `22122` (You can change that at `server/scripts/MainServer.gd`).

By default, the server only accepts a maximum amount of 10 players, you can change that in `server/scripts/MainServer.gd` too.

The server has some commands built in, to execute them you will have to connect to the port `11234` with a TCP connection (For Linux, see [`netcat`](http://netcat.sourceforge.net/)). First you will need to authorize yourself, by sending a password, which is hashed and then compared to the SHA256 hash in `server/cp.pswd`. If they match, you become authorized and now can send commands. For a list of commands execute `help`.

You can easily add more commands, by creating a `GDScript` script in `server/commands/`.
[A more in-depth look at creating commands](../../wiki/Creating-Commands)
 
<a name="client" />

### Client

To launch the game as client, just run it normally, or in other words, the `scenes/MainMenus.tscn` scene.

There's not much configuration on the client side, but you can change the server IP, to which it tries to connect at `scripts/Networking.gd`.
 
<a name="documentation" />

## Documentation

The technical documentation is available [here](../../wiki).

All improvements and modifications are really appreciated, as most of us have a lot of work, and can't really put much time into it.

The game's content wiki is being worked on.
 
<a name="contributing" />

## Contributing

We need:

 - Programmers
 - Artists
 - Sound Engineers/Music composers
 - Testers
 - Lore writers
 - Documentation writers
 - Generally supportive people :heart:

[Join our discord!](https://discord.gg/eEVGG7v)
 
<a name="behind" />

## Who's behind all this

This project is being worked on with passion by our team of complete strangers from all over the world, who have put their strenghts together to create something **good** :)

If you want to **support us**, contact the project leader [**@PonasKovas**](https://github.com/PonasKovas).
 
<a name="license" />

## License

Emberhunt uses 2 licenses.

 - Assets ― [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License](LICENSE.CC-BY-NC-SA-4.0)
   - The [CC-BY-NC-SA 4.0 license](LICENSE.CC-BY-NC-SA-4.0) applies to all files in [assets](assets) folder, except for files with `.import`, `.txt` or `.tres` file extension.
 - Code ― [GNU GENERAL PUBLIC LICENSE](LICENSE.GPL-3.0)
   - The [GPLv3 license](LICENSE.GPL-3.0) applies to all non-asset files, unless specified otherwise.
