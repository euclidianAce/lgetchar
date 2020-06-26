
local raw = require("lgetchar.raw")

local M = {
	keys: {string:{number}} = nil
}

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
		{Node} -- technically an map of {number:Node}
		len: number
		value: number
	end
	local tree: Node = {len = 0}
	local function insertseq(seq: {number|string}, val: number): boolean, string
		local currentNode = tree
		for i, v in ipairs(seq) do
			if v is string then
				v = string.byte(v)
			end
			if currentNode.value then
				return nil, "Sequence %d causes conflicts"
			end
			if currentNode.len > 0 and i == #seq then
				return nil, "Sequence %d terminates too early"
			end
			if not currentNode[v as number] then
				currentNode[v as number] = {len = 0}
			end
			currentNode.value = nil
			currentNode.len = currentNode.len + 1
			currentNode = currentNode[v as number]
		end
		currentNode.value = val
		return true
	end
	-- construct a tree of the sequences
	for i, sequence in ipairs(initSeq) do
		assert(#sequence > 0, "Sequence " .. i .. " is empty")
		local ok, err = insertseq(sequence, i)
		if not ok then
			error(err:format(i), 3)
		end
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
	right = {27, 91, 67}
	left = {27, 91, 68}
	-- crtl = {a = {27, 92}}, etc.
}

for i = 33, 128 do
	M.keys[string.char(i)] = {i}
end

return M
