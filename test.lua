#!/usr/bin/env lua

local getchar = require "lgetchar"

while true do
	local char = getchar.getchar()
	print("Character gotten: " .. char)
end