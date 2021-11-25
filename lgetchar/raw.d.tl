local record raw
	getChar: function(noSetup: boolean): integer, string
	getCharSeq: function(n: integer, noSetup: boolean): integer, string|integer, integer...
	nonBlockingSetup: function(): boolean, string
	poll: function(): boolean, integer|string
	restore: function(): boolean, string
	setup: function(): boolean, string
end

return raw
