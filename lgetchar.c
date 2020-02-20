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

int lua_getchar(lua_State *L) {
	setup();
	lua_pushinteger(L, getchar());
	restore();
	return 1;
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

int lua_get_char_or_esc(lua_State *L) {
	setup();
	int rnum = 1;
	int c = getchar();
	if(c == 27) {
		int argc = lua_gettop(L);
		int seq_len = 3;
		if(argc >= 1) {
			seq_len = luaL_checkinteger(L, 1);
		}
		lua_pushinteger(L, c);

		for(int i = 1; i < seq_len; i++) {
			lua_pushinteger(L, getchar());
		}
		rnum = seq_len;
	} else {
		lua_pushinteger(L, c);
	}
	restore();
	return rnum;
}

static const luaL_Reg funcs[] = {
	{"getchar", lua_getchar},
	{"getescseq", lua_get_esc_seq},
	{"getCharOrEscSeq", lua_get_char_or_esc},
	{NULL, NULL}
};

int luaopen_lgetchar(lua_State *L) {
	lua_newtable(L);
	luaL_setfuncs(L, funcs, 0);
	return 1;
}
