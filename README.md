# Systemnauts 
A first person MMORPG Linux file manager set in cyberspace.

## The Gist
The game is set *inside* a computer operating system.
The rooms are directories.
The player is represented by a shell process.
Player actions are carried out in the shell.
For example, when the player moves from one room to another in the 3D game world,
the `cd` command will be executed in their shell.

Commands on the underlying OS can also influence the game world.
For example, doors will become locked if the mode of directories is changed, 
such that the player user does not have permission to enter them.

### RPG Elements
- Players can get upgrades, like increased file system quotas and extra ram and cpu, making them more powerful and certain tasks easier.
- Players can obtain various binaries that allow the execute powerful commands on the operating system.
- Groups (like Guilds) allow the player to enter directories and execute commands that they couldn't otherwise.

### MMO Elements
- Each solar system runs on its own machine (VM, VPS or Bare Metal). Players can assist or attack each other over the internet, and visit other solar systems via SSH.

![](https://media.githubusercontent.com/media/lihop/systemnauts/d03f6c409f036f8bba83c0b8556d906528f49e58/screenshot.png)
