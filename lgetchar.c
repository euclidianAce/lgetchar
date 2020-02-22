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
