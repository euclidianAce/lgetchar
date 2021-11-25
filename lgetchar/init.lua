local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = true, require('compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local string = _tl_compat and _tl_compat.string or string; local table = _tl_compat and _tl_compat.table or table; local raw = require("lgetchar.raw")
local wrapper = require("lgetchar.wrapper")

local lgetchar = {
   keys = wrapper.keys,
}

function lgetchar.getChar()
   local c, err = raw.getChar()
   if not c then return nil, err end
   return string.char(c)
end

function lgetchar.getCharSeq(n)
   local res = { raw.getCharSeq(n) }
   if not res[1] then
      return nil, res[2]
   end
   for i, v in ipairs(res) do
      res[i] = string.char(v)
   end
   return table.concat(res)
end

function lgetchar.expect(keys)
   local idx, err = wrapper.expectSeq(keys)
   if not idx then return nil, err end
   return keys[idx]
end

function lgetchar.createPoller(keys)
   local poller = wrapper.poll(keys)
   return function(block)
      repeat
         local ok, res = poller()
         if not ok then
            return nil, res
         end
         if res then
            return keys[res]
         elseif not block then
            return nil
         end
      until not block
   end
end

return lgetchar