default:
	cyan build
	luarocks --local make
clean:
	rm -f *.o *.so *.dll
	rm -f $(wildcard lgetchar/*.lua)

.PHONY: clean
