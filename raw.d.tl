
local raw = record
	getChar: function(): number
	getChar: function(boolean): number
	getCharSeq: function(number): number...
	getCharSeq: function(number, boolean): number...
	setup: function()
	restore: function()
end

return raw
