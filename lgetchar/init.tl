local raw <const> = require("lgetchar.raw")
local wrapper <const> = require("lgetchar.wrapper")

local lgetchar <const> = {
	keys = wrapper.keys,
}

function lgetchar.getChar(): string, string
	local c <const>, err <const> = raw.getChar()
	if not c then return nil, err end
	return string.char(c)
end

function lgetchar.getCharSeq(n: integer): string, string
	local res <const> = { raw.getCharSeq(n) }
	if not res[1] then
		return nil, res[2] as string
	end
	for i, v in ipairs(res) do
		res[i] = string.char(v as integer)
	end
	return table.concat(res as {string})
end

function lgetchar.expect(keys: {{integer}}): {integer}, string
	local idx <const>, err <const> = wrapper.expectSeq(keys)
	if not idx then return nil, err end
	return keys[idx]
end

function lgetchar.createPoller(keys: {{integer}}): function(boolean): {integer}, string
	local poller = wrapper.poll(keys)
	return function(block: boolean): {integer}, string
		repeat
			local ok <const>, res <const> = poller()
			if not ok then
				return nil, res as string
			end
			if res then
				return keys[res as integer]
			elseif not block then
				return nil
			end
		until not block
	end
end

return lgetchar
