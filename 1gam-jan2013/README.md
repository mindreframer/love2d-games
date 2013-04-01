# Gameplay video

- [Watch video on Google+](https://plus.google.com/photos/105783622938386957806/albums/5829323380128334929/5835277748884803986)

# Running the game

Linux/OSX/Windows

- [Install LÖVE](https://love2d.org/)
- [Download the game](http://flagrantdisregard.com/wp-content/uploads/2013/01/115-1gam-johnwatson-1c9419e.love)
- Double-click to run it

Windows

- Download:
    - [32 bit](http://flagrantdisregard.com/wp-content/uploads/2013/01/115-1gam-johnwatson-1c9419e_win-x86.zip)
    - [64 bit](http://flagrantdisregard.com/wp-content/uploads/2013/01/115-1gam-johnwatson-1c9419e_win-x64.zip)
- Extract files
- Run 115.exe

Linux/OSX/Windows from source

- Download the source files
- Unzip, keeping the directory structure intact
- Run it with LÖVE. Example:
        $ love [folder name]

# How to play

You are a humble fuel thief trying to make ends meet in a lonely universe.

Maneuver your ship next to asteroids to mine them for fuel. Your ship has a limited amount of fuel. Watch the fuel gauge in your ship carefully!

Fuel you collect fills your tank. Any extra is added to your score. Collect enough extra fuel and to advance to the next level.

Beware of automated mines guarding the fuel asteroids. Although, some pilots have been known to increase their street cred by collecting fuel while being scanned...

- Use `W`, `A`, `S`, and `D` to move
- Collect asteroids by approaching them
- Avoid enemies
- Watch your fuel gauge -- don't run out
- Extra fuel is added to your score -- collect enough to advance
- Press `0` to self destruct
- Press `1`-`9` on start screen to start on that level

# Dev journal

## January 2, 2013

Started coding my first game for #onegameamonth. Spent about a week prior looking over frameworks and decided on using LÖVE with the Zoetrope library. Why? I didn't know Lua but I was curious about it because I know it's fairly widely used in game development. The documentation is good. It has a good reputation for speed (coding-wise and FPS-wise). And it makes distributing finished games easy-ish. I considered pygame but I get a very strong obsolete vibe from it.

Lua is very easy to pick up. Took just a bit of effort to wrap my head around tables and when to use colons instead of dots.

Ran "Hello, World".

Created a player sprite and hooked up keyboard controls using stock LÖVE. I left out Zoetrope at first just to see what I would gain by adding it. Zoetrope immediately let me eliminate a bunch of basic physics code (velocity, acceleration, etc) and helpfully defines all units in terms of pixels/second.

I now have a ship that can use thrusters to move around the screen.

Added boundary checking to make the ship bounce off the window edges.

Added an animation to show the thrust exhaust. Used the Zoetrope Factory class to automatically recycle the particles as needed.

Experimented a bit with PixelEffects (GLSL shaders). What is this I don't even.

I'm finding that I have to keep reminding myself not to polish. I spent a long time getting the thrust feel to a point where it felt good because I think that's important for gameplay. But I also spent more time than I should have on the appearance of the ship and thrust particles which doen't matter at all at this stage.

On the other hand, I'm finding that it's fun to do a little polishing here and there and to jump between subjects (mechanics to graphics to sound) to keep things interesting. When I get bored doing one thing, there's always something else I can jump to.

Hours: 5

## January 3, 2013

Read an article about game mechanics at Wikipedia: http://en.wikipedia.org/wiki/Game_mechanics

## January 4, 2013

Added a thrust sound effect. I started with a short looping sample. I wanted it to fade in but that looked like it was going to take a hack so it turned out it was much simpler to just make the loop much longer (1 minute) and include the fade in at the beginning of the sample. Used Audacity to create the sound (brown noise generator + tone generator + filters).

Added fuel consumption and a fuel gauge to the ship. I started on a HUD, and that was easy, but I've decided to try to make as many elements as possible visual instead of textual. The fuel gauge is drawn as a colored arc within the ship radius.

Added fuel that can be collected by colliding with it.

Did some experimenting with camera following the player and found that I'd written my sprite drawing methods in a way that prevented it from working. Rewrote those correctly and now everything works as expected (camera following the player is kind of neat) except that my thrust particles don't seem to be receiving their coordinates correctly from the framework for some reason. It's like they're not part of the update loop. Can't see the solution right now. It'll probably come to me in the morning.

Got it! With Zoetrope, sprite's might not be drawn correctly unless they have a width and height > 0.

Hours: 3

## January 7, 2013

Added a simple animation to show fuel being absorbed into the player ship. It works by checking for a "collision" between the asteroids and the ship. All of the collision detection and animation code is in the asteroids rather than the ship. If it was in the ship, I'd have to code a loop to check for collisions with each asteroid.

Changed mechanics a little so that the ship's fuel can only increase to a maximum amount. Any fuel collected beyond that is added to a surplus fuel counter which I'm thinking is, essentially, the player score.

Hours: 1

## January 8, 2013

Tweaking mechanics again. Lesson learned: designing a game and tweaking behavior is very time consuming. I may just set out to just flat out clone something next month.

Added some camera shake when thrusting hard off the currrent vector of movement.

Added enemies that scan for the player and home in if the player is within a certain radius. Spent some time (probably, too much time) creating a visualization for the enemy scanning radius so the player knows what areas he should avoid.

Hours: 3

## January 9, 2013

Added "gravity" to the tractor beam so that there is a slight pull towards the asteroids as they are being absorbed by the player. I'm aiming for a somewhat subtle effect. It can be used by players to line up their runs to collect as much fuel as possible without thrusters. The extra pull encourages players to develop a flow, slingshotting themselves from one asteroid to the next.

Used Audacity and http://www.bfxr.net/ to make sound effects.

Added more sound effects and a few additional visual effects.

Enemy scanning sound effects adapted from the Conet Project (number stations).

Inspired by the number station audio I added for the enemy ships, I added some more graphics stuff when the enemy has detected the player. I think she's saying, "eins eins fünf".

Added a custom font from http://www.dafont.com/8th-cargo.font

Adding beeping sound when the enemy is homing in on the player. The frequency of the beeps increases as the enemy closes in.

Added camera shake when the player hits a wall.

Hours: 12

## January 10, 2013

Added self destruct button, animation, and sound effect. For those moments when you run out of fuel and you're bored of waiting for a asteroid to float within range.

The framework (Zoetrope with Love2d) I'm using says you can play() a sound that is already playing and nothing happens (it'll just keep playing). But I've found that if you do that in the update loop then the game crashes at random times. The solution is just to check if the sound is already playing first.

Added levels.

Added game play instructions. Bug fixes.

Hours: 6

## January 11, 2013

Game is really coming together now. It's fully playable with a classic start screen, level progression, and a game over screen.

Now that the game is playable from beginning to end, I'm starting on some of the polish I'd been putting off. First up is making the HUD look awesome. This phase is fun but it's very time consuming. Making art and music is hard.

Up to now, all of the graphics have been procedurally generated. Most of it still is but I'm adding some bitmaps, like the cockpit controls. The cockpit is bitmap with open areas that I can draw procedural content onto to bring it to life. Particularly proud of the gauges and the holographic looking scanner.

Managing the state of the game almost isn't a problem but I can see that it could get very complicated for a game even moderately more complex than this one. The state of the player, the world, and other objects in game and how they all interact is crazy. For my next game, I need to do some research into state management to see if there's a sane way to manage state and changes between state.

Hours: 10

## January 15, 2013

Updated HUD graphic. Bug fixes. Tweaked fuel collection rate.

Added sound effect for completely mining an asteroid. Added bonus points with particles.

Hours: 4

## January 17, 2013

Learned about shaders today. Hacked together a bloom effect from code on the Love2D forum and got it working with Zoetrope. I made a small change to the Zoetrope library to get get it working but I don't know if the bug is with my code or with the library.

After all that, I ended up turning the bloom effect off because my son thought the unbloomed version looked better. I left all the code in though. To turn it on just uncomment the setEffect() line in main.lua.

Added a particle emitter to create a moving starfield on the play field. Using a particle emitter makes it trivially easy to manage hundreds of stars moving in the background. The illusion of depth is achieved by varying the size, brightness, and speed of each particle as it is generated.

Hours: 2

## January 18, 2013

Rewrote how music is loaded. The old way created a new sound source on the fly as the music changed. That was causing the game to stutter whenever the music changed. The new way creates all of the sound sources up front.

Spent some time compressing and normalizing the music in Audacity so I can get consistent volume throughout the game. I couldn't figure out how to do that in LMMS but it was easy enough to do it in post with Audacity.

Hours: 4
