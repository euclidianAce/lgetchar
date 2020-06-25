# lgetchar
I just wanted a way to detect arrow key presses in Lua.
After scouring the internet and reading very sparse man pages,
this is what I've come up with.

# Installation
lgetchar is avaliable on luarocks
```sh
luarocks install lgetchar
```

Or you can build from source with your choice of C compiler, for example:
```sh
gcc -fPIC -c lgetchar.c -o lgetchar.o -llua
gcc lgetchar.o -shared -o lgetchar.so
```

# Usage
For now it just adds these functions

 - `getChar()`
 - `getCharSeq(n)`

Which for Windows, basically just calls `getch()`, and for non-windows will put the terminal into raw mode, shut echo off and call `getchar()`.

# Implementation Details
For Windows, this is basically a wrapper for `getch()` from conio.h.
For \*nix, this uses termios.h and sys/ioctl.h to change some terminal settings (mainly turning off echo) and calls `getchar()`.
I still have no idea how portable this is, but it has worked on a few of my machines decently enough.

# Anyway
I may add more to this in the future, but the main use for this was for me to imitate some javascript cli menus that looked neat.
