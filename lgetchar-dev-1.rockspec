package = "lgetchar"
version = "dev-1"
source = {
   url = "git://github.com/euclidianAce/lgetchar",
}
description = {
   summary = "A library for getting raw keyboard input in a terminal.",
   detailed = [[Some Lua bindings for getch() and getchar() for simple input in a terminal.]],
   homepage = "https://github.com/euclidianAce/lgetchar",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["lgetchar.raw"] = {
         sources = {
            "lgetchar/raw.c",
         },
      },
      ["lgetchar.wrapper"] = "lgetchar/wrapper.lua",
      ["lgetchar.init"] = "lgetchar/init.lua",
   },
   install = {
      lua = {
         ["lgetchar.init"] = "lgetchar/init.tl",
         ["lgetchar.wrapper"] = "lgetchar/wrapper.tl",
         ["lgetchar.raw"] = "lgetchar/raw.d.tl",
      },
   },
}
