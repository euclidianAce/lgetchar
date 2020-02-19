#include <termio.h>
#include <stdio.h>
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
	m.c_lflag &= ~(ICANON|ECHO);
	m.c_cc[VMIN] = 1;
	m.c_cc[VTIME] = 0;
	return ioctl(stdinfileno, TCSETAW, &m);
}
int restore() {
	if(!changed_state) {
		return 0;
	}
	return ioctl(fileno(stdin), TCSETAW, &initial_state);
}

int lua_getchar(lua_State *L) {
	setup();
	int returnVals = 1;
	int n = getchar();
	lua_pushinteger(L, n);
	if(n == 27) {
		returnVals = 3;
		lua_pushinteger(L, getchar());
		lua_pushinteger(L, getchar());
	}
	restore();
	return returnVals;
}

static const luaL_Reg funcs[] = {
	{"getchar", lua_getchar},
	{NULL, NULL}
};

int luaopen_lgetchar(lua_State *L) {
	lua_newtable(L);
	luaL_setfuncs(L, funcs, 0);
	return 1;
}