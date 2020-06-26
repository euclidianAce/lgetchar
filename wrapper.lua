
local raw = require("lgetchar.raw")

local M = {
   keys = nil,
}

local function tobytes(keys)
   local bytes = {}
   for i, v in ipairs(keys) do
      if type(v) == "string" then
         v = string.byte(v)
      end
      bytes[v] = true
   end
   return bytes
end

function M.expect(keys)
   local set = tobytes(keys)
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
         if type(v) == "string" then
            v = string.byte(v)
         end
         if currentNode.value then
            return nil, "Sequence %d causes conflicts"
         end
         if currentNode.len > 0 and i == #seq then
            return nil, "Sequence %d terminates too early"
         end
         if not currentNode[v] then
            currentNode[v] = { len = 0 }
         end
         currentNode.value = nil
         currentNode.len = currentNode.len + 1
         currentNode = currentNode[v]
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
   repeat
      current = current[raw.getChar()]
      if not current then
         current = tree
      end
   until current.value
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
