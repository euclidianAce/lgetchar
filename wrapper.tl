
local raw = require("lgetchar.raw")

local M = {
	keys: {string:{number}} = nil
}

local function toset(keys: {number}): {number:boolean}
	local set: {number:boolean} = {}
	for i, v in ipairs(keys) do
		set[v] = true
	end
	return set
end

function M.expect(keys: {number}): number
	local set: {number:boolean} = toset(keys)
	local key: number
	repeat
		key = raw.getChar()
	until set[key]
	return key
end

local Node = record
	{Node} -- technically a map of {number:Node}
	len: number
	value: number -- if this is non-nil, this node is a leaf
end
local function insertseq(tree: Node, seq: {number}, val: number): boolean, string
	local currentNode = tree
	for i, v in ipairs(seq) do
		if currentNode.value then
			return nil, "Sequence %d causes conflicts"
		end
		if not currentNode[v] then
			currentNode[v] = {len = 0}
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
local function buildTree(keys: {{number}}): Node
	local tree: Node = {len = 0}
	for i, sequence in ipairs(keys) do
		assert(#sequence > 0, "Sequence " .. i .. " is empty")
		local ok, err = insertseq(tree, sequence, i)
		if not ok then
			error(err:format(i), 3)
		end
	end
	return tree
end

local function pollFrom(keys: {{number}}): boolean, number
	local tree = buildTree(keys)

	local current = tree
	raw.nonBlockingSetup()
	repeat
		local gotChar, char = false, 0
		while not gotChar do
			gotChar, char = raw.poll()
			if not gotChar then
				coroutine.yield(false)
			end
		end
		current = current[char]
		if not current then
			current = tree
		end
	until current.value
	raw.restore()
	return true, current.value
end
function M.poll(keys: {{number}}): function(): boolean, number
	local co = coroutine.create(pollFrom)
	return function(): boolean, number
		local ok, res1, res2 = coroutine.resume(co, keys)
		if not ok then
			error(res1 as string)
		end
		return res1 as boolean, res2 as number
	end
end

function M.expectSeq(initSeq: {{number}}): number
	local tree = buildTree(initSeq)
	-- use getchar to traverse the tree, resetting when a node isn't found
	local current = tree
	raw.setup()
	repeat
		local ok, res = pcall(raw.getChar, true)
		if not ok then
			raw.restore()
			error(res as string, 2)
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
