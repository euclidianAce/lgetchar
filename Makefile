CC = gcc
CFLAGS = -Wall -Wextra
LIBS = -llua

SRC = $(wildcard *.c)

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	TARGET = raw.so
else
	TARGET = raw.dll
endif

default: teal $(TARGET)

teal:
	tl check
	tl gen

$(TARGET):
	$(CC) $(CFLAGS) -fPIC $(SRC) -shared -o $(TARGET)

clean:
	rm -f *.o *.so *.dll
	rm -f $(filter-out tlconfig.lua, $(wildcard *.lua))
	rm -fr lgetchar

all: clean $(TARGET) teal

.PHONY: all clean
