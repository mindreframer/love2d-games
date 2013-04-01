# Phaedra

## Synopsis

This is an entry for the [25th Ludum Dare game jam](http://www.ludumdare.com/).
It's based on the theme *You are the Villain*.  
  
You are the evil overlord of a dungeon fortress and adventuring parties are raiding your dungeon for treasures and ultimately are attempting to slaughter you in the name of their king! To keep yourself safe while your army die horribly for you (as any good villain would), you stay in the luxurious heart of your fortress, watching over the battle with your seer's magic. You decide that without your brilliant command, the battle will be lost, so you use your magic to control your minions from afar and control the tide of the battle against the onslaught of heroes.

![Screenshot](http://i.imgur.com/fsxm7.png)

## Running

### Windows

The executable and all of the dependencies should be distributed in a `.zip` archive for you, so you can just extract the archive with your archive manager of choice and run the `.exe` to start playing!

### OSX

The executable should be distributed in a `.tar.gz` archive for you. You will first need to install [love2d 0.8.0](http://love2d.org) (the downloads are on the frontpage) and run the shell script `run.sh` once you have. We're sorry for forcing you to install dependencies, but we don't have an OSX user on our team so we were unable to test an installer.

### Linux

The executable should be distributed in a `.tar.gz` archive for you.  Depending on your distribution, you may need to install further dependencies by your package manager. Once you have installed the dependencies (using the methods described below) you can run the shell script `run.sh` included in the archive to run the game. We apologize for needing to install dependencies, but this is the best way we could think of distributing the game while sticking with the Linux philosophy. The game has been tested on 64-bit ArchLinux.

#### ArchLinux

`sudo pacman -S love`

Alternatively, install `phaedra` [from the AUR](http://aur.archlinux.org/packages/phaedra).

#### Ubuntu

N.B. The default `love` package in the Ubuntu package registry is not `0.8.0` on all systems, so you need to add the official love PPA.

```
apt-add-repository ppa:bartbes/love-stable
apt-get update
apt-get install love
```

#### Fedora

`yum install love`

#### Others

You will need to install [love2d 0.8.0](http://love2d.org) either from your system's package manager or source.

## Gameplay

The game blends the action and strategy genres by allowing you to control a minion directly with the WASD keys and attack, or select a group of minions using left click and drag and then right click to direct them towards enemies.  
  
The aim of the game is to prevent all of your minions from dieing, as they are the only thing stopping the heroes from getting to the heart of the dungeon, slaying you and stealing all of your treasure. The top left of the HUD shows a progress bar, which at the start of the game has a red bar and a blue bar which are of equal length. The red bar represents how close the minions are to killing all heroes (i.e. how close you are to winning) and the blue bar represents how close the heroes are to winning (i.e. how close you are to losing). There are four waves of heroes (the next wave starts after you kill all the alive heroes, an exclamation mark is shown on the minimap where the new wave spawn is). If you kill all four waves of the heroes and have minions left, you win and get to keep all your treasures and life!

### Controls

* `left mouse` - clicking on a minion (your evil servants fighting the invading heroes) will select it
* `left mouse + drag` - select a group of minions and then right click somewhere to direct them towards it
* `w, a, s, d` - four directional movement when a minion is under control, otherwise moves the camera
* `shift` - faster camera movement
* `space` - attack in the current direction when a minion is under control
* `arrow keys` - move the camera
* `escape` - stop controlling any minions

## Issues

We felt that game was moderately polished but there were definitely things we wanted to add but couldn't due to lack of time:

* Attack animations
* Cosmetics, such as fading in after the loading GUI, fading out on death, fading into red and out on damage instead of flashing, etc.
* Stairs for where heroes spawn
* Cooler dungeon decorations (we had torches, tables, roast food, etc. that we ran out of time to add to the generator)

There are also definitely some bugs here and here but nothing urgent; weird flipping in animations and such.

## Contributing

You must follow the code style guidelines:

1. Indent with four spaces
2. Add a new line after each file
3. Use camelBump case
4. Spaces between operators and expressions

### Windows

1. `util/dist.bat` will zip all of the source into a .love file, turn it into an executable and then run it
2. `dist/phaedra.exe` will be the distributable executable
3. All DLLs needed when distributing should be in the `deps` directory

### Linux

1. `util/dist.sh` will zip all of the source into a .love file, turn it into an executable and then run it
2. `dist/phaedra` will be the distributable executable
3. All shared libraries needed to run, should in most cases, be installed by the package manager and not handled by us
