
local raw = require("lgetchar.raw")
local wrapper = require("lgetchar.wrapper")

local lgetchar = {
   keys = wrapper.keys,
}

function lgetchar.getChar()
   return string.char(raw.getChar())
end

function lgetchar.getCharSeq(n)
   return string.char(raw.getCharSeq(n))
end

function lgetchar.expect(keys)
   local result = wrapper.expectSeq(keys)
   return keys[result], keys
end

return lgetchar
