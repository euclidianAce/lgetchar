
local raw = require("lgetchar.raw")
local wrapper = require("lgetchar.wrapper")

local lgetchar = {
	keys = wrapper.keys,
}

function lgetchar.getChar(): string
	return string.char(raw.getChar())
end

function lgetchar.getCharSeq(n: number): string
	return string.char(raw.getCharSeq(n))
end

function lgetchar.expect(keys: {{number}}): number
	
	return 0
end

return lgetchar
