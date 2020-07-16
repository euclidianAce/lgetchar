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

function lgetchar.createPoller(keys)
   local poller = wrapper.poll(keys)
   return function(block)
      repeat
         local ok, gotChar, idx = pcall(poller)
         if not ok and gotChar == "interrupted!" then
            raw.restore()
            io.stderr:write(gotChar, "\n")
            os.exit(1)
         end
         if gotChar then
            return keys[idx]
         else
            if not block then
               return nil
            end
         end
      until not block
   end
end

return lgetchar
