# lgetchar
I just wanted a way to detect arrow key presses in Lua.
After scouring the internet and reading very sparse man pages,
this is what I've come up with.

# Usage
For now, this just adds one function, `getchar`.
```lua
local getchar = require("lgetchar").getchar
local c = getchar()
```
Which puts the terminal into raw mode and reads in a character.
In addition, if the char that it reads is 27, then it also reads in the next two.
(Needed for arrow keys).
```lua
local chars = {getchar()}
if chars[1] == 27 then
	-- do stuff
end
```

# Implementation Details
I have no idea how portable this is (probably only works on *nix), but it works on my machine, so whatever.
It uses termio.h to set the terminal and read in a character.

# Anyway
I may add more to this in the future, but the main use for this was for me to imitate some
javascript cli menus that looked neat.