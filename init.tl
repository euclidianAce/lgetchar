
local raw = require("lgetchar.raw")
local wrapper = require("lgetchar.wrapper")

local lgetchar = {
	keys = wrapper.keys,
}

function lgetchar.getChar(): string
	return string.char(raw.getChar())
end

function lgetchar.getCharSeq(n: number): string
	return string.char(raw.getCharSeq(n))
end

function lgetchar.expect(keys: {{number}}): {number}, {{number}}
	local result = wrapper.expectSeq(keys)
	return keys[result], keys
end

function lgetchar.createPoller(keys: {{number}}): function(boolean): {number}
	local poller = wrapper.poll(keys)
	return function(block: boolean): {number}
		repeat
			local ok, gotChar, idx: boolean, boolean|string, number = pcall(poller)
			if not ok and gotChar == "interrupted!" then
				raw.restore() -- guarantee when intrrupted to restore the terminal
				io.stderr:write(gotChar as string, "\n")
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
