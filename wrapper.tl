
local raw = require("lgetchar.raw")

local M = {
	keys: {string:{number}} = nil
}

-- local function toset<T>(t: {T}): {T:boolean}
-- 	local set: {T:boolean} = {}
-- 	for i, v in ipairs(t) do
-- 		set[v] = true
-- 	end
-- 	return set
-- end

local function tobytes(keys: {number|string}): {number:boolean}
	local bytes: {number:boolean} = {}
	for i, v in ipairs(keys) do
		if v is string then
			v = string.byte(v)
		end
		bytes[v as number] = true
	end
	return bytes
end

function M.expect(keys: {number|string}): number
	local set: {number:boolean} = tobytes(keys)
	local key: number
	repeat
		key = raw.getChar()
	until set[key]
	return key
end

function M.expectSeq(initSeq: {{number|string}}): number
	local Node = record
		{Node}
		value: number
	end
	local tree: Node = {}
	local function insertseq(seq: {number|string}, val: number): boolean, string
		local currentNode = tree
		for i, v in ipairs(seq) do
			assert(#seq > 0, "Sequence " .. i .. " is empty")
			if v is string then
				v = string.byte(v)
			end
			if not currentNode[v as number] then
				currentNode[v as number] = {}
			elseif currentNode.value then
				return nil, "Conflict between sequence " .. i .. " and " .. currentNode.value
			end
			currentNode = currentNode[v as number]
		end
		currentNode.value = val
		return true
	end
	-- construct a tree of the sequences
	for i, sequence in ipairs(initSeq) do
		assert(insertseq(sequence, i))
	end

	-- use getchar to traverse the tree, resetting when a node isn't found
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
	up = {27, 91, 65}
	down = {27, 91, 66}
	left = {27, 91, 67}
	right = {27, 91, 68}
}

for i = 33, 128 do
	M.keys[string.char(i)] = {i}
end

return M
