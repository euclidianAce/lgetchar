local raw = require("lgetchar.raw")

local wrapper = {
	keys: {string:{integer}} = nil
}

local function toset(keys: {integer}): {integer:boolean}
	local set: {integer:boolean} = {}
	for _, v in ipairs(keys) do
		set[v] = true
	end
	return set
end

function wrapper.expect(keys: {integer}): integer, string
	local set: {integer:boolean} = toset(keys)
	local key, err: integer, string
	repeat
		key, err = raw.getChar()
		if not key then
			return nil, err
		end
	until set[key]
	return key
end

local record Node
	{Node} -- technically a map of {integer:Node}
	len: integer
	value: integer -- if this is non-nil, this node is a leaf
end
local function insertseq(tree: Node, seq: {integer}, val: integer): boolean, string
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
local function buildTree(keys: {{integer}}): Node
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

local function pollFrom(keys: {{integer}}): boolean, integer|string
	local tree = buildTree(keys)

	local current = tree
	local ok, err: boolean, string = raw.nonBlockingSetup()
	if not ok then return nil, err end
	repeat
		local res: integer|string
		while not res do
			ok, res = raw.poll()
			if not ok then
				return nil, res as string
			end
			if not res then
				coroutine.yield(false)
			end
		end
		current = current[res as integer]
		if not current then
			current = tree
		end
	until current.value
	ok, err = raw.restore()
	if not ok then return nil, err end
	return true, current.value
end

-- returns a function that when called, will check if stdin has any data
-- in the event of an error, return nil+error message,
-- otherwise returns true and nil when stdin has nothing, and the index of the
-- key otherwise
function wrapper.poll(keys: {{integer}}): function(): boolean, integer|string
	local co <const> = coroutine.create(pollFrom)
	return function(): boolean, integer|string
		return select(2, assert(coroutine.resume(co, keys)))
			as (boolean, integer|string)
	end
end

-- keep calling get char until one of the sequences matches
-- returns the index of the sequence in the list or nil+error message on error
function wrapper.expectSeq(initSeq: {{integer}}): integer, string
	local tree = buildTree(initSeq)
	-- use getchar to traverse the tree, resetting when a node isn't found
	local current = tree
	local ok, c, err: boolean, integer, string
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
	up = {27, 91, 65},
	down = {27, 91, 66},
	right = {27, 91, 67},
	left = {27, 91, 68},
	enter = { 10 },
	-- crtl = {a = {27, 92}}, etc.
}

for i = 33, 128 do
	wrapper.keys[string.char(i)] = {i}
end

return wrapper
