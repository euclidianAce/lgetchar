/* lgetchar: Some Lua bindings to read character input from a terminal
 *
 * Copyright (C) 2020 Corey Williamson
 *
 * This file is part of lgetchar.
 *
 * lgetchar is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * lgetchar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with lgetchar. If not, see http://www.gnu.org/licenses/.
*/

#include <sys/ioctl.h>
#include <termios.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static struct termio initial_state;
static int changed_state;

int setup() {
	struct termio m;
	int stdinfileno = fileno(stdin);
	if(ioctl(stdinfileno, TCGETA, &initial_state) < 0) {
		return 0;
	}
	changed_state = 1;
	m = initial_state;
	m.c_lflag &= ~(ICANON|ECHO); // turn off cannonical mode and echo
	m.c_cc[VMIN] = 1; // Minimum chars to input
	m.c_cc[VTIME] = 0; // Timeout 0 secs
	return ioctl(stdinfileno, TCSETAW, &m);
}
int restore() {
	if(!changed_state) {
		return 0;
	}
	changed_state = 0;
	return ioctl(fileno(stdin), TCSETAW, &initial_state);
}

int lua_get_char(lua_State *L) {
	setup();
	lua_pushinteger(L, getchar());
	restore();
	return 1;
}

int lua_get_char_seq(lua_State *L) {
	int n = luaL_checkinteger(L, 1);
	if(n < 1) return 0;
	for(int i = 0; i < n; i++)
		lua_pushinteger(L, getchar());
	restore();
	return n;
}

int lua_get_esc_seq(lua_State *L) {
	setup();
	int rnum = 1;
	int n = luaL_checkinteger(L, 1);
	int c = getchar();
	if(c == 27) {
		for(int i = 0; i < n-1; i++)
			lua_pushinteger(L, getchar());
		rnum = n-1;
	}
	restore();
	return rnum;
}

static const luaL_Reg funcs[] = {
	{"getChar", lua_get_char},
	{"getCharSeq", lua_get_char_seq},
	{"getEscSeq", lua_get_esc_seq},
	{NULL, NULL}
};

int luaopen_lgetchar(lua_State *L) {
	lua_newtable(L);
	luaL_setfuncs(L, funcs, 0);
	return 1;
}
