# Systemnauts 
Linux in cyberspace (or inside Linux).

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

![](/screenshot.png)
