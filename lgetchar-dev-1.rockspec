package = "lgetchar"
version = "dev-1"
source = {
   url = "git://github.com/3uclidian/lgetchar",
}
description = {
   summary = "A library for getting raw keyboard input in a terminal.",
   detailed = [[Some Lua bindings for getch() and getchar() for simple input in a terminal.]],
   homepage = "https://github.com/3uclidian/lgetchar",
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
            "raw.c",  
         }
      },
      ["lgetchar.wrapper"] = "wrapper.lua",
      ["lgetchar.init"] = "init.lua",
   }
}
