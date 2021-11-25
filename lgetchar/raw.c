#include <errno.h>
#include <stdio.h>
#include <string.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#ifdef _WIN32
#	include <io.h>
#	include <conio.h>
#	define setup() 1
#	define restore() 1
#	define non_blocking_setup() 1
#else
#	include <sys/ioctl.h>
#	include <termios.h>
#	include <unistd.h>
	static int setup();
	static int non_blocking_setup();
	static int restore();
#endif

static inline int get_char();
static inline int is_stdin_tty();

#ifdef _WIN32
	static inline int get_char() { return getch(); }
	static inline int is_stdin_tty() { return _isatty(STDIN_FILENO); }
#else
	static inline int get_char() { return getchar(); }
	static inline int is_stdin_tty() { return isatty(STDIN_FILENO); }
#endif

#define CHECK_TTY(lstate) do { \
		if (!is_stdin_tty()) { \
			lua_pushnil(lstate); \
			lua_pushstring(lstate, "stdin is not a tty"); \
			return 2; \
		} \
	} while (0)

#define FAIL_WITH_ERRNO_IF(L, expr) do { if (expr) { lua_pushnil(L); lua_pushstring(L, strerror(errno)); } } while (0)

// @teal-export getChar: function(boolean): integer, string [[
//    gets a character,
//    if the argument is falsy, `setup` will be called automatically,
//    otherwise you will need to call it yourself
//
//    on success returns the character,
//    on error returns nil + error message
// ]]
static int lua_get_char(lua_State *L) {
	CHECK_TTY(L);

	const int should_setup = lua_isnoneornil(L, 1);
	if (should_setup) {
		FAIL_WITH_ERRNO_IF(L, setup() < 0);
	}
	lua_pushnumber(L, get_char());
	if (should_setup) {
		FAIL_WITH_ERRNO_IF(L, restore() < 0);
	}
	return 1;
}

// @teal-export getCharSeq: function(n: integer, noSetup: boolean): integer, string|integer, integer... [[
//    get `n` characters from stdin and return them
//    on error returns nil + an error message
// ]]
static int lua_get_char_seq(lua_State *L) {
	CHECK_TTY(L);

	const int n = luaL_checknumber(L, 1);
	const int should_setup = lua_isnoneornil(L, 2);
	if (n < 1) return 0;
	if (should_setup) {
		FAIL_WITH_ERRNO_IF(L, setup() < 0);
	}
	for (int i = 0; i < n; i++) {
		lua_pushnumber(L, get_char());
	}
	if (should_setup) {
		FAIL_WITH_ERRNO_IF(L, restore() < 0);
	}
	return n;
}

// @teal-export poll: function(): boolean, integer|string [[
//    on error returns nil + an error message
//    otherwise polls stdin:
//       when a character is available:
//          returns true + the read character as an integer
//       otherwise:
//          returns true + nil
// ]]
static int lua_poll(lua_State *L) {
	CHECK_TTY(L);

	int c = 0;
	int got_char = read(STDIN_FILENO, &c, 1);
	FAIL_WITH_ERRNO_IF(L, got_char < 0);

	lua_pushboolean(L, got_char);
	if (got_char) {
		lua_pushnumber(L, c);
	} else {
		lua_pushnil(L);
	}
	return 2;
}

// @teal-export setup: function(): boolean, string [[
//    puts the terminal into raw mode and disables echo
//    reports whether the operation succeeded and the error message
// ]]
static int lua_setup(lua_State *L) {
	CHECK_TTY(L);

	FAIL_WITH_ERRNO_IF(L, setup() < 0);
	lua_pushboolean(L, 1);

	return 1;
}

// @teal-export nonBlockingSetup: function(): boolean, string [[
//    puts the terminal into raw mode, disables echo, and will not cause reads to block
//    reports whether the operation succeeded and the error message
// ]]
static int lua_non_blocking_setup(lua_State *L) {
	CHECK_TTY(L);

	FAIL_WITH_ERRNO_IF(L, non_blocking_setup() < 0);
	lua_pushboolean(L, 1);

	return 1;
}

// @teal-export restore: function(): boolean, string [[
//    undoes a setup operation
//    reports whether the operation succeeded and the error message
// ]]
static int lua_restore(lua_State *L) {
	CHECK_TTY(L);

	FAIL_WITH_ERRNO_IF(L, restore() < 0);
	lua_pushboolean(L, 1);

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
#include <signal.h>

static struct termio initial_state;
static int changed_state;
struct sigaction old_action = {0};

static void interrupt_handler(int sig) {
	restore();
	if (old_action.sa_handler)
		old_action.sa_handler(sig);
}

#define SETUP_SIGINT_HANDLER() do { \
		struct sigaction action = {0}; \
		action.sa_handler = interrupt_handler; \
		if (sigfillset(&action.sa_mask) != 0) \
			return -1; \
		if (sigaction(SIGINT, &action, &old_action) != 0) \
			return -1; \
	} while (0)

static inline void initialize_termio(struct termio *m, cc_t vmin) {
	*m = initial_state;
	m->c_lflag &= ~(ICANON|ECHO); // turn off cannonical mode and echo
	m->c_cc[VMIN] = vmin; // Minimum chars to input
	m->c_cc[VTIME] = 0; // Timeout 0 secs
}

static int setup() {
	if (ioctl(STDIN_FILENO, TCGETA, &initial_state) < 0)
		return 0;
	SETUP_SIGINT_HANDLER();
	changed_state = 1;
	struct termio m;
	initialize_termio(&m, 1);
	return ioctl(STDIN_FILENO, TCSETAW, &m);
}

static int non_blocking_setup() {
	if (ioctl(STDIN_FILENO, TCGETA, &initial_state) < 0)
		return 0;
	SETUP_SIGINT_HANDLER();
	changed_state = 1;
	struct termio m;
	initialize_termio(&m, 0);
	return ioctl(STDIN_FILENO, TCSETAW, &m);
}

static int restore() {
	if (!changed_state)
		return 0;
	changed_state = 0;

	if (sigaction(SIGINT, &old_action, NULL) != 0)
		return -1;

	return ioctl(STDIN_FILENO, TCSETAW, &initial_state);
}

#endif
