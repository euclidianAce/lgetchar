# lgetchar
I just wanted a way to detect arrow key presses in Lua.
After scouring the internet and reading very sparse man pages,
this is what I've come up with.

# Installation
lgetchar is avaliable on luarocks
```sh
luarocks install lgetchar
```

Or you can build from source with your choice of C compiler
```sh
gcc -fPIC -c lgetchar.c -o lgetchar.o -llua
gcc lgetchar.o -shared -o lgetchar.so -llua
```

# Usage
For now, this just adds three functions which almost all do the same thing.

 - `getChar()`
 - `getCharSeq()`
 - `getEscSeq()`

Which all put the terminal into raw mode, shuts echo off and reads in a character or more and returns the ascii codes.

# Implementation Details
I have no idea how portable this is (probably only works on \*nix), but it works on my machine, so whatever.
It uses termios.h and sys/ioctl.h to set the terminal and read in a character.

# Anyway
I may add more to this in the future, but the main use for this was for me to imitate some javascript cli menus that looked neat.
