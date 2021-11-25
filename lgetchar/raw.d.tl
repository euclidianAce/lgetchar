local record raw
	getChar: function(boolean): integer
	getCharSeq: function(integer, boolean): integer...
	setup: function(): boolean
	nonBlockingSetup: function(): boolean
	restore: function(): boolean
	poll: function(): boolean, integer
end

return raw
