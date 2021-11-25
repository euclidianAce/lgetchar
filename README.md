# lgetchar
I just wanted a way to detect arrow key presses in Lua.
After scouring the internet and reading very sparse man pages, this is what I've come up with.

# Teal
## (i.e. What are all those .tl files?)
This module is written with [Teal](https://github.com/teal-language/tl), a typed dialect of Lua.

# Installation
lgetchar is avaliable on luarocks
```sh
luarocks install lgetchar --dev
```

Or you can build from source by cloning the repo and running `make` (hopefully)

# Usage
lgetchar is separated into 3 modules:
 - `raw`: the C component that controls the terminal, you shouldn't need to use this directly, but hey, it's there if you want.
 - `wrapper`: Lua wrappers around the `raw` component for more convenience. Again, probably don't need this, but could be useful.
 - `lgetchar`: The main module.

### `raw`
 - `lgetchar.raw.setup(): boolean` `lgetchar.raw.restore(): boolean`
 	- Toggle canonical mode and echo, returns whether or not the operation succeeded
 - `lgetchar.raw.getChar(noSetup: boolean): integer`
 	- calls `getch` or `getchar` and returns the result
	- pass in `true` if you want to manually `raw.setup` yourself
 - `lgetchar.raw.getCharSeq(len: integer, noSetup: boolean): integer...`
 	- calls `getch` or `getchar` `len` times and returns the results
	- pass in `true` if you want to manually `raw.setup` yourself
### `wrapper`
 - `lgetchar.wrapper.keys: {string:{integer}}`
 	- A map of keys to use in `expect` functions
	- For example, `keys.up` is the up arrow escape sequence, `{27, 91, 65}`
 - `lgetchar.wrapper.expect(keys: {integer}): integer`
 	- calls `raw.getChar` until the result is one of `keys`
 - `lgetchar.wrapper.expectSeq(keys: {{integer}}): integer`
 	- calls `raw.getChar` until the resulting sequence is one of `keys`
### `lgetchar`
 - `lgetchar.keys: {string:{integer}}`
 	- an alias for `wrapper.keys`
 - `lgetchar.getChar(): string`
 	- calls `raw.getChar` and returns the result as a character
 - `lgetchar.getCharSeq(len: integer): string`
 	- calls `raw.getCharSeq` and returns the result as a string
 - `lgetchar.expect(keys: {{integer}}): {integer}, {{integer}}`
 	- calls `wrapper.expectSeq` and returns which key was caught
	- also returns the array passed in for convenience

# Implementation Details
For Windows, this is basically a wrapper for `getch()` from conio.h.
For \*nix, this uses termios.h and sys/ioctl.h to change some terminal settings (mainly turning off echo) and calls `getchar()`.
I still have no idea how portable this is, but it has worked on a few of my machines decently enough.

