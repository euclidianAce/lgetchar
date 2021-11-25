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
 - `raw.setup(): boolean, string`  `raw.nonBlockingSetup(): boolean, string`
   - Turn off canonical mode and echo. Returns whether the operation succeeded and an error message if any.
   - These functions will probably only error when stdin is not a tty or an `ioctl` call fails
 - `raw.restore(): boolean, string`
   - Re-enable canonical mode and echo. Returns whether the operation succeded and an error message if any.
 - `raw.getChar(noSetup: boolean): integer, string`
   - `read`s from stdin, returns the character read as an integer or nil and an error message. This function automatically calls `setup()` and `restore()`, pass `true` to do these manually.
 - `raw.getCharSeq(len: integer, noSetup: boolean): integer... | (nil, string)`
   - reads for `len` characters and returns them as integers, or nil and an error message. `noSetup` is the same as `getChar`

### `wrapper`
 - `wrapper.keys: {string:{integer}}`
   - A map of keys to use in `expect` functions: For example, `keys.up` is the up arrow escape sequence, `{27, 91, 65}`
 - `wrapper.expect(keys: {integer}): integer, string`
   - calls `raw.getChar` until the result is one of `keys`, forwards any errors
 - `wrapper.expectSeq(keys: {{integer}}): integer, string`
   - calls `raw.getChar` until the resulting sequence is one of `keys`, forwards any errors

### `lgetchar`
 - `lgetchar.keys: {string:{integer}}`
   - an alias for `wrapper.keys`
 - `lgetchar.getChar(): string, string`
   - calls `raw.getChar` and returns the result as a character, or nil and an error message
 - `lgetchar.getCharSeq(len: integer): string, string`
   - calls `raw.getCharSeq` and returns the result as a string, or nil and an error message
 - `lgetchar.expect(keys: {{integer}}): {integer}, string`
   - calls `wrapper.expectSeq` and returns which key was caught, or nil and an error message

# Implementation Details
For Windows, this is basically a wrapper for `getch()` from conio.h.
For \*nix, this uses termios.h and sys/ioctl.h to change some terminal settings (mainly turning off echo) and calls `getchar()`.
I still have no idea how portable this is, but it has worked on a few of my machines decently enough.

