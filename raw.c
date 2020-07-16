#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <unistd.h>

#ifdef DEBUG
#	include <stdio.h>
#	define log(...) printf(__VA_ARGS__)
#else
#	define log(...)
#endif
#if defined(_WIN32)
#	include <conio.h>
#	define setup()
#	define restore()
#	define non_blocking_setup()
#else
#	include <termios.h>
#	include <sys/ioctl.h>
	int setup();
	int non_blocking_setup();
	int restore();
#endif

int get_char() {
#ifdef _WIN32
	return getch();
#else
	return getchar();
#endif
}

int lua_get_char(lua_State *L) {
	const int should_setup = lua_isnoneornil(L, 1);
	if (should_setup) {
		log("Setting up\n");
		setup();
	}
	lua_pushnumber(L, get_char());
	if (should_setup) {
		log("Restoring\n");
		restore();
	}
	return 1;
}

int lua_get_char_seq(lua_State *L) {
	const int n = luaL_checknumber(L, 1);
	const int should_setup = lua_isnoneornil(L, 2);
	if (n < 1) return 0;
	if (should_setup) {
		setup();
	}
	for (int i = 0; i < n; i++) {
		lua_pushnumber(L, get_char());
	}
	if (should_setup) {
		restore();
	}
	return n;
}

int lua_poll(lua_State *L) {
	int c = 0;
	int got_char = read(fileno(stdin), &c, 1);
	log("poll called, got_char: %d\n", got_char);
	lua_pushboolean(L, got_char);
	if (got_char) {
		lua_pushnumber(L, c);
		return 2;
	}
	return 1;
}

int lua_setup(lua_State *L) {
	lua_pushboolean(L, setup());
	return 1;
}

int lua_non_blocking_setup(lua_State *L) {
	lua_pushboolean(L, non_blocking_setup());
	return 1;
}

int lua_restore(lua_State *L) {
	lua_pushboolean(L, restore());
	return 1;
}

static const luaL_Reg funcs[] = {
	{"getChar", lua_get_char},
	{"getCharSeq", lua_get_char_seq},
	{"setup", lua_setup},
	{"nonBlockingSetup", lua_non_blocking_setup},
	{"restore", lua_restore},
	{"poll", lua_poll},
	{NULL, NULL}
};

LUA_API int luaopen_lgetchar_raw(lua_State *L) {
	luaL_newlib(L, funcs);
	return 1;
}

#ifndef _WIN32
static struct termio initial_state;
static int changed_state;

int setup() {
	struct termio m;
	const int stdinfileno = fileno(stdin);
	if (ioctl(stdinfileno, TCGETA, &initial_state) < 0) {
		log("Not setting up, state already changed.\n");
		return 0;
	}
	changed_state = 1;
	m = initial_state;
	m.c_lflag &= ~(ICANON|ECHO); // turn off cannonical mode and echo
	m.c_cc[VMIN] = 1; // Minimum chars to input
	m.c_cc[VTIME] = 0; // Timeout 0 secs
	return ioctl(stdinfileno, TCSETAW, &m);
}
int non_blocking_setup() {
	struct termio m;
	const int stdinfileno = fileno(stdin);
	if (ioctl(stdinfileno, TCGETA, &initial_state) < 0) {
		log("Not setting up, state already changed.\n");
		return 0;
	}
	changed_state = 1;
	m = initial_state;
	m.c_lflag &= ~(ICANON|ECHO); // turn off cannonical mode and echo
	m.c_cc[VMIN] = 0; // Minimum chars to input
	m.c_cc[VTIME] = 0; // Timeout 0 secs
	return ioctl(stdinfileno, TCSETAW, &m);
}
int restore() {
	log("changed_state: %d\n", changed_state);
	if (!changed_state) {
		log("Not actually restoring, state not changed.\n");
		return 0;
	}
	changed_state = 0;
	return ioctl(fileno(stdin), TCSETAW, &initial_state);
}
#endif 
