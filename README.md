# Hatred
#### A skeleton project for the Love game framework

[Love2D](https://love2d.org/) is a fun project that makes game development in
pure Lua easy! Unfortunately, Lua can be a unnecessarily awkward to develop
games in without some convenience libraries. I'm building a custom project
skeleton for building games with Love that provides handy libraries including:
[Middleclass](https://github.com/kikito/middleclass) (a class implementation),
[Stateful](https://github.com/kikito/stateful.lua) (a GoF state pattern mixin
for Middleclass), and a few more.

On top of the libs, there'll be a small amount of project code. I like to have
some easy resource loading/managing code in place, and I tend to not use the 
Love callbacks, and hijack things by overriding love.run() for some bonus
fine-grained control and testability.

I'll also be including a test frame work (probably
[Busted](https://github.com/Olivine-Labs/busted), which I haven't tried, but
looks pretty good), some specs for the base code, and some handy tools like
luacov (a code coverage tool).

There'll even be a Makefile or something (last I checked no one has made a 
decent make/rake equivalent for Lua), that'll do things that need doing.

