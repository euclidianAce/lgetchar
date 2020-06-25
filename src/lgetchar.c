#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#if defined(WIN32) || defined(_WIN32)
#	define WINDOWS
#	include <conio.h>
#	define setup()
#	define restore()
#else
#	include <termios.h>
#	include <sys/ioctl.h>
	int setup();
	int restore();
#endif

int get_char() {
#ifdef WINDOWS
	return getch();
#else
	return getchar();
#endif
}

int lua_get_char(lua_State *L) {
	setup();
	lua_pushnumber(L, get_char());
	restore();
	return 1;
}

int lua_get_char_seq(lua_State *L) {
	int n = (int) luaL_checknumber(L, 1);
	if(n < 1) return 0;
	setup();
	for(int i = 0; i < n; i++)
		lua_pushnumber(L, get_char());
	restore();
	return n;
}

static const luaL_Reg funcs[] = {
	{"getChar", lua_get_char},
	{"getCharSeq", lua_get_char_seq},
	{NULL, NULL}
};

int luaopen_lgetchar(lua_State *L) {
	luaL_newlib(L, funcs);
	return 1;
}

#ifndef WINDOWS
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
#endif 
