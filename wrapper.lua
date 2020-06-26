
local raw = require("lgetchar.raw")

local M = {
   keys = nil,
}

local function toset(keys)
   local set = {}
   for i, v in ipairs(keys) do
      set[v] = true
   end
   return set
end

function M.expect(keys)
   local set = toset(keys)
   local key
   repeat
      key = raw.getChar()
   until set[key]
   return key
end

function M.expectSeq(initSeq)
   local Node = {}




   local tree = { len = 0 }
   local function insertseq(seq, val)
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

   for i, sequence in ipairs(initSeq) do
      assert(#sequence > 0, "Sequence " .. i .. " is empty")
      local ok, err = insertseq(sequence, i)
      if not ok then
         error(err:format(i), 3)
      end
   end


   local current = tree
   raw.setup()
   repeat
      local ok, res = pcall(raw.getChar, true)
      if not ok then
         raw.restore()
         error(res, 2)
      end
      current = current[res]
      if not current then
         current = tree
      end
   until current.value
   raw.restore()
   return current.value
end

M.keys = {
   up = { 27, 91, 65 },
   down = { 27, 91, 66 },
   right = { 27, 91, 67 },
   left = { 27, 91, 68 },

}

for i = 33, 128 do
   M.keys[string.char(i)] = { i }
end

return M
