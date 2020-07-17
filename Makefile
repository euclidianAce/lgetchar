default:
	tl build
	luarocks make
clean:
	rm -f *.o *.so *.dll
	rm -f $(filter-out tlconfig.lua, $(wildcard *.lua))
	rm -fr lgetchar

.PHONY: clean
