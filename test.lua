#!/usr/bin/env lua

local lgetchar = require "lgetchar"

while true do
	local char = lgetchar.getChar()
	print("Character gotten: " .. char)
end

