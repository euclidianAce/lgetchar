
local raw = record
	getChar: function(): number
	getChar: function(boolean): number
	getCharSeq: function(number): number...
	getCharSeq: function(number, boolean): number...
	setup: function(): boolean
	nonBlockingSetup: function(): boolean
	restore: function(): boolean
	poll: function(): boolean, number
end

return raw
