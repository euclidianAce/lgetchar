local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = true, require('compat53.module'); if p then _tl_compat = m end end; local assert = _tl_compat and _tl_compat.assert or assert; local coroutine = _tl_compat and _tl_compat.coroutine or coroutine; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local string = _tl_compat and _tl_compat.string or string; local raw = require("lgetchar.raw")

local wrapper = {
   keys = nil,
}

local function toset(keys)
   local set = {}
   for _, v in ipairs(keys) do
      set[v] = true
   end
   return set
end

function wrapper.expect(keys)
   local set = toset(keys)
   local key, err
   repeat
      key, err = raw.getChar()
      if not key then
         return nil, err
      end
   until set[key]
   return key
end

local Node = {}




local function insertseq(tree, seq, val)
   local currentNode = tree
   for i, v in ipairs(seq) do
      if currentNode.value then
         return nil, "Sequence %d causes conflicts"
      end
      if not currentNode[v] then
         currentNode[v] = { len = 0 }
      end
      currentNode.value = nil
      currentNode.len = currentNode.len + 1
      currentNode = currentNode[v]
      if currentNode.len > 0 and i == #seq then
         return nil, "Sequence %d terminates too early"
      end
   end
   currentNode.value = val
   return true
end
local function buildTree(keys)
   local tree = { len = 0 }
   for i, sequence in ipairs(keys) do
      assert(#sequence > 0, "Sequence " .. i .. " is empty")
      local ok, err = insertseq(tree, sequence, i)
      if not ok then
         error(err:format(i), 3)
      end
   end
   return tree
end

local function pollFrom(keys)
   local tree = buildTree(keys)

   local current = tree
   local ok, err = raw.nonBlockingSetup()
   if not ok then return nil, err end
   repeat
      local res
      while not res do
         ok, res = raw.poll()
         if not ok then
            return nil, res
         end
         if not res then
            coroutine.yield(false)
         end
      end
      current = current[res]
      if not current then
         current = tree
      end
   until current.value
   ok, err = raw.restore()
   if not ok then return nil, err end
   return true, current.value
end





function wrapper.poll(keys)
   local co = coroutine.create(pollFrom)
   return function()
      return select(2, assert(coroutine.resume(co, keys)))

   end
end



function wrapper.expectSeq(initSeq)
   local tree = buildTree(initSeq)

   local current = tree
   local ok, c, err
   ok, err = raw.setup()
   if not ok then return nil, err end
   repeat
      c, err = raw.getChar(true)
      if not c then
         return nil, err
      end
      current = current[c]
      if not current then
         current = tree
      end
   until current.value
   ok, err = raw.restore()
   if not ok then return nil, err end
   return current.value
end

wrapper.keys = {
   up = { 27, 91, 65 },
   down = { 27, 91, 66 },
   right = { 27, 91, 67 },
   left = { 27, 91, 68 },
   enter = { 10 },

}

for i = 33, 128 do
   wrapper.keys[string.char(i)] = { i }
end

return wrapper